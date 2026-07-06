# Apply Codex windows.shell_path + block broken WindowsApps pwsh alias.
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$pwshExe = 'C:\Program Files\PowerShell\7\pwsh.exe'
$codexConfig = Join-Path $env:USERPROFILE '.codex\config.toml'

function Write-Info([string]$m) { if (-not $Quiet) { Write-Host $m } }

if (-not (Test-Path -LiteralPath $pwshExe)) {
    Write-Info 'PS7 missing — run upgrade-powershell7-global.ps1 first'
    & (Join-Path $PSScriptRoot 'upgrade-powershell7-global.ps1')
}

# PATH: real pwsh before WindowsApps 0-byte alias (Codex issue #18937)
$pwshDir = Split-Path -Parent $pwshExe
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { $_ -and $_ -notlike '*WindowsApps*' }
if ($userPath[0] -ne $pwshDir) {
    [Environment]::SetEnvironmentVariable('Path', (($pwshDir) + ';' + ($userPath -join ';')), 'User')
    Write-Info 'User PATH: PS7 before WindowsApps alias'
}

if (-not (Test-Path -LiteralPath $codexConfig)) {
    throw "Missing $codexConfig"
}

$toml = Get-Content -LiteralPath $codexConfig -Raw -Encoding UTF8
$escaped = $pwshExe -replace '\\', '\\'
if ($toml -notmatch 'shell_path\s*=') {
    $toml = $toml -replace '(\[windows\]\r?\n)', "`$1shell_path = `"$escaped`"`n"
    Write-Info 'Added windows.shell_path'
}
else {
    $toml = $toml -replace 'shell_path\s*=\s*"[^"]*"', "shell_path = `"$escaped`""
    Write-Info 'Updated windows.shell_path'
}

$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($codexConfig, $toml, $utf8)

Write-Info "Codex config: $codexConfig"
Write-Info 'Restart Codex Desktop completely (quit tray + reopen).'
Write-Info 'In new session ask agent: $PSVersionTable.PSVersion — expect Major 7.'
