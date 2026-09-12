---
name: trading-safety-review
description: Review quant, alpha, and trading-agent changes for execution, state, precision, environment, and secret-safety hazards using read-only or synthetic evidence by default.
---

# Trading Safety Review

Default mode is read-only, dry-run, or exchange testnet. Never place a real order, alter a position, or print a credential.

## Review checklist

Trace request to durable state and reconciliation. Check duplicate and ghost orders, retry duplicate execution, idempotency keys, wrong direction, quantity and price precision, stop-loss/take-profit behavior, partial fills, stale orders, status reconciliation, timeout/retry semantics, persistence and restart recovery, leverage and liquidation risk, and testnet/live environment contamination. Confirm secrets are loaded without being logged and that errors do not include headers or tokens.

## Evidence protocol

Use synthetic order traces, public market data, or testnet only. Record the fixture, expected invariant, observed result, and residual risk. A live endpoint, account endpoint, order endpoint, or ambiguous environment is a blocker: stop and mark `BLOCKED` rather than probing it.

## Output

Report severity (`BLOCKER`, `HIGH`, `MEDIUM`, `LOW`), affected path, evidence, remediation, and whether the safe acceptance criteria pass. Explicitly state `NO LIVE TRADING PERFORMED`.
