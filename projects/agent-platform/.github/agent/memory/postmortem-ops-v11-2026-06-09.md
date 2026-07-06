# Postmortem: 智能体运营 v1.1 迭代失误 (2026-06-09)

## 现象

1. 侧栏点击「运营概览 / 审核工作台」→ `ERR_FILE_NOT_FOUND`（Windows `file://` 打开）
2. 卡片 `⋯` 菜单堆叠「去审核、撤回发布、查看详情、开发配置…」，与 v1.0 及用户要求不一致
3. 审核入口出现在卡片菜单和仪表盘快捷区，破坏「审核仅在工作台」的产品划分
4. 多次迭代仍像「单开新站」，未接入上一版运营壳与导航联动

## 根因

| # | 根因 | 说明 |
|---|------|------|
| R1 | **未先对齐现有产品模型** | 未以 `index.html` + `ops-platform-shell.js` + `buildAgentListActionsHtml` 为唯一参照，自行发明状态与菜单 |
| R2 | **导航路径未按运行环境验证** | `file://` 下 pathname 含 URL 编码中文目录；`resolveSidebarHref` 依赖 `currentPage()` 失败时生成 `智能体运营v1.1/dashboard.html` 双重路径 |
| R3 | **把「迭代」做成「重写」** | 独立 `.shell` 侧栏、独立文案仪表盘、独立审核交互，未保留用户已验收的跳转与信息架构 |
| R4 | **验收标准过窄** | `v11-ops-check` 只测 DOM 存在，未测侧栏 href 在 v1.1 目录内是否为相对路径、菜单词表是否与 v1.0 一致 |
| R5 | **忽视明确交互约束** | 用户多次强调：点卡片=查看；审核在工作台；菜单只要发布/停用/上架/下架/删除 |

## 修复

- `ops-platform-shell.js`: `isOnV11Folder()` + `decodeURIComponent` 路径；子目录内子链使用 `dashboard.html` 等相对路径
- `app.js`: 菜单词表对齐 v1.0；审核中/待审核卡片不显示 `⋯`；移除查看/审核/撤回等菜单项
- `AGENTS.md` + ADR-010 + 三端 memory 写入本契约，防止再犯

## 预防（三端 Agent 必读）

1. **改 v1.1 前**：读 `AGENTS.md` § Ops v1.1 UX Contract + 打开上一版对照页截图/文件
2. **改导航后**：在 `智能体运营v1.1/index.html` 用浏览器点侧栏两项，确认不 404
3. **改卡片后**：对照 `proto.js` `buildAgentListActionsHtml` 词表；禁止在卡片放审核
4. **交付前**：`node prototype/scripts/v11-ops-check.js` 全绿

## 责任人

AI-assisted implementation sessions (Cursor Agent), 2026-06-09.
