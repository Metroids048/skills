$ErrorActionPreference = 'Stop'
$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'

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

function New-SkillJunction {
    param([string]$LinkPath, [string]$TargetPath)
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Write-Warning "Missing target: $TargetPath"
        return
    }
    Remove-LinkOrDir -Path $LinkPath
    New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
}

function Mirror-Skill {
    param([string]$Name)
    $src = Join-Path $cursorSkills $Name
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "Missing cursor skill: $Name"
        return
    }
    $resolved = (Resolve-Path -LiteralPath $src).Path
    foreach ($root in @($claudeSkills, $codexSkills)) {
        if (-not (Test-Path $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        $dest = Join-Path $root $Name
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "Junction: $dest -> $resolved"
    }
}

# claude-code-prompts-reference
$ccRef = Join-Path $cursorSkills 'claude-code-prompts-reference'
New-Item -ItemType Directory -Path $ccRef -Force | Out-Null
New-SkillJunction (Join-Path $ccRef 'patterns') (Join-Path $vendor 'claude-code-prompts\patterns')
New-SkillJunction (Join-Path $ccRef 'skills') (Join-Path $vendor 'claude-code-prompts\skills')
New-SkillJunction (Join-Path $ccRef 'complete-prompts') (Join-Path $vendor 'claude-code-prompts\complete-prompts')

# most-capable vendor junction if missing
$mcRef = Join-Path $cursorSkills 'most-capable-agent-reference'
New-Item -ItemType Directory -Path $mcRef -Force | Out-Null
$vendorLink = Join-Path $mcRef 'vendor'
if (-not (Test-Path -LiteralPath $vendorLink)) {
    New-SkillJunction $vendorLink (Join-Path $vendor 'most-capable-agent')
}

foreach ($n in @(
        'claude-code-prompts-reference',
        'most-capable-agent-reference',
        'context-engineering',
        'ai-prompt-engineering',
        'workflow-gate'
    )) {
    Mirror-Skill -Name $n
}

Write-Host 'Quick junction install done.'
