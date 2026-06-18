# Scan a repo for UTF-8 / mojibake / BOM issues (delegates to Node for reliable UTF-8).
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,
    [string]$ReportDir = "",
    [switch]$FailOnError
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "ensure-utf8-console.ps1")

$nodeScript = Join-Path $PSScriptRoot "scan-encoding-issues.mjs"
if (-not (Test-Path -LiteralPath $nodeScript)) {
    throw "Missing $nodeScript"
}

$root = (Resolve-Path -LiteralPath $RepoPath).Path
$nodeArgs = @($nodeScript, $root)
if ($ReportDir) {
    $nodeArgs += (Resolve-Path -LiteralPath $ReportDir).Path
}

& node @nodeArgs
if ($FailOnError -and $LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
exit $LASTEXITCODE
