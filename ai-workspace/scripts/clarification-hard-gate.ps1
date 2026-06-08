# PreToolUse hard gate — block Write/Edit when clarification gate is pending (Type B).
param(
    [ValidateSet('Claude', 'Cursor', 'Codex', 'Auto')]
    [string]$OutputFormat = 'Auto'
)

$ErrorActionPreference = 'Stop'
$corePath = Join-Path $PSScriptRoot 'clarification-gate-core.ps1'
if (-not (Test-Path $corePath)) {
    $corePath = Join-Path $env:USERPROFILE '.ai-workspace\scripts\clarification-gate-core.ps1'
}
. $corePath

function Read-HookStdinJson {
    $stdinJson = ''
    try { $stdinJson = [Console]::In.ReadToEnd() } catch { }
    if (-not $stdinJson.Trim()) { return $null }
    try { return $stdinJson | ConvertFrom-Json } catch { return $null }
}

function Resolve-ToolContext {
    param([object]$Data)

    $toolName = $null
    $toolInput = $null
    $cwd = $null
    $eventName = $null

    if ($Data.PSObject.Properties.Name -contains 'tool_name') {
        $toolName = [string]$Data.tool_name
        $toolInput = $Data.tool_input
    }
    elseif ($Data.PSObject.Properties.Name -contains 'toolName') {
        $toolName = [string]$Data.toolName
        $toolInput = $Data.toolInput
    }

    if ($Data.PSObject.Properties.Name -contains 'cwd') { $cwd = [string]$Data.cwd }
    if ($Data.PSObject.Properties.Name -contains 'hook_event_name') { $eventName = [string]$Data.hook_event_name }
    if ($Data.PSObject.Properties.Name -contains 'hookEventName') { $eventName = [string]$Data.hookEventName }

    if (-not $cwd -and $Data.PSObject.Properties.Name -contains 'workspace_roots' -and $Data.workspace_roots) {
        $cwd = [string]$Data.workspace_roots[0]
    }

    return [pscustomobject]@{
        ToolName  = $toolName
        ToolInput = $toolInput
        Cwd       = $cwd
        EventName = $eventName
    }
}

function Emit-Allow {
    param([string]$Format)

    if ($Format -eq 'Claude') {
        @{
            continue           = $true
            hookSpecificOutput = @{
                hookEventName      = 'PreToolUse'
                permissionDecision = 'allow'
            }
        } | ConvertTo-Json -Compress -Depth 5
        return
    }
    if ($Format -eq 'Cursor') {
        @{ permission = 'allow' } | ConvertTo-Json -Compress
        return
    }
    Write-Output '{"permission":"allow"}'
}

function Emit-Deny {
    param(
        [string]$Format,
        [string]$Reason,
        [string]$DraftPath
    )

    $agentMsg = "CLARIFICATION GATE: $Reason Draft: $DraftPath Reply with confirm or use clearance phrase (e.g. confirm / execute per clarification)."
    $userMsg = "Clarification gate: complete Mini-Spec and get user confirm before code edits. Draft: $DraftPath"

    if ($Format -eq 'Claude') {
        @{
            continue           = $true
            hookSpecificOutput = @{
                hookEventName            = 'PreToolUse'
                permissionDecision       = 'deny'
                permissionDecisionReason = $agentMsg
            }
        } | ConvertTo-Json -Compress -Depth 5
        return
    }
    if ($Format -eq 'Cursor') {
        @{
            permission    = 'deny'
            user_message  = $userMsg
            agent_message = $agentMsg
        } | ConvertTo-Json -Compress
        return
    }
    Write-Output (@{ permission = 'deny'; reason = $agentMsg } | ConvertTo-Json -Compress)
}

$data = Read-HookStdinJson
if (-not $data) {
    Emit-Allow -Format $OutputFormat
    exit 0
}

$ctx = Resolve-ToolContext -Data $data
$format = $OutputFormat
if ($format -eq 'Auto') {
    $format = if ($ctx.EventName -match 'preToolUse|PreToolUse') { 'Cursor' } else { 'Claude' }
}

if (-not $ctx.ToolName) {
    Emit-Allow -Format $format
    exit 0
}

$shouldBlock = Test-ShouldBlockClarificationWrite -Cwd $ctx.Cwd -ToolName $ctx.ToolName -ToolInput $ctx.ToolInput
if (-not $shouldBlock) {
    Emit-Allow -Format $format
    exit 0
}

$entry = Get-GateEntry -Cwd $ctx.Cwd
$draft = if ($entry -and $entry.draftPath) { $entry.draftPath } else { '(see ~/.ai-workspace/clarifications/)' }
$reason = 'Type B fuzzy task — output Mini-Spec S4.5 + S7 and get user confirm before Write/Edit.'
Emit-Deny -Format $format -Reason $reason -DraftPath $draft
exit 0
