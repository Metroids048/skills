# Global skills scanner for Claude Code / Codex hooks.
# Scans ~/.cursor/skills, ~/.claude/skills, ~/.codex/skills, optional project skills/.
param(
    [ValidateSet('Cursor', 'Claude', 'Codex', 'Plain')]
    [string]$OutputFormat = 'Plain',
    [ValidateSet('SessionStart', 'UserPromptSubmit', 'Plain')]
    [string]$HookEvent = 'Plain',
    [int]$TopMatches = 8,
    [string]$StartDir = '',
    [string]$UserPrompt = ''
)

$ErrorActionPreference = 'Stop'

$gateCorePath = Join-Path $PSScriptRoot 'clarification-gate-core.ps1'
if (-not (Test-Path $gateCorePath)) {
    $gateCorePath = Join-Path $env:USERPROFILE '.ai-workspace\scripts\clarification-gate-core.ps1'
}
if (Test-Path $gateCorePath) { . $gateCorePath }

$script:HookPayloadCache = $null

$excludePathPattern = '(\\|/)(agency-agents-main|\.claude|\.codex|\.gemini|\.continue|\.factory|\.hermes|\.kiro|\.mastracode|\.opencode|\.codebuddy|\.pi|\.cursor)(\\|/)'
$globalIndexPath = Join-Path $env:USERPROFILE '.claude\global-skills-index.md'
$globalMemoryRoot = Join-Path $env:USERPROFILE '.ai-workspace\memory'
$sourcePriority = @('cursor', 'claude', 'codex', 'project')

function Get-GlobalMemoryPaths {
    $paths = [ordered]@{
        userMemory    = Join-Path $globalMemoryRoot 'user-memory.md'
        taskHistory   = Join-Path $globalMemoryRoot 'global-task-history.md'
        decisionsLog  = Join-Path $globalMemoryRoot 'global-decisions-log.md'
        projectsRegistry = Join-Path $globalMemoryRoot 'projects-registry.md'
    }
    return $paths
}

function Find-ProjectMemoryOverlay {
    param([string]$SeedDir)

    $candidates = @()
    if ($SeedDir) { $candidates += $SeedDir }
    if ($env:CLAUDE_PROJECT_DIR) { $candidates += $env:CLAUDE_PROJECT_DIR }
    if ($env:CURSOR_PROJECT_DIR) { $candidates += $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { $candidates += $env:CODEX_PROJECT_DIR }
    $candidates += (Get-Location).Path

    $seen = @{}
    foreach ($start in $candidates) {
        if ([string]::IsNullOrWhiteSpace($start)) { continue }
        $dir = (Resolve-Path -LiteralPath $start -ErrorAction SilentlyContinue).Path
        if (-not $dir) { $dir = $start }
        while ($dir) {
            if ($seen.ContainsKey($dir)) { break }
            $seen[$dir] = $true
            $overlay = Join-Path $dir '.github\agent\memory\project-memory.md'
            if (Test-Path $overlay) { return $overlay }
            $parent = Split-Path $dir -Parent
            if (-not $parent -or $parent -eq $dir) { break }
            $dir = $parent
        }
    }
    return $null
}

function Get-SkillsSyncConfig {
    $candidates = @(
        (Join-Path $PSScriptRoot 'skills-sync.config.json'),
        (Join-Path $env:USERPROFILE '.ai-workspace\scripts\skills-sync.config.json'),
        (Join-Path $env:USERPROFILE '.claude\scripts\skills-sync.config.json'),
        (Join-Path $env:USERPROFILE '.cursor\hooks\skills-sync.config.json')
    )
    $configPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $configPath) {
        return [pscustomobject]@{
            ConfigPath               = $null
            alwaysOnSkills           = @('global-session-core')
            conditionalAlwaysOnSkills = @()
            promptKeywordBoosts    = @{}
            intentProfilesFile     = 'intent-profiles.json'
            intentMatchMinScore    = 3
            intentSkillBoostFloor  = 20
        }
    }
    $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $alwaysOn = @()
    if ($raw.alwaysOnSkills) { $alwaysOn = @($raw.alwaysOnSkills) }
    if ($alwaysOn.Count -eq 0) { $alwaysOn = @('global-session-core') }
    $boosts = @{}
    if ($raw.promptKeywordBoosts) {
        $raw.promptKeywordBoosts.PSObject.Properties | ForEach-Object {
            $boosts[$_.Name] = @($_.Value)
        }
    }
    $conditional = @()
    if ($raw.conditionalAlwaysOnSkills) { $conditional = @($raw.conditionalAlwaysOnSkills) }
    return [pscustomobject]@{
        ConfigPath                = $configPath
        alwaysOnSkills            = $alwaysOn
        conditionalAlwaysOnSkills = $conditional
        promptKeywordBoosts       = $boosts
        intentProfilesFile        = if ($raw.intentProfilesFile) { [string]$raw.intentProfilesFile } else { 'intent-profiles.json' }
        intentMatchMinScore       = if ($raw.intentMatchMinScore) { [int]$raw.intentMatchMinScore } else { 3 }
        intentSkillBoostFloor     = if ($raw.intentSkillBoostFloor) { [int]$raw.intentSkillBoostFloor } else { 20 }
    }
}

