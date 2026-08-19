# Personal AI Runtime export.
# Default mode exports only portable public-safe configuration.
# Raw session/history material requires -IncludePrivateArchives AND a verified PRIVATE GitHub repository.

param(
    [switch]$Force,
    [switch]$IncludePrivateArchives
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$UserHome = $env:USERPROFILE

function Ensure-Dir([string]$Path) {
    if ($Path -and -not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Sync-Tree {
    param([string]$Source, [string]$Dest, [string[]]$ExtraExcludeDirs = @(), [string[]]$ExtraExcludeFiles = @())
    if (-not (Test-Path -LiteralPath $Source)) { Write-Warning "Skip missing: $Source"; return }
    if (Test-Path -LiteralPath $Dest) {
        if (-not $Force) { Write-Warning "Dest exists, use -Force: $Dest"; return }
        Remove-Item -LiteralPath $Dest -Recurse -Force
    }
    Ensure-Dir (Split-Path -Parent $Dest)
    $excludeDirs = @(".git", "__pycache__", ".venv", "venv", "node_modules", "cache", ".cache", "logs", "browser", "secrets", ".sandbox-secrets", "private-memory") + $ExtraExcludeDirs
    $excludeFiles = @("auth.json", ".credentials.json", ".env", ".env.*", "*.pem", "*.key", "*.p12", "*.pfx", "*token*.json", "*credentials*.json") + $ExtraExcludeFiles
    $args = @($Source, $Dest, "/E", "/XJ", "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP", "/XD") + $excludeDirs + @("/XF") + $excludeFiles
    & robocopy @args | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Source -> $Dest" }
    Write-Host "Synced: $Source -> $Dest"
}

function Copy-FileIfExists([string]$Source, [string]$Dest) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    Copy-Item -LiteralPath $Source -Destination $Dest -Force
    Write-Host "Copied: $Source -> $Dest"
}

function Assert-PrivateRepository {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $gh) {
        throw "-IncludePrivateArchives is fail-closed: GitHub CLI is required to verify repository visibility before raw private data can be exported."
    }
    Push-Location $RepoRoot
    try {
        $visibility = (& gh repo view --json visibility --jq '.visibility' 2>$null).Trim().ToUpperInvariant()
        if ($LASTEXITCODE -ne 0 -or $visibility -ne "PRIVATE") {
            throw "Private archive export refused: repository visibility is '$visibility', expected PRIVATE."
        }
    } finally {
        Pop-Location
    }
}

function Redact-Text([string]$Raw) {
    $value = $Raw
    $value = $value -replace '(?i)(token=)[^"&\s]+', '${1}YOUR_TOKEN'
    $value = $value -replace '(?i)(api[_-]?key=)[^"&\s]+', '${1}YOUR_API_KEY'
    $value = $value -replace '(?i)("?(?:api[_-]?key|token|secret|password|authorization)"?\s*:\s*")[^"]+(")', '${1}YOUR_SECRET${2}'
    $value = $value -replace '(?i)(Bearer\s+)[A-Za-z0-9._~+/=-]{12,}', '${1}YOUR_TOKEN'
    $value = $value -replace '(?i)(ghp_|github_pat_)[A-Za-z0-9_]{16,}', '${1}YOUR_TOKEN'
    $value = $value -replace '(?i)\bsk-proj-[A-Za-z0-9_-]{20,}', 'sk-proj-YOUR_SECRET'
    $value = $value -replace '(?i)\bsk-(?!YOUR_SECRET\b)[A-Za-z0-9_-]{20,}', 'sk-YOUR_SECRET'
    return $value
}

function Redact-File([string]$Path) {
    try {
        $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    } catch {
        Write-Warning "Skip non-text/unreadable file: $Path"
        return
    }
    $redacted = Redact-Text $raw
    if ($redacted -ne $raw) {
        [System.IO.File]::WriteAllText($Path, $redacted, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "Redacted: $Path"
    }
}

function Redact-Tree([string]$Root) {
    if (-not (Test-Path -LiteralPath $Root)) { return }
    Get-ChildItem -LiteralPath $Root -Recurse -File -Include "*.example", "*.template", "*.json", "*.jsonl", "*.toml", "*.md", "*.txt", "*.ps1", "*.py", "*.mjs", "*.js" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\\.git\\" } |
        ForEach-Object { Redact-File $_.FullName }
}

# Canonical skills are maintained in repo/skills-src. Do NOT refresh them from endpoint snapshots here.
# Export only portable configuration that is not private conversation history.
Copy-FileIfExists (Join-Path $UserHome ".cursor\USER_RULES.txt") (Join-Path $RepoRoot "cursor\USER_RULES.txt")
Sync-Tree (Join-Path $UserHome ".cursor\rules") (Join-Path $RepoRoot "cursor\rules") -ExtraExcludeDirs @("_archive")
Sync-Tree (Join-Path $UserHome ".cursor\commands") (Join-Path $RepoRoot "cursor\commands")

Copy-FileIfExists (Join-Path $UserHome ".claude\AGENTS.md") (Join-Path $RepoRoot "claude\AGENTS.local-snapshot.md")
Sync-Tree (Join-Path $UserHome ".claude\commands") (Join-Path $RepoRoot "claude\commands")
Sync-Tree (Join-Path $UserHome ".claude\rules") (Join-Path $RepoRoot "claude\rules")

Copy-FileIfExists (Join-Path $UserHome ".codex\RTK.md") (Join-Path $RepoRoot "codex\RTK.md")
Sync-Tree (Join-Path $UserHome ".codex\scripts") (Join-Path $RepoRoot "codex\scripts")

# Private durable memory always stays outside the repository in normal mode.
Write-Host "Private memory SSOT: $UserHome\.ai-workspace\private-memory (not exported)"

if ($IncludePrivateArchives) {
    Assert-PrivateRepository
    Write-Warning "Exporting raw private evidence because -IncludePrivateArchives was explicitly supplied. This is not durable memory."
    Sync-Tree (Join-Path $UserHome ".codex\sessions") (Join-Path $RepoRoot "archives\codex\sessions")
    Sync-Tree (Join-Path $UserHome ".codex\archived_sessions") (Join-Path $RepoRoot "archives\codex\archived_sessions")
    Sync-Tree (Join-Path $UserHome ".claude\file-history") (Join-Path $RepoRoot "archives\claude\file-history")
    Copy-FileIfExists (Join-Path $UserHome ".claude\history.jsonl") (Join-Path $RepoRoot "archives\claude\history.jsonl")
    Copy-FileIfExists (Join-Path $UserHome ".codex\session_index.jsonl") (Join-Path $RepoRoot "archives\codex\session_index.jsonl")

    $cursorProjects = Join-Path $UserHome ".cursor\projects"
    if (Test-Path -LiteralPath $cursorProjects) {
        Get-ChildItem -LiteralPath $cursorProjects -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $src = Join-Path $_.FullName "agent-transcripts"
            if (Test-Path -LiteralPath $src) {
                Sync-Tree $src (Join-Path $RepoRoot ("archives\cursor\agent-transcripts\" + $_.Name))
            }
        }
    }
    $knowledgeCenter = Join-Path $UserHome "Desktop\全局配置"
    if (Test-Path -LiteralPath $knowledgeCenter) {
        Sync-Tree $knowledgeCenter (Join-Path $RepoRoot "knowledge-center\raw") -ExtraExcludeDirs @(".git")
    }
    Redact-Tree (Join-Path $RepoRoot "archives")
    Redact-Tree (Join-Path $RepoRoot "knowledge-center\raw")
}

Redact-Tree (Join-Path $RepoRoot "cursor")
Redact-Tree (Join-Path $RepoRoot "claude")
Redact-Tree (Join-Path $RepoRoot "codex")

Write-Host "Export complete. Canonical skills and private memory were not overwritten."
