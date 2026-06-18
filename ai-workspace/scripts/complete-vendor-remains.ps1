# Complete remaining vendor installs (GitHub git blocked; use HTTP download + junctions).
$ErrorActionPreference = 'Stop'

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        Remove-Item -LiteralPath $Path -Force
    }
    elseif ($item.PSIsContainer) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    else {
        Remove-Item -LiteralPath $Path -Force
    }
}

function Install-SkillJunction {
    param(
        [string]$SkillName,
        [string]$TargetDir
    )
    $cursor = Join-Path $env:USERPROFILE ".cursor\skills\$SkillName"
    $claude = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
    $codex = Join-Path $env:USERPROFILE ".codex\skills\$SkillName"
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        throw "Missing target: $TargetDir"
    }
    $resolved = (Resolve-Path -LiteralPath $TargetDir).Path
    foreach ($dest in @($cursor, $claude, $codex)) {
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "Junction: $dest -> $resolved"
    }
}

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'

# --- PAIPlugin prompting -> context-engineering (HTTP) ---
$ctxVendor = Join-Path $vendor 'PAIPlugin-prompting\context-engineering'
New-Item -ItemType Directory -Path $ctxVendor -Force | Out-Null
$skillUrl = 'https://raw.githubusercontent.com/danielmiessler/PAIPlugin/main/skills/prompting/SKILL.md'
$claudeUrl = 'https://raw.githubusercontent.com/danielmiessler/PAIPlugin/main/skills/prompting/CLAUDE.md'
$skillRaw = (Invoke-WebRequest -Uri $skillUrl -UseBasicParsing).Content
$claudeRaw = (Invoke-WebRequest -Uri $claudeUrl -UseBasicParsing).Content
$skillRaw = $skillRaw -replace '(?m)^name:\s*prompting\s*$', 'name: context-engineering'
$skillRaw = $skillRaw -replace '(?m)^description:\s*', 'description: Context engineering and prompt structure standards — signal-to-noise, progressive discovery, just-in-time loading. '
if ($skillRaw -notmatch 'disable-model-invocation') {
    $skillRaw = $skillRaw -replace '(?m)^---\s*\r?\n', "---`r`ndisable-model-invocation: true`r`n"
}
$skillRaw = $skillRaw -replace '\$\{PAI_DIR\}/skills/prompting/CLAUDE\.md', 'CLAUDE.md'
Write-Utf8NoBomFile -Path (Join-Path $ctxVendor 'SKILL.md') -Content $skillRaw
Write-Utf8NoBomFile -Path (Join-Path $ctxVendor 'CLAUDE.md') -Content $claudeRaw
Write-Host "Downloaded PAIPlugin prompting -> $ctxVendor"

# --- ai-prompt-engineering full upstream (already via python installer) ---
$peUpstream = Join-Path $vendor 'ai-prompt-engineering-upstream\ai-prompt-engineering'
if (-not (Test-Path -LiteralPath (Join-Path $peUpstream 'SKILL.md'))) {
    throw "Missing upstream ai-prompt-engineering; run python install-skill-from-github.py first."
}
$peSkill = Get-Content -LiteralPath (Join-Path $peUpstream 'SKILL.md') -Raw -Encoding UTF8
if ($peSkill -notmatch 'disable-model-invocation') {
    $peSkill = $peSkill -replace '(?m)^---\s*\r?\n', "---`r`ndisable-model-invocation: true`r`n"
    Write-Utf8NoBomFile -Path (Join-Path $peUpstream 'SKILL.md') -Content $peSkill
}

# --- Install junctions to tri-end ---
Install-SkillJunction -SkillName 'context-engineering' -TargetDir $ctxVendor
Install-SkillJunction -SkillName 'ai-prompt-engineering' -TargetDir $peUpstream

# --- Optional: claude-skill-registry metadata (lightweight) ---
$registryMeta = Join-Path $vendor 'claude-skill-registry'
New-Item -ItemType Directory -Path $registryMeta -Force | Out-Null
$readme = @"
# claude-skill-registry (metadata stub)

Full `ai-prompt-engineering` skill installed from upstream:
https://github.com/vasilyu1983/AI-Agents-public/tree/main/frameworks/shared-skills/skills/ai-prompt-engineering

Local path: ``$peUpstream``

Git clone of majiayu000/claude-skill-registry skipped (main repo has no committed skills tree; registry is index-only).
"@
Write-Utf8NoBomFile -Path (Join-Path $registryMeta 'README.md') -Content $readme

Write-Host 'Vendor remainder complete.'
