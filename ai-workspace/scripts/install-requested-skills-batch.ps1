# Install requested GitHub skills (dedup cherry-pick) to tri-end via vendor junctions.
param(
    [switch]$DryRun,
    [switch]$SkipClone
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
$globalIndex = Join-Path $env:USERPROFILE '.claude\global-skills-index.md'
$configPath = Join-Path $PSScriptRoot 'skills-sync.config.json'

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
    foreach ($root in @($cursorSkills, $claudeSkills, $codexSkills)) {
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

function Ensure-RepoClone {
    param(
        [string]$RepoUrl,
        [string]$DestDir
    )
    if (Test-Path (Join-Path $DestDir '.git')) {
        Write-Host "Repo exists: $DestDir"
        return $true
    }
    if (Test-Path $DestDir) {
        $hasContent = Get-ChildItem -LiteralPath $DestDir -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hasContent) {
            Write-Host "Vendor dir exists (no .git): $DestDir"
            return $true
        }
    }
    if ($DryRun) {
        Write-Host "[dry-run] clone/download $RepoUrl -> $DestDir"
        return $true
    }
    New-Item -ItemType Directory -Path (Split-Path $DestDir -Parent) -Force | Out-Null
    $gitOk = $false
    try {
        & git clone --depth 1 $RepoUrl $DestDir 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0 -and (Test-Path $DestDir)) { $gitOk = $true }
    }
    catch { $gitOk = $false }
    if ($gitOk) { return $true }

    # Fallback: GitHub zip archive (when git HTTPS blocked)
    if ($RepoUrl -match 'github\.com/([^/]+)/([^/.]+)') {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $zipUrl = "https://github.com/$owner/$repo/archive/refs/heads/main.zip"
        $zipAlt = "https://github.com/$owner/$repo/archive/refs/heads/master.zip"
        $tempZip = Join-Path $env:TEMP ("skill-vendor-$owner-$repo.zip")
        $extractRoot = Join-Path $env:TEMP ("skill-vendor-$owner-$repo")
        foreach ($url in @($zipUrl, $zipAlt)) {
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
    }
    Write-Warning "git clone and zip download failed: $RepoUrl"
    return $false
}

function Get-InstalledSkillNames {
    $names = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($root in @($cursorSkills, $claudeSkills, $codexSkills)) {
        if (-not (Test-Path $root)) { continue }
        Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            [void]$names.Add($_.Name)
        }
    }
    return $names
}

function Get-FrontmatterName {
    param([string]$SkillMdPath)
    if (-not (Test-Path $SkillMdPath)) { return $null }
    $content = Get-Content -LiteralPath $SkillMdPath -Raw -Encoding UTF8
    if ($content -match '(?m)^name:\s*(.+)$') { return $Matches[1].Trim().Trim('"').Trim("'") }
    return (Split-Path (Split-Path $SkillMdPath -Parent) -Leaf)
}

function Get-ExclusiveConflictNames {
    if (-not (Test-Path $configPath)) { return @{} }
    $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $map = @{}
    if ($raw.exclusiveGroups) {
        foreach ($group in $raw.exclusiveGroups) {
            foreach ($n in $group) { $map[$n] = @($group) }
        }
    }
    return $map
}

function Test-SkillConflict {
    param(
        [string]$Name,
        [System.Collections.Generic.HashSet[string]]$Installed,
        [hashtable]$ExclusiveMap
    )
    if ($Installed.Contains($Name)) {
        return "already installed"
    }
    if ($ExclusiveMap.ContainsKey($Name)) {
        foreach ($peer in $ExclusiveMap[$Name]) {
            if ($peer -ne $Name -and $Installed.Contains($peer)) {
                return "exclusive with $peer"
            }
        }
    }
    return $null
}

# --- Skip lists (dedup policy) ---
$jamesSkip = @(
    'git-worktrees', 'prd-generator', 'openai-prompt-engineer', 'anthropic-prompt-engineer',
    'frontend-designer', 'engineer-skill-creator', 'swift-concurrency', 'swiftui-animation',
    'releasing-macos-apps', 'apple-hig-designer', 'book-illustrator', 'kids-book-writer',
    'math-teacher', 'reading-teacher', 'leetcode-teacher', 'trading-plan-generator'
)

$jamesPick = @(
    'anthropic-architect', 'llm-router', 'engineer-expertise-extractor',
    'design-brief-generator', 'content-brief-generator', 'query-expert',
    'technical-launch-planner', 'qa-test-planner'
)

$installed = Get-InstalledSkillNames
$exclusiveMap = Get-ExclusiveConflictNames
$report = [System.Collections.Generic.List[object]]::new()

# --- Repos ---
$repos = @(
    @{ Key = 'jamesrochabrun-skills'; Url = 'https://github.com/jamesrochabrun/skills.git'; SkillsRoot = 'skills' },
    @{ Key = 'ppt-master'; Url = 'https://github.com/hugohe3/ppt-master.git'; SkillsRoot = 'skills/ppt-master' },
    @{ Key = 'awesome-ai-ppt'; Url = 'https://github.com/ningzimu/awesome-ai-ppt.git'; SkillsRoot = 'skills/awesome-ai-ppt' },
    @{ Key = 'awesome-copilot'; Url = 'https://github.com/github/awesome-copilot.git'; SkillsRoot = 'skills' }
)

