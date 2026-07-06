# AI Agent Design

Use this when the product includes AI assistants, agents, RAG, prompt flows, or tool use.

## Design Fields

- User job.
- AI job.
- Source context.
- Tool access.
- Data owner.
- Output shape.
- Fallback behavior.
- Human confirmation point.
- Audit trail.

## Rules

- Do not present local fallback as model success.
- Do not let AI write persistent business data without a clear owner and confirmation rule.
- Retrieval inputs, model inputs, and user-visible output must be traceable.
- AI should reduce user effort, not hide state.

## Review Questions

- What does the AI know?
- What does the AI not know?
- What can the user verify?
- What happens when the model or network is unavailable?

