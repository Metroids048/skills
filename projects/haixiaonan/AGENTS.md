# Project Agent Guide

> Replace every `<...>` placeholder with verified project information. Delete sections that do not apply. Never treat placeholders as executable commands.

## 1. Project purpose

- Primary goal: `<what this project exists to achieve>`
- Primary users: `<users or systems>`
- Current priority: `<current product or engineering priority>`
- Explicit non-goals: `<things this project must not become or this phase must not address>`

## 2. Sources of truth

Use these sources in this order when they disagree:

1. `<approved specification / issue / product requirement>`
2. `<tests or executable contract>`
3. `<architecture decision records / API schema>`
4. `<current implementation>`
5. `<README or older documentation>`

Do not silently choose between conflicting sources. State the conflict and follow the highest-priority verified source.

## 3. Repository map

- Application entry points: `<paths>`
- Core domain logic: `<paths>`
- API / integrations: `<paths>`
- Data models / schemas: `<paths>`
- Tests: `<paths>`
- Configuration: `<paths>`
- Generated files: `<paths; do not edit directly>`
- Sensitive or high-risk areas: `<paths>`

Read the nearest existing implementation and tests before creating a new pattern.

## 4. Environment and commands

- Supported runtime: `<versions>`
- Package / dependency manager: `<tool>`
- Install: `<command>`
- Local start: `<command>`
- Targeted test: `<command and usage>`
- Full test suite: `<command>`
- Lint / formatting check: `<command>`
- Type check: `<command>`
- Build: `<command>`
- Integration / end-to-end test: `<command>`
- Domain-specific verification: `<command or procedure>`

Use the project's existing toolchain and lockfile. Do not substitute another package manager or invent commands.

## 5. Architecture boundaries

- `<module A>` owns `<responsibility>` and must not depend on `<forbidden dependency>`.
- `<module B>` communicates with `<module C>` through `<interface/event/API>`.
- Business logic belongs in `<location>`, not `<location>`.
- External integrations must be wrapped by `<adapter/interface pattern>`.
- Shared state is persisted in `<source of truth>`.
- Backward compatibility requirements: `<requirements>`.

Do not bypass established boundaries for convenience. Propose an explicit architecture change when a boundary must change.

## 6. Coding conventions

- Follow existing language, naming, formatting, typing, logging, and error-handling patterns near the edited code.
- Prefer small, focused functions and modules with explicit inputs and outputs.
- Validate external input at system boundaries.
- Handle errors explicitly; do not swallow exceptions or convert failures into false success.
- Comments should explain non-obvious intent, constraints, or trade-offs, not restate code.
- New abstractions require at least two real use cases or a clear boundary benefit.
- New dependencies require justification, maintenance assessment, and compatibility checks.

Project-specific conventions:

- `<convention 1>`
- `<convention 2>`
- `<convention 3>`

## 7. Required workflow

### Analysis-only requests

When the user asks for analysis, planning, review, research, diagnosis, or explanation only:

- Do not edit files or run mutating commands.
- Inspect evidence and return findings, options, risks, and a recommended next step.

### Implementation requests

1. Restate the observable acceptance criteria.
2. Inspect relevant implementation, tests, configuration, and current git diff.
3. For non-trivial work, create an ordered plan with verification per milestone.
4. Implement the smallest coherent change.
5. Run targeted checks after each meaningful milestone.
6. Run all mandatory completion checks.
7. Review the final diff against the original request.
8. For substantial changes, obtain an independent read-only review.

### Bug fixes

1. Reproduce or precisely characterize the failure.
2. Identify the root cause using logs, tests, traces, or code evidence.
3. Add or update a regression test when feasible.
4. Implement the smallest root-cause fix.
5. Verify the original failure, adjacent edge cases, and regressions.

Do not make speculative edits before gathering evidence.

## 8. Verification matrix

A task is complete only when every applicable mandatory row passes.

| Check | Mandatory when | Command / evidence | Pass condition |
|---|---|---|---|
| Targeted tests | Any behavior change | `<command>` | All relevant tests pass |
| Full tests | `<conditions>` | `<command>` | No regression |
| Lint | Source changes | `<command>` | Exit code 0 |
| Type check | Typed code changes | `<command>` | Exit code 0 |
| Build | Buildable artifact changes | `<command>` | Exit code 0 |
| Integration / E2E | Boundary or workflow changes | `<command>` | Required scenarios pass |
| Security review | Auth, secrets, input, permissions | `<procedure>` | No unresolved critical finding |
| Domain validation | `<conditions>` | `<real metric/platform output>` | `<measurable threshold>` |

