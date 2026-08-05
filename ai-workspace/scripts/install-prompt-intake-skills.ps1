# Install prompt-intake skills (prompt-architect, prompt-optimizer, maestro-prompt-leverage)
# to Cursor + Claude + Codex + .agents via vendor junctions.
param(
    [switch]$DryRun,
    [switch]$SkipDownload,
    [switch]$SkipIndexScan
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
$agentsSkills = Join-Path $env:USERPROFILE '.agents\skills'

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
    }
    elseif ($item.PSIsContainer) {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Recurse -Force }
    }
    else {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
    }
}

function Install-SkillJunction {
    param(
        [string]$SkillName,
        [string]$TargetDir
    )
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        Write-Warning "Missing target: $TargetDir"
        return $false
    }
    $resolved = (Resolve-Path -LiteralPath $TargetDir).Path
    foreach ($root in @($cursorSkills, $claudeSkills, $codexSkills, $agentsSkills)) {
        if (-not (Test-Path $root)) {
            if (-not $DryRun) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        }
        $dest = Join-Path $root $SkillName
        if ($DryRun) {
            Write-Host "[dry-run] junction $dest -> $resolved"
            continue
        }
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "Junction: $dest -> $resolved"
    }
    return $true
}

function Ensure-GithubZip {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$DestDir
    )
    if (Test-Path (Join-Path $DestDir 'SKILL.md')) {
        Write-Host "Vendor ready: $DestDir"
        return $true
    }
    if ($DryRun) {
        Write-Host "[dry-run] download $Owner/$Repo -> $DestDir"
        return $true
    }
    New-Item -ItemType Directory -Path (Split-Path $DestDir -Parent) -Force | Out-Null
    foreach ($branch in @('main', 'master')) {
        $url = "https://github.com/$Owner/$Repo/archive/refs/heads/$branch.zip"
        $tempZip = Join-Path $env:TEMP ("skill-vendor-$Owner-$Repo.zip")
        $extractRoot = Join-Path $env:TEMP ("skill-vendor-$Owner-$Repo")
        try {
            Write-Host "Trying zip: $url"
            Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing -TimeoutSec 120
            if (Test-Path $extractRoot) { Remove-Item -LiteralPath $extractRoot -Recurse -Force }
            Expand-Archive -LiteralPath $tempZip -DestinationPath $extractRoot -Force
            $inner = Get-ChildItem -LiteralPath $extractRoot -Directory | Select-Object -First 1
            if (-not $inner) { continue }
            if (Test-Path $DestDir) { Remove-Item -LiteralPath $DestDir -Recurse -Force }
            Move-Item -LiteralPath $inner.FullName -Destination $DestDir
            Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Downloaded zip -> $DestDir"
            return $true
        }
        catch {
            Write-Warning "Zip failed ($url): $_"
        }
    }
    return $false
}

function Find-FirstChildDir {
    param(
        [string]$Root,
        [string[]]$RelativeCandidates
    )
    foreach ($rel in $RelativeCandidates) {
        $p = Join-Path $Root $rel
        if (Test-Path (Join-Path $p 'SKILL.md')) { return $p }
    }
    return $null
}

$report = [System.Collections.Generic.List[object]]::new()

# --- vendor: prompt-architect (ckelsoe) ---
$paRepo = Join-Path $vendor 'prompt-architect'
if (-not $SkipDownload) {
    $null = Ensure-GithubZip -Owner 'ckelsoe' -Repo 'prompt-architect' -DestDir $paRepo
}
$paSkill = Find-FirstChildDir -Root $paRepo -RelativeCandidates @(
    'skills\prompt-architect',
    'prompt-architect'
)
if ($paSkill -and (Install-SkillJunction -SkillName 'prompt-architect' -TargetDir $paSkill)) {
    $report.Add([pscustomobject]@{ Skill = 'prompt-architect'; Action = 'install'; Source = 'ckelsoe/prompt-architect' })
}
else {
    $report.Add([pscustomobject]@{ Skill = 'prompt-architect'; Action = 'skip'; Reason = 'missing vendor skill dir' })
}

