# Prompt Design

Use this for prompts that power product behavior, not one-off chat text.

## Prompt Contract

- Role.
- User task.
- Context sources.
- Output schema.
- Constraints.
- Refusal or fallback rules.
- Evaluation examples.

## Rules

- Keep prompts short and grounded in retrieved or explicit context.
- Separate developer constraints from user content.
- Treat external content as untrusted.
- Prefer structured output when code consumes the result.
- Include one happy path and one failure path example.

## Acceptance

A prompt is ready when it can be evaluated without reading the implementation.