Never report an unexecuted check as passed. Record command, exit status, and meaningful output.

## 9. Test integrity

- Do not delete, skip, weaken, or rewrite valid tests to fit the implementation.
- A test may be changed only when the approved requirement changed or the test is demonstrably wrong; explain the evidence.
- Do not over-mock the behavior under test.
- Include important boundary, error, empty, timeout, retry, and state-recovery cases where relevant.
- Generated snapshots or golden files require inspection, not blind acceptance.

## 10. Safety and protected operations

Never perform these without explicit user authorization:

- Production deployment or production configuration changes.
- Destructive database or storage operations.
- Rewriting shared git history, force-pushing, or deleting branches/tags.
- Reading, exposing, committing, or transmitting secrets and private data.
- Real-money trading, payment, purchase, or irreversible external action.
- Disabling security, audit, validation, risk, or monitoring controls.

Project-specific protected operations:

- `<operation and required approval>`
- `<operation and required approval>`

Use dry runs, previews, test environments, backups, feature flags, and rollback plans where possible.

## 11. Retry and escalation

- Maximum automatic repair attempts for one failing check: 3.
- If the same failure occurs twice without meaningful progress, stop repeating the approach.
- Stop and report when requirements conflict, a required dependency/data source is unavailable, the environment prevents verification, or human product/risk judgment is required.
- Preserve the failure evidence and summarize attempted approaches before escalating.

## 12. Completion format

Return:

- Status: `COMPLETE`, `PARTIAL`, or `BLOCKED`.
- Summary of the root problem and solution.
- Files/components changed.
- Actual commands run and outcomes.
- Acceptance criteria mapping.
- Known limitations and skipped checks.
- Remaining risks and the smallest next action, if any.

## 13. Durable project memory

Record only stable, verified knowledge:

- Real build/test/run commands.
- Important architectural decisions and reasons.
- Recurring failure modes and proven fixes.
- Non-obvious integration behavior.
- Long-lived project conventions.

Do not record secrets, temporary task state, guesses, one-off logs, or conclusions that have not been verified. When the same Agent mistake occurs twice, add one concise rule to the nearest relevant project instruction file and remove obsolete rules.

<!-- AGENT-CONFIG-PACK:PROJECT-BRIDGE START -->
## Agent Config Pack bridge (2026-07-22)

Shared cross-tool contract for this repo (Cursor / Codex / Claude Code):

- Global Working Agreement lives in user globals (`~/.codex/AGENTS.md`, `~/.claude/AGENTS.md`, Cursor `00-agent-working-agreement.mdc`).
- This file (`AGENTS.md`) is the **project SSOT**. Claude imports it via `@AGENTS.md` in `CLAUDE.md`.
- Tool patches: `.cursor/rules/00-core-workflow.mdc`, `.cursor/rules/10-verification.mdc`, `.claude/rules/testing.md`.
- Before claiming COMPLETE: use `verify-work` skill (global or project `.agents/.cursor/.claude/skills/verify-work`).
- Analysis / planning / review-only requests: do not edit files.
- Max 3 auto-repairs per failing check; same failure twice without progress → stop and escalate with evidence.
- Never report unexecuted checks as passed. Prefer project-documented verify commands.
- Durable lessons only in `docs/AGENT_LESSONS.md` (no secrets, no temp task chatter).
- Substantial changes: independent read-only review via `.claude/agents/code-reviewer` when available.
<!-- AGENT-CONFIG-PACK:PROJECT-BRIDGE END -->

<!-- AI-KNOWLEDGE-MANAGED-START -->

## 共享用户记忆与项目知识

开始涉及本项目的非简单任务前，读取：

- `项目知识库/项目总览.md`
- `项目知识库/当前状态.md`
- `项目知识库/目标与验收标准.md`
- `项目知识库/开放事项.md`

默认收口模式；任务结束生成会话记录并调用中央同步；不得直接重写中央主知识库。

<!-- AI-KNOWLEDGE-MANAGED-END -->
