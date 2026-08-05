---
title: Cross-Agent Knowledge Memory Rules
version: 1.0
last_updated: 2026-07-28
scope: personal-ai-knowledge
---

# MEMORY_AGENTS.md

## 1. Purpose

This repository is the user's private, cross-agent knowledge system.

It stores:

- stable user preferences;
- project facts and current state;
- decisions and reasons;
- recurring Agent mistakes;
- proven fixes and verification evidence;
- tasks and open loops;
- content ideas derived from real experience;
- private personal records that must not be exposed.

It is not a raw transcript dump and not an automatic replacement for project-level `AGENTS.md`, `CLAUDE.md`, tests, CI, Hooks, or permissions.

## 2. Mandatory language

- Communicate with the user in Chinese by default.
- Preserve code, commands, logs, identifiers, filenames, APIs, and existing project terminology in their original language.

## 3. Source-of-truth order

When sources disagree, use this order:

1. the user's latest explicit correction or instruction;
2. real external results, platform output, exchange receipts, tests, logs, and current files;
3. approved project requirements and decisions;
4. current implementation and Git diff;
5. previous session summaries;
6. prior AI conclusions;
7. inference.

Never silently merge conflicting claims.

## 4. Record types

Every captured item must use one or more types:

- `USER_FACT`
- `USER_PREFERENCE`
- `USER_CONSTRAINT`
- `PROJECT_FACT`
- `PROJECT_STATUS`
- `DECISION`
- `TASK`
- `OPEN_QUESTION`
- `ASSUMPTION`
- `ERROR_PATTERN`
- `ROOT_CAUSE`
- `PROVEN_FIX`
- `VERIFICATION`
- `LESSON`
- `CONTENT_IDEA`
- `SENSITIVE`
- `DO_NOT_PUBLISH`

Every item must include:

- date and time when known;
- source tool;
- project;
- confidence;
- evidence or file/commit/command reference;
- public-safety classification;
- supersedes / conflicts-with reference when applicable.

## 5. What may enter durable memory

Record only information likely to matter again:

- stable user preferences and hard constraints;
- actual project paths, commands, architecture, and state;
- important decisions and rejected alternatives;
- recurring failure patterns;
- verified root causes and proven fixes;
- measurable results;
- real acceptance evidence;
- unresolved blockers;
- high-value content ideas grounded in real events.

## 6. What must not enter durable memory

Do not store:

- secrets, API keys, tokens, cookies, private keys, or `.env` contents;
- raw credentials;
- full proprietary customer documents;
- unredacted personal identity data in public/synced files;
- one-off terminal noise;
- unverifiable guesses;
- temporary task chatter;
- private chain-of-thought;
- repeated copies of the same facts;
- AI claims of completion without evidence;
- obsolete facts without a `STALE` marker.

## 7. Privacy tiers

### `PUBLIC_SAFE`

Can be used in content after normal fact checking.

### `PRIVATE`

Can be synced only in a private local/private remote repository.

### `SENSITIVE`

Personal, legal, financial, customer, employment, trading, identity, or account information. Keep in protected files and never insert into public content without explicit user approval.

### `SECRET`

Credentials and cryptographic material. Never store in this repository.

## 8. Session capture workflow

At the end of every meaningful session:

1. Read the current user request and visible conversation.
2. Inspect relevant project files, Git status/diff/log, task documents, test output, generated artifacts, and external results.
3. Produce one session capsule under `sessions/YYYY/MM/YYYY-MM-DD_HHMM_<tool>_<project>.md`.
4. Update the relevant project file.
5. Append new decisions to `DECISIONS.md`.
6. Append verified recurring lessons to `LESSONS.md`.
7. Add public-safe video ideas to `CONTENT_VAULT.md`.
8. Update `CURRENT_STATE.md`.
9. Propose a patch to `USER_KNOWLEDGE_BASE.md` only when a fact is durable and important.
10. Run contradiction, duplication, privacy, and stale-information checks.
11. Report exactly which files were changed and why.

Do not rewrite the entire master knowledge base after every small task.

## 9. Required session capsule

Each session capsule must contain:

```markdown
# Session Capsule

- Date:
- Tool:
- Project:
- User goal:
- Status: COMPLETE / PARTIAL / BLOCKED
- Sensitivity:
- Public-content eligibility:

## Inputs and context

## Actions performed

## Files changed

## Commands and external actions

## Verification evidence

## User feedback and corrections

## Decisions made

## Errors and root causes

## Proven fixes

## Unresolved items

## Reusable lessons

## Candidate video content

## Proposed durable-memory updates

## Conflicts / stale records

## Next smallest action
```

## 10. Completion evidence

Never write “completed” into durable memory unless there is evidence.

Acceptable evidence includes:

- real command and exit code;
- targeted test output;
- build/lint/typecheck output;
- generated artifact path;
- FFprobe metadata;
- exchange/platform receipt;
- screenshot or user-confirmed result;
- commit hash;
- independent read-only review.

When evidence is only the user's statement, use `USER_REPORTED`, not independently verified.

## 11. Project-memory boundaries

- Global user preferences belong in this repository.
- Project-specific facts belong in `projects/<project>.md` and the project's own `AGENTS.md`.
- Detailed implementation instructions belong in project Skills or plans.
- Mandatory checks belong in tests, CI, Hooks, permissions, or scripts.
- Do not make this knowledge repository a replacement for real project documentation.

## 12. Conflict and stale-data handling

When new evidence conflicts with existing memory:

1. preserve the old statement;
2. mark it `STALE` or `CONFLICTED`;
3. add the new statement with evidence and date;
4. link both records;
5. do not select a winner without sufficient evidence;
6. ask the user only when the conflict materially blocks the current task.

## 13. Content extraction rules

A real experience can become a video idea when it has:

- a clear goal;
- an observable conflict or surprise;
- real evidence;
- a decision or insight;
- a current result;
- a public-safe framing.

Never publish:

- customer names or documents;
- credentials or account details;
- unredacted legal counterpart identity;
- active trading secrets or exact protected Alpha formulas;
- live buy/sell recommendations;
- claims of stable profit without auditable evidence;
- copyrighted source content copied from references.

## 14. User's default project mode

Use closing mode:

- one objective;
- explicit acceptance criteria;
- minimal scope;
- blockers first;
- no unrelated refactor;
- real verification;
- stop when accepted.

Maximum automatic repair attempts for one check: 3.

If the same approach makes no meaningful progress twice, stop repeating it, return to the root cause and interface/state boundaries, and report evidence.

## 15. Final response format after memory updates

Return:

- Status;
- session capsule path;
- durable files updated;
- facts added or changed;
- evidence used;
- conflicts found;
- sensitive items withheld;
- content ideas created;
- remaining open items;
- smallest next action.