function Find-ProjectCodingGuardrails {
    param([string]$SeedDir)

    $candidates = @()
    if ($SeedDir) { $candidates += $SeedDir }
    if ($env:CLAUDE_PROJECT_DIR) { $candidates += $env:CLAUDE_PROJECT_DIR }
    if ($env:CURSOR_PROJECT_DIR) { $candidates += $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { $candidates += $env:CODEX_PROJECT_DIR }
    $candidates += (Get-Location).Path

    $seen = @{}
    foreach ($start in $candidates) {
        if ([string]::IsNullOrWhiteSpace($start)) { continue }
        $dir = (Resolve-Path -LiteralPath $start -ErrorAction SilentlyContinue).Path
        if (-not $dir) { $dir = $start }
        while ($dir) {
            if ($seen.ContainsKey($dir)) { break }
            $seen[$dir] = $true
            $agents = Join-Path $dir 'AGENTS.md'
            $memoryDir = Join-Path $dir '.github\agent\memory'
            if ((Test-Path $agents) -or (Test-Path $memoryDir)) {
                return [pscustomobject]@{
                    Root        = $dir
                    HasAgents   = Test-Path $agents
                    HasMemory   = Test-Path $memoryDir
                }
            }
            $parent = Split-Path $dir -Parent
            if (-not $parent -or $parent -eq $dir) { break }
            $dir = $parent
        }
    }
    return $null
}

function Resolve-EffectiveAlwaysOnNames {
    param(
        [array]$BaseAlwaysOn,
        [array]$ConditionalRules,
        [object]$CodingGuardrails
    )

    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($n in $BaseAlwaysOn) {
        if ($n -and $names -notcontains $n) { [void]$names.Add($n) }
    }
    if ($CodingGuardrails -and $ConditionalRules) {
        foreach ($rule in $ConditionalRules) {
            if ($rule.trigger -eq 'projectCodingGuardrails' -and $rule.skill) {
                if ($names -notcontains $rule.skill) { [void]$names.Add([string]$rule.skill) }
            }
        }
    }
    return @($names)
}

function Get-IntentProfiles {
    param([object]$SyncConfig)

    $candidates = @()
    if ($SyncConfig.ConfigPath) {
        $candidates += Join-Path (Split-Path $SyncConfig.ConfigPath -Parent) $SyncConfig.intentProfilesFile
    }
    $candidates += @(
        (Join-Path $PSScriptRoot 'intent-profiles.json'),
        (Join-Path $env:USERPROFILE '.ai-workspace\scripts\intent-profiles.json'),
        (Join-Path $env:USERPROFILE '.claude\scripts\intent-profiles.json'),
        (Join-Path $env:USERPROFILE '.cursor\hooks\intent-profiles.json')
    )
    $profilePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $profilePath) { return @() }
    try {
        $raw = Get-Content -LiteralPath $profilePath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($raw.profiles) { return @($raw.profiles) }
    }
    catch { }
    return @()
}

function Get-PromptTokens {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) { return @() }
    $lower = $Text.ToLowerInvariant()
    $tokens = [System.Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($lower, '[\p{L}\p{N}]+')) {
        if ($m.Value.Length -gt 1) { [void]$tokens.Add($m.Value) }
    }
    return @($tokens)
}

function Test-IntentSignalHit {
    param(
        [string]$PromptLower,
        [string]$Signal
    )

    if ([string]::IsNullOrWhiteSpace($Signal)) { return $false }
    $sig = $Signal.ToLowerInvariant().Trim()
    if ($sig.StartsWith('regex:')) {
        $pattern = $sig.Substring(6)
        try { return [regex]::IsMatch($PromptLower, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) }
        catch { return $false }
    }
    return $PromptLower.Contains($sig)
}

function Get-MessageTypeSignals {
    param([object]$SyncConfig)

    $candidates = @()
    if ($SyncConfig.ConfigPath) {
        $candidates += Join-Path (Split-Path $SyncConfig.ConfigPath -Parent) 'message-type-signals.json'
    }
    $candidates += @(
        (Join-Path $PSScriptRoot 'message-type-signals.json'),
        (Join-Path $env:USERPROFILE '.ai-workspace\scripts\message-type-signals.json')
    )
    $path = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $path) { return $null }
    try {
        return Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        return $null
    }
}

