---
name: figma-workflow
description: Use when Agent Platform Figma work needs figma.config.json — implement from Figma, sync HTML to Figma, or create design files. Triggers: 按 Figma 实现, 同步到 Figma, 对照设计稿.
disable-model-invocation: true
---
# Figma 工作流（Agent Platform）

## 配置来源

始终先读 [design/figma.config.json](../../design/figma.config.json)：

- `files.prototype.fileKey` / `fileUrl`：Figma 文件
- `files.prototype.screens.*`：各页面 nodeId 与 HTML 镜像路径
- `defaults.designSystem`：样式基准

完整 OAuth 与降级说明见 [docs/figma-setup.md](../../docs/figma-setup.md)。

## 场景 A：按 Figma 做页面

**触发**：「按 Figma 实现」「对照设计稿」「根据 Figma 更新原型」

1. 读 `design/figma.config.json`，定位目标 screen
2. 读 `.cursor/rules/figma-design.mdc`
3. 通过 Figma MCP 拉取 node 设计上下文
4. 修改对应 `prototype/*.html` 与 `style.css`
5. 本地预览验证布局与交互

## 场景 B：代码推到 Figma

**触发**：「写到 Figma」「同步到 Figma」「在 Figma 里重建这个页面」

1. 读 figma-generate-design skill（Cursor Figma 插件）
2. 读 figma-use skill，再调用 `use_figma`
3. 按页面 section 增量创建/更新 Figma 节点
4. 回写 `figma.config.json` 中的 nodeId（若新建 frame）

## 场景 C：新建 Figma 文件

**触发**：「新建 Figma 文件」「创建设计稿」

1. 读 figma-create-new-file skill
2. 创建文件后更新 `figma.config.json` 的 `fileKey` 与 `fileUrl`

## MCP 前置条件

- Cursor 全局 [~/.cursor/mcp.json](file:///~/.cursor/mcp.json) 已配置 `figma` → `https://mcp.figma.com/mcp`
- Settings → MCP 中完成 OAuth 授权
- Codex 侧已启用 `figma@openai-curated` 插件，共用同一 `figma.config.json`

## 禁止事项

- 不要把 API Key / OAuth token 写入仓库
- 不要用占位 icon 替代 Figma localhost 资产 URL
- 未读 figma-use skill 前不要调用 `use_figma`

