# Global Agent Master

Status: active
Last updated: 2026-06-26

This file is the SSOT for all agent-facing behavior across Cursor, Codex, and Claude Code.

## 1. 永久在线规则

1. Priority order: user instruction > repo AGENTS.md > global master > skills/tools suggestion.
2. Before any implementation work, read the global memory files and the active repo overlay if present.
3. Never claim done without verification evidence.
4. Never use fake success, TODO-as-done, or local fallback as model success.
5. "最大权限" means fewer confirmations for the stated task only, not destructive scope.
6. If uncertainty affects the implementation path, stop and ask.
7. When a task requires major changes, removes/replaces existing content, changes a product flow, or conflicts with existing behavior/PRD/ADR/implementation, ask in plain non-technical language before continuing. Explain what the user will see, what may change or disappear, and the practical tradeoff between options. “Continue” or “do it directly” does not waive this rule when a real conflict exists.

## 2. 对话提问门禁

Ask first when any of the following is true:

- The request is vague, broad, or outcome-only.
- The task touches product direction, IA, UI, AI/data, or multiple layers at once.
- The request is 0→1, new module, new page, or cross-file flow.
- The user has not specified the non-goals, acceptance, or data owner.
- The implementation would significantly change an existing page, route, workflow, saved data behavior, login/guest behavior, or user habit.
- The plan conflicts with existing code, project rules, tests, or a previous user preference.
- The change would delete, hide, or substantially replace existing content, modules, product copy, or user-facing entry points.

Required questions:

- Main change type: product / IA / UI / AI-data.
- Version target: prototype / internal beta / MVP / commercial.
- Out-of-scope list.
- Acceptance path.
- UI page acceptance card when applicable.
- Conflict/change choice: explain the conflict, 2-3 possible choices, user-visible impact, and your recommended choice.

Question style:

- Use plain language, not only technical terms.
- Say “what you will see/change” and “what this means for your current workflow.”
- Offer 2-3 clear options with tradeoffs when the direction is not obvious.
- If technical terms are necessary, translate them into user-visible impact in the same sentence.

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

## 7. 开发前置文档门禁

For product, IA, UI, architecture, or greenfield development work, do not jump straight into implementation.

Before creating pages, routes, APIs, data schemas, or major configuration:

1. Confirm the product goal, target users, in-scope work, out-of-scope work, acceptance path, and data owner.
2. Create or update the project-level pre-development documents: product architecture, page IA, UI direction, technical route, function list, PRD, and pending-confirmation list.
3. If the task conflicts with existing documents or requires a large change, ask the user first.
4. Ask in plain, non-technical language: explain what will change for the user, what options exist, and which option is recommended.
5. Do not silently resolve uncertainty by inventing business rules, fields, formulas, permissions, API contracts, or UI flows.
6. Project-specific details belong in the repo `AGENTS.md` or project memory, not in this global master.