# --- vendor: prompt-optimizer (daymade) ---
$poRepo = Join-Path $vendor 'daymade-claude-code-skills'
if (-not $SkipDownload) {
    $null = Ensure-GithubZip -Owner 'daymade' -Repo 'claude-code-skills' -DestDir $poRepo
}
$poSkill = Find-FirstChildDir -Root $poRepo -RelativeCandidates @(
    'prompt-optimizer',
    'skills\prompt-optimizer'
)
if ($poSkill -and (Install-SkillJunction -SkillName 'prompt-optimizer' -TargetDir $poSkill)) {
    $report.Add([pscustomobject]@{ Skill = 'prompt-optimizer'; Action = 'install'; Source = 'daymade/claude-code-skills' })
}
else {
    # fallback: awesome-copilot copy already in vendor
    $poFallback = Join-Path $vendor 'awesome-copilot\skills\prompt-optimizer'
    if ((Test-Path (Join-Path $poFallback 'SKILL.md')) -and (Install-SkillJunction -SkillName 'prompt-optimizer' -TargetDir $poFallback)) {
        $report.Add([pscustomobject]@{ Skill = 'prompt-optimizer'; Action = 'install'; Source = 'awesome-copilot fallback' })
    }
    else {
        $report.Add([pscustomobject]@{ Skill = 'prompt-optimizer'; Action = 'skip'; Reason = 'missing daymade + fallback' })
    }
}

# --- vendor: maestro prompt-leverage (Windows-safe name) ---
$maestroRepo = Join-Path $vendor 'maestro'
if (-not $SkipDownload) {
    $null = Ensure-GithubZip -Owner 'ReinaMacCredy' -Repo 'maestro' -DestDir $maestroRepo
}
$plSkill = Find-FirstChildDir -Root $maestroRepo -RelativeCandidates @(
    '.claude\skills\prompt-leverage'
)
# Prefer self-contained curated copy (maestro main only ships redirect stub)
$plCurated = Join-Path $env:USERPROFILE '.ai-workspace\skills-curated\maestro-prompt-leverage'
if (-not (Test-Path (Join-Path $plCurated 'SKILL.md')) -and $plSkill) {
    Copy-Item -LiteralPath (Join-Path $plSkill 'scripts') -Destination (Join-Path $plCurated 'scripts') -Recurse -Force -ErrorAction SilentlyContinue
}
if ((Test-Path (Join-Path $plCurated 'SKILL.md')) -and (Install-SkillJunction -SkillName 'maestro-prompt-leverage' -TargetDir $plCurated)) {
    $report.Add([pscustomobject]@{ Skill = 'maestro-prompt-leverage'; Action = 'install'; Source = 'skills-curated (from maestro prompt-leverage)' })
}
else {
    $report.Add([pscustomobject]@{ Skill = 'maestro-prompt-leverage'; Action = 'skip'; Reason = 'missing curated maestro-prompt-leverage' })
}

# --- prompt-intake-router (local canonical in .ai-workspace) ---
$routerCanonical = Join-Path $env:USERPROFILE '.ai-workspace\skills-curated\prompt-intake-router'
if (-not $DryRun -and -not (Test-Path (Join-Path $routerCanonical 'SKILL.md'))) {
    Write-Warning "prompt-intake-router not found at $routerCanonical — run sync after creating router skill"
}
elseif (Test-Path (Join-Path $routerCanonical 'SKILL.md')) {
    if (Install-SkillJunction -SkillName 'prompt-intake-router' -TargetDir $routerCanonical) {
        $report.Add([pscustomobject]@{ Skill = 'prompt-intake-router'; Action = 'install'; Source = 'local curated' })
    }
}

$reportPath = Join-Path $env:USERPROFILE '.ai-workspace\memory\prompt-intake-skills-install-report.json'
if (-not $DryRun) {
    Write-Utf8NoBomFile -Path $reportPath -Content ($report | ConvertTo-Json -Depth 3)
}

if (-not $SkipIndexScan -and -not $DryRun) {
    $scan = Join-Path $PSScriptRoot 'scan-global-skills.ps1'
    if (Test-Path $scan) {
        & $scan -OutputFormat Plain | Out-Null
        Write-Host "Ran scan-global-skills.ps1"
    }
}

$report | Format-Table -AutoSize
Write-Host "Report: $reportPath"
Write-Host "Installed: $(($report | Where-Object { $_.Action -eq 'install' }).Count) / $($report.Count)"
