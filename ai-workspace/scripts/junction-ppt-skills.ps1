# Junction-only install for PPT skills (vendor must already exist).
param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$roots = @(
    (Join-Path $env:USERPROFILE '.cursor\skills'),
    (Join-Path $env:USERPROFILE '.claude\skills'),
    (Join-Path $env:USERPROFILE '.codex\skills')
)

$defs = @(
    @{ SkillName = 'bruce-pptx-generator'; Path = 'bruce-pptx-generator' },
    @{ SkillName = 'guizang-ppt-skill'; Path = 'guizang-ppt-skill' },
    @{ SkillName = 'html-slide-to-pptx'; Path = 'html-slide-to-pptx' },
    @{ SkillName = 'revealjs'; Path = 'revealjs-skill\skills\revealjs' },
    @{ SkillName = 'awesome-ai-ppt'; Path = 'awesome-ai-ppt\skills\awesome-ai-ppt' },
    @{ SkillName = 'ppt-master'; Path = 'ppt-master\skills\ppt-master' },
    @{ SkillName = 'frontend-slides'; Path = 'frontend-slides' },
    @{ SkillName = 'huashu-design'; Path = 'huashu-design' }
)

foreach ($def in $defs) {
    $repoDir = Join-Path $vendor $def.Path.Split('\')[0]
    $target = Join-Path $vendor $def.Path
    if (-not (Test-Path (Join-Path $target 'SKILL.md'))) {
        $found = Get-ChildItem -Path $repoDir -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $target = $found.DirectoryName } else { Write-Warning "SKIP $($def.SkillName): no SKILL.md"; continue }
    }
    $resolved = (Resolve-Path -LiteralPath $target).Path
    foreach ($root in $roots) {
        if (-not (Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        $dest = Join-Path $root $def.SkillName
        if ($DryRun) { Write-Host "[dry-run] $dest -> $resolved"; continue }
        if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Force -Recurse -ErrorAction SilentlyContinue }
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "OK $($def.SkillName) @ $(Split-Path $root -Leaf)"
    }
}
Write-Host 'Junction pass complete.'
