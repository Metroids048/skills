# Start Headroom optimization proxy (default http://127.0.0.1:8787)
# Usage: powershell -File "$env:USERPROFILE\.ai-workspace\scripts\start-headroom-proxy.ps1"

$ErrorActionPreference = "Stop"
$headroom = Join-Path $env:APPDATA "Python\Python312\Scripts\headroom.exe"
if (-not (Test-Path $headroom)) {
    Write-Error "headroom.exe not found at $headroom. Install: pip install -i https://pypi.tuna.tsinghua.edu.cn/simple headroom-ai[mcp,proxy]==0.20.15"
}

$port = if ($env:HEADROOM_PORT) { $env:HEADROOM_PORT } else { "8787" }
Write-Host "Starting Headroom proxy on http://127.0.0.1:$port ..."
Write-Host "Stats: http://127.0.0.1:$port/stats"
Write-Host "Stop with Ctrl+C in this window."
& $headroom proxy --host 127.0.0.1 --port $port
