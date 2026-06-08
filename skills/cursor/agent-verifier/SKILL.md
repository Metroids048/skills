---
name: agent-verifier
description: Use before PR or when user asks to verify/audit agent-generated code for security, patterns, and quality.
disable-model-invocation: true
---
# agent-verifier (Agent Platform wrapper)

**Vendor source:** [`skills/vendor/agent-verifier/skills/verification/SKILL.md`](../../skills/vendor/agent-verifier/skills/verification/SKILL.md)

## Required workflow

1. **Read** the full vendor verification SKILL.md.
2. Run applicable sub-skills under `skills/vendor/agent-verifier/skills/`.
3. For **prototype delivery**, also run `node prototype/scripts/verify-all.js` — **5 steps** including `navigation-journey-check.js` (see `ai-delivery-gate`, ADR-003).
4. Navigation/session/proto init changes: read `.github/agent/memory/postmortem-navigation-2026-05-28.md`.

Combine with `verification-before-completion` — evidence before any PASS claim.

