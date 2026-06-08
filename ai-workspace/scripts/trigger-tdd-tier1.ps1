# Trigger TDD - test scan-global-skills Top 8 matching for Tier1 DAILY skills.
param(
    [string]$ProjectRoot = '',
    [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'
$scanScript = Join-Path $PSScriptRoot 'scan-global-skills.ps1'
if (-not $ProjectRoot) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
if (-not $OutputDir) {
    $OutputDir = Join-Path $ProjectRoot 'docs\skills-audit'
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$tests = @(
    @{ skill = 'figma-workflow'; prompt = 'implement ops platform page from Figma mockup' },
    @{ skill = 'figma2code'; prompt = 'Figma URL to HTML frame extraction interactions' },
    @{ skill = 'writing-skills'; prompt = 'how to write high quality skill trigger design' },
    @{ skill = 'skill-stocktake'; prompt = 'audit all skills inventory stocktake compliance' },
    @{ skill = 'agent-sort'; prompt = 'agent sort DAILY LIBRARY trim ECC for this repo' },
    @{ skill = 'zero-to-one-gate'; prompt = 'greenfield new module build from scratch architecture' },
    @{ skill = 'systematic-debugging'; prompt = 'bug keeps failing root cause before fix' },
    @{ skill = 'ai-delivery-gate'; prompt = 'prototype verify-all delivery sign-off after js edit' },
    @{ skill = 'deep-research'; prompt = 'deep research multi-source citations fact-check' },
    @{ skill = 'ouro-loop'; prompt = 'ouro loop MAP PLAN BUILD VERIFY autonomous task' },
    @{ skill = 'brainstorming'; prompt = 'brainstorm approaches before implementing new feature' },
    @{ skill = 'design-taste-frontend'; prompt = 'landing page anti-slop portfolio redesign taste' },
    @{ skill = 'figma-workflow'; prompt = 'sync HTML prototype to Figma figma.config' },
    @{ skill = 'figma2code'; prompt = 'design mockup to code file key node id' },
    @{ skill = 'writing-skills'; prompt = 'skills not invoked fix description CSO' },
    @{ skill = 'skill-stocktake'; prompt = 'skill quality audit why good skills not called' }
)

function Get-TopMatches {
    param([string]$Prompt)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $scanScript `
        -UserPrompt $Prompt -HookEvent Plain -StartDir $ProjectRoot 2>&1 | Out-String
    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($out -split "`n")) {
        if ($line -match '- \*\*(.+?)\*\* \(score') {
            [void]$names.Add($Matches[1].Trim())
        }
    }
    return @($names)
}

$results = @()
$pass = 0
$fail = 0

foreach ($t in $tests) {
    $top = Get-TopMatches -Prompt $t.prompt
    $hit = $top -contains $t.skill
    if ($hit) { $pass++ } else { $fail++ }
    $results += [pscustomobject]@{
        skill  = $t.skill
        prompt = $t.prompt
        hit    = $hit
        top8   = ($top -join ', ')
    }
}

$total = $pass + $fail
$rate = if ($total -gt 0) { [math]::Round(100.0 * $pass / $total, 1) } else { 0 }
$dateStamp = Get-Date -Format 'yyyy-MM-dd'
$jsonPath = Join-Path $OutputDir "$dateStamp-trigger-tdd.json"
$mdPath = Join-Path $OutputDir "$dateStamp-trigger-tdd.md"

[ordered]@{
    evaluatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    pass        = $pass
    fail        = $fail
    hitRatePct  = $rate
    targetPct   = 90
    results     = $results
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$md = @(
    "# Trigger TDD Report - $dateStamp",
    "",
    "Hit rate: $rate% ($pass/$total) target >= 90%",
    ""
)
foreach ($r in $results) {
    $md += "- $($r.skill): hit=$($r.hit) prompt=$($r.prompt)"
    $md += "  top: $($r.top8)"
}
Set-Content -LiteralPath $mdPath -Value ($md -join "`n") -Encoding UTF8

Write-Host "Trigger TDD: $rate% ($pass/$total) -> $mdPath"
if ($rate -lt 90) { exit 1 }
