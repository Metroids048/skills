# ai-global-config export
# Sync portable Cursor / Claude Code / Codex global agent config from this machine.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$UserHome = $env:USERPROFILE

$utf8Helpers = Join-Path $UserHome ".ai-workspace\scripts\Write-Utf8NoBom.ps1"
if (-not (Test-Path -LiteralPath $utf8Helpers)) {
    $utf8Helpers = Join-Path $RepoRoot "ai-workspace\scripts\Write-Utf8NoBom.ps1"
}
if (Test-Path -LiteralPath $utf8Helpers) {
    . $utf8Helpers
} else {
    function Write-Utf8NoBomFile {
        param([string]$Path, [string]$Content)
        $encoding = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Path, $Content, $encoding)
    }
    function Read-Utf8File {
        param([string]$Path)
        return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    }
}

$CommonExcludeDirs = @(
    ".git", "__pycache__", ".venv", "venv", "node_modules", "dist", "build",
    "cache", ".cache", "Cache", "CachedData", "GPUCache", "Code Cache",
    "sessions", "archived_sessions", "file-history", "history", "logs", "log",
    "telemetry", "shell-snapshots", "workspaceStorage", "Backups", "backups",
    "runtime", "tmp", ".tmp", "secrets", ".sandbox-secrets", "browser",
    "sqlite", "process_manager", "attachments"
)

$CommonExcludeFiles = @(
    "*.sqlite", "*.sqlite-shm", "*.sqlite-wal", "*.db", "*.log",
    "auth.json", ".credentials.json", ".env", ".env.*", "*.local.json",
    "history.jsonl", "session_index.jsonl", "installation_id", "cap_sid"
)

function Ensure-Dir {
    param([string]$Path)
    if ($Path -and -not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Sync-Tree {
    param(
        [string]$Source,
        [string]$Dest,
        [string[]]$ExtraExcludeDirs = @(),
        [string[]]$ExtraExcludeFiles = @(),
        [switch]$FollowJunctions,
        [switch]$KeepSessionArchives
    )
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skip missing: $Source"
        return
    }
    if (Test-Path -LiteralPath $Dest) {
        if ($Force) {
            Remove-Item -LiteralPath $Dest -Recurse -Force
        } else {
            Write-Warning "Dest exists, use -Force: $Dest"
            return
        }
    }
    Ensure-Dir (Split-Path -Parent $Dest)
    $baseDirs = $CommonExcludeDirs
    $baseFiles = $CommonExcludeFiles
    if ($KeepSessionArchives) {
        $sessionDirAllow = @("sessions", "archived_sessions", "file-history", "history")
        $baseDirs = @($CommonExcludeDirs | Where-Object { $sessionDirAllow -notcontains $_ })
        $sessionFileAllow = @("history.jsonl", "session_index.jsonl")
        $baseFiles = @($CommonExcludeFiles | Where-Object { $sessionFileAllow -notcontains $_ })
    }
    $excludeDirs = $baseDirs + $ExtraExcludeDirs
    $excludeFiles = $baseFiles + $ExtraExcludeFiles
    $roboArgs = @($Source, $Dest, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP")
    if (-not $FollowJunctions) { $roboArgs += "/XJ" }
    $roboArgs += "/XD"
    $roboArgs += $excludeDirs
    $roboArgs += "/XF"
    $roboArgs += $excludeFiles
    & robocopy @roboArgs | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Source -> $Dest" }
    Write-Host "Synced: $Source -> $Dest"
}

function Copy-FileIfExists {
    param([string]$Source, [string]$Dest)
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skip missing file: $Source"
        return
    }
    Ensure-Dir (Split-Path -Parent $Dest)
    Copy-Item -LiteralPath $Source -Destination $Dest -Force
    Write-Host "Copied: $Source -> $Dest"
}

function Sync-SkillsEndpoint {
    param(
        [string]$Source,
        [string]$Dest
    )
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skip missing skills endpoint: $Source"
        return
    }
    if (Test-Path -LiteralPath $Dest) {
        if ($Force) {
            Remove-Item -LiteralPath $Dest -Recurse -Force
        } else {
            Write-Warning "Dest exists, use -Force: $Dest"
            return
        }
    }
    Ensure-Dir $Dest
    $copied = 0
    $failed = 0
    Get-ChildItem -LiteralPath $Source -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $skillDir = $_.FullName
        $skillFile = Join-Path $skillDir "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillFile)) { return }
        $target = Join-Path $Dest $_.Name
        robocopy $skillDir $target /E /NFL /NDL /NJH /NJS /NC /NS /NP `
            /XD ".git" "__pycache__" ".venv" "venv" "node_modules" "dist" "build" "cache" ".cache" `
            /XF "*.sqlite" "*.sqlite-shm" "*.sqlite-wal" "auth.json" ".env" ".env.*" "*.local.json" | Out-Null
        if ($LASTEXITCODE -ge 8) {
            $failed++
            Write-Warning "Skill copy had errors, kept partial if any: $skillDir -> $target (robocopy $LASTEXITCODE)"
        } else {
            $copied++
        }
    }
    Write-Host "Synced skills endpoint: $Source -> $Dest (copied=$copied failed=$failed)"
}

