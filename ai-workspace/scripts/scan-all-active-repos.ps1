$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repos = @(
    "C:\Users\win\Desktop\program1-main",
    "C:\Users\win\Desktop\Agent Platform",
    "C:\Users\win\Desktop\demo1",
    "C:\Users\win\Desktop\skills"
)
$scan = Join-Path $scriptDir "scan-encoding-issues.ps1"
foreach ($repo in $repos) {
    if (-not (Test-Path -LiteralPath $repo)) {
        Write-Warning "Skip missing repo: $repo"
        continue
    }
    Write-Host "=== Scan: $repo ==="
    & $scan -RepoPath $repo
}
