# Security Review

Use for auth, settings, integrations, API keys, uploads, AI tools, and persistence.

## Check

- Secrets are not written to repo files.
- User input is validated before persistence or tool use.
- Uploaded or retrieved content is treated as untrusted.
- Permission changes are explicit.
- Destructive actions require confirmation.
- AI tool access is scoped to the user task.

