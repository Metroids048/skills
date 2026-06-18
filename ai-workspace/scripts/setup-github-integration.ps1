# One-shot GitHub integration check for Windows (git + gh + MCP smoke test).
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File setup-github-integration.ps1

param(
    [string]$GitUserName = 'Metroids048',
    [string]$GitUserEmail = 'Metroids048@users.noreply.github.com'
)

$ErrorActionPreference = 'Stop'

function Write-Section($title) {
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
}

Write-Section 'Global git identity'
$currentName = git config --global user.name 2>$null
$currentEmail = git config --global user.email 2>$null
if (-not $currentName) { git config --global user.name $GitUserName; Write-Host "Set user.name=$GitUserName" }
else { Write-Host "user.name=$currentName" }
if (-not $currentEmail) { git config --global user.email $GitUserEmail; Write-Host "Set user.email=$GitUserEmail" }
else { Write-Host "user.email=$currentEmail" }
git config --global init.defaultBranch main 2>$null
$helper = git config --global credential.helper 2>$null
if (-not $helper) {
    git config --global credential.helper manager-core 2>$null
    if (-not $?) { git config --global credential.helper manager }
}
Write-Host "credential.helper=$(git config --global credential.helper)"

Write-Section 'GitHub CLI (gh)'
try {
    gh auth status 2>&1 | Write-Host
    gh auth setup-git 2>$null
    Write-Host 'gh auth OK' -ForegroundColor Green
} catch {
    Write-Host 'gh not logged in. Run once:' -ForegroundColor Yellow
    Write-Host '  gh auth login --hostname github.com --git-protocol https --web'
    Write-Host 'Then re-run this script.'
}

Write-Section 'Remote sanity (optional repo path)'
if ($PWD.Path -match 'demo1|program1') {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        Write-Host "origin=$remote"
        git ls-remote --heads origin main 2>&1 | Select-Object -First 1 | Write-Host
    }
}

Write-Section 'Notes'
Write-Host '- Cursor GitHub MCP: enabled in ~/.cursor/mcp.json (server-github via npx)'
Write-Host '- Cursor UI push: Source Control -> Commit -> Sync (needs gh or GCM credentials)'
Write-Host '- PAT (optional): set user env GITHUB_PERSONAL_ACCESS_TOKEN for headless MCP outside Cursor OAuth'
