param(
    [switch]$DryRun,
    [switch]$SkipScan
)

$ErrorActionPreference = 'Stop'

$AiosRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$SkillSource = Join-Path $AiosRoot 'skills\ai-product-ui-workflow'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Write-TextNoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    }
    if ($DryRun) {
        Write-Host "[dry-run] write $Path"
        return
    }
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Backup-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $backup = "$Path.aios-bak-$Stamp"
    if (-not $DryRun) { Copy-Item -LiteralPath $Path -Destination $backup -Force }
    Write-Host "Backup: $backup"
}

function Upsert-ManagedBlock {
    param(
        [string]$Path,
        [string[]]$Lines
    )
    $start = '<!-- AIOS MANAGED BLOCK START -->'
    $end = '<!-- AIOS MANAGED BLOCK END -->'
    $nl = [Environment]::NewLine
    $block = (@($start) + $Lines + @($end)) -join $nl

    $existing = ''
    if (Test-Path -LiteralPath $Path) {
        $existing = [System.IO.File]::ReadAllText($Path)
    }

    if ($existing -match [regex]::Escape($start)) {
        $pattern = [regex]::Escape($start) + '(?s).*?' + [regex]::Escape($end)
        $updated = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block })
    }
    elseif ([string]::IsNullOrWhiteSpace($existing)) {
        $updated = $block + $nl
    }
    else {
        $updated = $existing.TrimEnd() + $nl + $nl + $block + $nl
    }

    if ($updated -ne $existing) {
        Backup-File -Path $Path
        Write-TextNoBom -Path $Path -Content $updated
        Write-Host "Updated: $Path"
    }
    else {
        Write-Host "Unchanged: $Path"
    }
}

function Install-SkillLink {
    param([string]$Root)
    if (-not (Test-Path -LiteralPath $Root)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $Root -Force | Out-Null }
    }
    $dest = Join-Path $Root 'ai-product-ui-workflow'
    if (Test-Path -LiteralPath $dest) {
        $item = Get-Item -LiteralPath $dest -Force
        if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
            if (-not $DryRun) { [System.IO.Directory]::Delete($dest, $false) }
        }
        else {
            $backup = "$dest.aios-bak-$Stamp"
            if (-not $DryRun) { Rename-Item -LiteralPath $dest -NewName (Split-Path -Leaf $backup) }
            Write-Host "Existing skill directory backed up: $backup"
        }
    }
    if ($DryRun) {
        Write-Host "[dry-run] junction $dest -> $SkillSource"
        return
    }
    New-Item -ItemType Junction -Path $dest -Target $SkillSource | Out-Null
    Write-Host "Junction: $dest -> $SkillSource"
}

if (-not (Test-Path -LiteralPath (Join-Path $SkillSource 'SKILL.md'))) {
    throw "Missing skill source: $SkillSource"
}

$entryLines = @(
    '## AI Coding OS',
    '',
    'For product design, page design, UI design, redesign, dashboard, landing page, AI product workflow, PRD-to-UI, or product/UI review tasks:',
    '',
    '- Read `C:\Users\win\.ai-workspace\ai-coding-os\AGENTS.md`.',
    '- Load only the specific AIOS workflow files needed for the task.',
    '- Keep existing global and repo rules higher priority than AIOS.',
    '- Do not jump from vague product/UI requests directly into code.'
)

Upsert-ManagedBlock -Path (Join-Path $env:USERPROFILE '.codex\AGENTS.md') -Lines $entryLines
Upsert-ManagedBlock -Path (Join-Path $env:USERPROFILE '.claude\AGENTS.md') -Lines $entryLines

$cursorRulePath = Join-Path $env:USERPROFILE '.cursor\rules\ai-coding-os.mdc'
$cursorLines = @(
    '---',
    'description: AI Coding OS product/page/UI workflow routing.',
    'alwaysApply: false',
    '---',
    '',
    '# AI Coding OS',
    '',
    'When a task involves product design, page design, UI design, redesign, dashboard, landing page, AI product workflow, PRD-to-UI, or product/UI review:',
    '',
    '- Read `C:\Users\win\.ai-workspace\ai-coding-os\AGENTS.md`.',
    '- Prefer `skills/ai-product-ui-workflow/SKILL.md` as the routing skill.',
    '- Load only the specific workflow and review files required.',
    '- Preserve existing global and repo rules as higher priority.'
)
Upsert-ManagedBlock -Path $cursorRulePath -Lines $cursorLines

Install-SkillLink -Root (Join-Path $env:USERPROFILE '.cursor\skills')
Install-SkillLink -Root (Join-Path $env:USERPROFILE '.claude\skills')
Install-SkillLink -Root (Join-Path $env:USERPROFILE '.codex\skills')

if (-not $SkipScan) {
    $scan = Join-Path $env:USERPROFILE '.ai-workspace\scripts\scan-global-skills.ps1'
    if (Test-Path -LiteralPath $scan) {
        if ($DryRun) {
            Write-Host "[dry-run] scan-global-skills.ps1"
        }
        else {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $scan
        }
    }
}

Write-Host "AIOS install complete: $AiosRoot"
