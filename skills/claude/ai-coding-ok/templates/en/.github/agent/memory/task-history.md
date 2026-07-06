# 📜 {{project-name}} — Task History

> **Purpose**: record summaries of recent tasks to give the AI agent short-term context.
> Keep the most recent 30 tasks; archive older entries.

---

## Record Format

```markdown
### [TASK-{number}] {task-title}
- **Date**: YYYY-MM-DD
- **Type**: feat / fix / refactor / docs / chore
- **Summary**: one sentence about what was done
- **Changed files**: list the core changed files
- **Related issue**: #xxx (if any)
- **Notes**: things to watch out for later (if any)
```

---

## Task Records

### [TASK-001] Project initialization
- **Date**: {{date}}
- **Type**: chore
- **Summary**: {{init-summary}}
- **Changed files**: {{files-list}}
- **Notes**: {{notes}}
