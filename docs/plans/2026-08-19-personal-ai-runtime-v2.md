# Personal AI Runtime v2 — Implementation Contract

Base: `cdb01ff81ffcb8a2e115dc1a21c49821b08153d6`
Branch: `agent/personal-ai-runtime-v2`

## Frozen user outcome

Turn the repository from a three-endpoint config/session snapshot into a portable Personal AI Runtime where Codex, Claude Code and Cursor share: (1) deterministic project context, (2) relevant durable memory and pitfalls, and (3) a small routed Skill set instead of hundreds of globally exposed Skills.

## Root causes closed by this change

1. Raw private archives were part of the normal export while the actual repository was public.
2. `.jsonl` session files bypassed the previous redaction traversal.
3. Hundreds of duplicated endpoint Skills were installed wholesale and routing depended on model/hook luck.
4. Source-machine absolute paths made the “one-command portable install” contract false.
5. Long-term memory existed as files but was not a bounded, task-relevant runtime retrieval layer.
6. Repo/Agent Platform/runtime scripts competed as SSOTs.

## Target contracts

- Canonical active Skill body: `skills-src/<id>`.
- Skill metadata/routing SSOT: `registry/skills.json`.
- Private memory SSOT: outside Git repo.
- `aiw context` is the shared tri-agent context entry.
- Raw history is L3 evidence, never default durable memory.
- Old endpoint skill pools remain only as migration/rollback evidence and are not installed.
- Default export never copies raw sessions or private memory.

## Implementation stages

1. Privacy boundary and safe export.
2. Runtime + project detection + memory retrieval.
3. Curated Skill registry + canonical `skills-src` + Top-5 router.
4. Thin Codex/Claude/Cursor adapters + portable installer.
5. ChatGPT export importer to private evidence store.
6. Routing/privacy/portability tests and independent review.
7. Merge only after fresh verification.

## Explicit non-claims

- This change does not erase secrets or private data from historical Git commits.
- This environment cannot execute Windows PowerShell, so clean-Windows tri-agent acceptance remains an external validation item.
- ChatGPT account history cannot be magically read by local agents; the supported backfill is structured current memory + user-provided ChatGPT data export into private memory.
