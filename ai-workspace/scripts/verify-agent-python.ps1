# Report which Python/packages agents should use (ASCII-only output).
param([switch]$Quiet)

$ErrorActionPreference = 'SilentlyContinue'
$ensure = Join-Path $PSScriptRoot 'ensure-python-env.ps1'
if (Test-Path -LiteralPath $ensure) {
    & $ensure -Quiet | Out-Null
}

$envJson = Join-Path $env:USERPROFILE '.ai-workspace\runtime\python-env.json'
$python = $null
$source = 'none'
if (Test-Path -LiteralPath $envJson) {
    $info = Get-Content -LiteralPath $envJson -Raw -Encoding UTF8 | ConvertFrom-Json
    $python = $info.python
    $source = $info.source
}

$codexPy = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$failures = @()
$warnings = @()

function Add-Fail([string]$m) { $script:failures += $m }
function Add-Warn([string]$m) { $script:warnings += $m }
function Write-Line([string]$m) { if (-not $Quiet) { Write-Host $m } }

if (-not $python) { Add-Fail 'No agent python in python-env.json' }
else {
    Write-Line "OK: agent python=$python ($source)"
    if ($source -notin @('global_agent_venv', 'agent_python_env')) {
        Add-Warn "python source=$source — expected global_agent_venv (run install-global-agent-python.ps1)"
    }
}

if (Test-Path -LiteralPath $codexPy) {
    Write-Line "NOTE: codex bundled python=$codexPy (no win32com - do NOT use for Office COM)"
}

if ($python) {
    $probe = Join-Path $PSScriptRoot 'probe-python-modules.py'
    $out = & $python $probe 2>&1
    if ($LASTEXITCODE -ne 0) {
        Add-Warn "Module probe failed: $out"
    }
    else {
        $data = $out | ConvertFrom-Json
        Write-Line "OK: modules on $($data.executable)"
        foreach ($m in @('win32com','pptx')) {
            if (-not $data.modules.$m) {
                if ($m -eq 'win32com') { Add-Warn 'win32com missing on agent python - pip install pywin32' }
                if ($m -eq 'pptx') { Add-Warn 'python-pptx missing - pip install python-pptx for PPT without COM' }
            }
            else { Write-Line "OK: $m available" }
        }
    }
}

Write-Line ''
if ($warnings.Count) { $warnings | ForEach-Object { Write-Line "WARN: $_" } }
if ($failures.Count) {
    $failures | ForEach-Object { Write-Line "FAIL: $_" }
    exit 1
}
Write-Line 'PASS: verify-agent-python'
exit 0
