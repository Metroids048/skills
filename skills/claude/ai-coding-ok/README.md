# 🧠 ai-coding-ok

> **English** | [中文](README.zh.md)

> **The PDCA memory loop for AI coding.**
> superpowers gives Claude discipline for one session. ai-coding-ok gives Claude memory that stays accurate across 50 iterations.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Works with](https://img.shields.io/badge/Works%20with-Claude%20Code%20%7C%20Copilot%20%7C%20Cursor%20%7C%20OpenCode-blueviolet)](#)
[![Version](https://img.shields.io/badge/Version-v3.0.0-blue)](#)

---

## The Problem

You ship a feature with Claude. Three sessions later, Claude "fixes" a bug by silently deleting a constraint it added last week. By iteration 50, your codebase has invisible regressions everywhere.

This isn't a prompt problem. It's a **memory problem with no feedback loop**.

Most AI tools (including [superpowers](https://github.com/obra/superpowers)) solve **single-session discipline** — plan before code, TDD, review. None of them solve **cross-session memory drift**.

---

## How ai-coding-ok Solves It

A four-stage **PDCA closed loop**, enforced on every task:

```
  Plan          Do            Check         Act
 ─────▶       ─────▶         ─────▶        ─────▶
read         write          run           update
memory       code +         tests,        memory
files        tests          verify        files
                            no
                            regression
```

| Phase | What happens |
|-------|--------------|
| **Plan** | Claude reads `project-memory.md`, `decisions-log.md`, `task-history.md` before touching code |
| **Do** | Code + tests in the same change |
| **Check** | Tests run; regression in unrelated features is caught |
| **Act** | Claude writes back to memory: `task-history.md` always; `decisions-log.md` on architecture change; `project-memory.md` on fact change |

The **Act** step is what most tools skip. Without it, your memory file is a snapshot that rots after 10 iterations because nobody updates it. With it, context stays accurate because every task closes the loop.

---

## Three-Tier Memory

| Tier | File | Content | Update frequency |
|------|------|---------|------------------|
| Long-term | `project-memory.md` | Architecture, constraints, known issues | Rarely |
| Mid-term | `decisions-log.md` | ADRs (why we chose X over Y) | On arch changes |
| Short-term | `task-history.md` | Last 30 task summaries | Every task |

Iteration 50 reads the same three files iteration 1 read — but they have grown 50 entries of compounded context. That's the point.

---

## Install

### Claude Code (recommended)

```
/plugin install ai-coding-ok@claude-plugins-official
```

Then in any project, in Claude Code:

```
install ai-coding-ok
```

Claude will:
1. Copy templates into your project
2. Ask one question: *"In one sentence, what are you building?"*
3. Infer your tech stack and fill all placeholders automatically
4. Bootstrap the first task-history entry — PDCA loop is active immediately

### Cursor / Copilot / OpenCode (script install)

```bash
git clone https://github.com/Mark7766/ai-coding-ok
cd your-project
bash /path/to/ai-coding-ok/install.sh --cursor   # or --copilot / --opencode
```

The templates auto-load via `.cursor/rules/ai-coding-ok.mdc` (Cursor), `.github/copilot-instructions.md` (Copilot), or `~/.config/opencode/AGENTS.md` (OpenCode).

---

## What gets installed in your project

```
your-project/
├── AGENTS.md                          # Architecture cheatsheet (AI reads first)
├── CLAUDE.md                          # Claude Code auto-load shim → @AGENTS.md
├── .cursor/rules/ai-coding-ok.mdc     # Cursor: alwaysApply PDCA rule
└── .github/
    ├── copilot-instructions.md        # Copilot: auto-loaded behavior rules
    ├── project-metadata.yml           # Machine-readable project facts
    ├── PULL_REQUEST_TEMPLATE.md       # PR template (memory-update checklist)
    ├── ISSUE_TEMPLATE/                # Issue templates
    ├── workflows/                     # CI + memory-update reminder
    └── agent/
        ├── system-prompt.md           # Agent persona + PDCA workflow
        ├── coding-standards.md        # Coding conventions
        ├── workflows.md               # Scenario playbooks
        ├── prompt-templates.md        # Prompt template library
        └── memory/
            ├── project-memory.md      # 🧠 long-term: project facts
            ├── decisions-log.md       # 📝 mid-term: ADRs
            └── task-history.md        # 📜 short-term: last 30 tasks
```

---

## Pairs with superpowers

ai-coding-ok and [superpowers](https://github.com/obra/superpowers) solve different problems and compose cleanly:

> **superpowers** brings per-session discipline.
> **ai-coding-ok** brings cross-session memory.

The combo flow:

```
1. ai-coding-ok Mode B  (Plan: load memory)        ← every task starts here
2. superpowers          (brainstorming → planning → execution)
3. ai-coding-ok Mode C  (Act: write memory back)   ← every task ends here
```

See [`docs/superpowers-combo.md`](docs/superpowers-combo.md) for five real-world recipes.

---

## How it differs from a hand-written AGENTS.md

A hand-written AGENTS.md is a snapshot. After 10 iterations it's stale because no one updates it. ai-coding-ok automates the **Act** step — Claude writes back to memory after every task, so the file stays alive.

| | Hand-written AGENTS.md | ai-coding-ok |
|---|---|---|
| Initial setup | Manual placeholders | One-sentence question, AI infers the rest |
| Mid-term decisions | Lost (or in scattered PR descriptions) | Captured as ADRs in `decisions-log.md` |
| Recent task context | Lost between sessions | Last 30 tasks in `task-history.md` |
| Memory update | Manual (and forgotten) | Automated via PDCA Act phase |
| Multi-tool support | One file per tool | One template, all tools auto-load |

---

## Honest caveats

- The Act step depends on Claude actually following instructions to write back. ~95% reliability in real use; the 5% can be caught by `scripts/verify.sh` running in CI.
- Memory files grow over time. `task-history.md` is capped at 30 entries by convention; `project-memory.md` should stay <500 lines or you lose the benefit (rotate old facts to ADRs).
- ai-coding-ok is opinionated about file layout. If you have an existing `AGENTS.md` with hand-edits, you'll want to merge by hand on first install.

---

## Upgrade

In a project with ai-coding-ok already installed:

```
upgrade ai-coding-ok
```

Claude detects your installed version, lists the framework changes, and merges them in — preserving your project-specific customizations.

For Copilot/Cursor users, see [`scripts/upgrade-prompt.md`](scripts/upgrade-prompt.md).

---

## Verify

After install, check that everything wired up correctly:

```bash
bash /path/to/ai-coding-ok/scripts/verify.sh
```

Exit codes: `0` = clean, `1` = missing files, `2` = unfilled placeholders.

---

## Documentation

- [Claude Code quickstart](docs/claude-code-quickstart.md)
- [Copilot quickstart](docs/copilot-quickstart.md)
- [Combo with superpowers](docs/superpowers-combo.md)
- [FAQ](docs/faq.md)
- [SKILL.md](skills/ai-coding-ok/SKILL.md) — canonical skill definition
- [CHANGELOG](CHANGELOG.md)

---

## Design philosophy

1. **One install, every tool** — Claude Code, Copilot, Cursor, OpenCode share the same template
2. **Let AI customize AI's config** — user says one sentence; the AI infers the rest
3. **Safe by default** — never overwrites existing files unless `--force`
4. **Auditable** — every install/upgrade leaves a trace in `task-history.md`

---

## Contributing

Issues and PRs welcome. Edit templates in `templates/{en,zh}/`. Edit skill behavior in `skills/ai-coding-ok/SKILL.md`. Edit docs in `docs/`.

---

## License

[MIT](LICENSE) — free for commercial use.
