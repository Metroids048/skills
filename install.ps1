# Personal AI Runtime v2 one-click installer for Windows.
param([switch]$SkipLegacyHookCleanup)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = $env:USERPROFILE
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Ensure-Dir([string]$Path) { if ($Path -and -not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null } }
function Backup-Path([string]$Path) { if (Test-Path -LiteralPath $Path) { Move-Item -LiteralPath $Path -Destination "$Path.bak-$Stamp" -Force } }
function Copy-Tree([string]$Source, [string]$Dest, [switch]$PreserveExisting) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    if ((Test-Path -LiteralPath $Dest) -and -not $PreserveExisting) { Backup-Path $Dest }
    Ensure-Dir $Dest
    robocopy $Source $Dest /E /XJ /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "Copy failed: $Source -> $Dest" }
    Write-Host "Installed: $Dest"
}
function Copy-File([string]$Source, [string]$Dest) {
    if (-not (Test-Path -LiteralPath $Source)) { return }
    Ensure-Dir (Split-Path -Parent $Dest)
    Backup-Path $Dest
    Copy-Item -LiteralPath $Source -Destination $Dest -Force
}
function Remove-LegacySkillScanHooks([string]$SettingsPath) {
    if (-not (Test-Path -LiteralPath $SettingsPath)) { return }
    try { $json = Get-Content -LiteralPath $SettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { Write-Warning "Cannot parse $SettingsPath; legacy hooks unchanged."; return }
    if (-not $json.hooks) { return }
    $changed = $false
    foreach ($eventName in @("SessionStart", "UserPromptSubmit")) {
        $groups = @($json.hooks.$eventName)
        if (-not $groups) { continue }
        $newGroups = @()
        foreach ($group in $groups) {
            $hooks = @($group.hooks | Where-Object { -not ($_.command -match "scan-global-skills\.ps1") })
            if ($hooks.Count -ne @($group.hooks).Count) { $changed = $true }
            if ($hooks.Count -gt 0) { $group.hooks = $hooks; $newGroups += $group }
        }
        $json.hooks.$eventName = $newGroups
    }
    if ($changed) {
        Copy-Item -LiteralPath $SettingsPath -Destination "$SettingsPath.bak-$Stamp" -Force
        $json | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $SettingsPath -Encoding UTF8
        Write-Host "Removed legacy full-scan skill hooks from: $SettingsPath"
    }
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
if (-not $python) { throw "Python 3 is required for Personal AI Runtime v2." }

foreach ($dir in @(".cursor", ".claude", ".codex", ".agents", ".ai-workspace")) { Ensure-Dir (Join-Path $UserHome $dir) }
Ensure-Dir (Join-Path $UserHome ".ai-workspace\private-memory")

# Runtime + registries + public-safe bootstrap memory.
Copy-Tree (Join-Path $RepoRoot "runtime") (Join-Path $UserHome ".ai-workspace\runtime")
Copy-Tree (Join-Path $RepoRoot "registry") (Join-Path $UserHome ".ai-workspace\registry")
Copy-Tree (Join-Path $RepoRoot "memory") (Join-Path $UserHome ".ai-workspace\memory")

# Skills v2: only canonical curated skills are exposed to agents.
# Legacy endpoint snapshots under repo/skills/ are intentionally NOT installed.
$canonicalSkills = Join-Path $RepoRoot "skills-src"
if (-not (Test-Path -LiteralPath $canonicalSkills)) { throw "Missing canonical skills-src/" }
Copy-Tree $canonicalSkills (Join-Path $UserHome ".ai-workspace\skills-src")
foreach ($dest in @(".cursor\skills", ".claude\skills", ".codex\skills", ".agents\skills")) {
    Copy-Tree $canonicalSkills (Join-Path $UserHome $dest)
}

# Thin platform adapters. They all call the same aiw runtime for context + routing.
Copy-File (Join-Path $RepoRoot "codex\AGENTS.md") (Join-Path $UserHome ".codex\AGENTS.md")
Copy-File (Join-Path $RepoRoot "claude\AGENTS.md") (Join-Path $UserHome ".claude\AGENTS.md")
Copy-File (Join-Path $RepoRoot "claude\CLAUDE.md") (Join-Path $UserHome ".claude\CLAUDE.md")
Ensure-Dir (Join-Path $UserHome ".cursor\rules")
Copy-File (Join-Path $RepoRoot "cursor\rules\00-personal-ai-working-contract.mdc") (Join-Path $UserHome ".cursor\rules\00-personal-ai-working-contract.mdc")
Copy-File (Join-Path $RepoRoot "cursor\rules\01-personal-ai-runtime.mdc") (Join-Path $UserHome ".cursor\rules\01-personal-ai-runtime.mdc")

if (-not $SkipLegacyHookCleanup) {
    Remove-LegacySkillScanHooks (Join-Path $UserHome ".claude\settings.json")
}

$aiw = Join-Path $UserHome ".ai-workspace\runtime\aiw.py"
Write-Host "Running AIW doctor..."
if ($python.Name -eq "py.exe" -or $python.Name -eq "py") { & $python.Source -3 $aiw doctor } else { & $python.Source $aiw doctor }
if ($LASTEXITCODE -ne 0) { throw "AIW doctor failed" }

Write-Host ""
Write-Host "Personal AI Runtime v2 installed. Restart Cursor / Claude Code / Codex."
Write-Host "Private memory remains at: $UserHome\.ai-workspace\private-memory"
Write-Host "Legacy skills snapshots were NOT installed; active skills come only from skills-src/."
