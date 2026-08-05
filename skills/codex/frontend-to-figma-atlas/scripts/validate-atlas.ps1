param(
  [Parameter(Mandatory = $true)]
  [string]$ArtifactsDir
)

$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $ArtifactsDir).Path
$manifestPath = Join-Path $resolved 'capture-manifest.json'
$zipPath = Join-Path $resolved 'figma-import.zip'

if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing $manifestPath" }
if (-not (Test-Path -LiteralPath $zipPath)) { throw "Missing $zipPath" }

$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath $manifestPath | ConvertFrom-Json
$ids = @($manifest | ForEach-Object { $_.id })
$names = @($manifest | ForEach-Object { $_.screenshotName })
if (($ids | Sort-Object -Unique).Count -ne $ids.Count) { throw 'Duplicate scene IDs in Manifest' }
if (($names | Sort-Object -Unique).Count -ne $names.Count) { throw 'Duplicate screenshot names in Manifest' }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $entries = @($archive.Entries | ForEach-Object { $_.FullName })
  if ($entries -notcontains 'capture-manifest.json') { throw 'ZIP is missing capture-manifest.json' }
  $successful = @($manifest | Where-Object { $_.status -eq 'success' })
  foreach ($scene in $successful) {
    $entryName = 'images/' + $scene.screenshotName
    if ($entries -notcontains $entryName) { throw "ZIP is missing $entryName" }
  }
  $pngCount = @($entries | Where-Object { $_ -like 'images/*.png' }).Count
  if ($pngCount -ne $successful.Count) {
    throw "ZIP PNG count $pngCount does not match successful scene count $($successful.Count)"
  }
} finally {
  $archive.Dispose()
}

Write-Output "ATLAS_VALIDATE_PASS scenes=$($manifest.Count) success=$($successful.Count) images=$pngCount"
