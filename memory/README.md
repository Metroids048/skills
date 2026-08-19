# AIW Memory Model

本目录只保存 **public-safe bootstrap memory**。真实用户画像、财务/求职/法律/交易、客户信息、ChatGPT 会话、Codex/Claude/Cursor 原始历史都不得提交到这里。

真正的长期私人记忆 SSOT 默认位于：

```text
~/.ai-workspace/private-memory/
```

也可以用 `AIW_PRIVATE_MEMORY_ROOT` 指定其他私有目录/私有 Git 仓库。

推荐结构：

```text
private-memory/
├─ global/
├─ projects/<project_id>/
│  ├─ PROJECT.md
│  ├─ CURRENT_STATE.md
│  ├─ DECISIONS.md
│  ├─ PITFALLS.md
│  ├─ PROVEN_FIXES.md
│  └─ ACCEPTANCE.md
├─ sessions/<project_id>/
├─ imports/chatgpt/
└─ proposed-updates/
```

加载分层：L0 全局稳定契约 → L1 当前项目包 → L2 当前任务相关记忆 → 只有显式追溯历史时才读取 L3 session evidence。
