param(
  [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

$configPath = Join-Path $CodexHome "config.toml"
$curatedRoot = Join-Path $CodexHome ".tmp\plugins"
$curatedMarketplace = Join-Path $curatedRoot ".agents\plugins\marketplace.json"
$targetMarketplaceDir = Join-Path $CodexHome ".agents\plugins"
$targetMarketplace = Join-Path $targetMarketplaceDir "marketplace.json"
$curatedCacheRoot = Join-Path $CodexHome "plugins\cache\openai-curated"
$curatedShaPath = Join-Path $CodexHome ".tmp\plugins.sha"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$codexBinDir = Join-Path $env:LOCALAPPDATA "OpenAI\Codex\bin"
$runtimeFiles = @(
  "codex.exe",
  "node.exe",
  "node_repl.exe",
  "rg.exe",
  "codex-command-runner.exe",
  "codex-windows-sandbox-setup.exe"
)

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

function Get-CodexResourcesDir {
  $pkg = Get-AppxPackage -Name "OpenAI.Codex" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($pkg -and $pkg.InstallLocation) {
    $candidate = Join-Path $pkg.InstallLocation "app\resources"
    if (Test-Path -LiteralPath (Join-Path $candidate "codex.exe")) {
      return $candidate
    }
  }

  $roots = @(
    "D:\WindowsApps",
    "$env:ProgramFiles\WindowsApps"
  )
  foreach ($root in $roots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    $match = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -like "OpenAI.Codex_*" } |
      Sort-Object Name -Descending |
      Select-Object -First 1
    if ($match) {
      $candidate = Join-Path $match.FullName "app\resources"
      if (Test-Path -LiteralPath (Join-Path $candidate "codex.exe")) {
        return $candidate
      }
    }
  }

  return $null
}

function Seed-CodexRuntimeBin {
  param([string]$ResourcesDir)

  New-Item -ItemType Directory -Force -Path $codexBinDir | Out-Null
  $missingBefore = @($runtimeFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $codexBinDir $_)) })
  if ($missingBefore.Count -eq 0) {
    Write-Host "runtime_ok $codexBinDir already seeded"
    return
  }

  robocopy $ResourcesDir $codexBinDir ($runtimeFiles -join " ") /NFL /NDL /NJH /NJS /R:1 /W:1 | Out-Null
  $missingAfter = @($runtimeFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $codexBinDir $_)) })
  if ($missingAfter.Count -gt 0) {
    throw "Failed to seed Codex runtime bin. Missing: $($missingAfter -join ', ')"
  }
  Write-Host "runtime_ok $codexBinDir seeded $($runtimeFiles.Count) executables"
}

