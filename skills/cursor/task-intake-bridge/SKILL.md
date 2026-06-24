---
name: task-intake-bridge
description: Use when a user request must first be typed, normalized, and rewritten into an execution-ready brief before routing downstream skills. Especially for fuzzy implementation, multi-step changes, cross-module work, debugging vs verification ambiguity, or skill-engineering requests.
disable-model-invocation: true
---
# Task Intake Bridge

## Overview

This skill adds a routing-grade intake layer between user language and tool execution. It classifies the request, rewrites it into a structured task shape, and points the agent at the right curated category before reading more specific skills.

## When to Use

- User asks in natural, broad, or mixed language
- Request may imply implementation, but scope is not yet normalized
- Request spans multiple steps, modules, repos, or decision layers
- Request is clearly one of: planning, implementation, debugging, verification, Figma/UI, research/docs, or skill engineering
- You need a compact internal brief before choosing downstream skills

Do not use when the task is a trivial factual answer with no follow-up action.

## Output Contract

Produce a compact internal task brief with these fields:

- `request_type`
- `goal`
- `constraints`
- `success_criteria`
- `scope_in`
- `scope_out`
- `risk_flags`
- `suggested_category`
- `suggested_skill_chain`

For fuzzy implementation requests, also produce a Mini-Spec before code changes.

## Request Types

Use exactly one primary type:

- `consultation`
- `clear_execution`
- `fuzzy_implementation`
- `zero_to_one`
- `debugging`
- `verification`
- `skill_engineering`

## Category Mapping

Map to one curated category before loading downstream skills:

- `consultation` -> `70-research-docs` or `90-reference-optional`
- `clear_execution` -> `30-implementation`
- `fuzzy_implementation` -> `10-intake-routing`
- `zero_to_one` -> `10-intake-routing` then `20-planning-spec`
- `debugging` -> `40-debugging`
- `verification` -> `50-verification-review`
- `skill_engineering` -> `80-skill-engineering`

## Bridge Strength

- Soft bridge: explicit, low-risk, single-step tasks. Normalize and proceed.
- Hard gate: fuzzy, multi-step, cross-module, 0-to-1, architecture, destructive, or bulk-reorganization tasks. Normalize, ask/confirm when needed, then proceed.

## Execution Pattern

1. Identify one primary request type.
2. Write the structured task brief.
3. Select the curated category.
4. Read that category's `_routing.md`.
5. Choose 1-3 downstream skills from that category.
6. Read only the chosen skill files.

## Red Flags

- Treating broad product language as implementation-ready
- Loading many skills before classifying the request
- Mixing debugging, planning, and execution in one untyped step
- Letting keyword overlap outrank actual task shape

