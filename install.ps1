# One-click install: sync global AI config to user profile (Windows)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = $env:USERPROFILE

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Copy-Tree([string]$Source, [string]$Dest) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    if (Test-Path -LiteralPath $Dest) { Remove-Item -LiteralPath $Dest -Recurse -Force }
    robocopy $Source $Dest /E /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Copy failed: $Source" }
    Write-Host "Installed: $Dest"
}

function Link-SkillsJunction([string]$Target, [string]$Link) {
    Ensure-Dir (Split-Path -Parent $Link)
    if (Test-Path -LiteralPath $Link) { Remove-Item -LiteralPath $Link -Recurse -Force }
    cmd /c mklink /J "$Link" "$Target" | Out-Null
    Write-Host "Linked: $Link -> $Target"
}

# Skills hub at ~/.cursor/skills
$cursorSkills = Join-Path $UserHome ".cursor\skills"
Copy-Tree -Source (Join-Path $RepoRoot "skills\cursor") -Dest $cursorSkills

# Junction Claude + Codex skills to Cursor hub
Link-SkillsJunction -Target $cursorSkills -Link (Join-Path $UserHome ".claude\skills")
Link-SkillsJunction -Target $cursorSkills -Link (Join-Path $UserHome ".codex\skills")

# Cursor rules
Copy-Tree -Source (Join-Path $RepoRoot "cursor\rules") -Dest (Join-Path $UserHome ".cursor\rules")

# Claude / Codex AGENTS
Ensure-Dir (Join-Path $UserHome ".claude")
Ensure-Dir (Join-Path $UserHome ".codex")
Copy-Item -LiteralPath (Join-Path $RepoRoot "claude\AGENTS.md") -Destination (Join-Path $UserHome ".claude\AGENTS.md") -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $RepoRoot "codex\AGENTS.md") -Destination (Join-Path $UserHome ".codex\AGENTS.md") -Force -ErrorAction SilentlyContinue

# ai-workspace
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\scripts") -Dest (Join-Path $UserHome ".ai-workspace\scripts")
Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\memory") -Dest (Join-Path $UserHome ".ai-workspace\memory")
if (Test-Path -LiteralPath (Join-Path $RepoRoot "ai-workspace\docs")) {
    Copy-Tree -Source (Join-Path $RepoRoot "ai-workspace\docs") -Dest (Join-Path $UserHome ".ai-workspace\docs")
}

Write-Host ""
Write-Host "Done. Restart Cursor / Claude Code / Codex."
Write-Host "Configure secrets per secrets/README.md if present."
