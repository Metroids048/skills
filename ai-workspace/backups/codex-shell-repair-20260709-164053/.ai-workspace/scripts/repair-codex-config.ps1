# Merge Codex [windows] block (pwsh + unelevated sandbox). Does NOT touch persistent_instructions
# (Windows paths with \U break TOML — rules live in ~/.codex/AGENTS.md instead).
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$pwshExe = 'C:\Program Files\PowerShell\7\pwsh.exe'
$codexConfig = Join-Path $env:USERPROFILE '.codex\config.toml'
$scripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'
$verifyPy = Join-Path $scripts 'verify-codex-config-toml.py'

function Write-Info([string]$m) { if (-not $Quiet) { Write-Host $m } }
function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

if (-not (Test-Path -LiteralPath $pwshExe)) {
    & (Join-Path $scripts 'upgrade-powershell7-global.ps1') -Quiet
}

$pwshDir = Split-Path -Parent $pwshExe
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';' | Where-Object { $_ -and $_ -notlike '*WindowsApps*' }
if ($userPath -notcontains $pwshDir -or $userPath[0] -ne $pwshDir) {
    $merged = @($pwshDir) + ($userPath | Where-Object { $_ -ne $pwshDir })
    [Environment]::SetEnvironmentVariable('Path', ($merged -join ';'), 'User')
}

if (-not (Test-Path -LiteralPath $codexConfig)) {
    throw "Missing $codexConfig"
}

$toml = Get-Content -LiteralPath $codexConfig -Raw -Encoding UTF8
$pwshEscaped = $pwshExe -replace '\\', '\\'

$windowsBlock = @"
[windows]
sandbox = "unelevated"
shell_path = "$pwshEscaped"
"@

if ($toml -match '\[windows\]') {
    $toml = [regex]::Replace($toml, '(?ms)\[windows\].*?(?=\r?\n\[|\z)', $windowsBlock.TrimEnd())
    Write-Info 'Replaced [windows] block in config.toml'
}
else {
    $toml = $toml.TrimEnd() + "`n`n" + $windowsBlock
    Write-Info 'Appended [windows] block to config.toml'
}

Write-Utf8NoBom $codexConfig $toml

$agentPy = Join-Path $env:USERPROFILE '.ai-workspace\venv\Scripts\python.exe'
if (Test-Path -LiteralPath $agentPy) {
    & $agentPy $verifyPy
    if ($LASTEXITCODE -ne 0) { throw 'config.toml failed TOML validation after repair' }
}
else {
    py -3 $verifyPy
    if ($LASTEXITCODE -ne 0) { throw 'config.toml failed TOML validation after repair' }
}

$pwshCmd = "`"$pwshExe`" -NoProfile -ExecutionPolicy Bypass"
$codexHooks = Join-Path $env:USERPROFILE '.codex\hooks.json'
$gate = Join-Path $scripts 'clarification-hard-gate.ps1'
$hookBody = @{
    hooks = @{
        PreToolUse = @{
            matcher = 'Write|Edit|MultiEdit|StrReplace|apply_patch'
            hooks   = @(
                @{ type = 'command'; command = "$pwshCmd -File `"$gate`" -OutputFormat Codex"; timeout = 5; statusMessage = 'Gate' }
            )
        }
    }
}
Write-Utf8NoBom $codexHooks ($hookBody | ConvertTo-Json -Depth 10)

Write-Info "Updated: $codexConfig (sandbox=unelevated, no persistent_instructions)"
Write-Info "Rules: $env:USERPROFILE\.codex\AGENTS.md"
Write-Info 'Restart Codex Desktop fully (quit tray).'
