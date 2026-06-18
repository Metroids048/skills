# Sync project skills/ (and .cursor/skills/) to ~/.cursor/skills/ for native Cursor discovery.
param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Prune,
    [switch]$AlsoClaude,
    [string]$StartDir = '',
    [string]$ProjectRoot = ''
)

$ErrorActionPreference = 'Stop'

$excludePathPattern = '(\\|/)(agency-agents-main|\.claude|\.codex|\.gemini|\.continue|\.factory|\.hermes|\.kiro|\.mastracode|\.opencode|\.codebuddy|\.pi|\.cursor)(\\|/)'
$scriptDir = $PSScriptRoot
$scanScript = Join-Path $scriptDir 'scan-project-skills.ps1'
$configPath = Join-Path $scriptDir 'skills-sync.config.json'

function Get-SyncConfig {
    if (-not (Test-Path $configPath)) {
        return [pscustomobject]@{
            excludeNames          = @()
            excludeNamePrefixes   = @()
            excludePathPatterns   = @()
            pruneCodexDuplicates  = $false
            codexDuplicateNames   = @()
            descriptionOverrides  = @{}
            refinementFiles       = @{}
        }
    }
    $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $desc = @{}
    if ($raw.descriptionOverrides) {
        $raw.descriptionOverrides.PSObject.Properties | ForEach-Object { $desc[$_.Name] = $_.Value }
    }
    $ref = @{}
    if ($raw.refinementFiles) {
        $raw.refinementFiles.PSObject.Properties | ForEach-Object { $ref[$_.Name] = $_.Value }
    }
    return [pscustomobject]@{
        excludeNames          = @($raw.excludeNames)
        excludeNamePrefixes   = if ($raw.excludeNamePrefixes) { @($raw.excludeNamePrefixes) } else { @() }
        excludePathPatterns   = @($raw.excludePathPatterns)
        pruneCodexDuplicates  = [bool]$raw.pruneCodexDuplicates
        codexDuplicateNames   = @($raw.codexDuplicateNames)
        descriptionOverrides  = $desc
        refinementFiles       = $ref
    }
}