foreach ($repo in $repos) {
    $repoDir = Join-Path $vendor $repo.Key
    if (-not $SkipClone) {
        $null = Ensure-RepoClone -RepoUrl $repo.Url -DestDir $repoDir
    }
}

# --- claude-skill-registry stub ---
$registryMeta = Join-Path $vendor 'claude-skill-registry'
if (-not $DryRun) {
    New-Item -ItemType Directory -Path $registryMeta -Force | Out-Null
    $readme = @"
# claude-skill-registry (metadata stub)

Upstream: https://github.com/majiayu000/claude-skill-registry

Index-only registry — no committed skills tree to install.
Use for discovery reference; local routing via global-skills-index.md.
"@
    Write-Utf8NoBomFile -Path (Join-Path $registryMeta 'README.md') -Content $readme
}

# --- jamesrochabrun cherry-pick (fast cmd junctions) ---
$jamesCmd = Join-Path $PSScriptRoot 'install-james-picks.cmd'
if (Test-Path $jamesCmd) {
    if ($DryRun) { Write-Host '[dry-run] install-james-picks.cmd' }
    else { cmd /c $jamesCmd | Out-Host }
}

# --- ppt-master ---
$pptTarget = Join-Path $vendor 'ppt-master\skills\ppt-master'
$pptConflict = Test-SkillConflict -Name 'ppt-master' -Installed $installed -ExclusiveMap $exclusiveMap
if (-not $pptConflict -and (Test-Path $pptTarget)) {
    if (Install-SkillJunction -SkillName 'ppt-master' -TargetDir $pptTarget) {
        [void]$installed.Add('ppt-master')
        $report.Add([pscustomobject]@{ Skill = 'ppt-master'; Action = 'install'; Reason = 'hugohe3/ppt-master' })
    }
}
else {
    $reason = if ($pptConflict) { $pptConflict } else { 'missing vendor' }
    $report.Add([pscustomobject]@{ Skill = 'ppt-master'; Action = 'skip'; Reason = $reason })
}

# --- awesome-ai-ppt ---
$aipptTarget = Join-Path $vendor 'awesome-ai-ppt\skills\awesome-ai-ppt'
$aipptConflict = Test-SkillConflict -Name 'awesome-ai-ppt' -Installed $installed -ExclusiveMap $exclusiveMap
if (-not $aipptConflict -and (Test-Path $aipptTarget)) {
    if (Install-SkillJunction -SkillName 'awesome-ai-ppt' -TargetDir $aipptTarget) {
        [void]$installed.Add('awesome-ai-ppt')
        $report.Add([pscustomobject]@{ Skill = 'awesome-ai-ppt'; Action = 'install'; Reason = 'ningzimu/awesome-ai-ppt' })
    }
}
else {
    $reason = if ($aipptConflict) { $aipptConflict } else { 'missing vendor' }
    $report.Add([pscustomobject]@{ Skill = 'awesome-ai-ppt'; Action = 'skip'; Reason = $reason })
}

# --- awesome-copilot cherry-pick (missing names only, cap 15) ---
$acRoot = Join-Path $vendor 'awesome-copilot\skills'
$acInstalled = 0
$acCap = 15
if (Test-Path $acRoot) {
    $skillFiles = Get-ChildItem -Path $acRoot -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue
    foreach ($sf in ($skillFiles | Sort-Object FullName)) {
        if ($acInstalled -ge $acCap) { break }
        $name = Get-FrontmatterName -SkillMdPath $sf.FullName
        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        $name = ($name -replace '[^a-zA-Z0-9\-]+', '-').ToLower().Trim('-')
        if ($name.StartsWith('awesome-')) { continue }
        $skillDir = $sf.DirectoryName
        $folderName = Split-Path $skillDir -Leaf
        $junctionName = if ($name -eq $folderName) { $name } else { $folderName }
        $conflict = Test-SkillConflict -Name $junctionName -Installed $installed -ExclusiveMap $exclusiveMap
        if ($conflict) {
            continue
        }
        if (Install-SkillJunction -SkillName $junctionName -TargetDir $skillDir) {
            [void]$installed.Add($junctionName)
            $acInstalled++
            $report.Add([pscustomobject]@{ Skill = $junctionName; Action = 'install'; Reason = 'awesome-copilot' })
        }
    }
}

# --- Skipped by policy (document) ---
@(
    @{ Skill = 'superprogramming'; Reason = 'overlap with brainstorming/writing-plans/ouro-loop/tdd-workflow' },
    @{ Skill = 'presenton'; Reason = 'full app (Docker/API/MCP); not installed as skill' }
) | ForEach-Object {
    $report.Add([pscustomobject]@{ Skill = $_.Skill; Action = 'skip'; Reason = $_.Reason })
}

# --- Report ---
$reportPath = Join-Path $env:USERPROFILE '.ai-workspace\memory\skills-install-batch-report.json'
if (-not $DryRun) {
    $json = $report | ConvertTo-Json -Depth 3
    Write-Utf8NoBomFile -Path $reportPath -Content $json
}
$report | Format-Table -AutoSize
Write-Host "Report: $reportPath"
Write-Host "Installed count this run: $(($report | Where-Object { $_.Action -eq 'install' }).Count)"
