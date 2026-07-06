# Codex on Windows: why PS7 upgrade may not show up in agent shell

## Facts (verified)

- **PS 7.6.3 is installed**: `C:\Program Files\PowerShell\7\pwsh.exe`
- **Codex Desktop/CLI on Windows** often executes shell via:
  `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` (5.1)
- **PreToolUse hooks for shell** are unreliable/disabled on Windows (OpenAI Codex issue #24453)
- Hooks **cannot rewrite** commands — only allow/deny

## What this means

Upgrading PS7 fixes **Cursor terminal**, **manual pwsh**, and **hooks that call pwsh**.
It does **NOT** automatically change Codex's built-in `command_execution` path.

## Agent must do instead

| Task | Command |
|------|---------|
| Python script | `python tools\script.py` |
| Safe Python runner | `& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -File "$env:USERPROFILE\.ai-workspace\scripts\run-agent-python.ps1" "script.py"` |
| Read text file | `python "$env:USERPROFILE\.ai-workspace\scripts\read-text-file.py" "path"` |
| PPT/Office | Python only (`ppt_v07_refine.py`, `win32com`) |

## Office enum error in PowerShell

"Office enumeration types not registered" is a **PowerShell COM interop** issue.
Use **Python win32com** or **python-pptx** — not PowerShell.

## Verify PS7 install (human)

```powershell
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -Command '$PSVersionTable.PSVersion'
```

## Verify Codex agent shell (inside Codex session)

Ask agent to run `$PSVersionTable.PSVersion` — expect **Major 7** after `windows.shell_path` is set and Codex restarted.

Config key (in `~/.codex/config.toml`):

```toml
[windows]
sandbox = "unelevated"
shell_path = "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
```

**Do NOT** put Windows paths in `persistent_instructions` inside TOML — `\U` in `C:\Users` breaks parsing (`invalid unicode 8-digit hex code`) and kills Codex++/plugin repair. Agent rules belong in `~/.codex/AGENTS.md`.

Apply/repair: `repair-codex-config.ps1` then `repair-codex-plus-plugins-mcp.ps1`

## $_ / $var eaten by outer wrapper (even with pwsh)

Codex wraps commands in `-Command "..."`. **Never use `$_` or `$foo` in inline shell.**
Use `rg`, `python script.py`, or write `.ps1` and run with `-File`.