function Classify-UserMessageType {
    param(
        [string]$UserPrompt,
        [object]$SyncConfig = $null
    )

    if ([string]::IsNullOrWhiteSpace($UserPrompt)) {
        return [pscustomobject]@{ Type = 'unknown'; Label = 'unknown'; ConsultationScore = 0; ImplementationScore = 0 }
    }

    $cfg = Get-MessageTypeSignals -SyncConfig $SyncConfig
    $consultSignals = if ($cfg.consultationSignals) { @($cfg.consultationSignals) } else { @('why', 'explain', 'what are') }
    $implSignals = if ($cfg.implementationSignals) { @($cfg.implementationSignals) } else { @('implement', 'fix', 'build') }
    $directSignals = if ($cfg.directExecuteSignals) { @($cfg.directExecuteSignals) } else { @() }
    $labels = if ($cfg.labels) { $cfg.labels } else { @{ A = 'consultation'; B = 'fuzzy implementation' } }

    $p = $UserPrompt.ToLowerInvariant()
    $cScore = 0
    $iScore = 0
    foreach ($s in $consultSignals) {
        if ([string]::IsNullOrWhiteSpace($s)) { continue }
        if ($p.Contains($s.ToLowerInvariant())) { $cScore += 2 }
    }
    foreach ($s in $implSignals) {
        if ([string]::IsNullOrWhiteSpace($s)) { continue }
        if ($p.Contains($s.ToLowerInvariant())) { $iScore += 2 }
    }
    foreach ($s in $directSignals) {
        if ([string]::IsNullOrWhiteSpace($s)) { continue }
        if ($p.Contains($s.ToLowerInvariant())) { $iScore += 4 }
    }
    if ($p -match '[?]\s*$' -or $p -match '\uFF1F\s*$') { $cScore += 3 }

    $type = 'B'
    $label = [string]$labels.B
    if ($iScore -eq 0 -and $cScore -ge 2) {
        $type = 'A'
        $label = [string]$labels.A
    }
    elseif ($iScore -ge 4 -and $cScore -le 1) {
        $type = 'B'
        $label = [string]$labels.B
    }
    elseif ($iScore -ge 2 -and $cScore -ge 2) {
        $type = 'B'
        $label = if ($labels.B_mixed) { [string]$labels.B_mixed } else { [string]$labels.B }
    }
    elseif ($iScore -ge 6) {
        $type = 'C'
        $label = [string]$labels.C
    }

    return [pscustomobject]@{
        Type                = $type
        Label               = $label
        ConsultationScore   = $cScore
        ImplementationScore = $iScore
    }
}

function Detect-UserIntents {
    param(
        [string]$UserPrompt,
        [array]$IntentProfiles
    )

    if ([string]::IsNullOrWhiteSpace($UserPrompt) -or $IntentProfiles.Count -eq 0) { return @() }

    $promptLower = $UserPrompt.ToLowerInvariant()
    $detected = @()

    foreach ($profile in $IntentProfiles) {
        $hits = 0
        $signals = @()
        if ($profile.signals) { $signals += @($profile.signals) }
        if ($profile.regexSignals) {
            foreach ($rx in $profile.regexSignals) { $signals += "regex:$rx" }
        }
        foreach ($sig in $signals) {
            if (Test-IntentSignalHit -PromptLower $promptLower -Signal $sig) { $hits++ }
        }

        if ($hits -gt 0) {
            $confidence = [math]::Min(100, 20 + ($hits * 15))
            $boosts = @{}
            if ($profile.skillBoosts) {
                $profile.skillBoosts.PSObject.Properties | ForEach-Object {
                    $boosts[$_.Name] = [int]$_.Value
                }
            }
            $detected += [pscustomobject]@{
                Id          = [string]$profile.id
                Label       = if ($profile.label) { [string]$profile.label } else { [string]$profile.id }
                Hits        = $hits
                Confidence  = $confidence
                SkillBoosts = $boosts
            }
        }
    }

    return @($detected | Sort-Object Confidence -Descending)
}

function Resolve-AlwaysOnSkillPaths {
    param(
        [array]$CatalogItems,
        [array]$AlwaysOnNames
    )

    $resolved = @()
    foreach ($name in $AlwaysOnNames) {
        $match = $CatalogItems | Where-Object { $_.Name -eq $name } | Select-Object -First 1
        if ($match) {
            $resolved += $match
            continue
        }
        $cursorPath = Join-Path (Join-Path $env:USERPROFILE '.cursor\skills') "$name\SKILL.md"
        if (Test-Path $cursorPath) {
            $resolved += [pscustomobject]@{
                Name        = $name
                Description = 'always-on session core'
                SkillFile   = $cursorPath
                Source      = 'cursor'
            }
        }
    }
    return $resolved
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

function Find-ProjectRootWithSkills {
    param([string]$SeedDir)

    $candidates = @()
    if ($SeedDir) { $candidates += $SeedDir }
    if ($env:CLAUDE_PROJECT_DIR) { $candidates += $env:CLAUDE_PROJECT_DIR }
    if ($env:CURSOR_PROJECT_DIR) { $candidates += $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { $candidates += $env:CODEX_PROJECT_DIR }
    $candidates += (Get-Location).Path

    $seen = @{}
    foreach ($start in $candidates) {
        if ([string]::IsNullOrWhiteSpace($start)) { continue }
        $dir = (Resolve-Path -LiteralPath $start -ErrorAction SilentlyContinue).Path
        if (-not $dir) { $dir = $start }
        while ($dir) {
            if ($seen.ContainsKey($dir)) { break }
            $seen[$dir] = $true
            $skillsRoot = Join-Path $dir 'skills'
            if (Test-Path $skillsRoot) {
                $hasSkill = Get-ChildItem -Path $skillsRoot -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.FullName -notmatch $excludePathPattern } |
                    Select-Object -First 1
                if ($hasSkill) { return $dir }
            }
            $parent = Split-Path $dir -Parent
            if (-not $parent -or $parent -eq $dir) { break }
            $dir = $parent
        }
    }
    return $null
}

function Get-GlobalSkillRoots {
    param([string]$ProjectRoot)

    $roots = [ordered]@{}
    $cursor = Join-Path $env:USERPROFILE '.cursor\skills'
    $claude = Join-Path $env:USERPROFILE '.claude\skills'
    $codex = Join-Path $env:USERPROFILE '.codex\skills'
    if (Test-Path $cursor) { $roots['cursor'] = $cursor }
    if (Test-Path $claude) { $roots['claude'] = $claude }
    if (Test-Path $codex) { $roots['codex'] = $codex }
    if ($ProjectRoot) {
        $projSkills = Join-Path $ProjectRoot 'skills'
        if (Test-Path $projSkills) { $roots['project'] = $projSkills }
    }
    return $roots
}

function Get-SkillFilesFromRoot {
    param(
        [string]$RootPath,
        [string]$SourceTag,
        [string]$ProjectRoot
    )

    if ($SourceTag -eq 'project') {
        return @(Get-ChildItem -Path $RootPath -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch $excludePathPattern })
    }
    return @(Get-ChildItem -Path $RootPath -Filter 'SKILL.md' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -eq $RootPath -or $_.Directory.Parent.FullName -eq $RootPath })
}

