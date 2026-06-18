param(
  [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

$mergePy = Join-Path $PSScriptRoot "merge-codex-config.py"
if (-not (Test-Path -LiteralPath $mergePy)) {
  throw "merge-codex-config.py not found: $mergePy"
}

function Invoke-ResolvedPython {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  foreach ($candidate in @(
    @{ Name = "py"; Args = @("-3") },
    @{ Name = "python"; Args = @() },
    @{ Name = "python3"; Args = @() }
  )) {
    if (-not (Get-Command $candidate.Name -ErrorAction SilentlyContinue)) {
      continue
    }
    try {
      & $candidate.Name @($candidate.Args + @("-c", "print('ok')")) *> $null
      if ($LASTEXITCODE -eq 0) {
        & $candidate.Name @($candidate.Args + $Arguments)
        return
      }
    }
    catch {}
  }
  throw "No working Python launcher found. Tried: python3, py -3, python"
}

$env:CODEX_HOME = $CodexHome
Invoke-ResolvedPython @($mergePy, $CodexHome)
if ($LASTEXITCODE -ne 0) {
  throw "merge-codex-config.py failed with exit code $LASTEXITCODE"
}
