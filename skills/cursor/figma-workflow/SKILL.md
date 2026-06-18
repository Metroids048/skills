---
name: figma-workflow
description: Use when Agent Platform Figma work needs figma.config.json — implement from Figma, sync HTML to Figma, or create design files. Triggers: 按 Figma 实现, 同步到 Figma, 对照设计稿. NOT when: pure Figma URL/frame-to-code without config sync（用 figma2code）。
disable-model-invocation: true
---
# Figma 工作流（Agent Platform · Starter 三端）

## 零配置原则

用户已跑过 `scripts/sync-figma-mcp.ps1`。**不要**每次重配 MCP；先读 `design/figma.config.json` 与 `docs/figma-setup.md`。

## 第一步（每次任务）

```bash
node scripts/resolve-figma-screen.js --html <原型路径>
# 或
node scripts/resolve-figma-screen.js --key userChat
```

## MCP 路由（`figma.config.json` → `mcp.agentRouting`）

### Figma → 代码

1. **批量结构/样式** → `FIGMA_API_KEY` + REST API（`figma2code` Phase 1）
2. **单帧精修** → `figma` Remote MCP `get_design_context`（Starter ≤6 次/月）
3. **链接解析** → `resolve-figma-screen.js` + 粘贴 Frame URL
4. 付费可选：`figma-desktop`（3845，需 Dev Seat）
5. 改 `htmlMirror` + `style.css`；验证 `verify-all.js`

### 代码 → Figma

1. 读 **figma-generate-design** + **figma-use** skill
2. Cursor：`plugin-figma-figma`；Codex/Claude：`figma` Remote MCP
3. `use_figma` / `generate_figma_design`（写免限额）
4. 新 Frame 回写 `figma.config.json` → `screens.<key>.nodeId`

## 配置索引

| 项 | 路径 |
|----|------|
| 文件 key / screens / 路由 | `design/figma.config.json` |
| 交互流 | `design/interaction-spec.json` |
| 三端同步 | `scripts/sync-figma-mcp.ps1` |
| MCP 健康检查 | `scripts/verify-figma-mcp.ps1` |
| nodeId 解析 | `scripts/resolve-figma-screen.js` |
| 一次性人工步骤 | `docs/figma-setup.md` |
| 管理员模板 | `scripts/global-workspace/templates/mcp/figma-mcp-canonical.json` |

## 用户端 Page（376:250）

| key | nodeId | 原型 |
|-----|--------|------|
| userChat | 376:250 | web端/index.html |
| userMessageCenterTodo | 376:984 | drawer:user-message-center |
| userExpertWorkbench | 377:356 | web端/专家工作台/workbench.html |
| userFeedbackBox | 377:1665 | drawer:feedback-tab |

## 禁止

- Token 入仓
- 占位图替代 Figma localhost 资产
- 未读 figma-use 就 `use_figma`
- 跑已废弃的 `scripts/open-figma-captures.ps1`