function Build-GlobalCatalog {
    param([string]$ProjectRoot)

    $allByName = @{}
    $roots = Get-GlobalSkillRoots -ProjectRoot $ProjectRoot

    foreach ($tag in $sourcePriority) {
        if (-not $roots.Contains($tag)) { continue }
        $rootPath = $roots[$tag]
        $files = if ($tag -eq 'project') {
            Get-ChildItem -Path $rootPath -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch $excludePathPattern }
        }
        else {
            Get-ChildItem -Path $rootPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $skillFile = Join-Path $_.FullName 'SKILL.md'
                if (Test-Path $skillFile) { Get-Item -LiteralPath $skillFile }
            }
        }

        foreach ($file in $files) {
            $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
            $name = Get-FrontmatterField -Content $content -Field 'name'
            if (-not $name) { $name = Split-Path $file.DirectoryName -Leaf }
            $description = Get-FrontmatterField -Content $content -Field 'description'
            if (-not $description) { $description = '(no description)' }

            if (-not $allByName.ContainsKey($name)) {
                $allByName[$name] = [pscustomobject]@{
                    Name        = $name
                    Description = $description
                    SkillFile   = $file.FullName
                    Source      = $tag
                }
            }
        }
    }

    return @($allByName.Values | Sort-Object Name)
}

function Write-GlobalSkillsIndex {
    param([array]$Items)

    $indexDir = Split-Path $globalIndexPath -Parent
    if (-not (Test-Path $indexDir)) {
        New-Item -ItemType Directory -Path $indexDir -Force | Out-Null
    }
    $lines = @(
        '# Global Skills Index',
        '',
        '> Auto-generated by scan-global-skills.ps1. Do not edit by hand.',
        "> Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
        "> Total: $($Items.Count) skills",
        '',
        '| name | source | description | path |',
        '| --- | --- | --- | --- |'
    )
    foreach ($item in $Items) {
        $desc = $item.Description -replace '\|', '\|' -replace "`r?`n", ' '
        $lines += "| $($item.Name) | $($item.Source) | $desc | $($item.SkillFile) |"
    }
    Set-Content -LiteralPath $globalIndexPath -Value ($lines -join "`n") -Encoding UTF8
}

function Read-HookPayloadOnce {
    if ($script:HookPayloadCache) { return $script:HookPayloadCache }

    try { [Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false) } catch { }

    $stdinJson = ''
    try { $stdinJson = [Console]::In.ReadToEnd() }
    catch { $stdinJson = '' }
    if (-not $stdinJson.Trim()) {
        try { $stdinJson = ($input | Out-String) }
        catch { $stdinJson = '' }
    }
    if (-not $stdinJson.Trim()) {
        $script:HookPayloadCache = $null
        return $null
    }
    try {
        $script:HookPayloadCache = $stdinJson | ConvertFrom-Json
        return $script:HookPayloadCache
    }
    catch {
        $script:HookPayloadCache = $null
        return $null
    }
}

function Get-HookUserPrompt {
    param([string]$Override = '')

    if (-not [string]::IsNullOrWhiteSpace($Override)) {
        return $Override
    }

    $hookData = Read-HookPayloadOnce
    if (-not $hookData) { return $null }
    if ($hookData.prompt) { return [string]$hookData.prompt }
    if ($hookData.user_message) { return [string]$hookData.user_message }
    return $null
}

