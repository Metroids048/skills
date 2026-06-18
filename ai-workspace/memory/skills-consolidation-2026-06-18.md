# Skills Consolidation Report — 2026-06-18

## Summary

Batch-3 install: external prompt/skills sources + six-phase workflow gate + project templates + routing dedup.

| Item | Status |
|------|--------|
| Vendor: `claude-code-prompts` | Cloned → junctions in `claude-code-prompts-reference` |
| Vendor: `most-capable-agent` | Cloned → `most-capable-agent-reference` |
| Vendor: `PAIPlugin` | GitHub clone failed (network); `context-engineering` written from upstream SKILL content |
| Vendor: `claude-skill-registry` | GitHub clone failed (network); `ai-prompt-engineering` operational summary installed |
| `workflow-gate` skill + rule | Installed; added to `alwaysOnSkills` |
| `~/.claude/AGENTS.md` | Project Brain + six-phase gate added |
| Project templates | `AGENT.md`, `RULES.md`, `DESIGN.md` + `init-project-memory.ps1` |
| `program1-main` overlay | `.github/agent/memory/*` created |

## New global skills (381 total indexed)

| Skill | Role | Tri-end |
|-------|------|---------|
| `workflow-gate` | Six-phase approval gate | cursor + junction → claude/codex |
| `context-engineering` | Signal-to-noise / JIT loading | cursor + junction → claude/codex |
| `ai-prompt-engineering` | Production prompt patterns | cursor + junction → claude/codex |
| `claude-code-prompts-reference` | repowise patterns (on demand) | cursor + junction → claude/codex |
| `most-capable-agent-reference` | Full prompt in vendor README | cursor + junction → claude/codex |

## Dedup / routing (skills-sync.config.json)

| Domain | Winner | Demoted |
|--------|--------|---------|
| Prompt ops | `ai-prompt-engineering` | `prompt-engineering` (routingExclude) |
| Context principles | `context-engineering` | — |
| Reference packs | `*-reference` | excludeNames + routingExclude |
| Delivery verify | `global-delivery-gate` | existing exclusiveGroup unchanged |

## Always-on stack (≤5 with conditional)

1. `global-session-core`
2. `requirement-clarifier`
3. `karpathy-guidelines`
4. `workflow-gate` **(new)**
5. `ai-coding-ok` (conditional: repo with AGENTS.md)

## Tri-end verify

- Removed forbidden `SessionStart` / `UserPromptSubmit` hooks from `~/.claude/settings.json` (DeepSeek cache compliance)
- Set `disableAllHooks: true`, `ENABLE_PROMPT_CACHING_1H: 1`, `CLAUDE_CODE_ATTRIBUTION_HEADER: 0`
- Re-run: `verify-tri-end-config.ps1` after this report

## Scripts added

- `~/.ai-workspace/scripts/install-skills-consolidation-batch3.ps1`
- `~/.ai-workspace/scripts/install-skills-junctions-quick.cmd`
- `~/.ai-workspace/scripts/prune-codex-duplicate-skills.ps1`

## Remaining risks

- ~~`PAIPlugin` / `claude-skill-registry` vendor mirrors incomplete~~ **Resolved 2026-06-18 PM** — see below
- `sync-cursor-global-skills.ps1` requires project with `skills/` folder (Agent Platform) — batch-3 uses junction install instead
- Codex prune removed 0 dirs (duplicates may already be absent)

## Vendor completion (2026-06-18 PM)

| Source | Vendor path | Tri-end skill |
|--------|-------------|---------------|
| PAIPlugin `skills/prompting` | `vendor/PAIPlugin-prompting/context-engineering/` (+ `CLAUDE.md`) | `context-engineering` junction |
| vasilyu1983/AI-Agents-public | `vendor/ai-prompt-engineering-upstream/ai-prompt-engineering/` (22 files, references+assets) | `ai-prompt-engineering` junction |
| majiayu000/claude-skill-registry | `vendor/claude-skill-registry/README.md` stub (main repo index-only) | N/A — upstream used instead |

Install helpers: `complete-vendor-remains.ps1`, `link-upstream-skills.cmd`

## Maintenance

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\scan-global-skills.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\verify-tri-end-config.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ai-workspace\scripts\init-project-memory.ps1" -ProjectName "my-project" -StartDir "C:\path\to\repo"
```
