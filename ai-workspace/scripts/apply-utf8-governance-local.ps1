$ErrorActionPreference = "Stop"
$skills = "C:\Users\win\Desktop\skills"
$UserHome = $env:USERPROFILE

Copy-Item -LiteralPath (Join-Path $skills "cursor\rules\windows-utf8-chinese-files.mdc") -Destination (Join-Path $UserHome ".cursor\rules\windows-utf8-chinese-files.mdc") -Force
Copy-Item -LiteralPath (Join-Path $skills "cursor\rules\windows-agent-shell.mdc") -Destination (Join-Path $UserHome ".cursor\rules\windows-agent-shell.mdc") -Force
Copy-Item -LiteralPath (Join-Path $skills "claude\AGENTS.md") -Destination (Join-Path $UserHome ".claude\AGENTS.md") -Force
Copy-Item -LiteralPath (Join-Path $skills "codex\AGENTS.md") -Destination (Join-Path $UserHome ".codex\AGENTS.md") -Force
Copy-Item -LiteralPath (Join-Path $skills "skills\cursor\workflow-gate\SKILL.md") -Destination (Join-Path $UserHome ".cursor\skills\workflow-gate\SKILL.md") -Force

$scriptNames = @(
    "Write-Utf8NoBom.ps1", "ensure-utf8-console.ps1", "scan-encoding-issues.ps1", "scan-encoding-issues.mjs",
    "strip-utf8-bom.mjs", "strip-bom-all-active-repos.ps1", "scan-all-active-repos.ps1",
    "apply-utf8-governance-local.ps1", "fix-invalid-utf8-svg.mjs", "rtk-hook-cursor.ps1",
    "repair-cursor-plugin-hooks.ps1", "repair-tri-end-hooks.ps1", "scan-global-skills.ps1", "scan-project-skills.ps1"
)
foreach ($name in $scriptNames) {
    $src = Join-Path $skills "ai-workspace\scripts\$name"
    if (Test-Path -LiteralPath $src) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $UserHome ".ai-workspace\scripts\$name") -Force
    }
}

Write-Host "apply-utf8-governance-local.ps1 complete"