function Redact-FileIfExists {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $raw = Read-Utf8File -Path $Path
    $redacted = $raw
    $redacted = $redacted -replace '(?i)(token=)[^"&\s]+', '${1}YOUR_TOKEN'
    $redacted = $redacted -replace '(?i)(api[_-]?key=)[^"&\s]+', '${1}YOUR_API_KEY'
    $redacted = $redacted -replace '(?i)("?(?:api[_-]?key|token|secret|password|authorization)"?\s*:\s*")[^"]+(")', '${1}YOUR_SECRET${2}'
    $redacted = $redacted -replace '(?i)(Bearer\s+)[A-Za-z0-9._~+/=-]{12,}', '${1}YOUR_TOKEN'
    $redacted = $redacted -replace '(?i)(ghp_|github_pat_)[A-Za-z0-9_]{16,}', '${1}YOUR_TOKEN'
    $redacted = $redacted -replace '(?i)\bsk-proj-[A-Za-z0-9_-]{20,}', 'sk-proj-YOUR_SECRET'
    $redacted = $redacted -replace '(?i)\bsk-(?!YOUR_SECRET\b)[A-Za-z0-9]{20,}', 'sk-YOUR_SECRET'
    if ($redacted -ne $raw) {
        Write-Utf8NoBomFile -Path $Path -Content $redacted
        Write-Host "Redacted: $Path"
    }
}

# Skills: preserve each endpoint exactly. This avoids losing Codex-specific skills.
Sync-SkillsEndpoint -Source (Join-Path $UserHome ".cursor\skills") -Dest (Join-Path $RepoRoot "skills\cursor")
Sync-SkillsEndpoint -Source (Join-Path $UserHome ".claude\skills") -Dest (Join-Path $RepoRoot "skills\claude")
Sync-SkillsEndpoint -Source (Join-Path $UserHome ".codex\skills") -Dest (Join-Path $RepoRoot "skills\codex")
if (Test-Path -LiteralPath (Join-Path $UserHome ".agents\skills")) {
    Sync-SkillsEndpoint -Source (Join-Path $UserHome ".agents\skills") -Dest (Join-Path $RepoRoot "skills\agents")
}

# Cursor
Sync-Tree -Source (Join-Path $UserHome ".cursor\rules") -Dest (Join-Path $RepoRoot "cursor\rules")
Sync-Tree -Source (Join-Path $UserHome ".cursor\commands") -Dest (Join-Path $RepoRoot "cursor\commands")
Sync-Tree -Source (Join-Path $UserHome ".cursor\hooks") -Dest (Join-Path $RepoRoot "cursor\hooks")
Sync-Tree -Source (Join-Path $UserHome ".cursor\mcp-configs") -Dest (Join-Path $RepoRoot "cursor\mcp-configs")
Copy-FileIfExists -Source (Join-Path $UserHome ".cursor\hooks.json") -Dest (Join-Path $RepoRoot "cursor\hooks.json.template")
Copy-FileIfExists -Source (Join-Path $UserHome ".cursor\mcp.json") -Dest (Join-Path $RepoRoot "cursor\mcp.json.example")

