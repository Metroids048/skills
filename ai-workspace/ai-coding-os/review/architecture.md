# Architecture Review

Use when work changes modules, routes, state, schemas, APIs, or AI/data flow.

## Check

- Module boundaries.
- State owner.
- Data flow.
- Entry points and navigation.
- Reuse versus new code.
- Failure modes.
- Verification strategy.
- Non-goals.

## Fail Conditions

- Two modules write the same durable state.
- A new route/page has no owner or acceptance path.
- AI output is persisted without traceability or confirmation.

