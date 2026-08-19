param(
    [Parameter(Mandatory=$true)][string]$BundlePath,
    [string]$Destination = (Join-Path $env:USERPROFILE ".ai-workspace\private-memory")
)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$resolvedDest = [System.IO.Path]::GetFullPath($Destination)
$resolvedRepo = [System.IO.Path]::GetFullPath($RepoRoot)
if ($resolvedDest.StartsWith($resolvedRepo, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Private memory destination must be outside the Git repository."
}
if (-not (Test-Path -LiteralPath $BundlePath)) { throw "Missing bundle: $BundlePath" }
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$source = $BundlePath
$temp = $null
if ((Get-Item -LiteralPath $BundlePath).PSIsContainer -eq $false) {
    if ([System.IO.Path]::GetExtension($BundlePath) -ne ".zip") { throw "Bundle must be a directory or .zip" }
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("aiw-memory-" + [guid]::NewGuid().ToString("N"))
    Expand-Archive -LiteralPath $BundlePath -DestinationPath $temp -Force
    $children = @(Get-ChildItem -LiteralPath $temp)
    $source = if ($children.Count -eq 1 -and $children[0].PSIsContainer) { $children[0].FullName } else { $temp }
}
try {
    robocopy $source $Destination /E /XJ /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Private memory install failed: $LASTEXITCODE" }
} finally {
    if ($temp -and (Test-Path -LiteralPath $temp)) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
Write-Host "Private memory installed to: $Destination"
Write-Host "Run aiw context / memory search from your project to verify retrieval."
