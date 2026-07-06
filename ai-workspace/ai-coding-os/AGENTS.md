# AI Coding OS Entry

This file is the AIOS source-of-truth entry for Codex, Cursor, and Claude Code.

## Load Policy

Always keep context lean:

- Read this file when the task mentions product design, page design, UI design, redesign, dashboard, landing page, PRD-to-UI, AI product workflow, or review.
- Then read only the specific workflow and reference files needed for the current task.
- Existing global rules still win: user instruction, repo `AGENTS.md`, global master, then AIOS.

## Mandatory Gate

For product/UI/AI product work, do not write implementation before the user has approved the design or task card, unless the request is an explicitly tiny single-point edit.

Follow the 12-step flow:

1. Understand request.
2. Analyze project.
3. Product design.
4. UI design.
5. Architecture confirmation.
6. Task list.
7. Wait for confirmation.
8. Development.
9. Self-test.
10. Code review.
11. UI review.
12. Summary.

## Layer Lock

Each work round must name one primary layer:

- Product mainline.
- Information architecture.
- UI visual/interaction.
- AI/data loop.

Do not silently mix layers. If a change crosses layers, ask in plain language and explain what the user will see.

## Core Routing

- New product/page/UI feature: `workflows/new-feature.md`.
- Redesign or visual improvement: `workflows/redesign.md`.
- Bugfix: `workflows/bugfix.md`.
- UI review only: `workflows/ui-review.md`.
- Code review only: `workflows/code-review.md`.
- Release readiness: `workflows/release.md`.

## Review Requirement

Before claiming done, run the applicable local verification and read:

- `review/code.md`.
- `review/ui.md` for any UI work.
- `review/accessibility.md` for user-facing surfaces.

