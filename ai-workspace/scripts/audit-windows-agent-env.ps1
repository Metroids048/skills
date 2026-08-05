# System-wide audit: Windows agent shell, encoding, Python, hooks (token waste).
param([switch]$Quiet)

$ErrorActionPreference = 'Continue'
$failures = @()
$warnings = @()
$scripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'

function Add-Fail([string]$m) { $script:failures += $m }
function Add-Warn([string]$m) { $script:warnings += $m }
function Write-Line([string]$m) { if (-not $Quiet) { Write-Host $m } }

function Run-Check {
    param([string]$Name, [string]$Script)
    if (-not (Test-Path -LiteralPath $Script)) {
        Add-Fail "MISSING: $Name -> $Script"
        return
    }
    & $Script -Quiet:$Quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Add-Fail "$Name failed (exit $LASTEXITCODE)" }
    else { Write-Line "OK: $Name" }
}

Write-Line '=== audit-windows-agent-env ==='

Run-Check 'verify-windows-shell-encoding' (Join-Path $scripts 'verify-windows-shell-encoding.ps1')
Run-Check 'verify-global-agent-stack' (Join-Path $scripts 'verify-global-agent-stack.ps1')
Run-Check 'verify-agent-python' (Join-Path $scripts 'verify-agent-python.ps1')
Run-Check 'verify-tri-end-config' (Join-Path $scripts 'verify-tri-end-config.ps1')

# Per-prompt skill hooks = token burn
$cursorHooks = Join-Path $env:USERPROFILE '.cursor\hooks.json'
if (Test-Path -LiteralPath $cursorHooks) {
    $h = Get-Content -LiteralPath $cursorHooks -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($bad in @('sessionStart', 'beforeSubmitPrompt', 'SessionStart', 'UserPromptSubmit')) {
        if ($h.hooks.PSObject.Properties.Name -contains $bad) {
            Add-Fail "Cursor hooks.json has $bad (runs scan-global-skills every prompt/session - token waste)"
        }
    }
}

$codexHooks = Join-Path $env:USERPROFILE '.codex\hooks.json'
if (Test-Path -LiteralPath $codexHooks) {
    $h = Get-Content -LiteralPath $codexHooks -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($bad in @('SessionStart', 'UserPromptSubmit')) {
        if ($h.hooks.PSObject.Properties.Name -contains $bad) {
            Add-Fail "Codex hooks.json has $bad (token waste on every prompt)"
        }
    }
}

$claudeSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $claudeSettings) {
    $s = Get-Content -LiteralPath $claudeSettings -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($s.PSObject.Properties.Name -contains 'hooks') {
        Add-Fail 'Claude settings.json has hooks block (token/cache conflict)'
    }
    if ($s.env.PYTHONIOENCODING -ne 'utf-8') {
        Add-Warn 'Claude settings env missing PYTHONIOENCODING=utf-8'
    }
}

$rule = Join-Path $env:USERPROFILE '.cursor\rules\windows-agent-shell.mdc'
if (Test-Path -LiteralPath $rule) {
    $r = Get-Content -LiteralPath $rule -Raw -Encoding UTF8
    if ($r -notmatch 'read-text-file\.py') { Add-Warn 'windows-agent-shell.mdc missing read-text-file.py guidance' }
    if ($r -match 'rtk powershell -NoProfile.*Get-Content') { Add-Warn 'windows-agent-shell.mdc still suggests rtk powershell for cmdlets' }
    if ($r -notmatch 'resolve-test-runner') { Add-Warn 'windows-agent-shell.mdc missing resolve-test-runner guidance' }
}
else { Add-Fail 'MISSING: ~/.cursor/rules/windows-agent-shell.mdc' }

$triage = Join-Path $env:USERPROFILE '.cursor\rules\windows-failure-triage.mdc'
if (-not (Test-Path -LiteralPath $triage)) {
    Add-Fail 'MISSING: ~/.cursor/rules/windows-failure-triage.mdc'
}
else {
    Write-Line 'OK: windows-failure-triage.mdc'
}

$catalog = Join-Path $env:USERPROFILE '.ai-workspace\memory\windows-agent-failure-catalog-zh.md'
if (-not (Test-Path -LiteralPath $catalog)) {
    Add-Fail 'MISSING: windows-agent-failure-catalog-zh.md'
}
else {
    Write-Line 'OK: failure catalog'
}

$resolve = Join-Path $scripts 'resolve-test-runner.py'
if (-not (Test-Path -LiteralPath $resolve)) {
    Add-Fail 'MISSING: resolve-test-runner.py'
}
else {
    Write-Line 'OK: resolve-test-runner.py'
}

$codexPy = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if (Test-Path -LiteralPath $codexPy) {
    Write-Line "NOTE: codex bundled python exists (no Office COM) - agents must use python-env.json python"
}

Write-Line ''
if ($warnings.Count) {
    Write-Line 'WARNINGS:'
    $warnings | ForEach-Object { Write-Line "  - $_" }
}
if ($failures.Count) {
    Write-Line 'FAILURES:'
    $failures | ForEach-Object { Write-Line "  - $_" }
    Write-Line ''
    Write-Line "Repair: powershell -NoProfile -File `"$scripts\repair-windows-agent-env.ps1`""
    exit 1
}

Write-Line 'PASS: audit-windows-agent-env'
exit 0
