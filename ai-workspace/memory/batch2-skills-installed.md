# Batch 2 skills install (2026-06-03)

Conservative gap-fill per `skills-gap-analysis.md`. Vendor sources under `~/.ai-workspace/vendor/`.

## Installed (junction → vendor, tri-endpoint)

| Name | Source | Trigger |
|------|--------|---------|
| `cursor-awesome-parallel-exploring` | spencerpauly/awesome-cursor-skills | 大仓并行 explore subagent |
| `cursor-awesome-auditing-performance` | same | 性能 / CWV / bundle 审计 |
| `cursor-awesome-building-skills-from-patterns` | same | 重复流程沉淀为 SKILL |
| `rezvani-soc2-audit-prep` | alirezarezvani/claude-skills compliance-os | SOC2 审计准备 |
| `rezvani-gdpr-audit-prep` | same | GDPR 审计准备 |
| `rezvani-ai-act-readiness` | same | EU AI Act 就绪 |

## Cursor rules (not always-on)

- `~/.cursor/rules/books-clean-code.mdc` — nano from ciembor/agent-rules-books
- `~/.cursor/rules/books-ddd.mdc` — DDD distilled nano

## Routing

`Agent Platform/scripts/hooks/skills-sync.config.json` → `promptKeywordBoosts` for the six skills above.

## Not installed (by design)

- antigravity-awesome-skills full tree
- VoltAgent awesome-agent-skills bulk copy
- claude-skills 337+ full clone
- ECC profile full / ECC hooks

## Maintenance

- Update vendor: re-download zip to `~/.ai-workspace/vendor/` then re-run junction script or reinstall from this doc.
- Global index: `powershell …/scan-global-skills.ps1`
- Backup before overwrite: `~/.ai-workspace/backups/pre-batch2-skills-2026-06-03/`
