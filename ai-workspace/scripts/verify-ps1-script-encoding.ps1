# Pre-flight check for Agent-written .ps1 with CJK content (ASCII-only wrapper).
param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'
$py = Join-Path $PSScriptRoot 'verify-ps1-script-encoding.py'
if (-not (Test-Path -LiteralPath $py)) {
    Write-Error "Missing: $py"
}
& python $py $Path
exit $LASTEXITCODE
