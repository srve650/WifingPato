function Send-EmailWithoutOutlook {
    param (
        [string]$SMTPServer,
        [int]$SMTPPort,
        [string]$From,
        [string]$Password,
        [string]$To,
        [string]$Subject,
        [string]$Body,
        [string[]]$AttachmentPaths
    )

    # Convert password to a secure string
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($From, $SecurePassword)

    # Create the email message
    $MailMessage = New-Object system.net.mail.mailmessage
    $MailMessage.From = $From
    $MailMessage.To.Add($To)
    $MailMessage.Subject = $Subject
    $MailMessage.Body = $Body
    $MailMessage.IsBodyHtml = $false

    # Attach each file if it exists
    foreach ($AttachmentPath in $AttachmentPaths) {
        if (Test-Path -Path $AttachmentPath) {
            $Attachment = New-Object System.Net.Mail.Attachment($AttachmentPath)
            $MailMessage.Attachments.Add($Attachment)
        } else {
            Write-Output "Attachment file '$AttachmentPath' not found."
        }
    }

    # Set up SMTP client
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = $Credential

    # Send the email
    try {
        $SMTPClient.Send($MailMessage)
        Write-Output "Email sent successfully!"
    } catch {
        Write-Output "Failed to send email. Error: $_"
    }

    # Dispose of attachments to release file locks
    foreach ($Attachment in $MailMessage.Attachments) {
        $Attachment.Dispose()
    }
}
