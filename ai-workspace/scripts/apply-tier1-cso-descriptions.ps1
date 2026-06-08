# Apply CSO-compliant descriptions from skills-sync.config.json descriptionOverrides to SKILL.md frontmatter.
param(
    [string]$ConfigPath = '',
    [string[]]$SkillNames = @()
)

$ErrorActionPreference = 'Stop'
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $PSScriptRoot 'skills-sync.config.json'
}
$raw = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
$overrides = @{}
$raw.descriptionOverrides.PSObject.Properties | ForEach-Object { $overrides[$_.Name] = [string]$_.Value }

if ($SkillNames.Count -eq 0) {
    $SkillNames = @($overrides.Keys)
}

function Set-SkillDescription {
    param([string]$SkillName, [string]$NewDesc)
    $roots = @(
        (Join-Path $env:USERPROFILE '.cursor\skills'),
        (Join-Path $env:USERPROFILE '.claude\skills'),
        (Join-Path $env:USERPROFILE '.codex\skills')
    )
    $updated = 0
    foreach ($root in $roots) {
        $path = Join-Path $root "$SkillName\SKILL.md"
        if (-not (Test-Path $path)) { continue }
        $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        if ($content -notmatch '(?ms)^---\s*\r?\n.*?\r?\n---') { continue }
        $newContent = [regex]::Replace($content, '(?m)^description:\s*.+$', "description: $NewDesc", 1)
        if ($newContent -ne $content) {
            [System.IO.File]::WriteAllText($path, $newContent, [System.Text.UTF8Encoding]::new($false))
            $updated++
        }
    }
    return $updated
}

$total = 0
foreach ($name in $SkillNames) {
    if (-not $overrides.ContainsKey($name)) { continue }
    $n = Set-SkillDescription -SkillName $name -NewDesc $overrides[$name]
    if ($n -gt 0) { Write-Host "Updated $name ($n paths)"; $total += $n }
}
Write-Host "Total files updated: $total"