function Get-HookWorkingDirectory {
    param([string]$StartDir = '')

    $hookData = Read-HookPayloadOnce
    if ($hookData) {
        if ($hookData.PSObject.Properties.Name -contains 'cwd' -and $hookData.cwd) {
            return [string]$hookData.cwd
        }
        if ($hookData.PSObject.Properties.Name -contains 'workspace_roots' -and $hookData.workspace_roots) {
            return [string]$hookData.workspace_roots[0]
        }
    }
    if ($StartDir) { return $StartDir }
    if ($env:CLAUDE_PROJECT_DIR) { return $env:CLAUDE_PROJECT_DIR }
    if ($env:CURSOR_PROJECT_DIR) { return $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { return $env:CODEX_PROJECT_DIR }
    return (Get-Location).Path
}

function Get-DescriptionTriggerPhrases {
    param([string]$Description)

    $phrases = [System.Collections.Generic.List[string]]::new()
    if ([string]::IsNullOrWhiteSpace($Description)) { return @() }

    $lower = $Description.ToLowerInvariant()
    foreach ($marker in @('use when', 'triggers on:', 'triggers:', 'when user', 'when the user')) {
        $idx = $lower.IndexOf($marker)
        if ($idx -ge 0) {
            $chunk = $Description.Substring($idx)
            foreach ($part in ($chunk -split '[,;.]| and | or ')) {
                $p = $part.Trim().ToLowerInvariant()
                if ($p.Length -ge 4 -and $p.Length -le 80) { [void]$phrases.Add($p) }
            }
        }
    }
    return @($phrases | Select-Object -Unique)
}

function Test-PartialTokenOverlap {
    param(
        [string]$PromptLower,
        [string]$Token
    )

    if ($Token.Length -lt 4) { return $false }
    if ($promptLower.Contains($Token)) { return $true }
    foreach ($pw in (Get-PromptTokens -Text $PromptLower)) {
        if ($pw.Length -lt 3) { continue }
        if ($Token.StartsWith($pw) -or $pw.StartsWith($Token)) { return $true }
        if ($Token.Length -ge 4 -and $pw.Length -ge 4) {
            $minLen = [math]::Min($Token.Length, $pw.Length)
            $prefixLen = 0
            for ($i = 0; $i -lt $minLen; $i++) {
                if ($Token[$i] -eq $pw[$i]) { $prefixLen++ } else { break }
            }
            if ($prefixLen -ge [math]::Max(3, [int]($minLen * 0.7))) { return $true }
        }
    }
    return $false
}

function Score-SkillAgainstPrompt {
    param(
        [array]$Skills,
        [string]$UserPrompt,
        [hashtable]$PromptKeywordBoosts = @{},
        [array]$DetectedIntents = @(),
        [int]$MinScore = 5,
        [int]$IntentBoostFloor = 20
    )

    if ([string]::IsNullOrWhiteSpace($UserPrompt)) { return @() }

    $promptLower = $UserPrompt.ToLowerInvariant()
    $promptWords = Get-PromptTokens -Text $promptLower
    $promptWordSet = @{}
    foreach ($w in $promptWords) { $promptWordSet[$w] = $true }

    $intentBoosts = @{}
    foreach ($intent in $DetectedIntents) {
        foreach ($key in $intent.SkillBoosts.Keys) {
            if (-not $intentBoosts.ContainsKey($key)) { $intentBoosts[$key] = 0 }
            $intentBoosts[$key] = [math]::Max($intentBoosts[$key], $intent.SkillBoosts[$key])
        }
    }

    $effectiveMin = if ($DetectedIntents.Count -gt 0) { [math]::Min($MinScore, 3) } else { $MinScore }

    $scored = @()
    foreach ($skill in $Skills) {
        $score = 0
        $reasons = [System.Collections.Generic.List[string]]::new()

        $nameLower = $skill.Name.ToLowerInvariant()
        $nameTokens = $nameLower -split '[-_\s]+' | Where-Object { $_.Length -gt 2 }
        foreach ($token in $nameTokens) {
            if ($promptLower.Contains($token)) {
                $score += 5
                [void]$reasons.Add('name')
            }
        }
        if ($promptLower.Contains($nameLower) -and $nameLower.Length -gt 5) {
            $score += 10
            [void]$reasons.Add('name-full')
        }

        $descLower = $skill.Description.ToLowerInvariant()
        $hitCount = 0
        $seenDescWords = @{}
        foreach ($m in [regex]::Matches($descLower, '[\p{L}\p{N}]+')) {
            $val = $m.Value
            if ($val.Length -gt 3 -and -not $seenDescWords.ContainsKey($val)) {
                $seenDescWords[$val] = $true
                if ($promptWordSet.ContainsKey($val)) {
                    $hitCount++
                }
                elseif (Test-PartialTokenOverlap -PromptLower $promptLower -Token $val) {
                    $hitCount++
                }
                if ($seenDescWords.Count -gt 50) { break }
            }
        }
        if ($hitCount -gt 0) {
            $score += $hitCount * 2
            [void]$reasons.Add("desc:$hitCount")
        }

        foreach ($phrase in (Get-DescriptionTriggerPhrases -Description $skill.Description)) {
            $phraseHits = 0
            foreach ($pw in $promptWords) {
                if ($phrase.Contains($pw) -and $pw.Length -gt 2) { $phraseHits++ }
            }
            if ($phraseHits -ge 2 -or ($phrase.Length -le 30 -and $promptLower.Contains($phrase))) {
                $score += 8
                [void]$reasons.Add('trigger-phrase')
                break
            }
        }

        if ($PromptKeywordBoosts.ContainsKey($skill.Name)) {
            foreach ($kw in $PromptKeywordBoosts[$skill.Name]) {
                if ([string]::IsNullOrWhiteSpace($kw)) { continue }
                $kwLower = $kw.ToLowerInvariant()
                if ($promptLower.Contains($kwLower) -or (Test-PartialTokenOverlap -PromptLower $promptLower -Token $kwLower)) {
                    $score += 25
                    [void]$reasons.Add('keyword')
                    break
                }
            }
        }

        if ($intentBoosts.ContainsKey($skill.Name)) {
            $score += $intentBoosts[$skill.Name]
            [void]$reasons.Add("intent:$($intentBoosts[$skill.Name])")
        }

        $include = $score -ge $effectiveMin
        if (-not $include -and $intentBoosts.ContainsKey($skill.Name) -and $intentBoosts[$skill.Name] -ge $IntentBoostFloor) {
            $include = $true
        }

        if ($include) {
            $scored += [pscustomobject]@{
                Name        = $skill.Name
                Description = if ($skill.Description.Length -gt 200) {
                    $skill.Description.Substring(0, 197) + '...'
                }
                else { $skill.Description }
                SkillFile   = $skill.SkillFile
                Score       = $score
                MatchReason = ($reasons -join ',')
            }
        }
    }

    return @($scored | Sort-Object Score -Descending | Select-Object -First $TopMatches)
}

function Build-SessionStartContext {
    param(
        [array]$Items,
        [array]$AlwaysOnItems,
        [string]$ProjectMemoryOverlay,
        [object]$CodingGuardrails = $null
    )

    $mem = Get-GlobalMemoryPaths
    $lines = @(
        '## Global Skills (SessionStart)',
        '',
        "Total skills available: **$($Items.Count)** (scanned from ~/.cursor/skills and other global dirs).",
        "Full index: ``$globalIndexPath``",
        ''
    )

    if ($AlwaysOnItems.Count -gt 0) {
        $lines += '**ALWAYS ON — Read these SKILL.md files before any other tools this session:**'
        $lines += ''
        foreach ($a in $AlwaysOnItems) {
            $lines += "- **$($a.Name)**: ``$($a.SkillFile)``"
        }
        $lines += ''
    }

    if (Test-Path $mem.userMemory) {
        $lines += '**Global memory (Read before coding tasks):**'
        $lines += ''
        $lines += "- **user-memory**: ``$($mem.userMemory)``"
        if (Test-Path $mem.taskHistory) {
            $lines += "- **global-task-history** (recent entries): ``$($mem.taskHistory)``"
        }
        if (Test-Path $mem.decisionsLog) {
            $lines += "- **global-decisions-log**: ``$($mem.decisionsLog)``"
        }
        $lines += ''
        $lines += 'PDCA: use `ai-coding-ok` — update global-task-history after every coding task.'
        $lines += ''
    }

    if ($ProjectMemoryOverlay) {
        $lines += "**Project overlay (team memory):** Read ``$ProjectMemoryOverlay`` if task touches this repo's conventions."
        $lines += ''
    }

    if ($CodingGuardrails) {
        $lines += "**Project coding guardrails detected** at ``$($CodingGuardrails.Root)`` — ``ai-coding-ok`` is in ALWAYS ON for this session (AGENTS.md / .github/agent/memory/)."
        $lines += ''
    }

    $lines += '**Context hygiene:** Long sessions → Headroom MCP (`headroom_compress` / `retrieve`) or `/compact` at logical milestones; savethetokens Lean Mode is in `global-session-core`.'
    $lines += ''

    $globalAgents = Join-Path $env:USERPROFILE '.claude\AGENTS.md'
    if (Test-Path $globalAgents) {
        $lines += "Default rules: ``$globalAgents`` (project AGENTS.md overrides if present)."
        $lines += ''
    }

    $lines += @(
        '**Zero-to-one gate (strict):** 新模块 / 大范围「帮我做…」→ Read ``~/.cursor/skills/zero-to-one-gate/SKILL.md`` + ``brainstorming`` before Write/Edit. Cursor: ``~/.cursor/rules/zero-to-one-gate.mdc``. Codex/Claude: ``~/.claude/AGENTS.md`` Zero-to-one section.',
        '',
        '**Maximum permission scope:** max permission / quan bu jie jue = fix current task only; do NOT delete CC Switch or run _remove-* without explicit user OK. Rule: ~/.cursor/rules/maximum-permission-scope.mdc ; ~/.claude/AGENTS.md Maximum permission section.',
        '',
        '**Required workflow for every task:**',
        '1. Read always-on skills + global memory paths above first.',
        '2. **Intent-first routing:** Match user meaning (not exact keywords) — hook intent profiles + skill descriptions + global index.',
        '3. For each additional applicable skill, **Read** the absolute path to `SKILL.md` before using other tools.',
        '4. Follow skill bodies strictly; mention enabled skill names in one short line at reply start (`Skills: ...`).',
        '5. Before claiming done: follow `global-delivery-gate` skill for verification.',
        '6. Priority: user instruction > matched global skill > built-in skill > default.',
        '',
        '**Vibe coding / fuzzy implementation:** B-class → requirement-clarifier + vibe-coding-bridge.md → Mini-Spec S4.5 → user confirm → S12 → execute.',
        ''
    )
    return ($lines -join "`n")
}

function Get-RequirementClarifierCompanionPaths {
    $skillDirs = @(
        Join-Path (Join-Path $env:USERPROFILE '.cursor\skills') 'requirement-clarifier'
    )
    $proj = Find-ProjectCodingGuardrails -SeedDir ''
    if ($proj) {
        $skillDirs += Join-Path $proj.Root 'skills\requirement-clarifier'
    }
    foreach ($dir in $skillDirs) {
        $bridge = Join-Path $dir 'vibe-coding-bridge.md'
        if (Test-Path $bridge) {
            return [pscustomobject]@{
                Bridge           = $bridge
                MiniSpec         = Join-Path $dir 'mini-spec-template.md'
                QuestionBank     = Join-Path $dir 'question-bank-zh.md'
                OutputTemplate   = Join-Path $dir 'output-template.md'
                InterviewProtocol = Join-Path $dir 'interview-protocol.md'
                Guardrails       = Join-Path $dir 'clarification-guardrails.md'
                SkillChainMap    = Join-Path $dir 'skill-chain-map.md'
            }
        }
    }
    return $null
}

function Test-ShouldUseVibeCodingBridge {
    param(
        [object]$MessageType,
        [array]$DetectedIntents
    )

    if (-not $MessageType) { return $false }
    if ($MessageType.Type -ne 'B') { return $false }
    $vibeIntentIds = @('vibe_coding', 'fuzzy_requirement', 'coding_task', 'greenfield_build')
    foreach ($intent in $DetectedIntents) {
        if ($vibeIntentIds -contains $intent.Id) { return $true }
    }
    if ($MessageType.ImplementationScore -ge 2) { return $true }
    return $false
}

function Build-UserPromptContext {
    param(
        [array]$AllItems,
        [array]$Matches,
        [array]$AlwaysOnItems,
        [string]$UserPrompt,
        [array]$DetectedIntents = @(),
        [object]$MessageType = $null
    )

    $lines = @(
        '## Global Skills (matched)',
        '',
        "Scanned **$($AllItems.Count)** global skills. Index: ``$globalIndexPath``",
        ''
    )

    if ($AlwaysOnItems.Count -gt 0) {
        $lines += '**ALWAYS ON (every prompt — Read before any tools):**'
        $lines += ''
        foreach ($a in $AlwaysOnItems) {
            $lines += "- **$($a.Name)**: ``$($a.SkillFile)``"
        }
        $lines += ''
        if ($MessageType -and $MessageType.Type -eq 'A') {
            $lines += '**Requirement clarifier (Type A consultation):** Light confirm (1-2 sentences) + direct answer. No full S1-S12. If user also wants code changes, escalate to Type B.'
        }
        elseif ($MessageType -and $MessageType.Type -eq 'B') {
            $lines += '**HARD GATE - Type B fuzzy implementation:** Read requirement-clarifier + output-template.md. MUST output S4.5 Mini-Spec + S7 pending questions + S12 BEFORE any Write/Edit. PreToolUse hook DENIES Write/Edit until user confirms (clearance: 确认 / 按澄清结果执行 / 直接做).'
            if (Test-ShouldUseVibeCodingBridge -MessageType $MessageType -DetectedIntents $DetectedIntents) {
                $companions = Get-RequirementClarifierCompanionPaths
                if ($companions) {
                    $lines += ''
                    $lines += '**Vibe coding bridge (mandatory for fuzzy implementation):**'
                    $lines += "- ``$($companions.SkillChainMap)`` (read first)"
                    $lines += "- ``$($companions.Bridge)``"
                    if ($companions.InterviewProtocol) {
                        $lines += "- ``$($companions.InterviewProtocol)`` (if ultra-vague: one Q + GUESS per turn)"
                    }
                    $lines += "- ``$($companions.MiniSpec)`` + ``$($companions.QuestionBank)``"
                    if ($companions.Guardrails) {
                        $lines += "- ``$($companions.Guardrails)`` (multi-file / deploy / delete)"
                    }
                    $lines += 'Produce Mini-Spec S4.5 for user confirmation; S12 must not expand beyond Mini-Spec. GitHub distill: superpowers + interview-me + clarify-first.'
                }
            }
        }
        else {
            $lines += '**Requirement clarifier gate:** Implementation task - Read requirement-clarifier + output-template.md; S1-S12 + S7 before Write/Edit unless Type C full spec or user said direct execute.'
        }
        $lines += ''
    }

    if ($MessageType) {
        $lines += "**Message type (hook):** $($MessageType.Label)"
        $lines += ''
    }

    if ($DetectedIntents.Count -gt 0) {
        $lines += '**Detected intents (meaning-based, not exact keywords):**'
        $lines += ''
        foreach ($intent in $DetectedIntents) {
            $lines += "- **$($intent.Label)** ($($intent.Id), confidence $($intent.Confidence))"
        }
        $lines += ''
        $lines += 'If the user paraphrases or implies the above intent without fixed trigger words, still route to the matched skills below.'
        $lines += ''
    }

    $alwaysOnNames = @($AlwaysOnItems | ForEach-Object { $_.Name })
    $extraMatches = @($Matches | Where-Object { $alwaysOnNames -notcontains $_.Name })

    if ($extraMatches.Count -gt 0) {
        $lines += '**Before replying or using tools**, Read these SKILL.md files and follow them:'
        $lines += ''
        foreach ($m in $extraMatches) {
            $reason = if ($m.MatchReason) { " [$($m.MatchReason)]" } else { '' }
            $lines += "- **$($m.Name)** (score $($m.Score)$reason): $($m.Description)"
            $lines += "  - Path: ``$($m.SkillFile)``"
        }
        $lines += ''
        $lines += 'Use the Read tool on each path above when the skill applies. Also scan the global index for semantic fits beyond hook scoring.'
    }
    else {
        $lines += 'No high-confidence skill match from hook scoring. **Still required:** semantically scan skill descriptions in the global index — user intent may be implicit or paraphrased.'
        $lines += ''
        $lines += '**Workflow:** Read ``' + $globalIndexPath + '``; pick skills by meaning; Read applicable SKILL.md files before tools.'
    }

    $lines += ''
    $lines += 'Priority: user instruction > intent-matched skill > semantic skill match > built-in > default.'
    return ($lines -join "`n")
}

function Emit-Output {
    param(
        [string]$Context,
        [string]$Format,
        [string]$Event
    )

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    if ([string]::IsNullOrWhiteSpace($Context)) {
        if ($Format -eq 'Claude') {
            Write-Output '{"continue":true}'
        }
        return
    }

    switch ($Format) {
        'Claude' {
            $eventName = if ($Event -eq 'Plain') { 'SessionStart' } else { $Event }
            @{
                continue           = $true
                hookSpecificOutput = @{
                    hookEventName     = $eventName
                    additionalContext = $Context
                }
            } | ConvertTo-Json -Compress -Depth 5
        }
        'Cursor' {
            @{ additional_context = $Context } | ConvertTo-Json -Compress
        }
        default {
            Write-Output $Context
        }
    }
}

$projectRoot = Find-ProjectRootWithSkills -SeedDir $StartDir
$items = Build-GlobalCatalog -ProjectRoot $projectRoot

if ($items.Count -eq 0) {
    if ($OutputFormat -eq 'Claude') { Write-Output '{"continue":true}' }
    exit 0
}

Write-GlobalSkillsIndex -Items $items

$syncConfig = Get-SkillsSyncConfig
$codingGuardrails = Find-ProjectCodingGuardrails -SeedDir $StartDir
$effectiveAlwaysOnNames = Resolve-EffectiveAlwaysOnNames `
    -BaseAlwaysOn $syncConfig.alwaysOnSkills `
    -ConditionalRules $syncConfig.conditionalAlwaysOnSkills `
    -CodingGuardrails $codingGuardrails
$alwaysOnItems = Resolve-AlwaysOnSkillPaths -CatalogItems $items -AlwaysOnNames $effectiveAlwaysOnNames
$projectOverlay = Find-ProjectMemoryOverlay -SeedDir $StartDir
$intentProfiles = Get-IntentProfiles -SyncConfig $syncConfig

$context = $null
if ($HookEvent -eq 'SessionStart') {
    $context = Build-SessionStartContext -Items $items -AlwaysOnItems $alwaysOnItems -ProjectMemoryOverlay $projectOverlay -CodingGuardrails $codingGuardrails
}
elseif ($HookEvent -eq 'UserPromptSubmit') {
    $userPrompt = Get-HookUserPrompt -Override $UserPrompt
    $messageType = Classify-UserMessageType -UserPrompt $userPrompt -SyncConfig $syncConfig
    $detectedIntents = Detect-UserIntents -UserPrompt $userPrompt -IntentProfiles $intentProfiles
    $gateEntry = $null
    if (Get-Command Update-ClarificationGateFromPrompt -ErrorAction SilentlyContinue) {
        $hookCwd = Get-HookWorkingDirectory -StartDir $StartDir
        $gateEntry = Update-ClarificationGateFromPrompt `
            -UserPrompt $userPrompt `
            -MessageType $messageType `
            -DetectedIntents $detectedIntents `
            -Cwd $hookCwd
    }
    $matches = Score-SkillAgainstPrompt -Skills $items -UserPrompt $userPrompt -PromptKeywordBoosts $syncConfig.promptKeywordBoosts -DetectedIntents $detectedIntents -MinScore $syncConfig.intentMatchMinScore -IntentBoostFloor $syncConfig.intentSkillBoostFloor
    $context = Build-UserPromptContext -AllItems $items -Matches $matches -AlwaysOnItems $alwaysOnItems -UserPrompt $userPrompt -DetectedIntents $detectedIntents -MessageType $messageType
    if ($gateEntry) {
        $gateLines = @(
            '',
            '**Clarification gate state (hook):**',
            "- status: $($gateEntry.gateStatus)",
            "- messageType: $($gateEntry.messageType)"
        )
        if ($gateEntry.draftPath) {
            $gateLines += "- intent draft: ``$($gateEntry.draftPath)``"
        }
        if ($gateEntry.gateStatus -eq 'pending') {
            $gateLines += '- Write/Edit blocked by PreToolUse until user confirms Mini-Spec'
        }
        if ($gateEntry.gateStatus -eq 'cleared') {
            $gateLines += '- Gate cleared — implementation may proceed'
        }
        $context = if ($context) { $context + "`n" + ($gateLines -join "`n") } else { ($gateLines -join "`n") }
    }
}
else {
    $userPrompt = if ($UserPrompt) { $UserPrompt } elseif ($args[0]) { $args[0] } else { '写 PRD' }
    $messageType = Classify-UserMessageType -UserPrompt $userPrompt -SyncConfig $syncConfig
    $detectedIntents = Detect-UserIntents -UserPrompt $userPrompt -IntentProfiles $intentProfiles
    $matches = Score-SkillAgainstPrompt -Skills $items -UserPrompt $userPrompt -PromptKeywordBoosts $syncConfig.promptKeywordBoosts -DetectedIntents $detectedIntents -MinScore $syncConfig.intentMatchMinScore -IntentBoostFloor $syncConfig.intentSkillBoostFloor
    $context = Build-UserPromptContext -AllItems $items -Matches $matches -AlwaysOnItems $alwaysOnItems -UserPrompt $userPrompt -DetectedIntents $detectedIntents -MessageType $messageType
}

Emit-Output -Context $context -Format $OutputFormat -Event $HookEvent
exit 0
