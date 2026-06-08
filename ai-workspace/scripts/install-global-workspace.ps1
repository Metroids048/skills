# One-shot global AI workspace setup — memory, scripts, hooks, AGENTS.
# Run from any directory. Re-run safe; use -Force to overwrite memory templates.
param(
    [switch]$Force,
    [switch]$SkipSkillsSync,
    [string]$RepoRoot = ''
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $RepoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    if (-not (Test-Path (Join-Path $RepoRoot 'AGENTS.md'))) {
        $RepoRoot = 'C:\Users\win\Desktop\Agent Platform'
    }
}

$workspaceRoot = Join-Path $env:USERPROFILE '.ai-workspace'
$memoryDir = Join-Path $workspaceRoot 'memory'
$scriptsDir = Join-Path $workspaceRoot 'scripts'
$templatesDir = Join-Path $RepoRoot 'scripts\global-workspace\templates'
$hooksSrc = Join-Path $RepoRoot 'scripts\hooks'

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

Ensure-Dir $workspaceRoot
Ensure-Dir $memoryDir
Ensure-Dir $scriptsDir
Ensure-Dir (Join-Path $workspaceRoot 'templates\rules')

Write-Host "Global workspace: $workspaceRoot"
Write-Host "Source repo:      $RepoRoot"
Write-Host ''

# --- Memory templates ---
$memoryTemplates = Join-Path $templatesDir 'memory'
if (Test-Path $memoryTemplates) {
    Get-ChildItem $memoryTemplates -Filter '*.md' | ForEach-Object {
        $dest = Join-Path $memoryDir $_.Name
        if ((Test-Path $dest) -and -not $Force) {
            Write-Host "Memory exists (skip): $($_.Name)"
        }
        else {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            Write-Host "Memory: $($_.Name)"
        }
    }
}

# --- Copy hook scripts to ~/.ai-workspace/scripts/ ---
@(
    'scan-global-skills.ps1',
    'scan-project-skills.ps1',
    'sync-cursor-global-skills.ps1',
    'install-global-skills-hooks.ps1',
    'skills-sync.config.json'
) | ForEach-Object {
    $src = Join-Path $hooksSrc $_
    if (Test-Path $src) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $scriptsDir $_) -Force
        Write-Host "Script: $_"
    }
}

Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $scriptsDir 'install-global-workspace.ps1') -Force
$initSrc = Join-Path (Split-Path $PSCommandPath) 'init-project-memory.ps1'
if (Test-Path $initSrc) {
    Copy-Item -LiteralPath $initSrc -Destination (Join-Path $scriptsDir 'init-project-memory.ps1') -Force
}
$syncSrc = Join-Path (Split-Path $PSCommandPath) 'sync-from-repo.ps1'
if (Test-Path $syncSrc) {
    Copy-Item -LiteralPath $syncSrc -Destination (Join-Path $scriptsDir 'sync-from-repo.ps1') -Force
}

if (Test-Path (Join-Path $hooksSrc 'refinements')) {
    Ensure-Dir (Join-Path $scriptsDir 'refinements')
    Copy-Item -LiteralPath (Join-Path $hooksSrc 'refinements\*') -Destination (Join-Path $scriptsDir 'refinements') -Recurse -Force
}

# --- Global AGENTS.md ---
$agentsTemplate = Join-Path $templatesDir 'AGENTS.global.md'
$claudeAgents = Join-Path $env:USERPROFILE '.claude\AGENTS.md'
if (Test-Path $agentsTemplate) {
    if ((Test-Path $claudeAgents) -and -not $Force) {
        Write-Host "Exists (skip): $claudeAgents"
    }
    else {
        Copy-Item -LiteralPath $agentsTemplate -Destination $claudeAgents -Force
        Write-Host "Installed: $claudeAgents"
    }
}

# --- Project rules templates -> workspace templates ---
$rulesSrc = Join-Path $RepoRoot '.cursor\rules'
if (Test-Path $rulesSrc) {
    $rulesTplDir = Join-Path $workspaceRoot 'templates\rules'
    Get-ChildItem $rulesSrc -Filter '*.mdc' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $rulesTplDir $_.Name) -Force
    }
    Write-Host 'Cached rules templates to ~/.ai-workspace/templates/rules/'
}

# --- Install hooks (delegates to repo script with ai-workspace paths) ---
$installHooks = Join-Path $hooksSrc 'install-global-skills-hooks.ps1'
if (Test-Path $installHooks) {
    Write-Host ''
    Write-Host 'Installing global hooks...'
    & $installHooks -UseJunctionForClaudeSkills -SkipSync -WorkspaceScriptsDir $scriptsDir -SkipAgentsUpdate
}

# --- Sync skills from repo ---
if (-not $SkipSkillsSync -and (Test-Path (Join-Path $scriptsDir 'sync-cursor-global-skills.ps1'))) {
    Write-Host ''
    Write-Host 'Syncing skills to ~/.cursor/skills ...'
    Push-Location $RepoRoot
    & (Join-Path $scriptsDir 'sync-cursor-global-skills.ps1') -Force -Prune -AlsoClaude -ProjectRoot $RepoRoot
    Pop-Location
}

# --- Sync rules to ~/.cursor/rules ---
$rulesDst = Join-Path $env:USERPROFILE '.cursor\rules'
Ensure-Dir $rulesDst
Get-ChildItem (Join-Path $workspaceRoot 'templates\rules') -Filter '*.mdc' -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $rulesDst $_.Name) -Force
    Write-Host "Rule: $($_.Name)"
}

# --- CLAUDE.md / Codex AGENTS.md pointers ---
$coreSkill = Join-Path $env:USERPROFILE '.cursor\skills\global-session-core\SKILL.md'
$memUser = Join-Path $memoryDir 'user-memory.md'

$claudeMd = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
$claudeContent = @"
# Global AI Workspace

@AGENTS.md

@RTK.md

**SessionStart:** Read ``$coreSkill`` and global memory at ``$memUser``.
"@
Write-Utf8NoBom -Path $claudeMd -Content $claudeContent
Write-Host "Updated: $claudeMd"

$codexMd = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
$codexContent = @"
# Global AI Workspace

Global rules: ``$claudeAgents``
Global memory: ``$memoryDir``
Skills index: ``~/.claude/global-skills-index.md``

SessionStart: Read ``$coreSkill`` before other tools.
See also ``~/.codex/RTK.md`` if present.
"@
Write-Utf8NoBom -Path $codexMd -Content $codexContent
Write-Host "Updated: $codexMd"

Write-Host ''
Write-Host 'Done. Restart Cursor / Claude Code / Codex.'
Write-Host "New projects need zero setup. Optional team memory: init-project-memory.ps1"
