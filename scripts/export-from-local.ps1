# ai-global-config export
# Sync Cursor / Claude Code / Codex global config from this machine into the repo.

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
. $utf8Helpers

function Sync-Tree {
    param(
        [string]$Source,
        [string]$Dest,
        [string[]]$Exclude = @()
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
    $parent = Split-Path -Parent $Dest
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    robocopy $Source $Dest /E /NFL /NDL /NJH /NJS /NC /NS /NP `
        /XD node_modules .git __pycache__ .venv dist `
        /XF *.sqlite *.sqlite-shm *.sqlite-wal auth.json .env .env.local `
        | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Source -> $Dest" }
    Write-Host "Synced: $Source -> $Dest"
}

function Copy-FileIfExists {
    param([string]$Source, [string]$Dest)
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skip missing file: $Source"
        return
    }
    $dir = Split-Path -Parent $Dest
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Copy-Item -LiteralPath $Source -Destination $Dest -Force
    Write-Host "Copied: $Source -> $Dest"
}

# Skills (Cursor is source of truth)
Sync-Tree -Source (Join-Path $UserHome ".cursor\skills") -Dest (Join-Path $RepoRoot "skills\cursor")

# Cursor rules
Sync-Tree -Source (Join-Path $UserHome ".cursor\rules") -Dest (Join-Path $RepoRoot "cursor\rules")

# Cursor hooks / MCP examples (templates only)
Copy-FileIfExists -Source (Join-Path $UserHome ".cursor\hooks.json") -Dest (Join-Path $RepoRoot "cursor\hooks.json.template")
Copy-FileIfExists -Source (Join-Path $UserHome ".cursor\mcp.json") -Dest (Join-Path $RepoRoot "cursor\mcp.json.example")

# Claude Code
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\AGENTS.md") -Dest (Join-Path $RepoRoot "claude\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".claude\settings.json") -Dest (Join-Path $RepoRoot "claude\settings.json.example")
if (Test-Path -LiteralPath (Join-Path $UserHome ".claude\hooks")) {
    Sync-Tree -Source (Join-Path $UserHome ".claude\hooks") -Dest (Join-Path $RepoRoot "claude\hooks")
}

# Codex
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\AGENTS.md") -Dest (Join-Path $RepoRoot "codex\AGENTS.md")
Copy-FileIfExists -Source (Join-Path $UserHome ".codex\config.toml") -Dest (Join-Path $RepoRoot "codex\config.toml.example")

# ai-workspace memory/docs from home; scripts stay repo SSOT (see end of script)
$wsScripts = Join-Path $UserHome ".ai-workspace\scripts"
$wsMemory = Join-Path $UserHome ".ai-workspace\memory"
$wsDocs = Join-Path $UserHome ".ai-workspace\docs"
if (Test-Path -LiteralPath $wsMemory) {
    Sync-Tree -Source $wsMemory -Dest (Join-Path $RepoRoot "ai-workspace\memory")
}
if (Test-Path -LiteralPath $wsDocs) {
    Sync-Tree -Source $wsDocs -Dest (Join-Path $RepoRoot "ai-workspace\docs")
}

# manifest
$skillCount = 0
$skillsRoot = Join-Path $RepoRoot "skills\cursor"
if (Test-Path -LiteralPath $skillsRoot) {
    $skillCount = (Get-ChildItem -LiteralPath $skillsRoot -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue).Count
}
$manifest = @{
    version = "1.0.0"
    exportedAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    skillCount = $skillCount
    sourceMachine = $env:COMPUTERNAME
} | ConvertTo-Json -Depth 3
Write-Utf8NoBomFile -Path (Join-Path $RepoRoot "manifest.json") -Content $manifest

# Push repo SSOT scripts -> home (avoid stale home overwriting repo on next export)
$repoScripts = Join-Path $RepoRoot "ai-workspace\scripts"
if (Test-Path -LiteralPath $repoScripts) {
    if (-not (Test-Path -LiteralPath $wsScripts)) {
        New-Item -ItemType Directory -Path $wsScripts -Force | Out-Null
    }
    robocopy $repoScripts $wsScripts /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed pushing scripts to home" }
    Write-Host "Pushed repo scripts -> $wsScripts"
}

# Redact secrets in exported templates
$settingsExample = Join-Path $RepoRoot "claude\settings.json.example"
if (Test-Path -LiteralPath $settingsExample) {
    $raw = Read-Utf8File -Path $settingsExample
    $redacted = $raw -replace 'token=[^"&\s]+', 'token=YOUR_VIBE_AROUND_TOKEN'
    if ($redacted -ne $raw) {
        Write-Utf8NoBomFile -Path $settingsExample -Content $redacted
        Write-Host "Redacted token in claude/settings.json.example"
    }
}

Write-Host "Export complete. Skills: $skillCount"
