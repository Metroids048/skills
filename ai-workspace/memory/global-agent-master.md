# Global Agent Master

Status: active
Last updated: 2026-06-22

This file is the SSOT for all agent-facing behavior across Cursor, Codex, and Claude Code.

## 1. 永久在线规则

1. Priority order: user instruction > repo AGENTS.md > global master > skills/tools suggestion.
2. Before any implementation work, read the global memory files and the active repo overlay if present.
3. Never claim done without verification evidence.
4. Never use fake success, TODO-as-done, or local fallback as model success.
5. "最大权限" means fewer confirmations for the stated task only, not destructive scope.
6. If uncertainty affects the implementation path, stop and ask.

## 2. 对话提问门禁

Ask first when any of the following is true:

- The request is vague, broad, or outcome-only.
- The task touches product direction, IA, UI, AI/data, or multiple layers at once.
- The request is 0→1, new module, new page, or cross-file flow.
- The user has not specified the non-goals, acceptance, or data owner.

Required questions:

- Main change type: product / IA / UI / AI-data.
- Version target: prototype / internal beta / MVP / commercial.
- Out-of-scope list.
- Acceptance path.
- UI page acceptance card when applicable.

## 3. R2T 需求转换

R2T converts the user's request into a task card, not an implementation order.

Minimum task card:

- main change type
- version target
- out-of-scope
- acceptance card
- data owner
- risk notes

R2T output must be shown to the user for confirmation before execution when the task is ambiguous, cross-layer, or 0→1.

## 4. Skills / 工具按需调用

Use skills and tools only after the task card is confirmed.

- Requirement clarification: whenever the request is vague or missing acceptance.
- Zero-to-one gate: any new module, page, or flow that lacks an approved architecture summary.
- Verification: every task completion requires fresh evidence.
- Development workflows, API workflows, UI workflows, release workflows, and retrospective workflows are optional modules, not default expansion.

## 5. 开发流程与验收

1. Clarify.
2. Convert to R2T.
3. Confirm task card.
4. Execute the smallest verifiable change.
5. Self-review.
6. Verify with fresh evidence.
7. Record history / decisions / fact changes.

## 6. 返工复盘与持续优化

Classify every rework:

- requirement not locked
- layered change mixed together
- verification missing
- configuration not loaded
- context drift

If the same failure repeats, update the rule files or task template first, not just the implementation.
