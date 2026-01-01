# --- THE SOURCE CODE ---
$originalScript = {
    Write-Host "--- SYSTEM DIAGNOSTIC START ---" -ForegroundColor Cyan
    Write-Host "Current User: $env:USERNAME"
    Write-Host "--- END ---"
}

# --- THE ENCODER ---
$bytes = [System.Text.Encoding]::Unicode.GetBytes($originalScript.ToString())
$encodedString = [Convert]::ToBase64String($bytes)

Write-Host "Encoded String: $encodedString" -ForegroundColor Yellow

# --- THE DECODER (Logic to include in your 'Loader') ---
$executionBlock = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($encodedString))

# Run it
Write-Host "Executing Decoded Code..." -ForegroundColor Green
Invoke-Expression $executionBlock