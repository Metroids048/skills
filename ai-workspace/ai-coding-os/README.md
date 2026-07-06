# AI Coding OS

AI Coding OS is the shared product, UI, architecture, review, and delivery workflow for Codex, Cursor, and Claude Code on this machine.

It is not a replacement for `C:\Users\win\.ai-workspace\memory\global-agent-master.md`. It is a focused extension for product design, page design, UI design, and AI product development work.

## Principles

- Keep one source of truth in `C:\Users\win\.ai-workspace\ai-coding-os`.
- Keep global agent entry files thin. Load detailed rules only when the task needs them.
- Do not jump from a vague request directly into code.
- Product direction, IA, UI, AI/data, and architecture are separate decision layers.
- Every meaningful UI change gets product review, UI review, accessibility review, and verification.

## Standard Flow

1. Understand the request.
2. Analyze the project.
3. Produce product design.
4. Produce UI design.
5. Confirm architecture.
6. Generate the task list.
7. Wait for confirmation.
8. Develop.
9. Self-test.
10. Run code review.
11. Run UI review.
12. Summarize completion and risks.

## First Files To Load

- `AGENTS.md` for the global AIOS entry.
- `workflows/new-feature.md` for most product/page/UI feature work.
- `workflows/redesign.md` for redesign or UI polish work.
- `product/requirement-analysis.md` before writing PRDs or product specs.
- `ui/theme.md` before creating or changing visual direction.
- `review/ui.md` and `review/code.md` before claiming done.

## Install

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\win\.ai-workspace\ai-coding-os\installer\install-aios.ps1
```

Verify:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\win\.ai-workspace\ai-coding-os\installer\verify-aios.ps1
```

