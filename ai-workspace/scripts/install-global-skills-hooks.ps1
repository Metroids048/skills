# Install global skills hooks for Cursor, Claude Code, and Codex (user-level, all projects).
param(
    [switch]$SkipSync,
    [switch]$UseJunctionForClaudeSkills,
    [string]$WorkspaceScriptsDir = '',
    [switch]$SkipAgentsUpdate
)

$ErrorActionPreference = 'Stop'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Merge-PreToolUseMatcherBlock {
    param(
        [array]$ExistingBlocks,
        [string]$Matcher,
        [string]$Command,
        [int]$Timeout = 15,
        [string]$StatusMessage = 'Clarification hard gate'
    )

    $blocks = @()
    if ($ExistingBlocks) { $blocks = @($ExistingBlocks) }

    $already = $false
    foreach ($b in $blocks) {
        if ($b.matcher -eq $Matcher) {
            $hookList = @($b.hooks)
            $hasOurs = $false
            foreach ($h in $hookList) {
                if ($h.command -and $h.command.Contains('clarification-hard-gate.ps1')) { $hasOurs = $true }
            }
            if (-not $hasOurs) {
                $hookList += @{
                    type          = 'command'
                    command       = $Command
                    timeout       = $Timeout
                    statusMessage = $StatusMessage
                }
                $b.hooks = $hookList
            }
            $already = $true
            break
        }
    }
    if (-not $already) {
        $blocks += @{
            matcher = $Matcher
            hooks   = @(
                @{
                    type          = 'command'
                    command       = $Command
                    timeout       = $Timeout
                    statusMessage = $StatusMessage
                }
            )
        }
    }
    return $blocks
}

function Merge-CursorPreToolUseEntries {
    param(
        [array]$ExistingEntries,
        [string]$Matcher,
        [string]$Command,
        [int]$Timeout = 15
    )

    $entries = @()
    if ($ExistingEntries) { $entries = @($ExistingEntries) }

    $hasOurGate = $false
    foreach ($e in $entries) {
        if ($e.command -and $e.command.Contains('clarification-hard-gate.ps1')) {
            $hasOurGate = $true
            break
        }
    }
    if (-not $hasOurGate) {
        $entries += @{
            matcher = $Matcher
            command = $Command
            timeout = $Timeout
        }
    }
    return $entries
}

$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$hooksDir = Join-Path $repoRoot 'scripts\hooks'
$aiWorkspaceScripts = if ($WorkspaceScriptsDir) {
    $WorkspaceScriptsDir
}
else {
    Join-Path $env:USERPROFILE '.ai-workspace\scripts'
}
if (-not (Test-Path (Join-Path $aiWorkspaceScripts 'scan-global-skills.ps1'))) {
    $aiWorkspaceScripts = $hooksDir
}

$claudeDir = Join-Path $env:USERPROFILE '.claude'
$claudeScripts = Join-Path $claudeDir 'scripts'
$cursorDir = Join-Path $env:USERPROFILE '.cursor'
$cursorHooks = Join-Path $cursorDir 'hooks'
$codexHooks = Join-Path $env:USERPROFILE '.codex\hooks'
$scanGlobalSrc = Join-Path $aiWorkspaceScripts 'scan-global-skills.ps1'
if (-not (Test-Path $scanGlobalSrc)) {
    $scanGlobalSrc = Join-Path $hooksDir 'scan-global-skills.ps1'
}
$configSrc = Join-Path $aiWorkspaceScripts 'skills-sync.config.json'
if (-not (Test-Path $configSrc)) {
    $configSrc = Join-Path $hooksDir 'skills-sync.config.json'
}
$scanGlobalDst = Join-Path $claudeScripts 'scan-global-skills.ps1'
$scanHookPath = Join-Path $env:USERPROFILE '.ai-workspace\scripts\scan-global-skills.ps1'
if (-not (Test-Path $scanHookPath)) {
    $scanHookPath = Join-Path $claudeScripts 'scan-global-skills.ps1'
}
$cursorScanHookPath = Join-Path $env:USERPROFILE '.ai-workspace\scripts\scan-global-skills.ps1'
if (-not (Test-Path $cursorScanHookPath)) {
    $cursorScanHookPath = Join-Path $cursorHooks 'scan-global-skills.ps1'
}

if (-not (Test-Path $claudeScripts)) {
    New-Item -ItemType Directory -Path $claudeScripts -Force | Out-Null
}
if (-not (Test-Path $cursorHooks)) {
    New-Item -ItemType Directory -Path $cursorHooks -Force | Out-Null
}

