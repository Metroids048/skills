# Skills quality audit — scans global catalog and emits JSON + Markdown summary.
# Usage: powershell -File scripts/hooks/audit-skills-quality.ps1 [-ProjectRoot "C:\path\to\repo"]
param(
    [string]$ProjectRoot = '',
    [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'
$scriptDir = $PSScriptRoot
$configPath = Join-Path $scriptDir 'skills-sync.config.json'
$intentPath = Join-Path $scriptDir 'intent-profiles.json'
$globalIndexPath = Join-Path $env:USERPROFILE '.claude\global-skills-index.md'

if (-not $ProjectRoot) {
    $ProjectRoot = (Resolve-Path (Join-Path $scriptDir '..\..')).Path
}
if (-not $OutputDir) {
    $OutputDir = Join-Path $ProjectRoot 'docs\skills-audit'
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

function Get-FrontmatterField {
    param([string]$Content, [string]$Field)
    if ($Content -match '(?ms)^---\s*\r?\n(.*?)\r?\n---') {
        $yaml = $Matches[1]
        if ($yaml -match "(?m)^${Field}:\s*['""](.+?)['""]\s*$") { return $Matches[1].Trim() }
        if ($yaml -match "(?m)^${Field}:\s*(.+)$") { return $Matches[1].Trim().Trim('"').Trim("'") }
    }
    return $null
}

function Build-CatalogFromIndex {
    $items = @()
    if (-not (Test-Path $globalIndexPath)) {
        throw "Missing global index: $globalIndexPath — run scan-global-skills.ps1 first."
    }
    $lines = Get-Content -LiteralPath $globalIndexPath -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -notmatch '^\| ([^|]+) \| ([^|]+) \| (.+) \| (.+) \|$') { continue }
        $name = $Matches[1].Trim()
        if ($name -in @('name', '---')) { continue }
        $source = $Matches[2].Trim()
        $desc = $Matches[3].Trim()
        $path = $Matches[4].Trim()
        $items += [pscustomobject]@{
            Name        = $name
            Source      = $source
            Description = $desc
            SkillFile   = $path
        }
    }
    return $items
}

$syncConfig = @{
    alwaysOnSkills           = @('global-session-core', 'requirement-clarifier', 'karpathy-guidelines')
    excludeNames             = @()
    promptKeywordBoosts      = @{}
    descriptionOverrides     = @{}
    conditionalAlwaysOnSkills = @()
}
if (Test-Path $configPath) {
    $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($raw.alwaysOnSkills) { $syncConfig.alwaysOnSkills = @($raw.alwaysOnSkills) }
    if ($raw.excludeNames) { $syncConfig.excludeNames = @($raw.excludeNames) }
    if ($raw.conditionalAlwaysOnSkills) { $syncConfig.conditionalAlwaysOnSkills = @($raw.conditionalAlwaysOnSkills) }
    if ($raw.promptKeywordBoosts) {
        $raw.promptKeywordBoosts.PSObject.Properties | ForEach-Object {
            $syncConfig.promptKeywordBoosts[$_.Name] = @($_.Value)
        }
    }
    if ($raw.descriptionOverrides) {
        $raw.descriptionOverrides.PSObject.Properties | ForEach-Object {
            $syncConfig.descriptionOverrides[$_.Name] = [string]$_.Value
        }
    }
}

$intentProfiles = @()
if (Test-Path $intentPath) {
    $intentRaw = Get-Content -LiteralPath $intentPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($intentRaw.profiles) { $intentProfiles = @($intentRaw.profiles) }
}

$catalog = Build-CatalogFromIndex

$alwaysOn = @($syncConfig.alwaysOnSkills)
foreach ($rule in $syncConfig.conditionalAlwaysOnSkills) {
    if ($rule.skill -and $alwaysOn -notcontains $rule.skill) { $alwaysOn += $rule.skill }
}
$excludeNames = @($syncConfig.excludeNames)
$keywordBoostSkills = @($syncConfig.promptKeywordBoosts.Keys)
$descriptionOverrides = @($syncConfig.descriptionOverrides.Keys)

$intentBoostSkills = [System.Collections.Generic.HashSet[string]]::new()
foreach ($profile in $intentProfiles) {
    if ($profile.skillBoosts) {
        $profile.skillBoosts.PSObject.Properties | ForEach-Object {
            [void]$intentBoostSkills.Add($_.Name)
        }
    }
}

$ruleSkillRefs = @{}
$rulesDir = Join-Path $ProjectRoot '.cursor\rules'
if (Test-Path $rulesDir) {
    Get-ChildItem -Path $rulesDir -Filter '*.mdc' -File | ForEach-Object {
        $text = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
        foreach ($item in $catalog) {
            if ($text -match [regex]::Escape($item.Name)) {
                if (-not $ruleSkillRefs.ContainsKey($item.Name)) { $ruleSkillRefs[$item.Name] = @() }
                $ruleSkillRefs[$item.Name] += $_.Name
            }
        }
    }
}

$namePaths = @{}
foreach ($item in $catalog) {
    if (-not $namePaths.ContainsKey($item.Name)) { $namePaths[$item.Name] = @() }
    if ($item.SkillFile -and (Test-Path $item.SkillFile)) {
        $namePaths[$item.Name] += $item.SkillFile
    }
}

function Test-MojibakeContent {
    param([string]$Text, [string]$SkillName)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
    if ($Text -match '\uFFFD') { return $true }
    # figma2code known corruption marker (U+9229 from mis-encoded UTF-8)
    if ($SkillName -eq 'figma2code' -and $Text -match '\u9229') { return $true }
    return $false
}

function Test-BrokenDescription {
    param([string]$Desc)
    if ([string]::IsNullOrWhiteSpace($Desc)) { return $true }
    if ($Desc -like '*no description*') { return $true }
    if ($Desc.Trim() -match '^>\-?\s*$') { return $true }
    if ($Desc.Length -lt 8) { return $true }
    return $false
}

function Test-CsoCompliantDescription {
    param([string]$Desc)
    if (Test-BrokenDescription -Desc $Desc) { return $false }
    $d = $Desc.Trim()
    if ($d -match '^(Use when|ALWAYS apply|USE FIRST|USE THIS SKILL FIRST|You MUST use)') { return $true }
    if ($d -match 'Triggers on:|Triggers:|Use for |when user|when the user') { return $true }
    return $false
}

function Test-WorkflowInDescription {
    param([string]$Desc)
    if ([string]::IsNullOrWhiteSpace($Desc)) { return $false }
    $patterns = @('\d+-agent', 'pipeline', 'step-by-step', 'coordinates', 'orchestrator', 'loads three-tier', '->', 'stage \d', 'phase \d')
    foreach ($p in $patterns) {
        if ($Desc -match $p) { return $true }
    }
    if ($Desc.Length -gt 500) { return $true }
    return $false
}

$results = @()
$verdictCounts = @{ PASS = 0; IMPROVE = 0; ROUTING_GAP = 0; MERGE = 0; RETIRE = 0; BROKEN = 0 }

foreach ($item in $catalog) {
    if ($excludeNames -contains $item.Name) {
        $verdictCounts.RETIRE++
        $results += [pscustomobject]@{
            name = $item.Name; source = $item.Source; path = $item.SkillFile
            verdict = 'RETIRE'; reasons = @('excludeNames'); descriptionLength = 0
            csoCompliant = $false; workflowInDescription = $false; bodyLines = 0
            mojibake = $false; routed = $false; alwaysOn = $false
            ruleOverlap = @(); duplicatePaths = @(); disableModelInvocation = $null
        }
        continue
    }

    $content = ''; $bodyLines = 0; $mojibake = $false; $hasCompletion = $false; $disableInvocation = $null
    if ($item.SkillFile -and (Test-Path $item.SkillFile)) {
        $content = Get-Content -LiteralPath $item.SkillFile -Raw -Encoding UTF8
        $bodyLines = @($content -split "`n").Count
        $mojibake = Test-MojibakeContent -Text $content -SkillName $item.Name
        $hasCompletion = ($content -match '(?i)(completion|verified|Remaining Risks|fail signal)')
        $disableRaw = Get-FrontmatterField -Content $content -Field 'disable-model-invocation'
        if ($disableRaw) { $disableInvocation = ($disableRaw -eq 'true') }
    }

    $desc = $item.Description
    if ($syncConfig.descriptionOverrides.ContainsKey($item.Name)) {
        $desc = $syncConfig.descriptionOverrides[$item.Name]
    }

    $brokenDesc = Test-BrokenDescription -Desc $desc
    $cso = Test-CsoCompliantDescription -Desc $desc
    $workflowDesc = Test-WorkflowInDescription -Desc $desc
    $alwaysOnFlag = $alwaysOn -contains $item.Name
    $routed = $alwaysOnFlag -or ($keywordBoostSkills -contains $item.Name) -or $intentBoostSkills.Contains($item.Name)
    $ruleOverlap = if ($ruleSkillRefs.ContainsKey($item.Name)) { @($ruleSkillRefs[$item.Name]) } else { @() }
    $dupPaths = if ($namePaths.ContainsKey($item.Name)) { @($namePaths[$item.Name]) } else { @() }

    $reasons = [System.Collections.Generic.List[string]]::new()
    if ($brokenDesc) { [void]$reasons.Add('broken-or-missing-description') }
    if ($mojibake) { [void]$reasons.Add('mojibake') }
    if (-not $cso) { [void]$reasons.Add('not-cso-compliant') }
    if ($workflowDesc) { [void]$reasons.Add('workflow-in-description') }
    if ($desc.Length -gt 500) { [void]$reasons.Add('description-too-long') }
    if ($bodyLines -gt 500) { [void]$reasons.Add('body-too-long') }
    if (-not $routed -and -not $ruleOverlap.Count) { [void]$reasons.Add('routing-gap') }
    if ($dupPaths.Count -gt 2) { [void]$reasons.Add('duplicate-paths') }
    if ($ruleOverlap.Count) { [void]$reasons.Add('rule-overlap') }

    $verdict = 'IMPROVE'
    if ($brokenDesc) { $verdict = 'BROKEN' }
    elseif ($dupPaths.Count -gt 2) { $verdict = 'MERGE' }
    elseif ($mojibake) { $verdict = 'IMPROVE' }
    elseif ($cso -and -not $workflowDesc -and $routed -and $bodyLines -le 500) { $verdict = 'PASS' }
    elseif (-not $routed -and -not $alwaysOnFlag -and -not $ruleOverlap.Count) { $verdict = 'ROUTING_GAP' }

    $verdictCounts[$verdict]++
    $results += [pscustomobject]@{
        name = $item.Name; source = $item.Source; path = $item.SkillFile; verdict = $verdict
        reasons = @($reasons); descriptionLength = $desc.Length; csoCompliant = $cso
        workflowInDescription = $workflowDesc; bodyLines = $bodyLines; mojibake = $mojibake
        routed = $routed; alwaysOn = $alwaysOnFlag; ruleOverlap = $ruleOverlap
        duplicatePaths = $dupPaths; disableModelInvocation = $disableInvocation
    }
}

$dateStamp = Get-Date -Format 'yyyy-MM-dd'
$jsonPath = Join-Path $OutputDir "$dateStamp-inventory.json"
$mdPath = Join-Path $OutputDir "$dateStamp-summary.md"

[ordered]@{
    evaluatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    projectRoot = $ProjectRoot; totalSkills = $results.Count; verdictCounts = $verdictCounts; skills = $results
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$mdLines = @(
    "# Skills Quality Audit - $dateStamp",
    "",
    "Total skills: $($results.Count)",
    "",
    "PASS: $($verdictCounts.PASS)",
    "IMPROVE: $($verdictCounts.IMPROVE)",
    "ROUTING_GAP: $($verdictCounts.ROUTING_GAP)",
    "MERGE: $($verdictCounts.MERGE)",
    "RETIRE: $($verdictCounts.RETIRE)",
    "BROKEN: $($verdictCounts.BROKEN)"
)
Set-Content -LiteralPath $mdPath -Value ($mdLines -join "`n") -Encoding UTF8

Write-Host "Audit: $($results.Count) skills -> $jsonPath"
