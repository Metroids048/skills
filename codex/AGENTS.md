# Global AI Workspace

Global rules: `C:\Users\win\.claude\AGENTS.md`
Global memory: `C:\Users\win\.ai-workspace\memory`
Skills index: `~/.claude/global-skills-index.md`

SessionStart: Read `C:\Users\win\.cursor\skills\global-session-core\SKILL.md` before other tools.
See also `~/.codex/RTK.md` if present.
## Windows Agent Shell (global)

**Codex on Windows still uses PowerShell 5.1 for `command_execution`** even after PS7 install. See `~/.ai-workspace/scripts/CODEX-WINDOWS-SHELL.md`.

Before Python / Chinese paths / Office files:

1. One-time stack: `install-global-agent-python.ps1` — see `~/.ai-workspace/AGENT-GLOBAL-STACK.md`
2. Verify (any folder): `verify-global-agent-stack.ps1` or full `audit-windows-agent-env.ps1`
3. Python ALWAYS: `$env:AGENT_PYTHON script.py` or `agent-python script.py` — NOT project `.venv`, NOT inline `python -c`
4. Read file: Cursor Read OR `read-text-file.py path`
5. Office/doc/ppt: global venv (win32com/python-pptx/python-docx) — do NOT write per-project dependency scripts
6. Never `rtk Get-Content`; use PS 7 at `C:\Program Files\PowerShell\7\pwsh.exe`

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