Copy-Item -LiteralPath $scanGlobalSrc -Destination $scanGlobalDst -Force
Copy-Item -LiteralPath $scanGlobalSrc -Destination (Join-Path $cursorHooks 'scan-global-skills.ps1') -Force
Copy-Item -LiteralPath $configSrc -Destination (Join-Path $claudeScripts 'skills-sync.config.json') -Force
Copy-Item -LiteralPath $configSrc -Destination (Join-Path $cursorHooks 'skills-sync.config.json') -Force
$intentSrc = Join-Path (Split-Path $configSrc -Parent) 'intent-profiles.json'
if (-not (Test-Path $intentSrc)) { $intentSrc = Join-Path $hooksDir 'intent-profiles.json' }
if (Test-Path $intentSrc) {
    if (-not (Test-Path $aiWorkspaceScripts)) { New-Item -ItemType Directory -Path $aiWorkspaceScripts -Force | Out-Null }
    $intentDstWs = Join-Path $aiWorkspaceScripts 'intent-profiles.json'
    if ((Resolve-Path -LiteralPath $intentSrc).Path -ne (Resolve-Path -LiteralPath $intentDstWs -ErrorAction SilentlyContinue).Path) {
        Copy-Item -LiteralPath $intentSrc -Destination $intentDstWs -Force
    }
    Copy-Item -LiteralPath $intentSrc -Destination (Join-Path $claudeScripts 'intent-profiles.json') -Force
    Copy-Item -LiteralPath $intentSrc -Destination (Join-Path $cursorHooks 'intent-profiles.json') -Force
    Write-Host "Installed: intent-profiles.json (3 targets)"
}
$msgTypeSrc = Join-Path (Split-Path $configSrc -Parent) 'message-type-signals.json'
if (-not (Test-Path $msgTypeSrc)) { $msgTypeSrc = Join-Path $hooksDir 'message-type-signals.json' }
if (Test-Path $msgTypeSrc) {
    $msgTypeDstWs = Join-Path $aiWorkspaceScripts 'message-type-signals.json'
    if ((Resolve-Path -LiteralPath $msgTypeSrc).Path -ne (Resolve-Path -LiteralPath $msgTypeDstWs -ErrorAction SilentlyContinue).Path) {
        Copy-Item -LiteralPath $msgTypeSrc -Destination $msgTypeDstWs -Force
    }
    Copy-Item -LiteralPath $msgTypeSrc -Destination (Join-Path $claudeScripts 'message-type-signals.json') -Force
    Copy-Item -LiteralPath $msgTypeSrc -Destination (Join-Path $cursorHooks 'message-type-signals.json') -Force
    Write-Host "Installed: message-type-signals.json (3 targets)"
}
Write-Host "Installed: $scanGlobalDst"
Write-Host "Installed: $(Join-Path $cursorHooks 'scan-global-skills.ps1')"

# Clarification hard-gate scripts (PreToolUse)
$gateScripts = @('clarification-gate-core.ps1', 'clarification-hard-gate.ps1', 'clarification-gate-keywords.json')
foreach ($gateScript in $gateScripts) {
    $src = Join-Path $hooksDir $gateScript
    if (-not (Test-Path $src)) { continue }
    if (-not (Test-Path $aiWorkspaceScripts)) {
        New-Item -ItemType Directory -Path $aiWorkspaceScripts -Force | Out-Null
    }
    Copy-Item -LiteralPath $src -Destination (Join-Path $aiWorkspaceScripts $gateScript) -Force
    Copy-Item -LiteralPath $src -Destination (Join-Path $claudeScripts $gateScript) -Force
    Copy-Item -LiteralPath $src -Destination (Join-Path $cursorHooks $gateScript) -Force
    Write-Host "Installed: $gateScript (3 targets)"
}
$hardGateHookPath = Join-Path $aiWorkspaceScripts 'clarification-hard-gate.ps1'

# Delegate wrappers
@(
    @{ Path = Join-Path $claudeScripts 'on-session-start.ps1'; Args = '-OutputFormat Claude -HookEvent SessionStart' }
    @{ Path = Join-Path $claudeScripts 'on-user-prompt.ps1'; Args = '-OutputFormat Claude -HookEvent UserPromptSubmit' }
) | ForEach-Object {
    $escapedHook = $scanHookPath.Replace("'", "''")
    $content = @"
& '$escapedHook' $($_.Args)
exit `$LASTEXITCODE
"@
    Set-Content -LiteralPath $_.Path -Value $content -Encoding UTF8
    Write-Host "Updated: $($_.Path)"
}

# Codex forwarder
if (-not (Test-Path $codexHooks)) {
    New-Item -ItemType Directory -Path $codexHooks -Force | Out-Null
}
$codexForwarder = Join-Path $codexHooks 'scan-project-skills.ps1'
@(
"param(",
"    [ValidateSet('Cursor', 'Claude', 'Codex', 'Plain')]",
"    [string]`$OutputFormat = 'Plain',",
"    [ValidateSet('SessionStart', 'UserPromptSubmit', 'Plain')]",
"    [string]`$HookEvent = 'Plain',",
"    [string]`$StartDir = ''",
")",
"`$mapEvent = switch (`$HookEvent) {",
"    'SessionStart' { 'SessionStart' }",
"    'UserPromptSubmit' { 'UserPromptSubmit' }",
"    default { 'Plain' }",
"}",
"& '$($scanHookPath.Replace("'", "''"))' -OutputFormat `$OutputFormat -HookEvent `$mapEvent -StartDir `$StartDir",
"exit `$LASTEXITCODE"
) -join "`n" | Set-Content -LiteralPath $codexForwarder -Encoding UTF8
Write-Host "Updated: $codexForwarder"