# Claude Code
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\AGENTS.md") -Dest (Join-Path $RepoRoot "claude\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\CLAUDE.md") -Dest (Join-Path $RepoRoot "claude\CLAUDE.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\settings.json") -Dest (Join-Path $RepoRoot "claude\settings.json.example")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\global-skills-index.md") -Dest (Join-Path $RepoRoot "claude\global-skills-index.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\global-skills-index-zh.md") -Dest (Join-Path $RepoRoot "claude\global-skills-index-zh.md")
Sync-Tree -Source (Join-Path $UserHome ".claude\commands") -Dest (Join-Path $RepoRoot "claude\commands")
Sync-Tree -Source (Join-Path $UserHome ".claude\mcp-configs") -Dest (Join-Path $RepoRoot "claude\mcp-configs")
if (Test-Path -LiteralPath (Join-Path $UserHome ".claude\rules")) {
    Sync-Tree -Source (Join-Path $UserHome ".claude\rules") -Dest (Join-Path $RepoRoot "claude\rules")
}
if (Test-Path -LiteralPath (Join-Path $UserHome ".claude\hooks")) {
    Sync-Tree -Source (Join-Path $UserHome ".claude\hooks") -Dest (Join-Path $RepoRoot "claude\hooks")
}

# Codex
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\AGENTS.md") -Dest (Join-Path $RepoRoot "codex\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\RTK.md") -Dest (Join-Path $RepoRoot "codex\RTK.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\config.toml") -Dest (Join-Path $RepoRoot "codex\config.toml.example")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\codex-plus-overlay.toml") -Dest (Join-Path $RepoRoot "codex\codex-plus-overlay.toml.example")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\codex-plus-mcp-overlay.toml") -Dest (Join-Path $RepoRoot "codex\codex-plus-mcp-overlay.toml.example")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\hooks.json") -Dest (Join-Path $RepoRoot "codex\hooks.json.template")
Sync-Tree -Source (Join-Path $UserHome ".codex\mcp-configs") -Dest (Join-Path $RepoRoot "codex\mcp-configs")
Sync-Tree -Source (Join-Path $UserHome ".codex\hooks") -Dest (Join-Path $RepoRoot "codex\hooks")
Sync-Tree -Source (Join-Path $UserHome ".codex\scripts") -Dest (Join-Path $RepoRoot "codex\scripts")

# Shared AI workspace: source material, not runtime.
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\memory") -Dest (Join-Path $RepoRoot "ai-workspace\memory")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\docs") -Dest (Join-Path $RepoRoot "ai-workspace\docs")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\scripts") -Dest (Join-Path $RepoRoot "ai-workspace\scripts")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\ai-coding-os") -Dest (Join-Path $RepoRoot "ai-workspace\ai-coding-os")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\templates") -Dest (Join-Path $RepoRoot "ai-workspace\templates")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\skills-curated") -Dest (Join-Path $RepoRoot "ai-workspace\skills-curated")
Copy-FileIfExists -Source (Join-Path $UserHome ".ai-workspace\AGENT-GLOBAL-STACK.md") -Dest (Join-Path $RepoRoot "ai-workspace\AGENT-GLOBAL-STACK.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".ai-workspace\skills-locale-zh.json") -Dest (Join-Path $RepoRoot "ai-workspace\skills-locale-zh.json")

# Project-level agent memory snapshots, no source code.
# Hardcoded known projects + Desktop dirs that have AGENTS.md / .github/agent.
$projects = [System.Collections.Generic.List[object]]::new()
$knownProjects = @(
    @{ Name = "agent-platform"; Path = Join-Path $UserHome "Desktop\Agent Platform" },
    @{ Name = "program1-main"; Path = Join-Path $UserHome "Desktop\program1-main" },
    @{ Name = "program1-main-latest"; Path = Join-Path $UserHome "Desktop\program1-main-latest" },
    @{ Name = "demo1"; Path = Join-Path $UserHome "Desktop\demo1" },
    @{ Name = "AI--main"; Path = Join-Path $UserHome "Desktop\AI--main" },
    @{ Name = "alpha"; Path = Join-Path $UserHome "Desktop\alpha" },
    @{ Name = "yinpinjianting"; Path = Join-Path $UserHome "Desktop\yinpinjianting" },
    @{ Name = "aoqin-ess"; Path = Join-Path $UserHome "Desktop\敖钦储能项目" },
    @{ Name = "haixiaonan"; Path = Join-Path $UserHome "Desktop\海小南" },
    @{ Name = "capacity-eval"; Path = Join-Path $UserHome "Desktop\产能评价" },
    @{ Name = "contract-review"; Path = Join-Path $UserHome "Desktop\合同审查" }
)
foreach ($kp in $knownProjects) { $projects.Add($kp) }

$desktopRoot = Join-Path $UserHome "Desktop"
$seenPaths = @{}
foreach ($p in $projects) { $seenPaths[$p.Path.ToLowerInvariant()] = $true }
Get-ChildItem -LiteralPath $desktopRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -notmatch '(?i)backup|skills$|全局配置' -and
        -not $seenPaths.ContainsKey($_.FullName.ToLowerInvariant()) -and
        (
            (Test-Path -LiteralPath (Join-Path $_.FullName "AGENTS.md")) -or
            (Test-Path -LiteralPath (Join-Path $_.FullName ".github\agent"))
        )
    } |
    ForEach-Object {
        $safeName = ($_.Name -replace '[\\/:*?"<>|]', '-').Trim()
        $projects.Add(@{ Name = $safeName; Path = $_.FullName })
    }

