# Idempotent repair: Windows User env + PS profile + tri-end PYTHONUTF8.
# Agent shells use powershell -NoProfile; User-level env is the durable fix.
param(
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Info([string]$Msg) {
    if (-not $Quiet) { Write-Host $Msg }
}

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

$shellUserEnv = [ordered]@{
    PYTHONUTF8         = '1'
    PYTHONIOENCODING   = 'utf-8'
}

foreach ($name in $shellUserEnv.Keys) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($current -ne $shellUserEnv[$name]) {
        [Environment]::SetEnvironmentVariable($name, $shellUserEnv[$name], 'User')
        Write-Info "User env: $name=$($shellUserEnv[$name])"
    }
    else {
        Write-Info "User env OK: $name=$current"
    }
}

$profileDir = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell'
$profilePath = Join-Path $profileDir 'Microsoft.PowerShell_profile.ps1'
$profileBody = @'
# Interactive PowerShell UTF-8 bootstrap.
# Agent/Codex hooks use -NoProfile; they rely on User-level PYTHONUTF8 instead.
$utf8Script = Join-Path $env:USERPROFILE '.ai-workspace\scripts\ensure-utf8-console.ps1'
if (Test-Path -LiteralPath $utf8Script) {
    . $utf8Script
}

'@

if (-not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$needsProfile = $true
if (Test-Path -LiteralPath $profilePath) {
    $existing = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8
    if ($existing -match 'ensure-utf8-console\.ps1') {
        $needsProfile = $false
        Write-Info "Profile OK: $profilePath"
    }
}
if ($needsProfile) {
    Write-Utf8NoBomFile -Path $profilePath -Content $profileBody
    Write-Info "Profile written: $profilePath"
}

$applyTriEnd = Join-Path $PSScriptRoot 'apply-tri-end-env.ps1'
if (Test-Path -LiteralPath $applyTriEnd) {
    & $applyTriEnd -Quiet
    Write-Info 'Tri-end env refreshed (Claude/Cursor settings)'
}

# Also set in current process so verify can pass without restart.
foreach ($name in $shellUserEnv.Keys) {
    Set-Item -Path "Env:$name" -Value $shellUserEnv[$name]
}

Write-Info 'PASS: repair-windows-shell-encoding complete'
Write-Info 'Restart Cursor/Codex/Claude Code if other processes still lack PYTHONUTF8.'
