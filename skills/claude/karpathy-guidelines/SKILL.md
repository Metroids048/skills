---
name: "1. Think 在编码之前使用"
slug: karpathy-guidelines
description: "1. Think 在编码之前使用：辅助完成相关分析、生成或审查任务"
disable-model-invocation: false
---
# Karpathy Guidelines

Behavioral guidelines from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876). **Bias toward caution over speed** 鈥?use judgment on trivial one-liners.

## 1. Think Before Coding

State assumptions; ask when uncertain; present multiple interpretations; push back on over-engineering; stop and ask when confused.

## 2. Simplicity First

No scope creep, no speculative abstractions, no unrequested flexibility. If 200 lines could be 50, rewrite.

## 3. Surgical Changes

No drive-by refactors; match existing style; mention unrelated dead code but do not delete unless asked. Remove orphans only from your own edits.

## 4. Goal-Driven Execution

Map tasks to verifiable checks (tests, repro steps). Multi-step work: `step 鈫?verify: 鈥 per line.

**Pair with:** `requirement-clarifier` (before work), `verification-before-completion` / `global-delivery-gate` (before claiming done).

