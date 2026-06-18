# Apply tri-end environment variables (idempotent).
# - CLAUDE_CODE_ATTRIBUTION_HEADER=0 (third-party API cache fix)
# - PYTHONUTF8=1, HEADROOM_REQUIRE_RUST_CORE=false
# - Codex persistent_instructions pointer to windows-agent-shell
param(
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Info([string]$Msg) {
    if (-not $Quiet) { Write-Host $Msg }
}

function Write-Utf8NoBomFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

$triEndEnv = [ordered]@{
    CLAUDE_CODE_ATTRIBUTION_HEADER = '0'
    PYTHONUTF8                     = '1'
    HEADROOM_REQUIRE_RUST_CORE     = 'false'
}

# --- Claude settings.json ---
$claudeSettingsPath = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path $claudeSettingsPath) {
    $settings = Get-Content $claudeSettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
else {
    $settings = [pscustomobject]@{
        '$schema' = 'https://json.schemastore.org/claude-code-settings.json'
        env       = [pscustomobject]@{}
    }
}

$envObj = @{}
if ($settings.env) {
    $settings.env.PSObject.Properties | ForEach-Object { $envObj[$_.Name] = $_.Value }
}
foreach ($k in $triEndEnv.Keys) {
    $envObj[$k] = $triEndEnv[$k]
}
$settingsObj = @{}
$settings.PSObject.Properties | ForEach-Object {
    if ($_.Name -ne 'env') { $settingsObj[$_.Name] = $_.Value }
}
$settingsObj['env'] = $envObj
if (-not $settingsObj.ContainsKey('$schema')) {
    $settingsObj['$schema'] = 'https://json.schemastore.org/claude-code-settings.json'
}
Write-Utf8NoBomFile -Path $claudeSettingsPath -Content ($settingsObj | ConvertTo-Json -Depth 20)
Write-Info "Updated: $claudeSettingsPath (env tri-end)"

# --- Cursor Claude Code extension env ---
$cursorSettingsPath = Join-Path $env:APPDATA 'Cursor\User\settings.json'
if (Test-Path $cursorSettingsPath) {
    $cursor = Get-Content $cursorSettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $existing = @{}
    if ($cursor.'claudeCode.environmentVariables') {
        foreach ($v in $cursor.'claudeCode.environmentVariables') {
            if ($v.name) { $existing[$v.name] = $v.value }
        }
    }
    foreach ($k in $triEndEnv.Keys) {
        $existing[$k] = $triEndEnv[$k]
    }
    $vars = @()
    foreach ($name in ($existing.Keys | Sort-Object)) {
        $vars += [ordered]@{ name = $name; value = [string]$existing[$name] }
    }
    $cursor | Add-Member -NotePropertyName 'claudeCode.environmentVariables' -NotePropertyValue $vars -Force
    Write-Utf8NoBomFile -Path $cursorSettingsPath -Content ($cursor | ConvertTo-Json -Depth 10)
    Write-Info "Updated: $cursorSettingsPath (claudeCode.environmentVariables)"
}

# --- User PATH: ~/.local/bin for rtk ---
$localBin = Join-Path $env:USERPROFILE '.local\bin'
if (Test-Path $localBin) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$localBin*") {
        [Environment]::SetEnvironmentVariable('Path', "$localBin;$userPath", 'User')
        Write-Info "Prepended to User PATH: $localBin"
    }
}

# --- Codex persistent_instructions pointer ---
$codexConfigPath = Join-Path $env:USERPROFILE '.codex\config.toml'
$shellPointer = 'Windows shell/RTK/Python: follow windows-agent-shell.mdc (~/.cursor/rules).'
if (Test-Path $codexConfigPath) {
    $toml = Get-Content $codexConfigPath -Raw -Encoding UTF8
    if ($toml -match 'persistent_instructions\s*=\s*"""') {
        if ($toml -notmatch 'windows-agent-shell') {
            $toml = $toml -replace '(persistent_instructions\s*=\s*""")', "`$1`n$shellPointer"
            Write-Utf8NoBomFile -Path $codexConfigPath -Content $toml
            Write-Info "Updated Codex persistent_instructions pointer"
        }
    }
}

Write-Info 'PASS: apply-tri-end-env complete'