# Claude settings.json hooks
$settingsPath = Join-Path $claudeDir 'settings.json'
$settings = @{}
if (Test-Path $settingsPath) {
    $settings = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
if (-not $settings) { $settings = [pscustomobject]@{} }

$hookCmdSs = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scanHookPath`" -OutputFormat Claude -HookEvent SessionStart"
$hookCmdUp = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scanHookPath`" -OutputFormat Claude -HookEvent UserPromptSubmit"

$newHooks = @{
    SessionStart = @(
        @{
            matcher = 'startup|resume|clear|compact'
            hooks   = @(
                @{
                    type          = 'command'
                    command       = $hookCmdSs
                    timeout       = 45
                    statusMessage = 'Load global skills'
                }
            )
        }
    )
    UserPromptSubmit = @(
        @{
            hooks = @(
                @{
                    type          = 'command'
                    command       = $hookCmdUp
                    timeout       = 45
                    statusMessage = '匹配全局 Skills'
                }
            )
        }
    )
}

if (Test-Path $settingsPath) {
    Copy-Item -LiteralPath $settingsPath -Destination ($settingsPath + '.bak') -Force
}
$settingsObj = @{}
if ($settings -is [PSCustomObject]) {
    $settings.PSObject.Properties | ForEach-Object { $settingsObj[$_.Name] = $_.Value }
}
$gateCmdClaude = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$hardGateHookPath`" -OutputFormat Claude"
$existingPreToolUse = @()
if ($settingsObj.ContainsKey('hooks') -and $settingsObj['hooks']) {
    $existingHooks = $settingsObj['hooks']
    if ($existingHooks -is [PSCustomObject] -and $existingHooks.PSObject.Properties.Name -contains 'PreToolUse') {
        $existingPreToolUse = @($existingHooks.PreToolUse)
    }
}
$newHooks['PreToolUse'] = Merge-PreToolUseMatcherBlock `
    -ExistingBlocks $existingPreToolUse `
    -Matcher 'Write|Edit|MultiEdit|StrReplace|apply_patch' `
    -Command $gateCmdClaude `
    -StatusMessage 'Clarification hard gate'
$settingsObj['hooks'] = $newHooks
if (-not $settingsObj.ContainsKey('$schema')) {
    $settingsObj['$schema'] = 'https://json.schemastore.org/claude-code-settings.json'
}
Write-Utf8NoBomFile -Path $settingsPath -Content ($settingsObj | ConvertTo-Json -Depth 10)
Write-Host "Updated: $settingsPath (backup: settings.json.bak)"

# Codex hooks.json
$codexHooksJson = Join-Path $env:USERPROFILE '.codex\hooks.json'
$codexHookBody = @{
    hooks = @{
        SessionStart = @(
            @{
                matcher = 'startup|resume'
                hooks   = @(
                    @{
                        type          = 'command'
                        command       = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scanHookPath`" -OutputFormat Codex -HookEvent SessionStart"
                        timeout       = 45
                        statusMessage = 'Scan global skills'
                    }
                )
            }
        )
        UserPromptSubmit = @(
            @{
                hooks = @(
                    @{
                        type          = 'command'
                        command       = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$scanHookPath`" -OutputFormat Codex -HookEvent UserPromptSubmit"
                        timeout       = 45
                        statusMessage = '匹配全局 Skills'
                    }
                )
            }
        )
    }
}
$codexExistingPre = @()
if (Test-Path $codexHooksJson) {
    Copy-Item -LiteralPath $codexHooksJson -Destination ($codexHooksJson + '.bak') -Force
    try {
        $codexExisting = Get-Content -LiteralPath $codexHooksJson -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($codexExisting.hooks -and $codexExisting.hooks.PreToolUse) {
            $codexExistingPre = @($codexExisting.hooks.PreToolUse)
        }
    }
    catch { }
}
$gateCmdCodex = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$hardGateHookPath`" -OutputFormat Claude"
$codexHookBody.hooks['PreToolUse'] = Merge-PreToolUseMatcherBlock `
    -ExistingBlocks $codexExistingPre `
    -Matcher 'Write|Edit|MultiEdit|StrReplace|apply_patch' `
    -Command $gateCmdCodex `
    -StatusMessage 'Clarification hard gate'
Write-Utf8NoBomFile -Path $codexHooksJson -Content ($codexHookBody | ConvertTo-Json -Depth 10)
Write-Host "Updated: $codexHooksJson (backup: hooks.json.bak, PreToolUse merged)"

# Cursor hooks.json — global skills (SessionStart always-on + UserPrompt Top 8)
$cursorHooksJson = Join-Path $cursorDir 'hooks.json'
$cursorHookCmdSs = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$cursorScanHookPath`" -OutputFormat Cursor -HookEvent SessionStart"
$cursorHookCmdUp = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$cursorScanHookPath`" -OutputFormat Cursor -HookEvent UserPromptSubmit"
$gateCmdCursor = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$hardGateHookPath`" -OutputFormat Cursor"
$cursorExistingPre = @()
if (Test-Path $cursorHooksJson) {
    Copy-Item -LiteralPath $cursorHooksJson -Destination ($cursorHooksJson + '.bak') -Force
    try {
        $cursorExisting = Get-Content -LiteralPath $cursorHooksJson -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($cursorExisting.hooks -and $cursorExisting.hooks.preToolUse) {
            $cursorExistingPre = @($cursorExisting.hooks.preToolUse)
        }
    }
    catch { }
}
$cursorHookBody = @{
    version = 1
    hooks   = @{
        sessionStart       = @(
            @{
                command = $cursorHookCmdSs
                timeout = 45
            }
        )
        beforeSubmitPrompt = @(
            @{
                command = $cursorHookCmdUp
                timeout = 45
            }
        )
        preToolUse         = Merge-CursorPreToolUseEntries `
            -ExistingEntries $cursorExistingPre `
            -Matcher 'Write|Edit' `
            -Command $gateCmdCursor `
            -Timeout 15
    }
}
Write-Utf8NoBomFile -Path $cursorHooksJson -Content ($cursorHookBody | ConvertTo-Json -Depth 10)
Write-Host "Updated: $cursorHooksJson (backup: hooks.json.bak, preToolUse merged)"

if (-not $SkipAgentsUpdate) {
    $coreSkillPath = Join-Path $env:USERPROFILE '.cursor\skills\global-session-core\SKILL.md'
    $memUser = Join-Path $env:USERPROFILE '.ai-workspace\memory\user-memory.md'
    $globalAgents = Join-Path $claudeDir 'AGENTS.md'

    $claudeMd = Join-Path $claudeDir 'CLAUDE.md'
    $claudeMdContent = @"
# Global AI Workspace

@AGENTS.md

@RTK.md

**SessionStart:** Read ``$coreSkillPath`` and global memory at ``$memUser``.
"@
    Write-Utf8NoBomFile -Path $claudeMd -Content $claudeMdContent
    Write-Host "Updated: $claudeMd"

    $codexMd = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
    $codexMdContent = @"
# Global AI Workspace

Global rules: ``$globalAgents``
Global memory: ``$($env:USERPROFILE)\.ai-workspace\memory``
Skills index: ``~/.claude/global-skills-index.md``

SessionStart: Read ``$coreSkillPath`` before other tools.
See also ``~/.codex/RTK.md`` if present.
"@
    Write-Utf8NoBomFile -Path $codexMd -Content $codexMdContent
    Write-Host "Updated: $codexMd"
}

# Mirror ~/.claude/skills -> ~/.cursor/skills
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $claudeDir 'skills'
if ($UseJunctionForClaudeSkills -and (Test-Path $cursorSkills)) {
    if (Test-Path $claudeSkills) {
        $item = Get-Item -LiteralPath $claudeSkills -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "Junction already exists: $claudeSkills -> $cursorSkills"
        }
        else {
            Remove-Item -LiteralPath $claudeSkills -Recurse -Force
            cmd /c mklink /J "`"$claudeSkills`"" "`"$cursorSkills`"" | Out-Null
            Write-Host "Junction: $claudeSkills -> $cursorSkills"
        }
    }
    else {
        cmd /c mklink /J "`"$claudeSkills`"" "`"$cursorSkills`"" | Out-Null
        Write-Host "Junction: $claudeSkills -> $cursorSkills"
    }
}
elseif (-not $SkipSync -and (Test-Path (Join-Path $hooksDir 'sync-cursor-global-skills.ps1'))) {
    Push-Location $repoRoot
    & (Join-Path $hooksDir 'sync-cursor-global-skills.ps1') -Force -Prune -AlsoClaude
    Pop-Location
}

Write-Host ''
Write-Host 'Done. Restart Cursor / Claude Code / Codex sessions. Re-trust Codex hooks if prompted.'
