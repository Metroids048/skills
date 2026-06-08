# Optional thin project memory overlay for team repos.
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [string]$StartDir = ''
)

$ErrorActionPreference = 'Stop'

$dir = if ($StartDir) { (Resolve-Path $StartDir).Path } else { (Get-Location).Path }
$memoryDir = Join-Path $dir '.github\agent\memory'
$overlayPath = Join-Path $memoryDir 'project-memory.md'

if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
}

if (-not (Test-Path $overlayPath)) {
    $content = @"
# Project Memory — $ProjectName

Last updated: $(Get-Date -Format 'yyyy-MM-dd')

## Project

- **Name**: $ProjectName
- **Path**: $dir

## Team facts (shared via git)

(Add stack, directory conventions, validation commands specific to this repo.)

## Validation

| Command | Purpose |
|---------|---------|
| | |

"@
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($overlayPath, $content, $utf8)
    Write-Host "Created: $overlayPath"
}
else {
    Write-Host "Exists: $overlayPath"
}

# Register in global projects-registry
$registry = Join-Path $env:USERPROFILE '.ai-workspace\memory\projects-registry.md'
if (Test-Path $registry) {
    $line = "| $ProjectName | ``$dir`` | $(Get-Date -Format 'yyyy-MM-dd') | |"
    if (-not ((Get-Content -LiteralPath $registry -Raw) -match [regex]::Escape($dir))) {
        Add-Content -LiteralPath $registry -Value $line -Encoding UTF8
        Write-Host "Registered in projects-registry.md"
    }
}

# Optional CLAUDE.md shim
$claudeShim = Join-Path $dir 'CLAUDE.md'
if (-not (Test-Path $claudeShim)) {
    @'
# Project shim — global rules in ~/.claude/AGENTS.md; this repo overrides via AGENTS.md if present.

See `@AGENTS.md` in repo root if exists, else global AGENTS.
'@ | Set-Content -LiteralPath $claudeShim -Encoding utf8NoBOM
    Write-Host "Created: $claudeShim"
}

Write-Host 'Done. Global memory still primary; this file is team overlay only.'
