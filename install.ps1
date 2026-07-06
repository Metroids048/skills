# One-click install: sync portable global AI config to user profile (Windows).

param(
    [switch]$UseJunctionSkills,
    [switch]$SkipProjectSnapshots
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = $env:USERPROFILE
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Ensure-Dir([string]$Path) {
    if ($Path -and -not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Backup-Path([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $backup = "$Path.bak-$Stamp"
    Move-Item -LiteralPath $Path -Destination $backup -Force
    Write-Host "Backed up: $Path -> $backup"
}

function Copy-Tree([string]$Source, [string]$Dest) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    Backup-Path $Dest
    robocopy $Source $Dest /E /XJ /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Copy failed: $Source -> $Dest" }
    Write-Host "Installed: $Dest"
}

function Copy-FileIfExists([string]$Source, [string]$Dest, [switch]$OnlyIfMissing) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    if ($OnlyIfMissing -and (Test-Path -LiteralPath $Dest)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    Copy-Item -LiteralPath $Source -Destination $Dest -Force
    Write-Host "Installed file: $Dest"
}

function Link-SkillsJunction([string]$Target, [string]$Link) {
    Ensure-Dir (Split-Path -Parent $Link)
    Backup-Path $Link
    cmd /c mklink /J "$Link" "$Target" | Out-Null
    Write-Host "Linked: $Link -> $Target"
}

Ensure-Dir (Join-Path $UserHome ".cursor")
Ensure-Dir (Join-Path $UserHome ".claude")
Ensure-Dir (Join-Path $UserHome ".codex")
Ensure-Dir (Join-Path $UserHome ".ai-workspace")

# Skills. Default preserves per-endpoint differences; -UseJunctionSkills favors dedup.
$cursorSkillsRepo = Join-Path $RepoRoot "skills\cursor"
$cursorSkillsHome = Join-Path $UserHome ".cursor\skills"
Copy-Tree -Source $cursorSkillsRepo -Dest $cursorSkillsHome

if ($UseJunctionSkills) {
    Link-SkillsJunction -Target $cursorSkillsHome -Link (Join-Path $UserHome ".claude\skills")
    Link-SkillsJunction -Target $cursorSkillsHome -Link (Join-Path $UserHome ".codex\skills")
} else {
    Copy-Tree -Source (Join-Path $RepoRoot "skills\claude") -Dest (Join-Path $UserHome ".claude\skills")
    Copy-Tree -Source (Join-Path $RepoRoot "skills\codex") -Dest (Join-Path $UserHome ".codex\skills")
}
Copy-Tree -Source (Join-Path $RepoRoot "skills\agents") -Dest (Join-Path $UserHome ".agents\skills")

# Cursor
Copy-Tree -Source (Join-Path $RepoRoot "cursor\rules") -Dest (Join-Path $UserHome ".cursor\rules")
Copy-Tree -Source (Join-Path $RepoRoot "cursor\commands") -Dest (Join-Path $UserHome ".cursor\commands")
Copy-Tree -Source (Join-Path $RepoRoot "cursor\hooks") -Dest (Join-Path $UserHome ".cursor\hooks")
Copy-Tree -Source (Join-Path $RepoRoot "cursor\mcp-configs") -Dest (Join-Path $UserHome ".cursor\mcp-configs")
Copy-FileIfExists -Source (Join-Path $RepoRoot "cursor\hooks.json.template") -Dest (Join-Path $UserHome ".cursor\hooks.json")
Copy-FileIfExists -Source (Join-Path $RepoRoot "cursor\mcp.json.example") -Dest (Join-Path $UserHome ".cursor\mcp.json") -OnlyIfMissing

# Claude Code
Copy-FileIfExists -Source (Join-Path $RepoRoot "claude\AGENTS.md") -Dest (Join-Path $UserHome ".claude\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "claude\CLAUDE.md") -Dest (Join-Path $UserHome ".claude\CLAUDE.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "claude\settings.json.example") -Dest (Join-Path $UserHome ".claude\settings.json") -OnlyIfMissing
Copy-FileIfExists -Source (Join-Path $RepoRoot "claude\global-skills-index.md") -Dest (Join-Path $UserHome ".claude\global-skills-index.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "claude\global-skills-index-zh.md") -Dest (Join-Path $UserHome ".claude\global-skills-index-zh.md")
Copy-Tree -Source (Join-Path $RepoRoot "claude\commands") -Dest (Join-Path $UserHome ".claude\commands")
Copy-Tree -Source (Join-Path $RepoRoot "claude\rules") -Dest (Join-Path $UserHome ".claude\rules")
Copy-Tree -Source (Join-Path $RepoRoot "claude\hooks") -Dest (Join-Path $UserHome ".claude\hooks")
Copy-Tree -Source (Join-Path $RepoRoot "claude\mcp-configs") -Dest (Join-Path $UserHome ".claude\mcp-configs")

# Codex
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\AGENTS.md") -Dest (Join-Path $UserHome ".codex\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\RTK.md") -Dest (Join-Path $UserHome ".codex\RTK.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\config.toml.example") -Dest (Join-Path $UserHome ".codex\config.toml") -OnlyIfMissing
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\codex-plus-overlay.toml.example") -Dest (Join-Path $UserHome ".codex\codex-plus-overlay.toml") -OnlyIfMissing
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\codex-plus-mcp-overlay.toml.example") -Dest (Join-Path $UserHome ".codex\codex-plus-mcp-overlay.toml") -OnlyIfMissing
Copy-FileIfExists -Source (Join-Path $RepoRoot "codex\hooks.json.template") -Dest (Join-Path $UserHome ".codex\hooks.json")
Copy-Tree -Source (Join-Path $RepoRoot "codex\hooks") -Dest (Join-Path $UserHome ".codex\hooks")
Copy-Tree -Source (Join-Path $RepoRoot "codex\scripts") -Dest (Join-Path $UserHome ".codex\scripts")
Copy-Tree -Source (Join-Path $RepoRoot "codex\mcp-configs") -Dest (Join-Path $UserHome ".codex\mcp-configs")

# Shared AI workspace
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\scripts") -Dest (Join-Path $UserHome ".ai-workspace\scripts")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\memory") -Dest (Join-Path $UserHome ".ai-workspace\memory")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\docs") -Dest (Join-Path $UserHome ".ai-workspace\docs")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\ai-coding-os") -Dest (Join-Path $UserHome ".ai-workspace\ai-coding-os")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\templates") -Dest (Join-Path $UserHome ".ai-workspace\templates")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\skills-curated") -Dest (Join-Path $UserHome ".ai-workspace\skills-curated")
Copy-FileIfExists -Source (Join-Path $RepoRoot "ai-workspace\AGENT-GLOBAL-STACK.md") -Dest (Join-Path $UserHome ".ai-workspace\AGENT-GLOBAL-STACK.md")
Copy-FileIfExists -Source (Join-Path $RepoRoot "ai-workspace\skills-locale-zh.json") -Dest (Join-Path $UserHome ".ai-workspace\skills-locale-zh.json")

if (-not $SkipProjectSnapshots) {
    Write-Host "Project snapshots are stored under repo/projects/. Copy them into matching project roots manually when those repos exist on this machine."
}

Write-Host ""
Write-Host "Done. Restart Cursor / Claude Code / Codex."
Write-Host "Review *.example files and configure real secrets locally; real tokens are intentionally not committed."
