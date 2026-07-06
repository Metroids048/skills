# Fast gate: Windows shell/Python UTF-8 + PS5.1 constraints for Agent work.
# Run before Python, Chinese paths, or Office file parsing. Use -Repair on FAIL.
param(
    [switch]$Quiet,
    [switch]$Repair
)

$ErrorActionPreference = 'Stop'
$failures = @()
$warnings = @()

function Add-Fail([string]$Msg) { $script:failures += $Msg }
function Add-Warn([string]$Msg) { $script:warnings += $Msg }
function Write-Line([string]$Msg) { if (-not $Quiet) { Write-Host $Msg } }

$requiredUserEnv = [ordered]@{
    PYTHONUTF8       = '1'
    PYTHONIOENCODING = 'utf-8'
}

# 1. Windows User-level env (durable; survives -NoProfile Agent shells)
foreach ($name in $requiredUserEnv.Keys) {
    $userVal = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($userVal -ne $requiredUserEnv[$name]) {
        Add-Fail "$name User env is '$userVal' (need $($requiredUserEnv[$name]))"
    }
    else {
        Write-Line "OK: User $name=$userVal"
    }
}

# 2. Current process env (warn if User OK but process stale — restart Agent)
foreach ($name in $requiredUserEnv.Keys) {
    $procVal = [Environment]::GetEnvironmentVariable($name, 'Process')
    if ($procVal -ne $requiredUserEnv[$name]) {
        $userVal = [Environment]::GetEnvironmentVariable($name, 'User')
        if ($userVal -eq $requiredUserEnv[$name]) {
            Add-Warn "Process $name='$procVal' — restart Cursor/Codex/Claude Code to pick up User env"
        }
    }
    else {
        Write-Line "OK: Process $name=$procVal"
    }
}

# 3. PowerShell profile (interactive terminals only; Agent uses User env)
$profilePath = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
if (-not (Test-Path -LiteralPath $profilePath)) {
    Add-Warn "Missing PS profile: $profilePath (interactive terminals only)"
}
elseif ((Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8) -notmatch 'ensure-utf8-console\.ps1') {
    Add-Warn "PS profile does not dot-source ensure-utf8-console.ps1"
}
else {
    Write-Line 'OK: PowerShell profile loads ensure-utf8-console.ps1'
}

$utf8Script = Join-Path $env:USERPROFILE '.ai-workspace\scripts\ensure-utf8-console.ps1'
if (-not (Test-Path -LiteralPath $utf8Script)) {
    Add-Fail "MISSING: $utf8Script"
}

# 4. Claude / Cursor extension env (secondary; User env is primary)
$claudeSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $claudeSettings) {
    $s = Get-Content -LiteralPath $claudeSettings -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($s.env.PYTHONUTF8 -ne '1') {
        Add-Warn 'PYTHONUTF8 not 1 in ~/.claude/settings.json env'
    }
    else { Write-Line 'OK: Claude settings.json PYTHONUTF8=1' }
}

$cursorSettings = Join-Path $env:APPDATA 'Cursor\User\settings.json'
if (Test-Path -LiteralPath $cursorSettings) {
    $c = Get-Content -LiteralPath $cursorSettings -Raw -Encoding UTF8 | ConvertFrom-Json
    $pyUtf8 = $c.'claudeCode.environmentVariables' | Where-Object { $_.name -eq 'PYTHONUTF8' } | Select-Object -First 1
    if (-not $pyUtf8 -or $pyUtf8.value -ne '1') {
        Add-Warn 'PYTHONUTF8 not 1 in Cursor claudeCode.environmentVariables'
    }
    else { Write-Line 'OK: Cursor extension PYTHONUTF8=1' }
}

# 5. PS version note (PS 5.1: no || operator)
$psMajor = $PSVersionTable.PSVersion.Major
if ($psMajor -lt 7) {
    Write-Line "NOTE: PowerShell $psMajor - Agent must not use bash-style || ; use -File .ps1 for scripts"
}

# 6. Live Python probe (Chinese path round-trip)
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
    Add-Warn 'python not in PATH — skip live encoding probe'
}
else {
  try {
    $probeRoot = Join-Path $env:USERPROFILE 'Desktop'
    $probeDir = $null
    if (Test-Path -LiteralPath $probeRoot) {
        $probeDir = Get-ChildItem -LiteralPath $probeRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '[\u4e00-\u9fff]' } |
            Select-Object -First 1
    }
    if ($probeDir) {
        Push-Location -LiteralPath $probeDir.FullName
        $pyOut = & python -c "import sys,os; print(sys.stdout.encoding); print(os.getcwd())" 2>&1
        Pop-Location
        $lines = @($pyOut | ForEach-Object { "$_" })
        if ($lines.Count -lt 2) {
            Add-Fail 'Python encoding probe returned no output'
        }
        else {
            $enc = $lines[0].Trim().ToLower()
            $cwd = $lines[1]
            if ($enc -notin @('utf-8', 'utf8')) {
                Add-Fail "Python stdout encoding is '$enc' (need utf-8) — run repair-windows-shell-encoding.ps1"
            }
            elseif ($cwd -ne $probeDir.FullName) {
                Add-Fail "Python cwd mismatch: got '$cwd' expected '$($probeDir.FullName)'"
            }
            else {
                Write-Line "OK: Python utf-8 + Chinese path ($($probeDir.Name))"
            }
        }
    }
    else {
        $pyOut = & python -c "import sys; print(sys.stdout.encoding)" 2>&1
        $enc = "$pyOut".Trim().ToLower()
        if ($enc -notin @('utf-8', 'utf8')) {
            Add-Fail "Python stdout encoding is '$enc' (need utf-8)"
        }
        else {
            Write-Line 'OK: Python stdout utf-8 (no Chinese Desktop dir for path probe)'
        }
    }
  }
  catch {
    Add-Fail "Python encoding probe failed: $_"
  }
}

Write-Line ''
if ($warnings.Count -gt 0) {
    Write-Line 'WARNINGS:'
    $warnings | ForEach-Object { Write-Line "  - $_" }
}

if ($failures.Count -gt 0) {
    Write-Line 'FAILURES:'
    $failures | ForEach-Object { Write-Line "  - $_" }
    Write-Line ''
    Write-Line 'Repair:'
    Write-Line '  powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\repair-windows-shell-encoding.ps1"'
    if ($Repair) {
        Write-Line ''
        Write-Line 'Running repair...'
        $repairScript = Join-Path $PSScriptRoot 'repair-windows-shell-encoding.ps1'
        & $repairScript -Quiet:$Quiet
        $script:failures = @()
        $script:warnings = @()
        & $PSCommandPath -Quiet:$Quiet
        exit $LASTEXITCODE
    }
    exit 1
}

Write-Line 'PASS: verify-windows-shell-encoding'
exit 0
