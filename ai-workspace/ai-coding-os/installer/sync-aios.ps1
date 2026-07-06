param(
    [switch]$DryRun,
    [switch]$SkipScan
)

$ErrorActionPreference = 'Stop'

$install = Join-Path $PSScriptRoot 'install-aios.ps1'
if (-not (Test-Path -LiteralPath $install)) {
    throw "Missing installer: $install"
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $install -DryRun:$DryRun -SkipScan:$SkipScan

