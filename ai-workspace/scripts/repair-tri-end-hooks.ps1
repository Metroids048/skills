# Repair tri-end hooks: RTK Shell hook only (no skills SessionStart / UserPromptSubmit).
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/hooks/repair-tri-end-hooks.ps1
param(
    [switch]$SkipGateOff
)

$ErrorActionPreference = 'Stop'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$hooksDir = $PSScriptRoot
$aiScripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'
$claudeScripts = Join-Path $env:USERPROFILE '.claude\scripts'
$cursorHooksDir = Join-Path $env:USERPROFILE '.cursor\hooks'
$cursorHooksJson = Join-Path $env:USERPROFILE '.cursor\hooks.json'

foreach ($d in @($aiScripts, $claudeScripts, $cursorHooksDir)) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

# Full RTK hook from repo SSOT
$rtkSrc = Join-Path $hooksDir 'rtk-hook-cursor.ps1'
if (-not (Test-Path $rtkSrc)) {
    throw "Missing RTK hook source: $rtkSrc"
}
foreach ($dst in @(
    (Join-Path $aiScripts 'rtk-hook-cursor.ps1'),
    (Join-Path $claudeScripts 'rtk-hook-cursor.ps1'),
    (Join-Path $cursorHooksDir 'rtk-hook-cursor.ps1')
)) {
    Copy-Item -LiteralPath $rtkSrc -Destination $dst -Force
    Write-Host "Installed RTK hook: $dst"
}

# Gate bypass stub (fail-open, no PS banner on Write/Edit)
$gateBypass = @'
param(
    [ValidateSet('Claude', 'Cursor', 'Codex', 'Auto')]
    [string]$OutputFormat = 'Auto'
)
[Console]::Out.Write('{"permission":"allow"}')
exit 0
'@
foreach ($dst in @(
    (Join-Path $aiScripts 'clarification-hard-gate.ps1'),
    (Join-Path $claudeScripts 'clarification-hard-gate.ps1'),
    (Join-Path $cursorHooksDir 'clarification-hard-gate.ps1'),
    (Join-Path $hooksDir 'clarification-hard-gate.ps1')
)) {
    Write-Utf8NoBomFile -Path $dst -Content $gateBypass
}
Write-Host 'Installed gate bypass stubs (CLARIFICATION_GATE_OFF mode)'

# cursor-shell-allow.js for Write/Edit (node, no PS banner)
$allowJsRepo = Join-Path $hooksDir 'cursor-shell-allow.js'
$allowJsGlobal = Join-Path $aiScripts 'cursor-shell-allow.js'
Copy-Item -LiteralPath $allowJsRepo -Destination $allowJsGlobal -Force
$allowHook = "node `"$allowJsGlobal`""
$rtkHookCmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$aiScripts\rtk-hook-cursor.ps1`" -OutputFormat Cursor"

if (-not $SkipGateOff) {
    [Environment]::SetEnvironmentVariable('CLARIFICATION_GATE_OFF', '1', 'User')
    $env:CLARIFICATION_GATE_OFF = '1'
    Write-Host 'Set CLARIFICATION_GATE_OFF=1 (User env)'
}

$hookBody = @{
    version = 1
    hooks   = @{
        preToolUse = @(
            @{ matcher = 'Write|Edit|MultiEdit|StrReplace|apply_patch|Delete'; command = $allowHook; timeout = 5 }
            @{ matcher = 'Shell'; command = $rtkHookCmd; timeout = 15 }
        )
    }
}

if (Test-Path $cursorHooksJson) {
    Copy-Item -LiteralPath $cursorHooksJson -Destination ($cursorHooksJson + '.bak-repair') -Force
}
Write-Utf8NoBomFile -Path $cursorHooksJson -Content ($hookBody | ConvertTo-Json -Depth 10)
Write-Host "Updated: $cursorHooksJson"

# Smoke tests
$nodeOut = & node $allowJsGlobal 2>&1 | Out-String
if ($nodeOut.Trim() -ne '{"permission":"allow"}') {
    throw "Allow hook smoke failed (node): [$nodeOut]"
}
$rtkContent = Get-Content -LiteralPath (Join-Path $aiScripts 'rtk-hook-cursor.ps1') -Raw
if ($rtkContent -notmatch 'rtk hook cursor') {
    throw 'RTK hook is still stub — expected rtk hook cursor'
}

Write-Host 'PASS: tri-end hooks repaired (gate bypass + RTK Shell).'
Write-Host 'Reload Cursor window, then run verify-tri-end-config.ps1'
