# Sync hooks config (intent-profiles, skills-sync) to global install paths.
param([switch]$WhatIf)

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$targets = @(
    (Join-Path $env:USERPROFILE '.ai-workspace\scripts'),
    (Join-Path $env:USERPROFILE '.claude\scripts'),
    (Join-Path $env:USERPROFILE '.cursor\hooks')
)
$files = @('skills-sync.config.json', 'intent-profiles.json')

foreach ($t in $targets) {
    if (-not (Test-Path $t)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $t"; continue }
        New-Item -ItemType Directory -Path $t -Force | Out-Null
    }
    foreach ($f in $files) {
        $dest = Join-Path $t $f
        if ($WhatIf) { Write-Host "[WhatIf] copy $f -> $dest"; continue }
        Copy-Item -LiteralPath (Join-Path $src $f) -Destination $dest -Force
        Write-Host "Synced $f -> $dest"
    }
}
