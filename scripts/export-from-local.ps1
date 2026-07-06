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
        [switch]$FollowJunctions
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
    $excludeDirs = $CommonExcludeDirs + $ExtraExcludeDirs
    $excludeFiles = $CommonExcludeFiles + $ExtraExcludeFiles
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
$projects = @(
    @{ Name = "agent-platform"; Path = Join-Path $UserHome "Desktop\Agent Platform" },
    @{ Name = "program1-main"; Path = Join-Path $UserHome "Desktop\program1-main" },
    @{ Name = "demo1"; Path = Join-Path $UserHome "Desktop\demo1" }
)
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
    version = "1.1.0"
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
        "project agent memory snapshots"
    )
    excludes = @(
        "tokens/secrets/auth/session files",
        "sqlite runtime state",
        "logs/cache/browser state",
        "venv/node_modules/vendor runtime caches"
    )
} | ConvertTo-Json -Depth 5
Write-Utf8NoBomFile -Path (Join-Path $RepoRoot "manifest.json") -Content $manifest

Write-Host "Export complete."
Write-Host ("Skill counts: " + ($skillCounts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ", ")
