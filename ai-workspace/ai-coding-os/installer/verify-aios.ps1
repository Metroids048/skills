param()

$ErrorActionPreference = 'Stop'

$AiosRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$errors = New-Object System.Collections.Generic.List[string]

function Add-Error {
    param([string]$Message)
    $errors.Add($Message) | Out-Null
    Write-Host "FAIL: $Message" -ForegroundColor Red
}

function Assert-Path {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Write-Host "OK: $Path"
    }
    else {
        Add-Error "Missing path: $Path"
    }
}

$required = @(
    'AGENTS.md',
    'CLAUDE.md',
    'CODEX.md',
    'CURSOR.md',
    'README.md',
    'skills\ai-product-ui-workflow\SKILL.md',
    'product\requirement-analysis.md',
    'product\user-flow.md',
    'product\information-architecture.md',
    'product\ai-agent-design.md',
    'product\prompt-design.md',
    'product\release-plan.md',
    'ui\theme.md',
    'ui\landing-page.md',
    'ui\dashboard.md',
    'ui\form.md',
    'ui\tables.md',
    'ui\empty-state.md',
    'ui\settings.md',
    'ui\pricing.md',
    'ui\chart.md',
    'ui\motion.md',
    'workflows\new-feature.md',
    'workflows\redesign.md',
    'workflows\bugfix.md',
    'workflows\ui-review.md',
    'workflows\code-review.md',
    'workflows\release.md',
    'review\code.md',
    'review\architecture.md',
    'review\product.md',
    'review\ui.md',
    'review\accessibility.md',
    'review\performance.md',
    'review\security.md',
    'installer\install-aios.ps1',
    'installer\sync-aios.ps1',
    'installer\verify-aios.ps1'
)

foreach ($rel in $required) {
    Assert-Path (Join-Path $AiosRoot $rel)
}

$skill = Join-Path $AiosRoot 'skills\ai-product-ui-workflow\SKILL.md'
if (Test-Path -LiteralPath $skill) {
    $skillText = [System.IO.File]::ReadAllText($skill)
    if ($skillText -notmatch '(?m)^---\s*$' -or $skillText -notmatch '(?m)^name:' -or $skillText -notmatch '(?m)^description:') {
        Add-Error "Invalid skill frontmatter: $skill"
    }
    else {
        Write-Host "OK: skill frontmatter"
    }
}

$shimFiles = @(
    (Join-Path $env:USERPROFILE '.codex\AGENTS.md'),
    (Join-Path $env:USERPROFILE '.claude\AGENTS.md'),
    (Join-Path $env:USERPROFILE '.cursor\rules\ai-coding-os.mdc')
)

foreach ($path in $shimFiles) {
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Error "Missing shim: $path"
        continue
    }
    $text = [System.IO.File]::ReadAllText($path)
    if ($text -notmatch 'AIOS MANAGED BLOCK START' -or $text -notmatch [regex]::Escape('C:\Users\win\.ai-workspace\ai-coding-os\AGENTS.md')) {
        Add-Error "Shim missing AIOS managed block or source path: $path"
    }
    else {
        Write-Host "OK: shim $path"
    }
}

$skillLinks = @(
    (Join-Path $env:USERPROFILE '.cursor\skills\ai-product-ui-workflow'),
    (Join-Path $env:USERPROFILE '.claude\skills\ai-product-ui-workflow'),
    (Join-Path $env:USERPROFILE '.codex\skills\ai-product-ui-workflow')
)

foreach ($path in $skillLinks) {
    Assert-Path (Join-Path $path 'SKILL.md')
}

$files = Get-ChildItem -LiteralPath $AiosRoot -Recurse -File -Include *.md,*.ps1
foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Add-Error "UTF-8 BOM detected: $($file.FullName)"
    }
}
Write-Host "OK: UTF-8 BOM scan complete"

if ($errors.Count -gt 0) {
    Write-Host "AIOS VERIFY FAILED ($($errors.Count) issue(s))." -ForegroundColor Red
    exit 1
}

Write-Host "AIOS VERIFY PASSED." -ForegroundColor Green
exit 0

