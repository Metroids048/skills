# Create GitHub repo and push (requires: gh auth login)
param(
    [string]$RepoName = 'ai-global-config',
    [switch]$Public,
    [string]$RepoRoot = ''
)

$ErrorActionPreference = 'Stop'
if (-not $RepoRoot) { $RepoRoot = Split-Path $PSScriptRoot -Parent }

$gh = Get-Command gh -ErrorAction SilentlyContinue
if (-not $gh) {
    $ghPath = 'C:\Program Files\GitHub CLI\gh.exe'
    if (Test-Path $ghPath) { $gh = $ghPath } else { throw 'Install GitHub CLI: winget install GitHub.cli' }
}

Push-Location $RepoRoot
try {
    & $gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Run first: gh auth login'
        exit 1
    }

    $visibility = if ($Public) { '--public' } else { '--private' }
    $desc = 'Portable Cursor / Claude Code / Codex global config (skills, rules, hooks, AGENTS)'

    $remote = git remote get-url origin 2>$null
    if (-not $remote) {
        Write-Host "Creating repo $RepoName ..."
        & $gh repo create $RepoName $visibility --source=. --remote=origin --description $desc
        if ($LASTEXITCODE -ne 0) { throw 'gh repo create failed' }
    }

    $branch = git branch --show-current
    if (-not $branch) { git checkout -b main; $branch = 'main' }
    if ($branch -eq 'master') { git branch -M main; $branch = 'main' }

    Write-Host "Pushing to origin/$branch ..."
    git push -u origin $branch
    if ($LASTEXITCODE -ne 0) { throw 'git push failed' }

    $url = & $gh repo view --json url -q .url
    Write-Host ''
    Write-Host "Done: $url"
}
finally {
    Pop-Location
}
