# Install/configure PowerShell 7 for Cursor/Codex/Claude Code agents (MSI, not Store alias).
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$pwshMsi = Join-Path $env:TEMP 'PowerShell-7.6.3-win-x64.msi'
$pwshExe = 'C:\Program Files\PowerShell\7\pwsh.exe'
$scripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'

function Write-Info([string]$m) { if (-not $Quiet) { Write-Host $m } }

if (-not (Test-Path -LiteralPath $pwshExe)) {
    Write-Info 'Downloading PowerShell 7.6.3 MSI...'
    Invoke-WebRequest -Uri 'https://github.com/PowerShell/PowerShell/releases/download/v7.6.3/PowerShell-7.6.3-win-x64.msi' -OutFile $pwshMsi -UseBasicParsing
    Write-Info 'Installing MSI (UAC)...'
    Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$pwshMsi`" /quiet /norestart USE_MU=1 ADD_PATH=1" -Verb RunAs -Wait
}
if (-not (Test-Path -LiteralPath $pwshExe)) {
    throw "PS7 not found at $pwshExe after install"
}
Write-Info "OK: $pwshExe"

# User PATH: MSI path before WindowsApps alias
$pwshDir = Split-Path -Parent $pwshExe
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$pwshDir*") {
    [Environment]::SetEnvironmentVariable('Path', "$pwshDir;$userPath", 'User')
    Write-Info 'Prepended PS7 to User PATH'
}

# PS7 profile
$profileDir = Join-Path $env:USERPROFILE 'Documents\PowerShell'
$profilePath = Join-Path $profileDir 'Microsoft.PowerShell_profile.ps1'
if (-not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
$profileBody = @"
# Interactive PowerShell 7 UTF-8 bootstrap.
`$utf8Script = Join-Path `$env:USERPROFILE '.ai-workspace\scripts\ensure-utf8-console.ps1'
if (Test-Path -LiteralPath `$utf8Script) {
    . `$utf8Script
}

"@
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($profilePath, $profileBody, $utf8)
Write-Info "Profile: $profilePath"

# Cursor settings
$cursorSettings = Join-Path $env:APPDATA 'Cursor\User\settings.json'
if (Test-Path -LiteralPath $cursorSettings) {
    $c = Get-Content -LiteralPath $cursorSettings -Raw -Encoding UTF8 | ConvertFrom-Json
    $c.'terminal.integrated.defaultProfile.windows' = 'PowerShell 7'
    $c.'terminal.integrated.automationProfile.windows' = [pscustomobject]@{
        path = $pwshExe
        args = @('-NoLogo')
    }
    $profiles = @{
        'PowerShell 7'       = [pscustomobject]@{ path = $pwshExe; icon = 'terminal-powershell'; args = @('-NoLogo') }
        'Windows PowerShell' = [pscustomobject]@{ path = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'; icon = 'terminal-powershell' }
    }
    $c | Add-Member -NotePropertyName 'terminal.integrated.profiles.windows' -NotePropertyValue $profiles -Force
    [System.IO.File]::WriteAllText($cursorSettings, ($c | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding $false))
    Write-Info "Updated: $cursorSettings"
}

# Hooks: use pwsh for Codex/Cursor hook scripts
$pwshCmd = "`"$pwshExe`" -NoProfile -ExecutionPolicy Bypass"
$cursorHooks = Join-Path $env:USERPROFILE '.cursor\hooks.json'
if (Test-Path -LiteralPath $cursorHooks) {
    $h = Get-Content -LiteralPath $cursorHooks -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($hook in $h.hooks.preToolUse) {
        if ($hook.command -match 'powershell\.exe|(?<!\\)powershell ') {
            $hook.command = $hook.command -replace '(?i)powershell(\.exe)?', ($pwshExe -replace '\\', '\\')
        }
        if ($hook.command -match 'rtk-hook-cursor') {
            # keep as-is (launched via pwsh in repair if needed)
        }
    }
    [System.IO.File]::WriteAllText($cursorHooks, ($h | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding $false))
    Write-Info 'Updated Cursor hooks to pwsh where applicable'
}

$codexHooks = Join-Path $env:USERPROFILE '.codex\hooks.json'
if (Test-Path -LiteralPath $codexHooks) {
    $gate = Join-Path $scripts 'clarification-hard-gate.ps1'
    $body = @{
        hooks = @{
            PreToolUse = @{
                matcher = 'Write|Edit|MultiEdit|StrReplace|apply_patch'
                hooks   = @(
                    @{ type = 'command'; command = "$pwshCmd -File `"$gate`" -OutputFormat Codex"; timeout = 5; statusMessage = 'Gate' }
                )
            }
        }
    }
    [System.IO.File]::WriteAllText($codexHooks, ($body | ConvertTo-Json -Depth 10), (New-Object System.Text.UTF8Encoding $false))
    Write-Info 'Updated Codex hooks to pwsh'
}

$ver = & $pwshExe -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
Write-Info "PASS: PowerShell $ver"
Write-Info 'Restart Cursor/Codex/Claude Code completely.'
