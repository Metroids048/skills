# Install/update phuryn/pm-skills gaps + mvanhorn/last30days-skill via Agent Platform canonical source.
# Writes into Agent Platform/skills/, then runs sync-ai-guardrails.ps1 -Force (skip-if-exists at global layer).
param(
    [string]$AgentPlatformRoot = (Join-Path $env:USERPROFILE 'Desktop\Agent Platform'),
    [switch]$Force,
    [switch]$SkipLast30Days,
    [switch]$SkipPmSkillsUpdate,
    [switch]$SkipSync
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')

$skillsRoot = Join-Path $AgentPlatformRoot 'skills'
$pmMain = Join-Path $skillsRoot 'pm-skills-main'
$vendorDir = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$syncScript = Join-Path $AgentPlatformRoot 'scripts\sync-ai-guardrails.ps1'

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -in @('Junction', 'SymbolicLink')) {
        Remove-Item -LiteralPath $Path -Force
    }
    elseif ($item.PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    else {
        Remove-Item -LiteralPath $Path -Force
    }
}

if (-not (Test-Path $skillsRoot)) {
    throw "Agent Platform skills/ not found at $skillsRoot"
}

function Ensure-SkillMd {
    param([string]$DestDir, [string]$Url)
    if ((Test-Path (Join-Path $DestDir 'SKILL.md')) -and -not $Force) {
        return 'skipped'
    }
    if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null }
    Invoke-WebRequest -Uri $Url -OutFile (Join-Path $DestDir 'SKILL.md') -UseBasicParsing
    return 'installed'
}

$installed = @()

if (-not $SkipPmSkillsUpdate) {
    $shipRoot = Join-Path $pmMain 'pm-ai-shipping\skills'
    foreach ($n in @('shipping-artifacts', 'intended-vs-implemented')) {
        $dir = Join-Path $shipRoot $n
        $url = "https://raw.githubusercontent.com/phuryn/pm-skills/main/pm-ai-shipping/skills/$n/SKILL.md"
        if ((Ensure-SkillMd -DestDir $dir -Url $url) -eq 'installed') { $installed += $n }
    }
    $redDir = Join-Path $pmMain 'pm-execution\skills\strategy-red-team'
    if ((Ensure-SkillMd -DestDir $redDir -Url 'https://raw.githubusercontent.com/phuryn/pm-skills/main/pm-execution/skills/strategy-red-team/SKILL.md') -eq 'installed') {
        $installed += 'strategy-red-team'
    }
}

if (-not $SkipLast30Days) {
    $zip = Join-Path $vendorDir 'last30days-skill-main.zip'
    $extracted = Join-Path $vendorDir 'last30days-skill'
    if (-not (Test-Path (Join-Path $extracted 'skills\last30days\SKILL.md'))) {
        Write-Host 'Downloading last30days-skill zip...'
        Invoke-WebRequest -Uri 'https://github.com/mvanhorn/last30days-skill/archive/refs/heads/main.zip' -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $vendorDir -Force
        $folder = Get-ChildItem $vendorDir -Directory | Where-Object { $_.Name -like 'last30days-skill-*' } | Select-Object -First 1
        if ($folder) {
            if (Test-Path $extracted) { Remove-Item $extracted -Recurse -Force }
            Rename-Item $folder.FullName $extracted
        }
    }
    $l30src = Join-Path $extracted 'skills\last30days'
    $l30dst = Join-Path $skillsRoot 'last30days'
    if (Test-Path $l30src) {
        if ((Test-Path $l30dst) -and -not $Force) {
            Write-Host 'SKIP exists: last30days (repo)'
        }
        else {
            if (Test-Path $l30dst) { Remove-LinkOrDir -Path $l30dst }
            Copy-Item -LiteralPath $l30src -Destination $l30dst -Recurse -Force
            $installed += 'last30days'
        }
    }
}

if (-not $SkipSync -and (Test-Path $syncScript)) {
    & $syncScript -Force
}

Write-Host ''
Write-Host "Done. Repo updated: $($installed -join ', ')"
Write-Host "Re-run: powershell -File `"$syncScript`" -Force"
