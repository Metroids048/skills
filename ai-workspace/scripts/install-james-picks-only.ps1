$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor\jamesrochabrun-skills\skills'
$picks = @(
    'anthropic-architect', 'llm-router', 'engineer-expertise-extractor',
    'design-brief-generator', 'content-brief-generator', 'query-expert',
    'technical-launch-planner', 'qa-test-planner'
)

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        Remove-Item -LiteralPath $Path -Force
    }
    elseif ($item.PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    else {
        Remove-Item -LiteralPath $Path -Force
    }
}

foreach ($name in $picks) {
    $target = Join-Path $vendor $name
    if (-not (Test-Path -LiteralPath $target)) {
        Write-Warning "Missing: $target"
        continue
    }
    $resolved = (Resolve-Path -LiteralPath $target).Path
    foreach ($root in @(
            (Join-Path $env:USERPROFILE '.cursor\skills'),
            (Join-Path $env:USERPROFILE '.claude\skills'),
            (Join-Path $env:USERPROFILE '.codex\skills')
        )) {
        if (-not (Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        $dest = Join-Path $root $name
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "Junction: $dest"
    }
}

Write-Host 'James picks installed.'
