---
name: claude-code-prompts-reference
description: Read-only reference for repowise-dev/claude-code-prompts patterns and sub-skills. Use when studying Claude Code prompt architecture — not for routine coding.
disable-model-invocation: true
---
# Claude Code Prompts Reference

Source: https://github.com/repowise-dev/claude-code-prompts (vendor mirror under `~/.ai-workspace/vendor/claude-code-prompts/`)

## When to Read

- Designing agent system/tool prompts
- Comparing verification or delegation patterns
- Fixing weak prompt structure (read `skills/prompt-architect/`)

## Contents (local)

| Path | Use |
|------|-----|
| `patterns/` | Pattern analyses with reusable templates |
| `skills/coding-agent-standards/` | Implementation discipline |
| `skills/prompt-architect/` | Prompt design methodology |
| `skills/verification-agent/` | Risk-based verification (reference only) |
| `complete-prompts/` | Full prompt templates |

## Do NOT duplicate at runtime

- P5 self-review: use `agent-verifier` + `verification-before-completion`, not vendor verification-agent as always-on.
- Routine delivery: use `workflow-gate` + `global-delivery-gate`.