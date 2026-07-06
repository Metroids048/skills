# Apply skills-locale-zh.json to SKILL.md frontmatter across cursor/claude/codex.
# Sets Chinese display name + slug for routing + bilingual description.
param(
    [switch]$DryRun,
    [string]$LocalePath = ''
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')

if (-not $LocalePath) {
    $LocalePath = Join-Path $env:USERPROFILE '.ai-workspace\skills-locale-zh.json'
}

function Get-FrontmatterYaml {
    param([string]$Content)
    if ($Content -match '(?ms)^---\s*\r?\n(.*?)\r?\n---') { return $Matches[1] }
    return $null
}

function Get-FrontmatterField {
    param([string]$Content, [string]$Field)
    $yaml = Get-FrontmatterYaml -Content $Content
    if (-not $yaml) { return $null }
    if ($yaml -match "(?m)^${Field}:\s*['""](.+?)['""]\s*$") { return $Matches[1].Trim() }
    if ($yaml -match "(?m)^${Field}:\s*(.+)$") { return $Matches[1].Trim().Trim('"').Trim("'") }
    return $null
}

function Get-SkillBody {
    param([string]$Content)
    if ($Content -match '(?ms)^---\s*\r?\n.*?\r?\n---\s*\r?\n(.*)$') { return $Matches[1] }
    return $Content
}

function Get-EnglishDescription {
    param([string]$Description)
    if ([string]::IsNullOrWhiteSpace($Description)) { return '' }
    if ($Description -match '\bEN:\s*(.+)$') { return $Matches[1].Trim() }
    return $Description.Trim()
}

function Build-LocalizedDescription {
    param(
        [object]$LocaleEntry
    )
    $picker = [string]$LocaleEntry.picker_zh
    if ([string]::IsNullOrWhiteSpace($picker)) {
        $picker = [string]$LocaleEntry.summary_zh
    }
    $picker = $picker.Trim()
    # Codex picker 只显示 description：纯中文、前几十个字讲清功能，不要重复标题/英文/Triggers
    if ($picker -match '^\[.+?\]\s*') {
        $picker = ($picker -replace '^\[.+?\]\s*', '').Trim()
    }
    if ($picker -match '\s*Triggers:') {
        $picker = ($picker -split '\s*Triggers:')[0].Trim()
    }
    if ($picker -match '\s*EN:') {
        $picker = ($picker -split '\s*EN:')[0].Trim()
    }
    if ($picker.Length -gt 72) {
        $picker = $picker.Substring(0, 71) + '...'
    }
    return $picker
}

function Escape-YamlDoubleQuoted {
    param([string]$Value)
    $v = $Value -replace '\\', '\\\\'
    return $v.Replace('"', '\"')
}

function Set-SkillFrontmatter {
    param(
        [string]$Content,
        [string]$DisplayName,
        [string]$Slug,
        [string]$Description
    )
    $body = Get-SkillBody -Content $Content
    $disable = Get-FrontmatterField -Content $Content -Field 'disable-model-invocation'
    $nameLine = 'name: "' + (Escape-YamlDoubleQuoted -Value $DisplayName) + '"'
    $descLine = 'description: "' + (Escape-YamlDoubleQuoted -Value $Description) + '"'
    $fmLines = @(
        '---',
        $nameLine,
        ('slug: ' + $Slug),
        $descLine
    )
    if ($disable -eq 'true') { $fmLines += 'disable-model-invocation: true' }
    elseif ($disable -eq 'false') { $fmLines += 'disable-model-invocation: false' }
    $fmLines += @('---', '')
    $fm = ($fmLines -join "`n")
    return $fm + $body.TrimStart()
}

function Get-AllSkillFiles {
    $seen = @{}
    $items = @()
    foreach ($rel in @('.cursor\skills', '.claude\skills', '.codex\skills')) {
        $root = Join-Path $env:USERPROFILE $rel
        if (-not (Test-Path -LiteralPath $root)) { continue }
        foreach ($name in (Get-ChildItem -LiteralPath $root -Name -ErrorAction SilentlyContinue)) {
            $dir = Join-Path $root $name
            $skillFile = Join-Path $dir 'SKILL.md'
            if (-not (Test-Path -LiteralPath $skillFile)) { continue }
            $resolved = (Resolve-Path -LiteralPath $skillFile).Path
            if ($seen.ContainsKey($resolved)) { continue }
            $seen[$resolved] = $true
            $items += [pscustomobject]@{
                Path = $resolved
                Slug = $name
            }
        }
    }
    return $items
}

if (-not (Test-Path -LiteralPath $LocalePath)) {
    throw "Missing locale file: $LocalePath"
}
$localeRaw = Get-Content -LiteralPath $LocalePath -Raw -Encoding UTF8 | ConvertFrom-Json
$localeMap = @{}
$localeRaw.skills.PSObject.Properties | ForEach-Object { $localeMap[$_.Name] = $_.Value }

$stats = @{ Patched = 0; MissingLocale = 0; SkippedNoFile = 0 }
$skillFiles = Get-AllSkillFiles

foreach ($item in ($skillFiles | Sort-Object Slug)) {
    if (-not $localeMap.ContainsKey($item.Slug)) {
        $stats.MissingLocale++
        continue
    }
    $content = Get-Content -LiteralPath $item.Path -Raw -Encoding UTF8
    $currentDesc = Get-FrontmatterField -Content $content -Field 'description'
    $localeEntry = $localeMap[$item.Slug]
    $displayName = [string]$localeEntry.label_zh
    if ([string]::IsNullOrWhiteSpace($displayName)) { $displayName = $item.Slug }
    $newDesc = Build-LocalizedDescription -LocaleEntry $localeEntry
    if ($newDesc.Length -gt 1024) {
        $newDesc = $newDesc.Substring(0, 1021) + '...'
    }
    $newContent = Set-SkillFrontmatter -Content $content -DisplayName $displayName -Slug $item.Slug -Description $newDesc
    if ($DryRun) {
        Write-Host "[dry-run] patch $($item.Slug) -> $displayName ($($item.Path))"
    }
    else {
        Write-Utf8NoBomFile -Path $item.Path -Content $newContent
    }
    $stats.Patched++
}

Write-Host "Locale apply done. Patched=$($stats.Patched) MissingLocale=$($stats.MissingLocale) Files=$($skillFiles.Count)"