function Test-ExcludedSkill {
    param(
        [string]$RawName,
        [string]$RelativePath,
        $Config
    )
    if ($Config.excludeNames -contains $RawName) { return $true }
    foreach ($prefix in $Config.excludeNamePrefixes) {
        if ($RawName.StartsWith($prefix)) { return $true }
    }
    foreach ($pat in $Config.excludePathPatterns) {
        $norm = $pat.Replace('/', '\')
        if ($RelativePath -like "*$norm*") { return $true }
    }
    return $false
}

function Get-RefinedSkillBody {
    param(
        [string]$RawName,
        [string]$OriginalContent,
        $Config
    )
    $body = $OriginalContent
    if ($OriginalContent -match '(?ms)^---\s*\r?\n.*?\r?\n---\s*\r?\n(.*)$') {
        $body = $Matches[1]
    }
    elseif ($OriginalContent -match '(?ms)^---\s*\r?\n.*?\r?\n---\s*(.*)$') {
        $body = $Matches[1]
    }
    $key = $RawName
    if ($Config.refinementFiles.ContainsKey($key)) {
        $refPath = Join-Path $scriptDir $Config.refinementFiles[$key]
        if (Test-Path $refPath) {
            return (Get-Content -LiteralPath $refPath -Raw -Encoding UTF8).TrimStart()
        }
    }
    return $body.TrimStart()
}

function Get-FrontmatterYaml {
    param([string]$Content)
    if ($Content -match '(?ms)^---\s*\r?\n(.*?)\r?\n---') {
        return $Matches[1]
    }
    return $null
}

function Get-FrontmatterField {
    param([string]$Content, [string]$Field)
    $yaml = Get-FrontmatterYaml -Content $Content
    if (-not $yaml) { return $null }
    if ($yaml -match "(?m)^${Field}:\s*\|\s*$") {
        $start = $Matches[0]
        $rest = $yaml.Substring($yaml.IndexOf($start) + $start.Length)
        $lines = @()
        foreach ($line in ($rest -split "`r?`n")) {
            if ($line -match '^\S') { break }
            if ($line -match '^(\s+)(.*)$') { $lines += $Matches[2].TrimEnd() }
            elseif ($line.Trim() -eq '') { $lines += '' }
            else { break }
        }
        return (($lines -join ' ').Trim())
    }
    if ($yaml -match "(?m)^${Field}:\s*['""](.+?)['""]\s*$") {
        return $Matches[1].Trim()
    }
    if ($yaml -match "(?m)^${Field}:\s*(.+)$") {
        return $Matches[1].Trim().Trim('"').Trim("'")
    }
    return $null
}

function Get-DisableModelInvocation {
    param([string]$Content)
    $yaml = Get-FrontmatterYaml -Content $Content
    if (-not $yaml) { return $null }
    if ($yaml -match '(?m)^disable-model-invocation:\s*(true|false)\s*$') {
        return $Matches[1].ToLower() -eq 'true'
    }
    return $null
}

function Normalize-SkillName {
    param([string]$Name)
    $n = ($Name -replace '[^a-zA-Z0-9\-]+', '-').ToLower().Trim('-')
    if ($n.Length -gt 64) { $n = $n.Substring(0, 64).TrimEnd('-') }
    if ([string]::IsNullOrWhiteSpace($n)) { $n = 'unnamed-skill' }
    return $n
}

function Find-ProjectRoot {
    param([string]$SeedDir)
    if ($SeedDir) {
        $resolved = Resolve-Path -LiteralPath $SeedDir -ErrorAction SilentlyContinue
        if ($resolved) { return $resolved.Path }
    }
    $dir = (Get-Location).Path
    while ($dir) {
        if (Test-Path (Join-Path $dir 'skills')) { return $dir }
        $parent = Split-Path $dir -Parent
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

function Get-SkillSourceFiles {
    param([string]$Root)

    $sources = @()
    $skillsRoot = Join-Path $Root 'skills'
    if (Test-Path $skillsRoot) {
        $sources += Get-ChildItem -Path $skillsRoot -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $excludePathPattern }
    }
    $cursorSkills = Join-Path $Root '.cursor\skills'
    if (Test-Path $cursorSkills) {
        $sources += Get-ChildItem -Path $cursorSkills -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue
    }
    return $sources
}

function Build-SkillEntries {
    param(
        [string]$Root,
        $Config
    )

    $script:configExcluded = @()
    $raw = @(Get-SkillSourceFiles -Root $Root | ForEach-Object {
            $relative = $_.FullName.Substring($Root.Length).TrimStart('\', '/').Replace('\', '/')
            $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
            $name = Get-FrontmatterField -Content $content -Field 'name'
            $description = Get-FrontmatterField -Content $content -Field 'description'
            $folderName = Split-Path (Split-Path $relative -Parent) -Leaf
            if (-not $name) { $name = $folderName }
            if (Test-ExcludedSkill -RawName $name -RelativePath $relative -Config $Config) {
                $script:configExcluded += $name
                return
            }
            if ($Config.descriptionOverrides.ContainsKey($name)) {
                $description = $Config.descriptionOverrides[$name]
            }
            $missingDesc = [string]::IsNullOrWhiteSpace($description)
            if ($missingDesc) {
                $description = "Skill $folderName. Use when the task matches this skill directory or name."
            }
            if ($description.Length -gt 1024) {
                $description = $description.Substring(0, 1021) + '...'
            }
            [pscustomobject]@{
                RawName              = $name
                Description          = $description
                MissingDescription   = $missingDesc
                Path                 = $relative
                SkillDir             = $_.DirectoryName
                SkillFile            = $_.FullName
                Content              = $content
                RefinedBody          = Get-RefinedSkillBody -RawName $name -OriginalContent $content -Config $Config
                DisableInvocation    = Get-DisableModelInvocation -Content $content
                ConfigExcluded       = $false
            }
        })

    $byName = @{}
    $duplicates = @()
    foreach ($item in ($raw | Sort-Object { $_.Path.Length }, Path)) {
        $key = $item.RawName
        if ($byName.ContainsKey($key)) {
            $duplicates += [pscustomobject]@{
                Name    = $key
                Kept    = $byName[$key].Path
                Skipped = $item.Path
            }
        }
        else {
            $byName[$key] = $item
        }
    }

    $usedNames = @{}
    $entries = @()
    foreach ($item in ($byName.Values | Sort-Object RawName)) {
        $baseName = Normalize-SkillName -Name $item.RawName
        $finalName = $baseName
        $suffix = 2
        while ($usedNames.ContainsKey($finalName)) {
            $suffixStr = "-$suffix"
            $maxBase = 64 - $suffixStr.Length
            $finalName = (Normalize-SkillName -Name $item.RawName).Substring(0, [Math]::Min($maxBase, (Normalize-SkillName -Name $item.RawName).Length)) + $suffixStr
            $suffix++
        }
        $usedNames[$finalName] = $true
        $entries += [pscustomobject]@{
            Name                 = $finalName
            RawName              = $item.RawName
            Renamed              = ($finalName -ne (Normalize-SkillName -Name $item.RawName))
            Description          = $item.Description
            MissingDescription   = $item.MissingDescription
            Path                 = $item.Path
            SkillDir             = $item.SkillDir
            SkillFile            = $item.SkillFile
            Content              = $item.Content
            RefinedBody          = $item.RefinedBody
            DisableInvocation    = $item.DisableInvocation
        }
    }

    return @{
        Entries        = $entries
        Duplicates     = $duplicates
        ConfigExcluded = @($configExcluded | Sort-Object -Unique)
    }
}

function Set-FrontmatterInContent {
    param(
        [string]$Body,
        [string]$Name,
        [string]$Description,
        [bool]$DisableModelInvocation
    )

    $disableLine = if ($DisableModelInvocation) { 'disable-model-invocation: true' } else { 'disable-model-invocation: false' }
    $descEscaped = $Description -replace '\\', '\\\\' -replace '"', '\"'

    $frontmatter = @(
        '---',
        "name: $Name",
        "description: $descEscaped",
        $disableLine,
        '---',
        ''
    ) -join "`n"

    return $frontmatter + $body.TrimStart()
}

function Copy-SkillDirectory {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [string]$SkillMdContent
    )
    if (Test-Path $DestDir) {
        Remove-Item -LiteralPath $DestDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null

    Get-ChildItem -LiteralPath $SourceDir -Force | Where-Object { $_.Name -ne 'SKILL.md' } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestDir $_.Name) -Recurse -Force
    }
    Set-Content -LiteralPath (Join-Path $DestDir 'SKILL.md') -Value $SkillMdContent -Encoding UTF8 -NoNewline:$false
}

function Get-CodexSkillNames {
    $codexRoot = Join-Path $env:USERPROFILE '.codex\skills'
    if (-not (Test-Path $codexRoot)) { return @() }
    return @(Get-ChildItem -Path $codexRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
}

$root = if ($ProjectRoot) {
    (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
}
else {
    Find-ProjectRoot -SeedDir $StartDir
}

if (-not $root) {
    Write-Error 'Could not find project root with skills/ folder.'
}

$globalSkillsRoot = Join-Path $env:USERPROFILE '.cursor\skills'
if (-not (Test-Path $globalSkillsRoot)) {
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $globalSkillsRoot -Force | Out-Null
    }
}

$syncConfig = Get-SyncConfig
$built = Build-SkillEntries -Root $root -Config $syncConfig
$entries = $built.Entries
$duplicates = $built.Duplicates
$configExcluded = $built.ConfigExcluded
$codexNames = @(Get-CodexSkillNames)
$existingGlobal = @()
if (Test-Path $globalSkillsRoot) {
    $existingGlobal = @(Get-ChildItem -Path $globalSkillsRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
}

$synced = @()
$skipped = @()
$overwrites = @()
$codexOverlaps = @()
$highTrigger = @()

foreach ($entry in $entries) {
    $destDir = Join-Path $globalSkillsRoot $entry.Name
    $destExists = Test-Path $destDir
    if ($destExists -and -not $Force -and -not $DryRun) {
        $skipped += $entry.Name
        continue
    }
    if ($destExists) { $overwrites += $entry.Name }
    if ($codexNames -contains $entry.Name) {
        $codexOverlaps += $entry.Name
    }
    if ($entry.RawName -eq 'using-superpowers' -and -not $syncConfig.refinementFiles.ContainsKey('using-superpowers')) {
        $highTrigger += $entry.Name
    }

    $disable = $true
    if ($null -ne $entry.DisableInvocation) {
        $disable = $entry.DisableInvocation
    }
    $newContent = Set-FrontmatterInContent -Body $entry.RefinedBody -Name $entry.Name -Description $entry.Description -DisableModelInvocation $disable

    if ($DryRun) {
        $synced += [pscustomobject]@{
            Name       = $entry.Name
            Source     = $entry.Path
            Action     = if ($destExists) { 'overwrite' } else { 'create' }
            MissingDesc = $entry.MissingDescription
        }
    }
    else {
        Copy-SkillDirectory -SourceDir $entry.SkillDir -DestDir $destDir -SkillMdContent $newContent
        if ($AlsoClaude) {
            $claudeDest = Join-Path (Join-Path $env:USERPROFILE '.claude\skills') $entry.Name
            Copy-SkillDirectory -SourceDir $entry.SkillDir -DestDir $claudeDest -SkillMdContent $newContent
        }
        $synced += $entry.Name
    }
}

$pruned = @()
if ($Prune -and -not $DryRun) {
    $targetNames = @($entries | ForEach-Object { $_.Name })
    foreach ($dir in (Get-ChildItem -Path $globalSkillsRoot -Directory -ErrorAction SilentlyContinue)) {
        if ($dir.Name -notin $targetNames) {
            Remove-Item -LiteralPath $dir.FullName -Recurse -Force
            $pruned += $dir.Name
        }
    }
}

$codexRemoved = @()
if ($syncConfig.pruneCodexDuplicates -and -not $DryRun) {
    $codexRoot = Join-Path $env:USERPROFILE '.codex\skills'
    foreach ($n in $syncConfig.codexDuplicateNames) {
        $dir = Join-Path $codexRoot $n
        if (Test-Path $dir) {
            Remove-Item -LiteralPath $dir -Recurse -Force
            $codexRemoved += $n
        }
    }
}

if (-not $DryRun -and (Test-Path $scanScript)) {
    & $scanScript -StartDir $root -OutputFormat Plain | Out-Null
}

$reportPath = Join-Path $root 'sync-report.md'
$reportLines = @(
    '# Cursor Global Skills Sync Report',
    '',
    "> Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "> Mode: $(if ($DryRun) { 'DryRun' } else { 'Apply' })",
    "> Project: $root",
    "> Target: $globalSkillsRoot",
    '',
    "## Summary",
    '',
    "- Skills synced: $($synced.Count)",
    "- Skipped (exists, no -Force): $($skipped.Count)",
    "- Pruned from global: $($pruned.Count)",
    "- Duplicate names in source (kept shortest path): $($duplicates.Count)",
    "- Overlap with ~/.codex/skills: $($codexOverlaps.Count)",
    "- Excluded by skills-sync.config.json: $($configExcluded.Count)",
    "- Codex duplicates removed: $($codexRemoved.Count)",
    "- Refined skill bodies: $($syncConfig.refinementFiles.Count)",
    '',
    "## Token notes",
    '',
    '- Each synced skill adds `name` + `description` to every Cursor session.',
    '- `disable-model-invocation: true` is set by default so full SKILL.md loads only when matched.',
    '- Do not add hooks that inject the full skills catalog (duplicates native discovery).',
    ''
)

if ($highTrigger.Count -gt 0) {
    $reportLines += '## High trigger rate skills', ''
    $reportLines += 'These skills instruct the agent to invoke skills aggressively:', ''
    foreach ($n in $highTrigger) { $reportLines += "- $n" }
    $reportLines += ''
}

if ($duplicates.Count -gt 0) {
    $reportLines += '## Source duplicates (skipped)', ''
    foreach ($d in $duplicates) {
        $reportLines += "- **$($d.Name)**: kept ``$($d.Kept)``, skipped ``$($d.Skipped)``"
    }
    $reportLines += ''
}

if ($configExcluded.Count -gt 0) {
    $reportLines += '## Excluded by config (not synced)', ''
    foreach ($n in $configExcluded) { $reportLines += "- $n" }
    $reportLines += ''
}

if ($codexRemoved.Count -gt 0) {
    $reportLines += '## Removed from ~/.codex/skills (duplicate of Cursor)', ''
    foreach ($n in ($codexRemoved | Sort-Object)) { $reportLines += "- $n" }
    $reportLines += ''
}

$remainingCodexOverlap = @($codexOverlaps | Where-Object {
        Test-Path (Join-Path (Join-Path $env:USERPROFILE '.codex\skills') $_)
    })
if ($remainingCodexOverlap.Count -gt 0) {
    $reportLines += '## Remaining overlap with ~/.codex/skills', ''
    foreach ($n in ($remainingCodexOverlap | Sort-Object)) { $reportLines += "- $n" }
    $reportLines += ''
}

if ($skipped.Count -gt 0) {
    $reportLines += '## Skipped (use -Force to overwrite)', ''
    foreach ($n in $skipped) { $reportLines += "- $n" }
    $reportLines += ''
}

$missingDescList = @($entries | Where-Object { $_.MissingDescription } | ForEach-Object { $_.Name })
if ($missingDescList.Count -gt 0) {
    $reportLines += '## Auto-generated descriptions', ''
    foreach ($n in $missingDescList) { $reportLines += "- $n" }
    $reportLines += ''
}

if ($DryRun) {
    $reportLines += '## Planned actions', ''
    foreach ($s in $synced) {
        $reportLines += "- [$($s.Action)] **$($s.Name)** from ``$($s.Source)``"
    }
}
else {
    $reportLines += '## Synced skills', ''
    foreach ($n in ($synced | Sort-Object)) { $reportLines += "- $n" }
}

if (-not $DryRun) {
    Set-Content -LiteralPath $reportPath -Value ($reportLines -join "`n") -Encoding UTF8
}

Write-Host "Project: $root"
Write-Host "Target:  $globalSkillsRoot"
Write-Host "Skills:  $($entries.Count) unique (source files deduped)"
Write-Host "Synced:  $($synced.Count)$(if ($DryRun) { ' (dry run)' })"
if ($skipped.Count) { Write-Host "Skipped: $($skipped.Count) (use -Force)" }
if ($pruned.Count) { Write-Host "Pruned:  $($pruned.Count)" }
Write-Host "Report:  $reportPath"

if ($DryRun) {
    $reportLines | Set-Content -LiteralPath $reportPath -Encoding UTF8
}

exit 0
