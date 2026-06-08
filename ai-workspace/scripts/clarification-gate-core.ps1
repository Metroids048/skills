# Shared clarification gate state machine (requirement-clarifier hard block).
$ErrorActionPreference = 'Stop'

$script:ClarificationGateRoot = Join-Path $env:USERPROFILE '.ai-workspace\clarifications'

function Get-ClarificationGateRoot {
    if (-not (Test-Path $script:ClarificationGateRoot)) {
        New-Item -ItemType Directory -Path $script:ClarificationGateRoot -Force | Out-Null
    }
    return $script:ClarificationGateRoot
}

function Get-ClarificationGateStatePath {
    return Join-Path (Get-ClarificationGateRoot) 'gate-state.json'
}

function Get-ClarificationGateKeywordsPath {
    $local = Join-Path $PSScriptRoot 'clarification-gate-keywords.json'
    if (Test-Path $local) { return $local }
    return Join-Path $env:USERPROFILE '.ai-workspace\scripts\clarification-gate-keywords.json'
}

function Get-ClarificationGateKeywords {
    $path = Get-ClarificationGateKeywordsPath
    if (-not (Test-Path $path)) {
        return [pscustomobject]@{
            clearKeywords        = @('confirm', 'go ahead', 'yes proceed', 'execute')
            allowedPathFragments = @('\clarifications\', '\docs\intent\', '\.github\agent\memory\')
        }
    }
    return Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Normalize-GateCwd {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return (Get-Location).Path.ToLowerInvariant()
    }
    $p = $Path
    try { $p = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path }
    catch { }
    return $p.ToLowerInvariant()
}

function Get-ClarificationGateConfig {
    $kw = Get-ClarificationGateKeywords
    $defaults = [pscustomobject]@{
        enabled              = $true
        blockTools           = @('Write', 'Edit', 'MultiEdit', 'StrReplace', 'apply_patch')
        clearKeywords        = @($kw.clearKeywords)
        allowedPathFragments = @($kw.allowedPathFragments)
        exemptMessageTypes   = @('A', 'C', 'unknown')
    }
    if ($env:CLARIFICATION_GATE_OFF -eq '1') {
        $defaults.enabled = $false
    }
    return $defaults
}

function Get-GateStateStore {
    $path = Get-ClarificationGateStatePath
    if (-not (Test-Path $path)) { return @{} }
    try {
        $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
        $store = @{}
        if ($raw.entries) {
            $raw.entries.PSObject.Properties | ForEach-Object { $store[$_.Name] = $_.Value }
        }
        return $store
    }
    catch {
        return @{}
    }
}

function Save-GateStateStore {
    param([hashtable]$Store)

    $path = Get-ClarificationGateStatePath
    $payload = @{
        version = 1
        updated = (Get-Date).ToString('o')
        entries = $Store
    }
    $json = $payload | ConvertTo-Json -Depth 8 -Compress:$false
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($path, $json, $utf8)
}

function Get-GateEntry {
    param([string]$Cwd)

    $key = Normalize-GateCwd -Path $Cwd
    $store = Get-GateStateStore
    if ($store.ContainsKey($key)) { return $store[$key] }
    return $null
}

function Set-GateEntry {
    param(
        [string]$Cwd,
        [hashtable]$Entry
    )

    $key = Normalize-GateCwd -Path $Cwd
    $store = Get-GateStateStore
    $store[$key] = $Entry
    Save-GateStateStore -Store $store
}

function Test-ClearanceKeywords {
    param(
        [string]$UserPrompt,
        [array]$Keywords
    )

    if ([string]::IsNullOrWhiteSpace($UserPrompt)) { return $false }
    $p = $UserPrompt.ToLowerInvariant()
    foreach ($kw in $Keywords) {
        if ([string]::IsNullOrWhiteSpace($kw)) { continue }
        if ($p.Contains($kw.ToLowerInvariant())) { return $true }
    }
    return $false
}

function New-IntentDraftFile {
    param(
        [string]$Cwd,
        [string]$UserPrompt,
        [string]$MessageType,
        [array]$Intents
    )

    $root = Get-ClarificationGateRoot
    $slug = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $safeCwd = if ($Cwd) { [regex]::Replace($Cwd, '[^\w\-]', '_') } else { 'cwd' }
    $fileName = "pending-$slug-$safeCwd.md"
    if ($fileName.Length -gt 120) { $fileName = "pending-$slug.md" }
    $path = Join-Path $root $fileName
    $intentLines = ($Intents | ForEach-Object { "- $($_.Label) ($($_.Id))" }) -join "`n"
    $body = @"
# Clarification Draft (auto)

- **Created**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **CWD**: $Cwd
- **Message type**: $MessageType
- **Gate**: pending — user must confirm Mini-Spec before code edits

## User prompt

$UserPrompt

## Detected intents

$intentLines

## Agent: fill before execute

1. HYPOTHESIS + CONFIDENCE (interview-protocol)
2. Section 4.5 Mini-Spec (mini-spec-template.md)
3. Section 7 pending questions (<=5)
4. User explicit confirm -> gate clears

"@
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($path, $body, $utf8)
    return $path
}

function Update-ClarificationGateFromPrompt {
    param(
        [string]$UserPrompt,
        [object]$MessageType,
        [array]$DetectedIntents = @(),
        [string]$Cwd = ''
    )

    $cfg = Get-ClarificationGateConfig
    if (-not $cfg.enabled) { return $null }

    $cwdNorm = Normalize-GateCwd -Path $Cwd
    $type = if ($MessageType) { $MessageType.Type } else { 'unknown' }

    $entry = @{
        cwd           = $cwdNorm
        messageType   = $type
        gateStatus    = 'exempt'
        lastPrompt    = $UserPrompt
        lastPromptAt  = (Get-Date).ToString('o')
        intentIds     = if ($DetectedIntents -and $DetectedIntents.Count -gt 0) {
            @($DetectedIntents | ForEach-Object { $_.Id })
        } else { @() }
        draftPath     = $null
        clearedAt     = $null
        clearedReason = $null
    }

    if (Test-ClearanceKeywords -UserPrompt $UserPrompt -Keywords $cfg.clearKeywords) {
        $entry.gateStatus = 'cleared'
        $entry.clearedAt = (Get-Date).ToString('o')
        $entry.clearedReason = 'user-clearance-keyword'
    }
    elseif ($type -eq 'B') {
        $entry.gateStatus = 'pending'
        $entry.draftPath = New-IntentDraftFile -Cwd $cwdNorm -UserPrompt $UserPrompt -MessageType $type -Intents $DetectedIntents
    }
    elseif ($cfg.exemptMessageTypes -contains $type) {
        $entry.gateStatus = 'exempt'
    }
    else {
        $entry.gateStatus = 'pending'
    }

    Set-GateEntry -Cwd $cwdNorm -Entry $entry
    return $entry
}

function Test-ClarificationAllowedPath {
    param(
        [string]$FilePath,
        [array]$AllowedFragments
    )

    if ([string]::IsNullOrWhiteSpace($FilePath)) { return $false }
    $norm = $FilePath.Replace('/', '\').ToLowerInvariant()
    foreach ($frag in $AllowedFragments) {
        if ($norm.Contains($frag.ToLowerInvariant())) { return $true }
    }
    return $false
}

function Get-WriteTargetPathFromToolInput {
    param(
        [string]$ToolName,
        [object]$ToolInput
    )

    if (-not $ToolInput) { return $null }
    if ($ToolInput.PSObject.Properties.Name -contains 'file_path') {
        return [string]$ToolInput.file_path
    }
    if ($ToolInput.PSObject.Properties.Name -contains 'path') {
        return [string]$ToolInput.path
    }
    return $null
}

function Test-ShouldBlockClarificationWrite {
    param(
        [string]$Cwd,
        [string]$ToolName,
        [object]$ToolInput
    )

    $cfg = Get-ClarificationGateConfig
    if (-not $cfg.enabled) { return $false }
    if ($cfg.blockTools -notcontains $ToolName) { return $false }

    $entry = Get-GateEntry -Cwd $Cwd
    if (-not $entry) { return $false }
    $status = if ($entry.gateStatus) { [string]$entry.gateStatus } else { 'exempt' }
    if ($status -ne 'pending') { return $false }

    $target = Get-WriteTargetPathFromToolInput -ToolName $ToolName -ToolInput $ToolInput
    if (-not $target) { return $true }
    if (Test-ClarificationAllowedPath -FilePath $target -AllowedFragments $cfg.allowedPathFragments) {
        return $false
    }
    return $true
}
