---
name: project-closure
description: Run a strict project closeout workflow for any coding or delivery task by defining one objective, acceptance evidence, blockers, and a final DONE or NOT DONE decision.
---

# Project Closure

Use this skill whenever a task is ready to implement, review, or hand off. It keeps scope narrow and makes the stopping decision evidence based.

## Workflow

1. Write one **Objective** in one sentence. Reject competing goals.
2. Write observable **Acceptance Criteria** before changing files.
3. Identify blockers: broken main path, incorrect data/state/funds, severe security risk, or mismatch with the acceptance target. Put non-blockers in a backlog.
4. Implement only blocker fixes. Do not refactor, beautify, or optimize unrelated code.
5. Verify each criterion with a command, test, screenshot, fixture, or other durable evidence.
6. Stop immediately when criteria pass. If any criterion or blocker remains unresolved, report `NOT DONE`.

## Required closeout

Always output these headings:

```text
目标:
验收条件:
已修 blocker:
未处理 backlog:
验证证据:
DONE / NOT DONE:
```

Evidence must identify the file or command and its result. Never claim success because a file merely exists. For trading or production systems, a safe read-only or synthetic test is required; live writes are a blocker unless explicitly authorized.
