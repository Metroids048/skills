# Merge audit-skills-quality output into skill-stocktake results.json format.
param(
    [string]$AuditJson = '',
    [string]$ResultsPath = ''
)

$ErrorActionPreference = 'Stop'
if (-not $AuditJson) {
    $repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $AuditJson = Join-Path $repo "docs\skills-audit\$(Get-Date -Format 'yyyy-MM-dd')-inventory.json"
    if (-not (Test-Path $AuditJson)) {
        $AuditJson = (Get-ChildItem (Join-Path $repo 'docs\skills-audit\*-inventory.json') | Sort-Object Name -Descending | Select-Object -First 1).FullName
    }
}
if (-not $ResultsPath) {
    $ResultsPath = Join-Path $env:USERPROFILE '.claude\skills\skill-stocktake\results.json'
}

$audit = Get-Content -LiteralPath $AuditJson -Raw -Encoding UTF8 | ConvertFrom-Json
$stocktakeDir = Split-Path $ResultsPath -Parent
if (-not (Test-Path $stocktakeDir)) { New-Item -ItemType Directory -Path $stocktakeDir -Force | Out-Null }

function Map-StocktakeVerdict {
    param([string]$AuditVerdict, [array]$Reasons)
    switch ($AuditVerdict) {
        'PASS' { return 'Keep' }
        'RETIRE' { return 'Retire' }
        'BROKEN' { return 'Retire' }
        'MERGE' {
            if ($Reasons -contains 'duplicate-paths') { return 'Merge into canonical path' }
            return 'Merge'
        }
        'ROUTING_GAP' { return 'Improve' }
        default { return 'Improve' }
    }
}

function Build-Reason {
    param($Skill)
    $parts = @($Skill.reasons)
    if ($Skill.mojibake) { $parts += 'encoding corruption' }
    if ($Skill.workflowInDescription) { $parts += 'CSO: workflow in description' }
    if (-not $Skill.csoCompliant) { $parts += 'CSO: add Use when triggers' }
    if (-not $Skill.routed -and -not $Skill.alwaysOn) { $parts += 'add intent profile or keywordBoost' }
    if ($Skill.bodyLines -gt 500) { $parts += "trim body ($($Skill.bodyLines) lines)" }
    return ($parts | Select-Object -Unique) -join '; '
}

$skillsObj = @{}
foreach ($s in $audit.skills) {
    $verdict = Map-StocktakeVerdict -AuditVerdict $s.verdict -Reasons $s.reasons
    $reason = Build-Reason -Skill $s
    $mtime = ''
    if ($s.path -and (Test-Path $s.path)) {
        $mtime = (Get-Item -LiteralPath $s.path).LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    $skillsObj[$s.name] = [ordered]@{
        path    = $s.path
        verdict = $verdict
        reason  = $reason
        mtime   = $mtime
        auditVerdict = $s.verdict
        source  = $s.source
    }
}

$payload = [ordered]@{
    evaluated_at   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    mode           = 'full'
    auditSource    = $AuditJson
    batch_progress = [ordered]@{
        total     = $audit.totalSkills
        evaluated = $audit.totalSkills
        status    = 'completed'
    }
    skills = $skillsObj
}

$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ResultsPath -Encoding UTF8
Write-Host "Stocktake results: $ResultsPath ($($audit.totalSkills) skills)"
