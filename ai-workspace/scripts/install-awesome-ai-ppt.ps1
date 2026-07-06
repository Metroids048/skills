$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')

$zip = Join-Path $env:TEMP 'awesome-ai-ppt.zip'
$url = 'https://github.com/ningzimu/awesome-ai-ppt/archive/refs/heads/main.zip'
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -TimeoutSec 90
$ex = Join-Path $env:TEMP 'aippt-ex'
if (Test-Path $ex) { Remove-Item $ex -Recurse -Force }
Expand-Archive -LiteralPath $zip -DestinationPath $ex -Force
$inner = Get-ChildItem -LiteralPath $ex -Directory | Select-Object -First 1
$dest = Join-Path $env:USERPROFILE '.ai-workspace\vendor\awesome-ai-ppt'
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Move-Item -LiteralPath $inner.FullName -Destination $dest
$target = Join-Path $dest 'skills\awesome-ai-ppt'
if (-not (Test-Path $target)) { throw "Missing skill dir: $target" }
foreach ($r in @('.cursor', '.claude', '.codex')) {
    $link = Join-Path $env:USERPROFILE ($r + '\skills\awesome-ai-ppt')
    if (Test-Path $link) { cmd /c "rmdir `"$link`"" | Out-Null }
    cmd /c "mklink /J `"$link`" `"$target`""
}
Write-Host 'awesome-ai-ppt installed'