foreach ($project in $projects) {
    $projectRoot = $project.Path
    $destRoot = Join-Path $RepoRoot ("projects\" + $project.Name)
    Copy-FileIfExists -Source (Join-Path $projectRoot "AGENTS.md") -Dest (Join-Path $destRoot "AGENTS.md")
    Copy-FileIfExists -Source (Join-Path $projectRoot "CLAUDE.md") -Dest (Join-Path $destRoot "CLAUDE.md")
    if (Test-Path -LiteralPath (Join-Path $projectRoot ".github\agent")) {
        Sync-Tree -Source (Join-Path $projectRoot ".github\agent") -Dest (Join-Path $destRoot ".github\agent")
    }
    if (Test-Path -LiteralPath (Join-Path $projectRoot ".cursor\rules")) {
        Sync-Tree -Source (Join-Path $projectRoot ".cursor\rules") -Dest (Join-Path $destRoot ".cursor\rules")
    }
    if (Test-Path -LiteralPath (Join-Path $projectRoot ".claude\skills")) {
        Sync-Tree -Source (Join-Path $projectRoot ".claude\skills") -Dest (Join-Path $destRoot ".claude\skills")
    }
}

# Extra ai-workspace retention (not venv/vendor/runtime)
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\clarifications") -Dest (Join-Path $RepoRoot "ai-workspace\clarifications")
Sync-Tree -Source (Join-Path $UserHome ".ai-workspace\backups") -Dest (Join-Path $RepoRoot "ai-workspace\backups")

# Cursor portable extras
Copy-FileIfExists -Source (Join-Path $UserHome ".cursor\USER_RULES.txt") -Dest (Join-Path $RepoRoot "cursor\USER_RULES.txt")
if (Test-Path -LiteralPath (Join-Path $UserHome ".cursor\skills-cursor")) {
    Sync-SkillsEndpoint -Source (Join-Path $UserHome ".cursor\skills-cursor") -Dest (Join-Path $RepoRoot "skills\cursor-builtin")
}

# Claude retention: history, file-history, plans, projects metadata, backups, agents
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\history.jsonl") -Dest (Join-Path $RepoRoot "archives\claude\history.jsonl")
Sync-Tree -Source (Join-Path $UserHome ".claude\file-history") -Dest (Join-Path $RepoRoot "archives\claude\file-history") -KeepSessionArchives
Sync-Tree -Source (Join-Path $UserHome ".claude\plans") -Dest (Join-Path $RepoRoot "archives\claude\plans")
Sync-Tree -Source (Join-Path $UserHome ".claude\projects") -Dest (Join-Path $RepoRoot "archives\claude\projects") -ExtraExcludeDirs @("cache", ".cache")
Sync-Tree -Source (Join-Path $UserHome ".claude\backups") -Dest (Join-Path $RepoRoot "archives\claude\backups")
Sync-Tree -Source (Join-Path $UserHome ".claude\agents") -Dest (Join-Path $RepoRoot "archives\claude\agents")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\config.json") -Dest (Join-Path $RepoRoot "claude\config.json.example")

# Codex retention: sessions, archived_sessions, memories, agents, automations
Sync-Tree -Source (Join-Path $UserHome ".codex\sessions") -Dest (Join-Path $RepoRoot "archives\codex\sessions") -KeepSessionArchives -ExtraExcludeDirs @("cache", ".cache", "browser")
Sync-Tree -Source (Join-Path $UserHome ".codex\archived_sessions") -Dest (Join-Path $RepoRoot "archives\codex\archived_sessions") -KeepSessionArchives
Sync-Tree -Source (Join-Path $UserHome ".codex\memories") -Dest (Join-Path $RepoRoot "archives\codex\memories")
Sync-Tree -Source (Join-Path $UserHome ".codex\agents") -Dest (Join-Path $RepoRoot "archives\codex\agents")
Sync-Tree -Source (Join-Path $UserHome ".codex\automations") -Dest (Join-Path $RepoRoot "archives\codex\automations")
Sync-Tree -Source (Join-Path $UserHome ".codex\backups") -Dest (Join-Path $RepoRoot "archives\codex\backups")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\session_index.jsonl") -Dest (Join-Path $RepoRoot "archives\codex\session_index.jsonl")

# Cursor agent transcripts under ~/.cursor/projects/*/agent-transcripts
$cursorProjects = Join-Path $UserHome ".cursor\projects"
$transcriptDestRoot = Join-Path $RepoRoot "archives\cursor\agent-transcripts"
if (Test-Path -LiteralPath $cursorProjects) {
    Get-ChildItem -LiteralPath $cursorProjects -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $src = Join-Path $_.FullName "agent-transcripts"
        if (Test-Path -LiteralPath $src) {
            $files = @(Get-ChildItem -LiteralPath $src -File -Recurse -ErrorAction SilentlyContinue)
            if ($files.Count -gt 0) {
                Sync-Tree -Source $src -Dest (Join-Path $transcriptDestRoot $_.Name) -KeepSessionArchives
            }
        }
    }
}

