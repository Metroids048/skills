# Agent-sort output for Agent Platform — DAILY vs LIBRARY buckets with repo evidence.
param(
    [string]$ProjectRoot = '',
    [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'
if (-not $ProjectRoot) {
    $ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}
if (-not $OutputDir) {
    $OutputDir = Join-Path $ProjectRoot 'docs\skills-audit'
}
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$evidence = @{
    hasPrototype     = Test-Path (Join-Path $ProjectRoot 'prototype\scripts\verify-all.js')
    hasAgentsMd      = Test-Path (Join-Path $ProjectRoot 'AGENTS.md')
    hasMemory        = Test-Path (Join-Path $ProjectRoot '.github\agent\memory\project-memory.md')
    hasFigmaConfig   = Test-Path (Join-Path $ProjectRoot 'design\figma.config.json')
    hasFigmaWorkflow = Test-Path (Join-Path $ProjectRoot '.cursor\skills\figma-workflow\SKILL.md')
}

$daily = @(
    [ordered]@{ name = 'global-session-core'; evidence = 'alwaysOnSkills; session routing in all tools' }
    [ordered]@{ name = 'requirement-clarifier'; evidence = 'alwaysOnSkills; .cursor/rules/requirement-clarifier.mdc' }
    [ordered]@{ name = 'karpathy-guidelines'; evidence = 'alwaysOnSkills; coding discipline always on' }
    [ordered]@{ name = 'ai-coding-ok'; evidence = 'AGENTS.md + .github/agent/memory/ PDCA loop' }
    [ordered]@{ name = 'zero-to-one-gate'; evidence = 'AGENTS.md zero-to-one; new modules/pages' }
    [ordered]@{ name = 'brainstorming'; evidence = '0-to-1 chain; design before implement' }
    [ordered]@{ name = 'writing-plans'; evidence = 'post-ADR implementation plans' }
    [ordered]@{ name = 'ai-delivery-gate'; evidence = 'prototype/scripts/verify-all.js 5-step gate' }
    [ordered]@{ name = 'global-delivery-gate'; evidence = 'verification-before-completion cross-repo' }
    [ordered]@{ name = 'systematic-debugging'; evidence = 'bug fix workflow; intent profile bug_fix_debug' }
    [ordered]@{ name = 'diagnose'; evidence = 'intent profile bug_fix_debug boost 40' }
    [ordered]@{ name = 'figma-workflow'; evidence = 'design/figma.config.json; project .cursor/skills' }
    [ordered]@{ name = 'figma2code'; evidence = 'figma转前端; Figma URL to HTML workflow' }
    [ordered]@{ name = 'design-taste-frontend'; evidence = 'prototype UI quality; keywordBoost landing/portfolio' }
    [ordered]@{ name = 'ouro-loop'; evidence = 'multi-step autonomous MAP-PLAN-BUILD-VERIFY' }
    [ordered]@{ name = 'planning-with-files-zh'; evidence = 'intent profile plan_multistep; Chinese planning' }
    [ordered]@{ name = 'verification-before-completion'; evidence = 'intent profile verify_delivery' }
    [ordered]@{ name = 'agent-verifier'; evidence = 'project .cursor/skills; pre-PR audit' }
    [ordered]@{ name = 'writing-skills'; evidence = 'skill engineering; skill_engineering profile' }
    [ordered]@{ name = 'skill-stocktake'; evidence = 'skill_engineering profile; quality audits' }
    [ordered]@{ name = 'agent-sort'; evidence = 'skill_engineering profile; DAILY/LIBRARY curation' }
    [ordered]@{ name = 'cursor-awesome-parallel-exploring'; evidence = 'intent explore_codebase; large repo' }
    [ordered]@{ name = 'memory-handoff'; evidence = 'intent memory_session; session resume' }
    [ordered]@{ name = 'pm-prd-writer'; evidence = 'intent prd_document; Codex pm-* mirrored' }
)

if (-not $evidence.hasPrototype) {
    $daily = $daily | Where-Object { $_.name -notin @('ai-delivery-gate') }
}
if (-not $evidence.hasFigmaConfig) {
    $daily = $daily | Where-Object { $_.name -notin @('figma-workflow', 'figma2code') }
}

$dateStamp = Get-Date -Format 'yyyy-MM-dd'
$jsonPath = Join-Path $OutputDir "$dateStamp-agent-sort.json"
$mdPath = Join-Path $OutputDir "$dateStamp-daily-library.md"

$payload = [ordered]@{
    evaluatedAt = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    projectRoot = $ProjectRoot
    repoEvidence = $evidence
    dailyCount  = $daily.Count
    daily       = $daily
    libraryNote = 'All other skills in global-skills-index (~280) remain LIBRARY — reachable via scan-global-skills Top 8 + search, not loaded every session.'
}

$payload | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$md = @(
    "# Agent Platform DAILY Skills ($dateStamp)",
    "",
    "Repo evidence: prototype=$($evidence.hasPrototype) AGENTS.md=$($evidence.hasAgentsMd) figma.config=$($evidence.hasFigmaConfig)",
    "",
    "## DAILY ($($daily.Count))",
    ""
)
foreach ($d in $daily) {
    $md += "- **$($d.name)** — $($d.evidence)"
}
$md += @('', '## LIBRARY', '', $payload.libraryNote)
Set-Content -LiteralPath $mdPath -Value ($md -join "`n") -Encoding UTF8

Write-Host "DAILY=$($daily.Count) -> $mdPath"
