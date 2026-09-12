---
name: "AI 浜у搧 UI 宸ヤ綔娴?
slug: ai-product-ui-workflow
description: "AI Coding OS锛氫骇鍝佽璁°€侀〉闈㈣璁°€乁I璁捐銆佹敼鐗堛€乨ashboard銆乴anding page銆丳RD杞晫闈€丄I浜у搧宸ヤ綔娴併€佷骇鍝?.."
disable-model-invocation: true
---
# AI Product UI Workflow

Use this skill as the routing entry for AIOS product and UI work.

## Source

Read `C:\Users\Windows11\.ai-workspace\ai-coding-os\AGENTS.md` first.

Then read only the files needed for the current task:

- `workflows/new-feature.md` for new product/page/UI work.
- `workflows/redesign.md` for visual or UX improvement.
- `workflows/ui-review.md` for UI audit.
- `product/requirement-analysis.md` before PRD/product specs.
- `ui/theme.md` before visual direction decisions.
- `review/ui.md` and `review/code.md` before completion.

## Hard Gates

- Vague task: ask for goal, scope, non-goals, version target, and acceptance path.
- 0-to-1 task: produce product/UI/architecture plan and wait for confirmation before coding.
- UI task: define required states, responsive behavior, interaction, and acceptance card before implementation.
- Review task: findings first, ordered by severity, with file or screen references when available.

## Output Contract

For planning, output:

- Goal and primary layer.
- Product design.
- UI design.
- Architecture and data owner.
- Task list.
- Acceptance and verification.

For delivery, output:

- Completed.
- Verified.
- Remaining risks.
