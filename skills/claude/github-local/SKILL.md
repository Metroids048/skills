---
name: github-local
description: Use the official gh CLI for provider-independent GitHub work with read-only defaults, safe public repository inspection, and explicit authorization gates for private or write operations.
---

# GitHub Local

Prefer `gh` CLI. Start with `gh --version` and `gh auth status` (never print token material). Public read-only operations may run without login when GitHub permits them; private reads, pushes, issues, and pull requests require the user to authorize the specific action.

Safe example: `gh repo view cli/cli --json nameWithOwner,description,defaultBranchRef` or `gh api repos/cli/cli --method GET`. Reject commands containing push, merge, delete, or mutation unless explicitly authorized. Summarize errors without headers or credentials.
