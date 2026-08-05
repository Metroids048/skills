# Global AI Workspace

Global master: `C:\Users\win\.ai-workspace\memory\global-agent-master.md`
Global memory: `C:\Users\win\.ai-workspace\memory`
Skills index: `~/.claude/global-skills-index.md`

SessionStart: Read `C:\Users\win\.cursor\skills\global-session-core\SKILL.md` before other tools.
See also `~/.codex/RTK.md` if present.

## Plain-language confirmation rule

For any large change or conflict with existing behavior, stop and ask the user in plain non-technical language before implementing. Explain what will change on screen, what existing workflow or data may be affected, and give clear options with tradeoffs.
## Windows Agent Shell (global)

Before Python / Chinese paths / Office files / Shell cmdlets:

1. `powershell -NoProfile -File "$env:USERPROFILE\.ai-workspace\scripts\audit-windows-agent-env.ps1"`
2. Read file: Cursor Read tool OR `python ...\read-text-file.py path`
3. Run Python: write `.py` then `run-agent-python.ps1 script.py` 鈥?never inline `python -c`
4. Office/PPT: use agent python from `python-env.json` 鈥?NOT codex bundled python under `.cache\codex-runtimes`
5. Never `rtk Get-Content`; prefer PS 7 (`pwsh`) — installed at `C:\Program Files\PowerShell\7\pwsh.exe`

Full rules: `~/.cursor/rules/windows-agent-shell.mdc`
Upgrade/repair: `~/.ai-workspace/scripts/upgrade-powershell7-global.ps1`

<!-- AIOS MANAGED BLOCK START -->
## AI Coding OS

For product design, page design, UI design, redesign, dashboard, landing page, AI product workflow, PRD-to-UI, or product/UI review tasks:

- Read `C:\Users\win\.ai-workspace\ai-coding-os\AGENTS.md`.
- Load only the specific AIOS workflow files needed for the task.
- Keep existing global and repo rules higher priority than AIOS.
- Do not jump from vague product/UI requests directly into code.
<!-- AIOS MANAGED BLOCK END -->
