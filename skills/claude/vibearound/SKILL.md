---
name: "当 到 使用"
slug: vibearound
description: "当 到 使用：辅助完成相关分析、生成或审查任务"
---
# VibeAround Session Handover

Hand over the current coding session via the VibeAround orchestrator. The user can then pick it up from any connected IM channel (the pickup is not tied to a specific channel).

## When to Use

- User says `/vibearound handover`
- User asks to "hand over", "transfer", or "continue" the session on their phone or another device

## Prerequisites

The VibeAround MCP server must be connected (server name: `vibearound`). If not available, tell the user to start the VibeAround desktop app.

## Handover Steps

### 1. Get your session ID

Use the `/va-session` skill to resolve your current session ID.

### 2. Call prepare_handover

```
Tool: prepare_handover
Server: vibearound
Arguments:
  session_id: "<session_id from step 1>"  (pass if available)
  cwd: "<current working directory>"
  agent_kind: "<your agent type>"
```

If the tool says the workspace is not registered, ask the user for confirmation, then call `register_workspace` with the `cwd`, and retry.

### 3. Copy to clipboard and present the result

Copy the `/pickup` command to the user's clipboard, then show it. The user can paste it in any IM chat connected to VibeAround to resume the session there with the same agent.

## Error Handling

- **MCP server not available**: Start the VibeAround desktop app.
- **Workspace not registered**: Offer to register it (needs user confirmation).
- **Session ID not found**: The server can auto-discover in most cases. If that fails, tell the user.
