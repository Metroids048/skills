# Install 3-end AI global config from this repo onto the current machine.
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1 [-Force] [-SkipMcpMerge]
param(
    [string]$RepoRoot = '',
    [switch]$Force,
    [switch]$SkipMcpMerge,
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $RepoRoot = $PSScriptRoot
}

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path $Path)) {
        if ($WhatIf) { Write-Host "[WhatIf] mkdir $Path"; return }
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    Ensure-Dir (Split-Path $Path -Parent)
    if ($WhatIf) { Write-Host "[WhatIf] write $Path"; return }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Expand-UserProfile([string]$Text) {
    return $Text.Replace('{{USERPROFILE}}', $env:USERPROFILE).Replace('{{USERPROFILE_ESC}}', $env:USERPROFILE.Replace('\', '\\'))
}

function Copy-Tree {
    param([string]$Source, [string]$Dest)
    if (-not (Test-Path $Source)) { throw "Missing: $Source" }
    Ensure-Dir $Dest
    if ($WhatIf) { Write-Host "[WhatIf] robocopy $Source -> $Dest"; return }
    if (Test-Path $Dest) { Remove-Item -LiteralPath $Dest -Recurse -Force -ErrorAction SilentlyContinue }
    & robocopy $Source $Dest /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $Source" }
}

function Ensure-Junction {
    param([string]$Link, [string]$Target)
    if ($WhatIf) { Write-Host "[WhatIf] junction $Link -> $Target"; return }
    if (Test-Path $Link) {
        $item = Get-Item -LiteralPath $Link -Force
        if ($item.LinkType -eq 'Junction' -and $item.Target -eq $Target) { return }
        if ($Force) { Remove-Item -LiteralPath $Link -Recurse -Force }
        else { Write-Host "Skip junction (exists): $Link"; return }
    }
    Ensure-Dir (Split-Path $Target -Parent)
    cmd /c mklink /J "$Link" "$Target" | Out-Null
    Write-Host "Junction: $Link -> $Target"
}

function Merge-JsonFile {
    param(
        [string]$DestPath,
        [string]$FragmentPath,
        [string]$PropertyName
    )
    if (-not (Test-Path $FragmentPath)) { return }
    $frag = Expand-UserProfile (Get-Content -LiteralPath $FragmentPath -Raw -Encoding UTF8) | ConvertFrom-Json
    $dest = @{}
    if (Test-Path $DestPath) {
        $dest = Get-Content -LiteralPath $DestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    if (-not $dest.PSObject.Properties[$PropertyName]) {
        Add-Member -InputObject $dest -NotePropertyName $PropertyName -NotePropertyValue $frag
    }
    else {
        $dest.$PropertyName = $frag
    }
    Write-Utf8NoBom -Path $DestPath -Content ($dest | ConvertTo-Json -Depth 20)
}

Write-Host "=== Install ai-global-config ==="
Write-Host "Repo: $RepoRoot"
Write-Host "Home: $env:USERPROFILE"
Write-Host ''

$skillsSrc = Join-Path $RepoRoot 'skills\cursor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'
$workspaceRoot = Join-Path $env:USERPROFILE '.ai-workspace'
$scriptsDst = Join-Path $workspaceRoot 'scripts'
$memoryDst = Join-Path $workspaceRoot 'memory'

# 1. Skills -> ~/.cursor/skills
Write-Host '--- Skills ---'
Copy-Tree -Source $skillsSrc -Dest $cursorSkills

# 2. Mirror skills to Claude + Codex (junction to save space)
Ensure-Junction -Link $claudeSkills -Target $cursorSkills
Ensure-Junction -Link $codexSkills -Target $cursorSkills

# 3. Cursor rules
Write-Host '--- Cursor rules ---'
$rulesSrc = Join-Path $RepoRoot 'cursor\rules'
$rulesDst = Join-Path $env:USERPROFILE '.cursor\rules'
Ensure-Dir $rulesDst
if (-not $WhatIf) {
    Get-ChildItem $rulesSrc -Filter '*.mdc' | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $rulesDst $_.Name) -Force
    }
}

# 4. ai-workspace scripts + docs + memory
Write-Host '--- ai-workspace ---'
Copy-Tree -Source (Join-Path $RepoRoot 'ai-workspace\scripts') -Dest $scriptsDst
if (Test-Path (Join-Path $RepoRoot 'ai-workspace\docs')) {
    Copy-Tree -Source (Join-Path $RepoRoot 'ai-workspace\docs') -Dest (Join-Path $workspaceRoot 'docs')
}
Ensure-Dir $memoryDst
Get-ChildItem (Join-Path $RepoRoot 'ai-workspace\memory') -Filter '*.md' | ForEach-Object {
    $dest = Join-Path $memoryDst $_.Name
    if ((Test-Path $dest) -and -not $Force) {
        Write-Host "Memory exists (skip): $($_.Name)"
    }
    elseif (-not $WhatIf) {
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        Write-Host "Memory: $($_.Name)"
    }
}

# 5. Claude AGENTS + CLAUDE.md
Write-Host '--- Claude Code ---'
$claudeDir = Join-Path $env:USERPROFILE '.claude'
Ensure-Dir $claudeDir
foreach ($f in @('AGENTS.md', 'CLAUDE.md', 'AGENTS.ecc-supplement.md')) {
    $src = Join-Path $RepoRoot "claude\$f"
    if (Test-Path $src) {
        if (-not $WhatIf) { Copy-Item -LiteralPath $src -Destination (Join-Path $claudeDir $f) -Force }
        Write-Host "Claude: $f"
    }
}

# 6. Codex AGENTS
$codexDir = Join-Path $env:USERPROFILE '.codex'
Ensure-Dir $codexDir
foreach ($f in @('AGENTS.md', 'AGENTS.ecc-supplement.md')) {
    $src = Join-Path $RepoRoot "codex\$f"
    if (Test-Path $src) {
        if (-not $WhatIf) { Copy-Item -LiteralPath $src -Destination (Join-Path $codexDir $f) -Force }
        Write-Host "Codex: $f"
    }
}

# 7. Hooks (Cursor)
$cursorHooksTpl = Join-Path $RepoRoot 'cursor\hooks.json.template'
if (Test-Path $cursorHooksTpl) {
    $hooksJson = Expand-UserProfile (Get-Content -LiteralPath $cursorHooksTpl -Raw -Encoding UTF8)
    Write-Utf8NoBom -Path (Join-Path $env:USERPROFILE '.cursor\hooks.json') -Content $hooksJson
    Write-Host 'Installed: ~/.cursor/hooks.json'
}

# 8. Hooks (Codex) — same scripts, Codex format
$codexHooks = @{
    hooks = @{
        PreToolUse = @{
            hooks   = @(
                @{
                    command       = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$($env:USERPROFILE)\.ai-workspace\scripts\clarification-hard-gate.ps1`" -OutputFormat Codex"
                    timeout       = 15
                    type          = 'command'
                    statusMessage = 'Clarification hard gate'
                }
            )
            matcher = 'Write|Edit|MultiEdit|StrReplace|apply_patch'
        }
        SessionStart     = @(
            @{
                hooks   = @(
                    @{
                        command       = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$($env:USERPROFILE)\.ai-workspace\scripts\scan-global-skills.ps1`" -OutputFormat Codex -HookEvent SessionStart"
                        timeout       = 45
                        type          = 'command'
                        statusMessage = 'Scan global skills'
                    }
                )
                matcher = 'startup|resume'
            }
        )
        UserPromptSubmit = @(
            @{
                hooks = @(
                    @{
                        command       = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$($env:USERPROFILE)\.ai-workspace\scripts\scan-global-skills.ps1`" -OutputFormat Codex -HookEvent UserPromptSubmit"
                        timeout       = 45
                        type          = 'command'
                        statusMessage = 'Match global skills'
                    }
                )
            }
        )
    }
}
Write-Utf8NoBom -Path (Join-Path $codexDir 'hooks.json') -Content ($codexHooks | ConvertTo-Json -Depth 10)
Write-Host 'Installed: ~/.codex/hooks.json'

# 9. Claude settings hooks merge (preserve existing mcpServers if present)
$settingsPath = Join-Path $claudeDir 'settings.json'
$settingsExample = Join-Path $RepoRoot 'claude\settings.json.example'
$hooksFrag = Join-Path $RepoRoot 'claude\hooks.fragment.json'
if (Test-Path $settingsExample) {
    $settings = Expand-UserProfile (Get-Content -LiteralPath $settingsExample -Raw -Encoding UTF8) | ConvertFrom-Json
    if (Test-Path $settingsPath) {
        $existing = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($existing.mcpServers) { $settings.mcpServers = $existing.mcpServers }
        if ($existing.env) { $settings.env = $existing.env }
    }
    if (Test-Path $hooksFrag) {
        $frag = Expand-UserProfile (Get-Content -LiteralPath $hooksFrag -Raw -Encoding UTF8) | ConvertFrom-Json
        $settings.hooks = $frag
    }
    Write-Utf8NoBom -Path $settingsPath -Content ($settings | ConvertTo-Json -Depth 20)
    Write-Host 'Installed/merged: ~/.claude/settings.json'
}

# 10. Codex config.toml (only if missing or -Force)
$codexCfgExample = Join-Path $RepoRoot 'codex\config.toml.example'
$codexCfg = Join-Path $codexDir 'config.toml'
if (Test-Path $codexCfgExample) {
    if (-not (Test-Path $codexCfg) -or $Force) {
        $cfg = Get-Content -LiteralPath $codexCfgExample -Raw -Encoding UTF8
        $headroomExe = "$env:APPDATA\Python\Python312\Scripts\headroom.exe".Replace('\', '\\')
        $cfg = $cfg.Replace('{{HEADROOM_EXE}}', $headroomExe)
        Write-Utf8NoBom -Path $codexCfg -Content $cfg
        Write-Host 'Installed: ~/.codex/config.toml (from example — set HCAI_API_KEY etc.)'
    }
    else {
        Write-Host 'Skip codex config.toml (exists; use -Force to overwrite)'
    }
}

# 11. Cursor mcp.json (example -> only if missing)
if (-not $SkipMcpMerge) {
    $mcpExample = Join-Path $RepoRoot 'cursor\mcp.json.example'
    $mcpDest = Join-Path $env:USERPROFILE '.cursor\mcp.json'
    if ((Test-Path $mcpExample) -and (-not (Test-Path $mcpDest) -or $Force)) {
        $mcp = Expand-UserProfile (Get-Content -LiteralPath $mcpExample -Raw -Encoding UTF8)
    $mcp = $mcp.Replace('{{HEADROOM_EXE}}', "$env:APPDATA\Python\Python312\Scripts\headroom.exe".Replace('\', '\\'))
        Write-Utf8NoBom -Path $mcpDest -Content $mcp
        Write-Host 'Installed: ~/.cursor/mcp.json (replace YOUR_VIBEAROUND_TOKEN)'
    }
}

# 12. Regenerate skills index
$scanScript = Join-Path $scriptsDst 'scan-global-skills.ps1'
if ((Test-Path $scanScript) -and -not $WhatIf) {
    Write-Host ''
    Write-Host 'Regenerating global-skills-index.md ...'
    & $scanScript | Out-Null
}

Write-Host ''
Write-Host '=== Install complete ==='
Write-Host 'Next steps:'
Write-Host '  1. Edit ~/.cursor/mcp.json — set VibeAround token if used'
Write-Host '  2. Edit ~/.codex/config.toml — set HCAI_API_KEY / model if needed'
Write-Host '  3. Edit ~/.claude/settings.json — ANTHROPIC_BASE_URL for your proxy'
Write-Host '  4. Restart Cursor, Claude Code, Codex'
Write-Host '  5. Optional: codegraph init -i in each project; headroom / agentmemory per docs'
