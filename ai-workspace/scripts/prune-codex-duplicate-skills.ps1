# Prune Codex duplicate skills per skills-sync.config.json (no project root required).
$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'skills-sync.config.json'
$raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$codexRoot = Join-Path $env:USERPROFILE '.codex\skills'
$removed = @()
foreach ($n in @($raw.codexDuplicateNames)) {
    $dir = Join-Path $codexRoot $n
    if (Test-Path -LiteralPath $dir) {
        Remove-Item -LiteralPath $dir -Recurse -Force
        $removed += $n
        Write-Host "Removed: $n"
    }
}
Write-Host "Codex prune done. Removed: $($removed.Count)"
