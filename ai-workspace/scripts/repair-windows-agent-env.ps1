# One-shot system repair: encoding, Python Office stack, hooks token waste, tri-end env.
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'
$scripts = Join-Path $env:USERPROFILE '.ai-workspace\scripts'

function Write-Info([string]$m) { if (-not $Quiet) { Write-Host $m } }

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

Write-Info '=== repair-windows-agent-env ==='

# 1. Encoding + User env + PS profile
& (Join-Path $scripts 'repair-windows-shell-encoding.ps1') -Quiet:$Quiet
& (Join-Path $scripts 'apply-tri-end-env.ps1') -Quiet:$Quiet

# 2. Agent Python + Office packages (system python only, not codex bundled)
& (Join-Path $scripts 'ensure-python-env.ps1') -Quiet
$envJson = Join-Path $env:USERPROFILE '.ai-workspace\runtime\python-env.json'
$agentPy = $null
if (Test-Path -LiteralPath $envJson) {
    $info = Get-Content -LiteralPath $envJson -Raw -Encoding UTF8 | ConvertFrom-Json
    $agentPy = $info.python
}
if (-not $agentPy) { $agentPy = (Get-Command python -ErrorAction Stop).Source }

$probePy = Join-Path $scripts 'probe-python-modules.py'
foreach ($item in @(
        @{ pip = 'python-pptx'; mod = 'pptx' }
        @{ pip = 'python-docx'; mod = 'docx' }
        @{ pip = 'pywin32';    mod = 'win32com' }
    )) {
    if (Test-Path -LiteralPath $probePy) {
        $modJson = & $agentPy $probePy | ConvertFrom-Json
        $has = $modJson.modules.($item.mod)
    }
    else {
        $has = $false
    }
    if (-not $has) {
        Write-Info "pip install $($item.pip) ..."
        & $agentPy -m pip install $item.pip --quiet
    }
}

# 3. Cursor hooks: RTK Shell only (remove per-prompt skill scan)
$repairHooks = Join-Path $scripts 'repair-tri-end-hooks.ps1'
if (Test-Path -LiteralPath $repairHooks) {
    & $repairHooks
}
else {
    Write-Info 'WARN: repair-tri-end-hooks.ps1 not found'
}

# 4. Codex hooks: strip SessionStart / UserPromptSubmit
$codexHooksPath = Join-Path $env:USERPROFILE '.codex\hooks.json'
if (Test-Path -LiteralPath $codexHooksPath) {
    Copy-Item -LiteralPath $codexHooksPath -Destination ($codexHooksPath + '.bak-repair') -Force
    $gate = Join-Path $scripts 'clarification-hard-gate.ps1'
    $gateCmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$gate`" -OutputFormat Codex"
    $body = @{
        hooks = @{
            PreToolUse = @{
                matcher = 'Write|Edit|MultiEdit|StrReplace|apply_patch'
                hooks   = @(
                    @{ type = 'command'; command = $gateCmd; timeout = 5; statusMessage = 'Gate' }
                )
            }
        }
    }
    Write-Utf8NoBomFile -Path $codexHooksPath -Content ($body | ConvertTo-Json -Depth 10)
    Write-Info "Updated: $codexHooksPath (removed SessionStart/UserPromptSubmit)"
}

# 5. Claude settings: env only, no hooks (cache + token)
$claudePath = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $claudePath) {
    Copy-Item -LiteralPath $claudePath -Destination ($claudePath + '.bak-repair') -Force
    $s = Get-Content -LiteralPath $claudePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $envObj = @{}
    if ($s.env) {
        $s.env.PSObject.Properties | ForEach-Object { $envObj[$_.Name] = $_.Value }
    }
    foreach ($kv in @{
        CLAUDE_CODE_ATTRIBUTION_HEADER = '0'
        ENABLE_PROMPT_CACHING_1H      = '1'
        PYTHONUTF8                    = '1'
        PYTHONIOENCODING              = 'utf-8'
        HEADROOM_REQUIRE_RUST_CORE    = 'false'
    }.GetEnumerator()) {
        if (-not $envObj.ContainsKey($kv.Key)) { $envObj[$kv.Key] = $kv.Value }
    }
    $out = [ordered]@{}
    $s.PSObject.Properties | ForEach-Object {
        if ($_.Name -notin @('hooks', 'disableAllHooks')) { $out[$_.Name] = $_.Value }
    }
    $out['disableAllHooks'] = $true
    $out['env'] = $envObj
    if (-not $out.Contains('$schema')) {
        $out['$schema'] = 'https://json.schemastore.org/claude-code-settings.json'
    }
    Write-Utf8NoBomFile -Path $claudePath -Content ($out | ConvertTo-Json -Depth 20)
    Write-Info "Updated: $claudePath (removed hooks, disableAllHooks=true)"
}

# 6. CLARIFICATION_GATE_OFF for faster agent flow
if ([Environment]::GetEnvironmentVariable('CLARIFICATION_GATE_OFF', 'User') -ne '1') {
    [Environment]::SetEnvironmentVariable('CLARIFICATION_GATE_OFF', '1', 'User')
    Write-Info 'Set CLARIFICATION_GATE_OFF=1 (User env)'
}

# 7. AGENTS.md shell pointer (append once)
$claudeAgents = Join-Path $env:USERPROFILE '.claude\AGENTS.md'
$shellNote = @'

## Windows Agent Shell (global)

Before Python / Chinese paths / Office files / Shell cmdlets:

1. `powershell -NoProfile -File "$env:USERPROFILE\.ai-workspace\scripts\audit-windows-agent-env.ps1"`
2. Read file: Cursor Read tool OR `python ...\read-text-file.py path`
3. Run Python: write `.py` then `run-agent-python.ps1 script.py` — never inline `python -c`
4. Office/PPT: use agent python from `python-env.json` — NOT codex bundled python under `.cache\codex-runtimes`
5. Never `rtk Get-Content`; PS 5.1 has no `||`

Full rules: `~/.cursor/rules/windows-agent-shell.mdc`
'@
if (Test-Path -LiteralPath $claudeAgents) {
    $agents = Get-Content -LiteralPath $claudeAgents -Raw -Encoding UTF8
    if ($agents -notmatch 'audit-windows-agent-env') {
        Write-Utf8NoBomFile -Path $claudeAgents -Content ($agents.TrimEnd() + $shellNote)
        Write-Info 'Updated: ~/.claude/AGENTS.md shell pointer'
    }
}
$codexAgents = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
if (Test-Path -LiteralPath $codexAgents) {
    $agents = Get-Content -LiteralPath $codexAgents -Raw -Encoding UTF8
    if ($agents -notmatch 'audit-windows-agent-env') {
        Write-Utf8NoBomFile -Path $codexAgents -Content ($agents.TrimEnd() + $shellNote)
        Write-Info 'Updated: ~/.codex/AGENTS.md shell pointer'
    }
}

Write-Info ''
Write-Info 'Running post-repair audit...'
& (Join-Path $scripts 'repair-codex-config.ps1') -Quiet:$Quiet
& (Join-Path $scripts 'audit-windows-agent-env.ps1') -Quiet:$Quiet
exit $LASTEXITCODE
