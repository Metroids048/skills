# Quick gate smoke test (no full skill scan).
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'clarification-gate-core.ps1')

$repo = 'C:\Users\win\Desktop\Agent Platform'
$mt = [pscustomobject]@{ Type = 'B'; Label = 'fuzzy' }

$e = Update-ClarificationGateFromPrompt `
    -UserPrompt 'optimize index dashboard fuzzy task' `
    -MessageType $mt `
    -DetectedIntents @() `
    -Cwd $repo

if ($e.gateStatus -ne 'pending') { throw "Expected pending, got $($e.gateStatus)" }
Write-Host "PASS: pending draft=$($e.draftPath)"

$block = Test-ShouldBlockClarificationWrite `
    -Cwd $repo `
    -ToolName 'Write' `
    -ToolInput ([pscustomobject]@{ file_path = Join-Path $repo 'prototype\index.html' })
if (-not $block) { throw 'Expected block on prototype write' }
Write-Host 'PASS: block prototype'

$allow = Test-ShouldBlockClarificationWrite `
    -Cwd $repo `
    -ToolName 'Write' `
    -ToolInput ([pscustomobject]@{ file_path = Join-Path $env:USERPROFILE '.ai-workspace\clarifications\ok.md' })
if ($allow) { throw 'Expected allow on clarifications path' }
Write-Host 'PASS: allow clarifications'

$e2 = Update-ClarificationGateFromPrompt `
    -UserPrompt 'go ahead per clarification' `
    -MessageType $mt `
    -DetectedIntents @() `
    -Cwd $repo
if ($e2.gateStatus -ne 'cleared') { throw "Expected cleared, got $($e2.gateStatus)" }
Write-Host 'PASS: cleared on confirm keyword'

$block2 = Test-ShouldBlockClarificationWrite `
    -Cwd $repo `
    -ToolName 'Write' `
    -ToolInput ([pscustomobject]@{ file_path = Join-Path $repo 'prototype\index.html' })
if ($block2) { throw 'Expected allow after clear' }
Write-Host 'PASS: allow after clear'

$null = Update-ClarificationGateFromPrompt `
    -UserPrompt 'another fuzzy task' `
    -MessageType $mt `
    -DetectedIntents @() `
    -Cwd $repo

$preIn = @{
    tool_name       = 'Write'
    tool_input      = @{ file_path = Join-Path $repo 'prototype\index.html' }
    cwd             = $repo
    hook_event_name = 'preToolUse'
} | ConvertTo-Json -Compress -Depth 5

$hardGate = Join-Path $PSScriptRoot 'clarification-hard-gate.ps1'
$preOut = $preIn | powershell -NoProfile -ExecutionPolicy Bypass -File $hardGate -OutputFormat Cursor 2>&1 | Out-String
if ($preOut -notmatch 'deny') { throw "Expected deny from hard-gate: $preOut" }
Write-Host 'PASS: hard-gate deny JSON'

Write-Host 'ALL PASS'
