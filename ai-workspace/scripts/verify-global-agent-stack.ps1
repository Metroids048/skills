# One command: global stack OK for ANY project folder (no per-project venv audit).
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$scripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'
$venvPy = Join-Path $env:USERPROFILE '.ai-workspace\venv\Scripts\python.exe'

if (-not (Test-Path -LiteralPath $venvPy)) {
    Write-Host 'FAIL: global venv missing — run install-global-agent-python.ps1'
    exit 1
}

& $venvPy (Join-Path $scripts 'verify-global-agent-stack.py')
exit $LASTEXITCODE
