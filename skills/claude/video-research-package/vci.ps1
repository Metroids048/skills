# vci.ps1 — 稳定入口。VCI 仓库没有 __main__.py，所以 `python -m vci` 会失败。
# 用法：pwsh -NoProfile -File <此文件> ingest "<url>"
#       pwsh -NoProfile -File <此文件> status
$ErrorActionPreference = 'Stop'

$Python = 'C:\Users\Windows11\.ai-workspace\venv\Scripts\python.exe'
$Repo   = 'C:\Users\Windows11\Desktop\video\video-content-intelligence'

if (-not (Test-Path $Python)) { Write-Error "agent python 不存在：$Python"; exit 3 }
if (-not (Test-Path $Repo))   { Write-Error "VCI 仓库不存在：$Repo"; exit 3 }

$env:PYTHONPATH = $Repo
$env:PYTHONIOENCODING = 'utf-8'

# 从任意 cwd 调用；工作区固定在 VCI 仓库下，包不会散落。
& $Python -c "import sys; from vci.cli import main; sys.exit(main(sys.argv[1:]))" @args
exit $LASTEXITCODE
