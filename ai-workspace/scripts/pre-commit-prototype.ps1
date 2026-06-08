# Pre-commit helper: block commit if prototype shared JS changed without verify-all passing.
# Install (optional, from repo root):
#   git config core.hooksPath .githooks
# Or copy to .git/hooks/pre-commit

$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path (Join-Path $root 'prototype\scripts\verify-all.js'))) {
  $root = Split-Path $PSScriptRoot -Parent
}

$staged = git diff --cached --name-only 2>$null
if (-not $staged) { exit 0 }

$needsVerify = $false
foreach ($f in $staged) {
  if ($f -match '^prototype/assets/.*\.js$' -or $f -match '^prototype/.*\.html$') {
    $needsVerify = $true
    break
  }
}

if (-not $needsVerify) { exit 0 }

Write-Host 'prototype/assets/*.js or HTML changed — running verify-all...'
Push-Location $root
try {
  node prototype/scripts/verify-all.js
  if ($LASTEXITCODE -ne 0) {
    Write-Error 'verify-all failed. Fix before commit.'
    exit 1
  }
} finally {
  Pop-Location
}

exit 0