# Knowledge center: FULL Desktop/全局配置 (private repo). Only skip nested .git.
$knowledgeCenter = Join-Path $UserHome "Desktop\全局配置"
if (Test-Path -LiteralPath $knowledgeCenter) {
    $kcDest = Join-Path $RepoRoot "knowledge-center"
    Sync-Tree -Source $knowledgeCenter -Dest $kcDest -KeepSessionArchives -ExtraExcludeDirs @(".git")
    Write-Host "Synced knowledge-center FULL (Desktop/全局配置)"
} else {
    Write-Warning "Skip missing knowledge center: $knowledgeCenter"
}

# Redact exported examples and templates.
Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Include "*.example", "*.template", "*.json", "*.toml", "*.md", "*.ps1", "*.mjs", "*.js" |
    Where-Object {
        $_.FullName -notmatch "\\\.git\\" -and
        $_.FullName -ne (Join-Path $RepoRoot "scripts\export-from-local.ps1") -and
        $_.Length -lt 1MB
    } |
    ForEach-Object { Redact-FileIfExists -Path $_.FullName }

$skillCounts = @{}
foreach ($endpoint in @("cursor", "claude", "codex", "agents")) {
    $root = Join-Path $RepoRoot ("skills\" + $endpoint)
    $skillCounts[$endpoint] = if (Test-Path -LiteralPath $root) {
        (Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }).Count
    } else { 0 }
}

$manifest = [ordered]@{
    version = "1.3.0"
    exportedAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    sourceMachine = $env:COMPUTERNAME
    skillCounts = $skillCounts
    includes = @(
        "endpoint skills",
        "commands",
        "rules",
        "hooks",
        "mcp configs",
        "AIOS",
        "global memory",
        "project agent memory snapshots",
        "knowledge-center FULL (Desktop/全局配置)",
        "codex/claude/cursor session archives",
        "ai-workspace clarifications/backups"
    )
    excludes = @(
        "tokens/secrets/auth/.env/CC Switch",
        "sqlite runtime state",
        "logs/cache/browser state",
        "venv/vendor/node_modules",
        "AppData editor caches"
    )
} | ConvertTo-Json -Depth 5
Write-Utf8NoBomFile -Path (Join-Path $RepoRoot "manifest.json") -Content $manifest

Write-Host "Export complete."
Write-Host ("Skill counts: " + ($skillCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ", ")