function Build-PluginOverlayToml {
  param(
    [string[]]$Bundled,
    [string[]]$Primary,
    [string[]]$Curated,
    [string]$CodexHomeDir
  )

  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("[marketplaces.openai-bundled]")
  $lines.Add('last_updated = "2026-06-08T00:00:00Z"')
  $lines.Add('source_type = "local"')
  $lines.Add("source = '$CodexHomeDir\.tmp\bundled-marketplaces\openai-bundled'")
  $lines.Add("")
  $lines.Add("[marketplaces.openai-curated]")
  $lines.Add('last_updated = "2026-06-08T00:00:00Z"')
  $lines.Add('source_type = "local"')
  $lines.Add("source = '$CodexHomeDir\.tmp\plugins'")
  $lines.Add("")
  $lines.Add("[marketplaces.openai-primary-runtime]")
  $lines.Add('last_updated = "2026-06-08T00:00:00Z"')
  $lines.Add('source_type = "local"')
  $lines.Add("source = '$env:USERPROFILE\.cache\codex-runtimes\codex-primary-runtime\plugins\openai-primary-runtime'")
  $lines.Add("")

  foreach ($name in $Bundled) {
    $lines.Add("[plugins.`"$name@openai-bundled`"]")
    $lines.Add("enabled = true")
    $lines.Add("")
  }
  foreach ($name in $Primary) {
    $lines.Add("[plugins.`"$name@openai-primary-runtime`"]")
    $lines.Add("enabled = true")
    $lines.Add("")
  }
  foreach ($name in $Curated) {
    $lines.Add("[plugins.`"$name@openai-curated`"]")
    $lines.Add("enabled = true")
    $lines.Add("")
  }

  return (($lines -join "`r`n").TrimEnd() + "`r`n")
}

function Sync-CodexPlusPluginOverlay {
  param(
    [string]$OverlayToml,
    [string]$McpOverlayToml,
    [string[]]$PluginIds,
    [string]$Stamp
  )

  $settingsPath = Join-Path $env:USERPROFILE ".codex-session-delete\settings.json"
  if (-not (Test-Path -LiteralPath $settingsPath)) {
    Write-Host "codexplus_skip settings.json not found at $settingsPath"
    return
  }

  $plus = Get-Process codex-plus-plus -ErrorAction SilentlyContinue
  if ($plus) {
    Write-Host "codexplus_stop stopping Codex++ helper (PID $($plus.Id)) before persisting overlay"
    Stop-Process -Id $plus.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
  }

  Copy-Item -LiteralPath $settingsPath -Destination "$settingsPath.bak-repair-$Stamp"

  $overlayFile = [System.IO.Path]::GetTempFileName()
  $mcpFile = [System.IO.Path]::GetTempFileName()
  $idsFile = [System.IO.Path]::GetTempFileName()
  try {
    [System.IO.File]::WriteAllText($overlayFile, $OverlayToml, $utf8NoBom)
    [System.IO.File]::WriteAllText($mcpFile, $McpOverlayToml, $utf8NoBom)
    [System.IO.File]::WriteAllText($idsFile, (ConvertTo-Json -InputObject $PluginIds -Compress), $utf8NoBom)

    Invoke-ResolvedPython @("-c", @"
import json
import pathlib
import sys

overlay = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')
mcp_overlay = pathlib.Path(sys.argv[2]).read_text(encoding='utf-8')
ids = json.loads(pathlib.Path(sys.argv[3]).read_text(encoding='utf-8'))
settings_path = pathlib.Path(sys.argv[4])
settings = json.loads(settings_path.read_text(encoding='utf-8'))
settings['relayCommonConfigContents'] = overlay
settings['relayContextConfigContents'] = mcp_overlay
for profile in settings.get('relayProfiles', []):
    if profile.get('useCommonConfig'):
        cs = profile.setdefault('contextSelection', {})
        cs['plugins'] = [{'id': pid, 'enabled': True} for pid in ids]
        profile['contextSelectionInitialized'] = True
settings_path.write_text(json.dumps(settings, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('codexplus_ok', len(overlay), 'overlay_chars', len(mcp_overlay), 'mcp_chars', len(ids), 'registry_plugins')
"@, $overlayFile, $mcpFile, $idsFile, $settingsPath)
  }
  finally {
    Remove-Item -LiteralPath $overlayFile, $mcpFile, $idsFile -Force -ErrorAction SilentlyContinue
  }
}

if (-not (Test-Path -LiteralPath $configPath)) {
  throw "Codex config not found: $configPath"
}
if (-not (Test-Path -LiteralPath $curatedMarketplace)) {
  throw "OpenAI curated plugin marketplace cache not found: $curatedMarketplace"
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item -LiteralPath $configPath -Destination "$configPath.bak-install-core-plugins-$stamp"
New-Item -ItemType Directory -Force -Path $targetMarketplaceDir | Out-Null
New-Item -ItemType Directory -Force -Path $curatedCacheRoot | Out-Null
if (Test-Path -LiteralPath $targetMarketplace) {
  Copy-Item -LiteralPath $targetMarketplace -Destination "$targetMarketplace.bak-install-core-plugins-$stamp"
}

$market = Get-Content -LiteralPath $curatedMarketplace -Raw | ConvertFrom-Json
$curatedVersion = "local"
if (Test-Path -LiteralPath $curatedShaPath) {
  $curatedVersion = (Get-Content -LiteralPath $curatedShaPath -Raw).Trim()
  if ($curatedVersion.Length -gt 8) {
    $curatedVersion = $curatedVersion.Substring(0, 8)
  }
}
foreach ($plugin in $market.plugins) {
  if ($plugin.source.source -eq "local" -and $plugin.source.path.StartsWith("./")) {
    $relative = $plugin.source.path.Substring(2)
    $plugin.source.path = (Join-Path $curatedRoot $relative)
  }
  if ($plugin.source.source -eq "local" -and (Test-Path -LiteralPath $plugin.source.path)) {
    $pluginCacheDir = Join-Path (Join-Path $curatedCacheRoot $plugin.name) $curatedVersion
    New-Item -ItemType Directory -Force -Path $pluginCacheDir | Out-Null
    Copy-Item -Path (Join-Path $plugin.source.path "*") -Destination $pluginCacheDir -Recurse -Force
  }
}
$market.name = "openai-curated"
$market.interface.displayName = "Codex official"
$marketJson = $market | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($targetMarketplace, $marketJson + "`r`n", $utf8NoBom)

$bundled = @("browser", "chrome", "computer-use")
$primary = @("documents", "spreadsheets", "presentations")
$curated = @($market.plugins | ForEach-Object { $_.name } | Sort-Object -Unique)

$pluginIds = @(
  ($bundled | ForEach-Object { "$_@openai-bundled" })
  ($primary | ForEach-Object { "$_@openai-primary-runtime" })
  ($curated | ForEach-Object { "$_@openai-curated" })
)
$pluginOverlayToml = Build-PluginOverlayToml -Bundled $bundled -Primary $primary -Curated $curated -CodexHomeDir $CodexHome

$overlayTomlPath = Join-Path $CodexHome "codex-plus-overlay.toml"
$mcpOverlayTomlPath = Join-Path $CodexHome "codex-plus-mcp-overlay.toml"
[System.IO.File]::WriteAllText($overlayTomlPath, $pluginOverlayToml, $utf8NoBom)

$mergePy = Join-Path $PSScriptRoot "merge-codex-config.py"
Invoke-ResolvedPython @($mergePy, "--export-mcp", $configPath, $mcpOverlayTomlPath)
$mcpOverlayToml = Get-Content -LiteralPath $mcpOverlayTomlPath -Raw -ErrorAction SilentlyContinue
if (-not $mcpOverlayToml) { $mcpOverlayToml = "" }

Sync-CodexPlusPluginOverlay -OverlayToml $pluginOverlayToml -McpOverlayToml $mcpOverlayToml -PluginIds $pluginIds -Stamp $stamp

$mergePs1 = Join-Path $PSScriptRoot "merge-codex-config.ps1"
& $mergePs1 -CodexHome $CodexHome

$resourcesDir = Get-CodexResourcesDir
if (-not $resourcesDir) {
  throw "Codex Desktop resources directory not found. Install or update Codex Desktop first."
}
Seed-CodexRuntimeBin -ResourcesDir $resourcesDir

Invoke-ResolvedPython @("-c", "import json,tomllib,pathlib; c=pathlib.Path(r'$configPath'); m=pathlib.Path(r'$targetMarketplace'); s=pathlib.Path(r'$env:USERPROFILE\.codex-session-delete\settings.json'); o=pathlib.Path(r'$overlayTomlPath'); d=tomllib.loads(c.read_text(encoding='utf-8-sig')); j=json.loads(m.read_text(encoding='utf-8-sig')); cache=pathlib.Path(r'$curatedCacheRoot'); missing=[p['name'] for p in j.get('plugins',[]) if not (cache/p['name']/r'$curatedVersion'/'.codex-plugin'/'plugin.json').exists()]; sj=json.loads(s.read_text(encoding='utf-8')) if s.exists() else {}; print('config_ok', len(d.get('plugins',{})), 'plugins'); print('marketplace_ok', j['name'], len(j.get('plugins',[])), 'available'); print('preinstalled_ok', len(j.get('plugins',[])) - len(missing), 'cached', 'missing', len(missing)); print('codexplus_overlay_ok', len(sj.get('relayCommonConfigContents','')), 'common_chars', len(sj.get('relayContextConfigContents','')), 'context_chars'); print('overlay_file_ok', o.exists(), o.stat().st_size if o.exists() else 0)")
