---
name: visual-qa
description: Perform functional and visual QA of web pages with fixed desktop and mobile viewports, screenshots, and an evidence-based review of hierarchy, spacing, typography, contrast, and consistency.
---

# Visual QA

Build or start the page, open the real URL in a local Chrome-compatible runtime, and capture both required viewports: desktop `1440x900` and mobile `390x844`. A passing build or lint run is not visual acceptance.

## Procedure

1. Record URL, commit/build, and test data. Avoid production mutation.
2. Capture screenshots at both viewports (use `scripts/capture.mjs` when Playwright is available).
3. Check navigation, keyboard focus, responsive overflow, loading/error states, and key CTA behavior.
4. Review visual hierarchy, contrast, typography, spacing, grid/alignment, density, rhythm, card/icon consistency, Chinese/English consistency, focal point, and whether the page looks like disconnected templates or excessive pure black.
5. Record each defect with viewport and screenshot path. Fix only blockers, then recapture.

## Completion gate

Functional checks **and** visual checks must pass. If a browser runtime is unavailable, report `BLOCKED: browser runtime unavailable`; do not infer visual success from source code.
