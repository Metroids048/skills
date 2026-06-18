# Optional thin project memory overlay for team repos.
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [string]$StartDir = '',
    [switch]$SkipDesign
)

$ErrorActionPreference = 'Stop'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Expand-ProjectTemplate {
    param([string]$TemplatePath, [string]$ProjectName, [string]$ProjectPath)
    if (-not (Test-Path $TemplatePath)) { return $null }
    $raw = Get-Content -LiteralPath $TemplatePath -Raw -Encoding UTF8
    return $raw.Replace('{{PROJECT_NAME}}', $ProjectName).
        Replace('{{PROJECT_PATH}}', $ProjectPath).
        Replace('{{DATE}}', (Get-Date -Format 'yyyy-MM-dd'))
}

function Ensure-FromTemplate {
    param(
        [string]$DestPath,
        [string]$TemplatePath,
        [string]$ProjectName,
        [string]$ProjectPath
    )
    if (Test-Path $DestPath) {
        Write-Host "Exists: $DestPath"
        return
    }
    $content = Expand-ProjectTemplate -TemplatePath $TemplatePath -ProjectName $ProjectName -ProjectPath $ProjectPath
    if (-not $content) {
        Write-Warning "Missing template: $TemplatePath"
        return
    }
    Write-Utf8NoBomFile -Path $DestPath -Content $content
    Write-Host "Created: $DestPath"
}

$dir = if ($StartDir) { (Resolve-Path $StartDir).Path } else { (Get-Location).Path }
$memoryDir = Join-Path $dir '.github\agent\memory'
$templatesRoot = Join-Path $env:USERPROFILE '.ai-workspace\templates\project'

if (-not (Test-Path $memoryDir)) {
    New-Item -ItemType Directory -Path $memoryDir -Force | Out-Null
}

$overlayPath = Join-Path $memoryDir 'project-memory.md'
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
    Write-Utf8NoBomFile -Path $overlayPath -Content $content
    Write-Host "Created: $overlayPath"
}
else {
    Write-Host "Exists: $overlayPath"
}

Ensure-FromTemplate -DestPath (Join-Path $memoryDir 'AGENT.md') -TemplatePath (Join-Path $templatesRoot 'AGENT.md') -ProjectName $ProjectName -ProjectPath $dir
Ensure-FromTemplate -DestPath (Join-Path $memoryDir 'RULES.md') -TemplatePath (Join-Path $templatesRoot 'RULES.md') -ProjectName $ProjectName -ProjectPath $dir

if (-not $SkipDesign) {
    Ensure-FromTemplate -DestPath (Join-Path $memoryDir 'DESIGN.md') -TemplatePath (Join-Path $templatesRoot 'DESIGN.md') -ProjectName $ProjectName -ProjectPath $dir
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
    $shim = @'
# Project shim — global rules in ~/.claude/AGENTS.md; this repo overrides via AGENTS.md if present.

See `@AGENTS.md` in repo root if exists, else global AGENTS.
'@
    Write-Utf8NoBomFile -Path $claudeShim -Content $shim
    Write-Host "Created: $claudeShim"
}

Write-Host 'Done. Global memory still primary; project overlay in .github/agent/memory/.'
