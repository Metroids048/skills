# Windows Agent Shell — global command cheat sheet (ASCII only, safe for all agents).
#
# READ FILE (never rtk Get-Content, never PS inline):
#   python "$env:USERPROFILE\.ai-workspace\scripts\read-text-file.py" "path\to\file.md"
#   Or use Cursor Read tool — preferred for source/docs.
#
# RUN PYTHON (never inline python -c for multi-line / CJK / Office):
#   powershell -NoProfile -File "$env:USERPROFILE\.ai-workspace\scripts\run-agent-python.ps1" "script.py"
#
# RUN PS1 with CJK:
#   verify-ps1-script-encoding.ps1 -Path script.ps1  then  invoke-agent-ps1.ps1 -Path script.ps1
#   Or rewrite in Python instead.
#
# OFFICE / PPT / Word:
#   Use agent python from python-env.json (system py -3), NOT codex bundled python under .cache\codex-runtimes.
#   Check: verify-agent-python.ps1
#
# RTK:
#   rtk git / rtk node / rtk npm / rtk python script.py
#   NEVER: rtk Get-Content, rtk Select-Object, rtk powershell -Command "..." with nested quotes
#
# VERIFY before long tasks:
#   verify-windows-shell-encoding.ps1
#   verify-agent-python.ps1
