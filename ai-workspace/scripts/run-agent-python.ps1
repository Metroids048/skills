# Run a .py file with the agent Python (never inline python -c for multi-line/CJK).
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ScriptPath,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$ScriptArgs
)

$ErrorActionPreference = 'Stop'

$globalPy = Join-Path $env:USERPROFILE '.ai-workspace\venv\Scripts\python.exe'
$python = $null
if ($env:AGENT_PYTHON -and (Test-Path -LiteralPath $env:AGENT_PYTHON)) {
    $python = $env:AGENT_PYTHON
}
elseif (Test-Path -LiteralPath $globalPy) {
    $python = $globalPy
}
else {
    $envJson = Join-Path $env:USERPROFILE '.ai-workspace\runtime\python-env.json'
    if (Test-Path -LiteralPath $envJson) {
        $info = Get-Content -LiteralPath $envJson -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($info.python -and (Test-Path -LiteralPath $info.python)) {
            $python = $info.python
        }
    }
}
if (-not $python) {
    $python = (Get-Command python -ErrorAction SilentlyContinue).Source
}
if (-not $python) {
    Write-Error 'No python found. Run ensure-python-env.ps1 first.'
}

$resolved = Resolve-Path -LiteralPath $ScriptPath
if ($ScriptArgs -and $ScriptArgs.Count -gt 0) {
    & $python $resolved.Path @ScriptArgs
}
else {
    & $python $resolved.Path
}
exit $LASTEXITCODE
