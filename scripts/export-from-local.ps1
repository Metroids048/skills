# Export current machine's 3-end AI config into this repo (canonical source for GitHub sync).
# Run from repo root: powershell -File scripts/export-from-local.ps1
param(
    [string]$RepoRoot = '',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

if (-not $RepoRoot) {
    $RepoRoot = Split-Path $PSScriptRoot -Parent
}

$userHome = $env:USERPROFILE
$agentPlatform = 'C:\Users\win\Desktop\Agent Platform'

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

function Copy-TreeResolved {
    param([string]$Source, [string]$Dest, [switch]$Overwrite)
    if (-not (Test-Path $Source)) {
        Write-Warning "Skip missing: $Source"
        return
    }
    Ensure-Dir $Dest
    if (Test-Path $Dest) {
        if (-not $Overwrite) { Write-Host "Exists (use -Force): $Dest"; return }
        Remove-Item -LiteralPath $Dest -Recurse -Force
    }
    # Resolve junctions — copy real files for portability
    & robocopy $Source $Dest /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE): $Source -> $Dest" }
    Write-Host "Exported: $Dest"
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    Ensure-Dir (Split-Path $Path -Parent)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Redact-SecretsInJson {
    param([string]$Json)
    $j = $Json
    $j = $j -replace '(token=)[a-f0-9]{32,}', '${1}YOUR_VIBEAROUND_TOKEN'
    $j = $j -replace '("url"\s*:\s*"http://127\.0\.0\.1:12358/va/mcp\?token=)[^"]+"', '${1}YOUR_VIBEAROUND_TOKEN"'
    $j = $j -replace 'C:\\\\Users\\\\win\\\\AppData\\\\Roaming\\\\Python\\\\Python312\\\\Scripts\\\\headroom\.exe', '{{HEADROOM_EXE}}'
    return $j
}

Write-Host "=== Export 3-end AI config -> $RepoRoot ==="
Write-Host ''

# --- Skills (canonical: ~/.cursor/skills) ---
Copy-TreeResolved -Source (Join-Path $userHome '.cursor\skills') -Dest (Join-Path $RepoRoot 'skills\cursor') -Overwrite:$Force

# --- Cursor rules ---
Copy-TreeResolved -Source (Join-Path $userHome '.cursor\rules') -Dest (Join-Path $RepoRoot 'cursor\rules') -Overwrite:$Force

# --- ai-workspace scripts (runtime) + merge Agent Platform hooks canonical ---
$scriptsDst = Join-Path $RepoRoot 'ai-workspace\scripts'
Ensure-Dir $scriptsDst
$runtimeScripts = Join-Path $userHome '.ai-workspace\scripts'
if (Test-Path $runtimeScripts) {
    Get-ChildItem $runtimeScripts -File | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $scriptsDst $_.Name) -Force
    }
}
$hooksSrc = Join-Path $agentPlatform 'scripts\hooks'
if (Test-Path $hooksSrc) {
    Get-ChildItem $hooksSrc -File | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $scriptsDst $_.Name) -Force
    }
    $refSrc = Join-Path $hooksSrc 'refinements'
    if (Test-Path $refSrc) {
        Copy-TreeResolved -Source $refSrc -Dest (Join-Path $scriptsDst 'refinements') -Overwrite:$Force
    }
}
Write-Host "Exported: ai-workspace/scripts (merged)"

# --- ai-workspace docs + memory templates ---
if (Test-Path (Join-Path $userHome '.ai-workspace\docs')) {
    Copy-TreeResolved -Source (Join-Path $userHome '.ai-workspace\docs') -Dest (Join-Path $RepoRoot 'ai-workspace\docs') -Overwrite:$Force
}
$memDst = Join-Path $RepoRoot 'ai-workspace\memory'
Ensure-Dir $memDst
@(
    'user-memory.md', 'global-decisions-log.md', 'global-task-history.md',
    'projects-registry.md', 'skills-gap-analysis.md', 'batch2-skills-installed.md',
    'supplement-tools-installed.md'
) | ForEach-Object {
    $src = Join-Path (Join-Path $userHome '.ai-workspace\memory') $_
    if (Test-Path $src) {
        Copy-Item -LiteralPath $src -Destination (Join-Path $memDst $_) -Force
        Write-Host "Memory template: $_"
    }
}

# --- Claude ---
Ensure-Dir (Join-Path $RepoRoot 'claude')
foreach ($f in @('AGENTS.md', 'CLAUDE.md')) {
    $src = Join-Path (Join-Path $userHome '.claude') $f
    if (Test-Path $src) { Copy-Item -LiteralPath $src -Destination (Join-Path $RepoRoot "claude\$f") -Force }
}
if (Test-Path (Join-Path $userHome '.claude\AGENTS.ecc-supplement.md')) {
    Copy-Item (Join-Path $userHome '.claude\AGENTS.ecc-supplement.md') (Join-Path $RepoRoot 'claude\AGENTS.ecc-supplement.md') -Force
}

$settingsPath = Join-Path $userHome '.claude\settings.json'
if (Test-Path $settingsPath) {
    $raw = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8
    $example = Redact-SecretsInJson -Json $raw
    Write-Utf8NoBom -Path (Join-Path $RepoRoot 'claude\settings.json.example') -Content $example
    Write-Host 'Exported: claude/settings.json.example (tokens redacted)'
}

