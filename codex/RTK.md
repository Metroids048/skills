# RTK - Rust Token Killer (Codex CLI)

**Usage**: Token-optimized CLI proxy for native executable commands only.

## Rule

Use `rtk` only for native executables where it is known to work, such as:

```powershell
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

## Do Not Wrap

Never prefix PowerShell cmdlets, aliases, or nested shell commands with `rtk`.

Forbidden examples:

```powershell
rtk Get-Content path\file.txt
rtk Select-String -Pattern foo
rtk Get-ChildItem -Recurse
rtk powershell -Command "..."
rtk pwsh -Command "..."
```

For file reads, use the Read tool when available, or:

```powershell
& $env:AGENT_PYTHON "$env:USERPROFILE\.ai-workspace\scripts\read-text-file.py" "path"
```

For PowerShell work, call PS7 directly or write a `.ps1` and run it with `-File`:

```powershell
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -ExecutionPolicy Bypass -File "script.ps1"
```

## Meta Commands

```powershell
rtk gain
rtk gain --history
rtk proxy <cmd>
```

## Verification

```powershell
rtk --version
rtk gain
where.exe rtk
```