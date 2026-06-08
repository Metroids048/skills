# Install Leonxlnx/taste-skill bundle to ~/.cursor/skills, ~/.claude/skills, ~/.codex/skills
# Source: skills/vendor/taste-skill/ (sync from upstream via -RefreshFromGitHub)
param(
    [switch]$RefreshFromGitHub,
    [switch]$Force,
    [string]$VendorRoot = ''
)

$ErrorActionPreference = 'Stop'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Get-SkillInstallName {
    param([string]$SkillMdPath)
    $content = Get-Content -LiteralPath $SkillMdPath -Raw -Encoding UTF8
    if ($content -match '(?m)^name:\s*(.+)$') {
        return $Matches[1].Trim().Trim('"').Trim("'")
    }
    return $null
}

function Copy-SkillToTarget {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [switch]$ForceCopy
    )
    if ((Test-Path $DestDir) -and -not $ForceCopy) {
        return 'skipped'
    }
    if (Test-Path $DestDir) {
        Remove-Item -LiteralPath $DestDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    Copy-Item -Path (Join-Path $SourceDir '*') -Destination $DestDir -Recurse -Force
    return 'installed'
}

$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $VendorRoot) {
    $VendorRoot = Join-Path $repoRoot 'skills\vendor\taste-skill'
}

if ($RefreshFromGitHub) {
    $zip = Join-Path $env:TEMP 'taste-skill-main.zip'
    $extractRoot = Join-Path $env:TEMP 'taste-skill-main'
    Write-Host 'Downloading taste-skill from GitHub...'
    Invoke-WebRequest -Uri 'https://github.com/Leonxlnx/taste-skill/archive/refs/heads/main.zip' -OutFile $zip -UseBasicParsing
    if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $env:TEMP -Force
    $upstreamSkills = Join-Path $extractRoot 'skills'
    if (-not (Test-Path $upstreamSkills)) { throw "Upstream skills folder not found: $upstreamSkills" }
    if (Test-Path $VendorRoot) { Remove-Item $VendorRoot -Recurse -Force }
    New-Item -ItemType Directory -Path $VendorRoot -Force | Out-Null
    Get-ChildItem -Path $upstreamSkills -Directory | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $VendorRoot $_.Name) -Recurse -Force
    }
    if (Test-Path (Join-Path $upstreamSkills 'llms.txt')) {
        Copy-Item -LiteralPath (Join-Path $upstreamSkills 'llms.txt') -Destination $VendorRoot -Force
    }
    Write-Utf8NoBomFile -Path (Join-Path $VendorRoot 'UPSTREAM.txt') -Content @(
        'Upstream: https://github.com/Leonxlnx/taste-skill'
        "Refreshed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        'License: MIT'
    )
    Write-Host "Vendor refreshed: $VendorRoot"
}

if (-not (Test-Path $VendorRoot)) {
    throw "Vendor not found: $VendorRoot. Run with -RefreshFromGitHub first."
}

$targets = @(
    (Join-Path $env:USERPROFILE '.cursor\skills')
    (Join-Path $env:USERPROFILE '.claude\skills')
    (Join-Path $env:USERPROFILE '.codex\skills')
)
foreach ($t in $targets) {
    if (-not (Test-Path $t)) { New-Item -ItemType Directory -Path $t -Force | Out-Null }
}

$installed = @()
$skipped = @()
$failed = @()

Get-ChildItem -Path $VendorRoot -Directory | ForEach-Object {
    $skillMd = Join-Path $_.FullName 'SKILL.md'
    if (-not (Test-Path $skillMd)) { return }
    $installName = Get-SkillInstallName -SkillMdPath $skillMd
    if (-not $installName) {
        $failed += $_.Name
        return
    }
    foreach ($targetRoot in $targets) {
        $dest = Join-Path $targetRoot $installName
        $result = Copy-SkillToTarget -SourceDir $_.FullName -DestDir $dest -ForceCopy:$Force
        if ($result -eq 'installed') {
            $installed += "$installName -> $targetRoot"
        }
        else {
            $skipped += "$installName ($targetRoot)"
        }
    }
}

Write-Host ''
Write-Host "Installed entries: $($installed.Count / 3) skills x 3 targets"
if ($skipped.Count -gt 0) {
    Write-Host "Skipped (exists, use -Force): $($skipped.Count)"
}
if ($failed.Count -gt 0) {
    Write-Host "Failed (no name in frontmatter): $($failed -join ', ')"
}

$scanHook = Join-Path $env:USERPROFILE '.ai-workspace\scripts\scan-global-skills.ps1'
if (-not (Test-Path $scanHook)) {
    $scanHook = Join-Path $repoRoot 'scripts\hooks\scan-global-skills.ps1'
}
if (Test-Path $scanHook) {
    & $scanHook -OutputFormat Plain -HookEvent Plain -StartDir $repoRoot | Out-Null
    Write-Host "Refreshed: ~/.claude/global-skills-index.md"
}

Write-Host ''
Write-Host 'Done. Restart Cursor / Claude Code / Codex sessions.'
Write-Host 'Default skill: design-taste-frontend (taste-skill v2). Codex variant: gpt-taste.'
