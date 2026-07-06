# Bugfix Workflow

Use this for defects in product behavior, UI states, styling, integration, or AI output.

## Steps

1. Reproduce or identify the failing condition.
2. Locate owner: product logic, IA/navigation, UI state, AI/data, backend, or config.
3. Fix root cause with minimal unrelated change.
4. Add or update regression coverage when practical.
5. Verify fresh output.
6. Review for adjacent regressions.

## UI Bug Checks

- No overflow.
- No clipped text.
- Disabled/loading/error states remain coherent.
- Navigation and back flow still preserve context.

