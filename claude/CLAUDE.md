@AGENTS.md

# Claude Code adapter — Personal AI Runtime v2

For every non-trivial task, do not rely on SessionStart/UserPromptSubmit full-scan hooks. Ask the shared deterministic runtime for context and Skills:

```powershell
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" context "<user task>"
```

Then load only the selected skill files from `~/.claude/skills/<id>/SKILL.md`.

For explicit history/continuation requests, use:

```powershell
python "$env:USERPROFILE\.ai-workspace\runtime\aiw.py" memory search "<query>"
```

Do not bulk-load raw ChatGPT/Codex/Claude/Cursor transcripts. Durable memory is structured project knowledge; raw sessions are L3 evidence only.
