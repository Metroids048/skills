# Detect Python runtime for agents — avoid blind pip install.
# Writes ~/.ai-workspace/runtime/python-env.json
param(
    [string]$ProjectDir = '',
    [switch]$Quiet
)

$ErrorActionPreference = 'SilentlyContinue'

function Resolve-ProjectDir {
    param([string]$Seed)
    $candidates = @()
    if ($Seed) { $candidates += $Seed }
    if ($env:CLAUDE_PROJECT_DIR) { $candidates += $env:CLAUDE_PROJECT_DIR }
    if ($env:CURSOR_PROJECT_DIR) { $candidates += $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { $candidates += $env:CODEX_PROJECT_DIR }
    $candidates += (Get-Location).Path
    foreach ($start in $candidates) {
        if ([string]::IsNullOrWhiteSpace($start)) { continue }
        $dir = (Resolve-Path -LiteralPath $start -ErrorAction SilentlyContinue).Path
        if (-not $dir) { $dir = $start }
        if (Test-Path $dir) { return $dir }
    }
    return $null
}

function Test-VenvValid {
    param([string]$VenvPython)
    $venvRoot = Split-Path (Split-Path $VenvPython -Parent) -Parent
    $cfg = Join-Path $venvRoot 'pyvenv.cfg'
    if (-not (Test-Path $cfg)) { return $false }
    $homeLine = Get-Content $cfg | Where-Object { $_ -match '^home\s*=' } | Select-Object -First 1
    if (-not $homeLine) { return $false }
    $home = ($homeLine -replace '^home\s*=\s*', '').Trim()
    return (Test-Path $home)
}

function Find-Python {
    $projectDir = Resolve-ProjectDir -Seed $ProjectDir
    $result = [ordered]@{
        python      = $null
        source      = 'none'
        venv_valid  = $false
        venv_path   = $null
        user_site   = $null
        py_launcher = $false
        updated     = (Get-Date).ToString('o')
        project_dir = $projectDir
    }

    if ($projectDir) {
        $venvPy = Join-Path $projectDir '.venv\Scripts\python.exe'
        if (Test-Path $venvPy) {
            $result.venv_path = $venvPy
            if (Test-VenvValid -VenvPython $venvPy) {
                $result.python = $venvPy
                $result.source = 'project_venv'
                $result.venv_valid = $true
            }
        }
    }

    if (-not $result.python) {
        $py3 = Get-Command py -ErrorAction SilentlyContinue
        if ($py3) {
            $ver = & py -3 -c "import sys; print(sys.executable)" 2>$null
            if ($ver -and (Test-Path $ver.Trim())) {
                $result.python = $ver.Trim()
                $result.source = 'py_launcher'
                $result.py_launcher = $true
            }
        }
    }

    if (-not $result.python) {
        $py = Get-Command python -ErrorAction SilentlyContinue
        if ($py) {
            $result.python = $py.Source
            $result.source = 'path_python'
        }
    }

    if ($result.python) {
        $site = & $result.python -c "import site; print(site.USER_SITE)" 2>$null
        if ($site) { $result.user_site = $site.Trim() }
    }

    $runtimeDir = Join-Path $env:USERPROFILE '.ai-workspace\runtime'
    if (-not (Test-Path $runtimeDir)) {
        New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
    }
    $outPath = Join-Path $runtimeDir 'python-env.json'
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outPath, ($result | ConvertTo-Json -Depth 5), $utf8)

    if (-not $Quiet) {
        Write-Host "python-env -> $outPath"
        Write-Host "  python: $($result.python) ($($result.source))"
        if ($result.venv_path -and -not $result.venv_valid) {
            Write-Host "  WARN: .venv exists but pyvenv.cfg home invalid — use system python"
        }
    }

    return $result
}

Find-Python | Out-Null
