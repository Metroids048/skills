$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$strip = Join-Path $scriptDir "strip-utf8-bom.mjs"
$repos = @(
    "C:\Users\win\Desktop\skills",
    "C:\Users\win\Desktop\Agent Platform",
    "C:\Users\win\Desktop\program1-main",
    "C:\Users\win\Desktop\demo1"
)
foreach ($repo in $repos) {
    if (-not (Test-Path -LiteralPath $repo)) { continue }
    Write-Host "=== Strip BOM: $repo ==="
    & node $strip $repo
}
