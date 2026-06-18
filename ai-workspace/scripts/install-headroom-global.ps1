# Headroom + RTK global install for Cursor / Claude Code / Codex (Windows)
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\install-headroom-global.ps1"

$ErrorActionPreference = "Stop"
$HeadroomExe = Join-Path $env:APPDATA "Python\Python312\Scripts\headroom.exe"
$PyScripts = Join-Path $env:APPDATA "Python\Python312\Scripts"
$LocalBin = Join-Path $env:USERPROFILE ".local\bin"
$Mirror = "https://pypi.tuna.tsinghua.edu.cn/simple"

function Ensure-PathEntry([string]$Dir) {
  if (-not (Test-Path $Dir)) { return }
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $parts = $userPath -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
  if ($parts -notcontains $Dir) {
    $newPath = ($parts + $Dir) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = "$Dir;$env:Path"
    Write-Host "PATH + $Dir"
  }
}

Write-Host "=== Headroom global install ===" -ForegroundColor Cyan

if (-not (Test-Path $HeadroomExe)) {
  Write-Host "Installing headroom-ai[mcp,proxy] ..."
  python -m pip install --user --only-binary=:all: -i $Mirror "headroom-ai[mcp,proxy]==0.20.15"
}

Ensure-PathEntry $PyScripts
Ensure-PathEntry $LocalBin

# Windows 0.20.x wheel lacks Rust core — proxy needs degraded mode
[Environment]::SetEnvironmentVariable("HEADROOM_REQUIRE_RUST_CORE", "false", "User")
$env:HEADROOM_REQUIRE_RUST_CORE = "false"

& $HeadroomExe --version
& $HeadroomExe mcp install --force 2>&1 | Out-Host

# Codex MCP (idempotent append)
$CodexToml = Join-Path $env:USERPROFILE ".codex\config.toml"
if (Test-Path $CodexToml) {
  $toml = Get-Content $CodexToml -Raw -Encoding UTF8
  if ($toml -notmatch '\[mcp_servers\.headroom\]') {
    $block = @"

[mcp_servers.headroom]
command = "$($HeadroomExe -replace '\\','\\')"
args = ["mcp", "serve", "--direct"]
startup_timeout_sec = 30

"@
    Add-Content -Path $CodexToml -Value $block -Encoding UTF8
    Write-Host "Codex: added [mcp_servers.headroom]"
  } else {
    Write-Host "Codex: headroom MCP already present"
  }
}

# Cursor MCP — ~/.cursor/mcp.json (manual verify; JSON merge avoided here)
Write-Host "Cursor: ensure ~/.cursor/mcp.json has headroom → mcp serve (see headroom-setup-zh.md)"

# Cursor hooks: RTK requires preToolUse to be an array (merge with existing gates)
$CursorHooks = Join-Path $env:USERPROFILE ".cursor\hooks.json"
if (Test-Path $CursorHooks) {
  $hooksRaw = Get-Content $CursorHooks -Raw -Encoding UTF8
  $hooks = $hooksRaw | ConvertFrom-Json
  $pre = $hooks.hooks.preToolUse
  if ($pre -and $pre.GetType().Name -ne "Object[]") {
    $arr = @($pre)
    if ($arr.matcher -notmatch "Shell") {
      $arr += [pscustomobject]@{ matcher = "Shell"; command = "rtk hook cursor"; timeout = 15 }
    }
    $hooks.hooks.preToolUse = $arr
    $hooks | ConvertTo-Json -Depth 10 | Set-Content $CursorHooks -Encoding UTF8
    Write-Host "Cursor: converted preToolUse to array + Shell RTK hook"
  }
}

# RTK shell compression (bundled in Headroom stack)
if (Get-Command rtk -ErrorAction SilentlyContinue) {
  rtk init -g --auto-patch 2>&1 | Out-Host
  rtk init -g --agent cursor 2>&1 | Out-Host
  rtk init -g --codex --auto-patch 2>&1 | Out-Host
} else {
  Write-Warning "rtk not found in PATH — install RTK or add $($LocalBin)"
}

Write-Host ""
Write-Host "Done. Restart Cursor / Claude Code / Codex to load MCP." -ForegroundColor Green
Write-Host "Optional full-traffic proxy: powershell -File `"$env:USERPROFILE\.ai-workspace\scripts\start-headroom-proxy.ps1`""