# hooks template (paths use {{USERPROFILE}} placeholder)
$hooksTemplate = @'
{
  "PreToolUse": {
    "hooks": [
      {
        "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\clarification-hard-gate.ps1\" -OutputFormat Claude",
        "timeout": 15,
        "type": "command",
        "statusMessage": "Clarification hard gate"
      }
    ],
    "matcher": "Write|Edit|MultiEdit|StrReplace|apply_patch"
  },
  "SessionStart": [
    {
      "hooks": [
        {
          "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\scan-global-skills.ps1\" -OutputFormat Claude -HookEvent SessionStart",
          "timeout": 45,
          "type": "command",
          "statusMessage": "Load global skills"
        }
      ],
      "matcher": "startup|resume|clear|compact"
    }
  ],
  "UserPromptSubmit": [
    {
      "hooks": [
        {
          "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\scan-global-skills.ps1\" -OutputFormat Claude -HookEvent UserPromptSubmit",
          "timeout": 45,
          "type": "command",
          "statusMessage": "Match global skills"
        }
      ]
    }
  ]
}
'@
Write-Utf8NoBom -Path (Join-Path $RepoRoot 'claude\hooks.fragment.json') -Content $hooksTemplate

# --- Codex ---
Ensure-Dir (Join-Path $RepoRoot 'codex')
if (Test-Path (Join-Path $userHome '.codex\AGENTS.md')) {
    Copy-Item (Join-Path $userHome '.codex\AGENTS.md') (Join-Path $RepoRoot 'codex\AGENTS.md') -Force
}
if (Test-Path (Join-Path $userHome '.codex\AGENTS.ecc-supplement.md')) {
    Copy-Item (Join-Path $userHome '.codex\AGENTS.ecc-supplement.md') (Join-Path $RepoRoot 'codex\AGENTS.ecc-supplement.md') -Force
}

$configToml = Join-Path $userHome '.codex\config.toml'
if (Test-Path $configToml) {
    $toml = Get-Content -LiteralPath $configToml -Raw -Encoding UTF8
    # Strip machine-specific project trust paths
    $toml = $toml -replace '(?ms)\[projects\..*?\]\r?\ntrust_level.*?\r?\n', ''
    $toml = $toml -replace '(?ms)\[hooks\.state\..*?\]\r?\ntrusted_hash.*?\r?\n', ''
    $toml = $toml -replace '(token=)[a-f0-9]{32,}', '${1}YOUR_VIBEAROUND_TOKEN'
    $toml = $toml -replace 'command = "C:\\\\Users\\\\win\\\\AppData\\\\Roaming\\\\Python\\\\Python312\\\\Scripts\\\\headroom\.exe"', 'command = "{{HEADROOM_EXE}}"'
    $toml = $toml -replace '(?ms)\[marketplaces\..*?\]\r?\n.*?(?=\r?\n\[|\r?\n#|\z)', ''
    Write-Utf8NoBom -Path (Join-Path $RepoRoot 'codex\config.toml.example') -Content $toml.TrimEnd() + "`n"
    Write-Host 'Exported: codex/config.toml.example (machine paths stripped)'
}

# --- Cursor hooks + mcp ---
Ensure-Dir (Join-Path $RepoRoot 'cursor')
$cursorHooks = @'
{
  "version": 1,
  "hooks": {
    "preToolUse": {
      "matcher": "Write|Edit",
      "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\clarification-hard-gate.ps1\" -OutputFormat Cursor",
      "timeout": 15
    },
    "sessionStart": [
      {
        "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\scan-global-skills.ps1\" -OutputFormat Cursor -HookEvent SessionStart",
        "timeout": 45
      }
    ],
    "beforeSubmitPrompt": [
      {
        "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"{{USERPROFILE}}\\.ai-workspace\\scripts\\scan-global-skills.ps1\" -OutputFormat Cursor -HookEvent UserPromptSubmit",
        "timeout": 45
      }
    ]
  }
}
'@
Write-Utf8NoBom -Path (Join-Path $RepoRoot 'cursor\hooks.json.template') -Content $cursorHooks

$mcpPath = Join-Path $userHome '.cursor\mcp.json'
if (Test-Path $mcpPath) {
    $mcp = Redact-SecretsInJson -Json (Get-Content -LiteralPath $mcpPath -Raw -Encoding UTF8)
    Write-Utf8NoBom -Path (Join-Path $RepoRoot 'cursor\mcp.json.example') -Content $mcp
}

# --- Skill count in manifest ---
$skillCount = (Get-ChildItem (Join-Path $RepoRoot 'skills\cursor') -Directory -ErrorAction SilentlyContinue).Count
$ruleCount = (Get-ChildItem (Join-Path $RepoRoot 'cursor\rules') -Filter '*.mdc' -ErrorAction SilentlyContinue).Count
$manifestPath = Join-Path $RepoRoot 'manifest.json'
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$manifest | Add-Member -NotePropertyName 'exportedAt' -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd') -Force
$manifest | Add-Member -NotePropertyName 'skillCount' -NotePropertyValue $skillCount -Force
$manifest | Add-Member -NotePropertyName 'ruleCount' -NotePropertyValue $ruleCount -Force
Write-Utf8NoBom -Path $manifestPath -Content ($manifest | ConvertTo-Json -Depth 5)

Write-Host ''
Write-Host "Done. Skills: $skillCount | Rules: $ruleCount"
Write-Host 'Review secrets in *.example files before git push.'
