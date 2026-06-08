# Refresh ~/.ai-workspace/scripts from Agent Platform repo (canonical source).
param(
    [string]$RepoRoot = 'C:\Users\win\Desktop\Agent Platform'
)

$ErrorActionPreference = 'Stop'
$install = Join-Path $RepoRoot 'scripts\global-workspace\install-global-workspace.ps1'
if (-not (Test-Path $install)) {
    Write-Error "Not found: $install"
}
& $install -RepoRoot $RepoRoot
Write-Host 'Workspace scripts refreshed from repo.'
