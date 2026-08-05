# Personal AI Knowledge System V1

本包包含：

- `USER_KNOWLEDGE_BASE.md`：用户背景、项目总账、内容素材和个人开放事项。
- `MEMORY_AGENTS.md`：类似 `AGENTS.md` 的跨 Agent 知识记录规则。
- `KNOWLEDGE_CAPTURE_PROMPTS.md`：初始化、会话归档、周复盘、月度清理、视频提取和 Token 耗尽前收口 Prompt。
- `SESSION_CAPSULE_TEMPLATE.md`：每次任务结束时使用的标准记录模板。

## 推荐部署

建立一个稳定的本地私有目录，例如：

```text
D:\AI-Knowledge\
```

或：

```text
~/AI-Knowledge/
```

不要放在公共 GitHub 仓库。

## 最稳妥的同步方式

1. 本地私有目录作为唯一事实源。
2. Cursor、Codex、Claude Code 都读取同一目录。
3. 每次重要会话结束生成 Session Capsule。
4. 使用私有 Git 进行版本控制和多设备同步。
5. 包含法律、客户、交易和身份信息的内容必须标记 `SENSITIVE`。
6. 密钥、Token、Cookie、私钥和 `.env` 永远不写入。
7. Agent 只生成主知识库修改建议，不自动整篇覆盖。

## 为什么不自动保存所有聊天

全量聊天包含大量重复、临时猜测、错误方案、工具噪音、隐私和未验证结论。

真正有长期价值的是结构化提取：

- 事实；
- 决策；
- 证据；
- 错误；
- 根因；
- 修复；
- 用户反馈；
- 结果；
- 视频素材。

## 推荐完整目录

```text
personal-ai-knowledge/
├─ USER_KNOWLEDGE_BASE.md
├─ MEMORY_AGENTS.md
├─ KNOWLEDGE_CAPTURE_PROMPTS.md
├─ CURRENT_STATE.md
├─ DECISIONS.md
├─ LESSONS.md
├─ CONTENT_VAULT.md
├─ inbox/
├─ proposed_updates/
├─ sessions/
├─ projects/
├─ personal/
├─ templates/
├─ schemas/
└─ tools/
```

## 接入顺序

1. 把本目录保存到固定私有路径。
2. 让 Claude Code 或 Codex 使用 `KNOWLEDGE_CAPTURE_PROMPTS.md` 中的 Prompt A 初始化完整仓库。
3. 在各项目中增加指向 `MEMORY_AGENTS.md` 的精简规则。
4. 每次编码或项目任务结束使用 Prompt B。
5. 普通网页 AI 对话结束使用 Prompt C。
6. 每周运行 Prompt E。
7. 每月运行 Prompt F。
8. 做视频时运行 Prompt G。
9. Token 或上下文接近上限时运行 Prompt H。

## 各工具入口

### Claude Code

项目 `CLAUDE.md`：

```markdown
@AGENTS.md
@D:/AI-Knowledge/MEMORY_AGENTS.md
```

路径替换为你的真实路径。

### Cursor

把精简规则放到：

```text
.cursor/rules/knowledge-memory.mdc
```

不要把整份主知识库复制进 User Rules。

### Codex

在全局或项目 `AGENTS.md` 中增加共享知识库入口，要求读取：

- `MEMORY_AGENTS.md`
- `CURRENT_STATE.md`
- 当前项目记录

### 普通 AI 对话

使用 Prompt C 输出 Session Capsule，保存到 `inbox/`，之后由本地 Agent 合并。

## 重要原则

- 主知识库不自动整篇重写。
- 用户最新纠正优先于旧记忆。
- 实际测试和外部结果优先于 AI 总结。
- 用户口头报告完成时标记 `USER_REPORTED`。
- 敏感信息永不进入公开视频。
- 项目规则不能被个人总知识库替代。
- 强制验收仍需 tests、CI、Hooks 和权限控制。
