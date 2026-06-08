---
name: global-delivery-gate
description: Use before claiming done/fixed/PASS on any repo — run detected verify commands with fresh evidence.
disable-model-invocation: true
---
# Global Delivery Gate

Run **before** claiming done, fixed, or PASS on any project.

## Detection order (first match wins)

1. **`prototype/scripts/verify-all.js`** exists → run all 5 steps (incl. navigation-journey):
   ```bash
   node prototype/scripts/verify-all.js
   ```
   Also use `ai-delivery-gate` skill for Agent Platform prototype JS edits.

2. **`package.json` scripts** (run what exists, in order):
   - `npm run verify` / `pnpm verify` / `yarn verify`
   - `npm run lint`
   - `npm run typecheck`
   - `npm test`
   - `npm run build`

3. **Makefile**: `make test`, then `make lint` if targets exist

4. **Fallback**: `verification-before-completion` — run any project-documented check; capture fresh output

## Rules

- Never claim PASS from grep-only or assumed output
- If any step fails → fix first, or state **"Task is NOT fully verified."**
- End with **Completed / Verified / Remaining Risks**

