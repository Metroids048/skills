# One-time global Agent Python stack (Office/file/CJK). Same for ALL projects.
param([switch]$Quiet, [switch]$WithPdf)

$ErrorActionPreference = 'Stop'
$venvRoot = Join-Path $env:USERPROFILE '.ai-workspace\venv'
$venvPy = Join-Path $venvRoot 'Scripts\python.exe'
$basePy = (Get-Command py -ErrorAction SilentlyContinue)
if (-not $basePy) { $basePy = Get-Command python -ErrorAction Stop }

function Write-Info([string]$m) { if (-not $Quiet) { Write-Host $m } }

if (-not (Test-Path -LiteralPath $venvPy)) {
    Write-Info "Creating global agent venv: $venvRoot"
    & $basePy.Source -3 -m venv $venvRoot
}

$packages = @(
    'pywin32', 'python-pptx', 'python-docx', 'openpyxl', 'Pillow'
)
if ($WithPdf) { $packages += 'pymupdf' }
foreach ($pkg in $packages) {
    Write-Info "pip install $pkg ..."
    & $venvPy -m pip install $pkg --quiet --disable-pip-version-check
}

# User env: agents read this, not project .venv
[Environment]::SetEnvironmentVariable('AGENT_PYTHON', $venvPy, 'User')
$env:AGENT_PYTHON = $venvPy

# PATH shim dir
$bin = Join-Path $env:USERPROFILE '.local\bin'
if (-not (Test-Path $bin)) { New-Item -ItemType Directory -Path $bin -Force | Out-Null }
$shim = Join-Path $bin 'agent-python.cmd'
$shimBody = "@echo off`r`n`"$venvPy`" %*`r`n"
[System.IO.File]::WriteAllText($shim, $shimBody, (New-Object System.Text.UTF8Encoding $false))

& (Join-Path $PSScriptRoot 'ensure-python-env.ps1') -Quiet
Write-Info "PASS: global agent python -> $venvPy"
Write-Info "Use: agent-python script.py   OR   `$env:AGENT_PYTHON script.py"
