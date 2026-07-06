# Postmortem: Web 用户端与智能体运营联动 (2026-06-10)

## 背景

多轮对话围绕 **Web 用户端**（`prototype/web端/`）与 **智能体运营 v1.1** 的 UI 对齐、交互契约和后台打通。用户对照 Figma 截图 p2–p7 与运营迭代经验，要求：用户端体验与运营后台分离、Figma 1:1、智能体切换联动、消息中心与专家工作台交互正确。

## 现象（曾出现或用户指出）

| # | 现象 | 影响 |
|---|------|------|
| P1 | 模型下拉仍显示 DeepSeek 等开发侧命名 | 用户端与产品口径不一致 |
| P2 | 智能体侧栏保留 i 图标、详情 drawer、能力与来源按钮 | 暴露运营/配置信息，干扰对话主路径 |
| P3 | 专家工作台 web 端沿用运营 sidebar 或占位表格 | 与 Figma 243 系列和用户 aioq 壳不一致 |
| P4 | 消息中心用侧滑 drawer | 与设计稿 376:984 居中弹窗不符 |
| P5 | 专家任务行菜单为「做任务 + 查看上下文」 | 与用户端词表「查看 / 做任务 / 取消领取」不符 |
| P6 | 切换智能体后推荐问句雷同（v11/demo 走 generic fallback） | 每个智能体场景感丢失 |
| P7 | Skills 按钮星形 18px，与附件/语音不协调 | 图标语义弱、视觉失衡 |
| P8 | 未跑 verify-all 就声称完成 | 导航/契约回归风险（ADR-003 教训） |
| P9 | plan「可选」语音输入被写进 + 菜单与契约 | 用户认为上传文件被替换；未经确认扩 scope |
| P10 | 模型下拉用 Flash/标准/深度/专家 tier 化名 | 与敖钦 Web 截图 DeepSeek 四档全名不一致 |
| P11 | `buildRefinedSummary` 长文本写入 note.summary | 个人空间卡片/popover 出现轮次废话，违背「名称+短总结」 |

## 根因

| # | 根因 | 说明 |
|---|------|------|
| R1 | **用户端与运营端边界未写死** | 复用了运营详情、能力面板、审核语义 |
| R2 | **Figma 对照不足** | MCP 限额时未强制本地 extract + 截图双对照，出现占位 UI |
| R3 | **智能体数据多源合并未统一 enrich** | `UserAgentResolver` 先写入 v11 条目，`DEFAULT_AGENTS` 被 `seen` 跳过，suggestions 落 generic |
| R4 | **组件形态抄错** | 消息中心误用 `drawer-overlay`（运营侧 pattern） |
| R5 | **专家工作台 portal/ops 分支不完整** | 行菜单、查看页文案仍偏运营视角 |
| R6 | **图标未按 composer 场景设计** | 统一 18px 星形，未区分「附件 / Skills 增强 / 语音」语义 |
| R7 | **Plan 可选项当必做** | 「可选语音」直接进 HTML + web-portal-check |
| R8 | **ADR 与用户截图冲突未澄清** | v4 tier 化名 vs 用户 1:1 DeepSeek 名 |
| R9 | **summary 过度实现** | 保存与展示共用 `buildRefinedSummary` 长文本 |

## 修复措施（已落地）

1. **对话页**：四档模型命名；删除 i / drawer / 能力按钮；输入区回形针 + **拼图 Skills**（20px + `--skill` 样式）；建议区 chip + 按 agent 刷新
2. **UserAgentResolver**：`SUGGESTION_CATALOG` + `resolveSuggestions()`，demo/v11 智能体专属推荐问句
3. **消息中心**：`modal-overlay` + 居中 `aioq-msg-center-modal`（非 drawer）
4. **专家工作台 web**：aioq 侧栏 + Figma 243 主内容；行菜单 **查看 → task-view / 做任务 → task-detail / 取消领取 → cancelClaimTask**
5. **验证**：`web-portal-check.js` 断言上述契约；改 JS 后必跑 `verify-all.js`

## 预防（三端 Agent 必读）

### 用户端硬约束

- **禁止**在用户对话侧栏暴露：智能体详情 drawer、能力/来源面板、审核/派单/开发配置入口
- **消息中心**：居中 modal（`376:984`），三 Tab：公告 / 待办 / 意见箱
- **专家工作台（web）**：壳 = `user-portal-shell.js`；主内容对齐 Figma 243；行操作 = 查看 / 做任务 / 取消领取
- **智能体切换**：welcome 文案 + `#promptSuggestions` 必须随 `agentId` 变化；resolver 不得落 generic 三连问
- **Skills 图标**：拼图/插件语义，20px，与附件同级视觉权重
- **+ 菜单（v5）**：仅「上传文件 + 引用笔记」；禁止擅自加语音
- **模型下拉（v5）**：UI 显示 DeepSeek 四档全名；禁止 tier 化名
- **笔记 summary（v5）**：展示面仅短总结；轮次/全文仅在 `#historySummaryModal`
- **Plan 可选项**：须用户确认后才可进 HTML/契约

### 运营 v1.1（与 ADR-010/011 并存）

- 迭代 ≠ 重写；复用 `ops-platform-shell.js`
- 卡片点选 = 查看；审核仅侧栏工作台
- v1.1 目录内链相对路径 + `decodeURIComponent`

### 交付门禁

```bash
node prototype/scripts/verify-all.js   # 含 web-portal-check + navigation-journey
node prototype/scripts/v11-ops-check.js  # 改 v1.1 时
```

## 相关 ADR / 文件

- ADR-010/011：运营 v1.1 UX 与权限
- `design/figma.config.json`：376（用户端）、243（专家工作台）
- `prototype/assets/user-portal-bridge.js`：用户端 ↔ 运营 mock 桥
- 本 postmortem 同步至 `~/.ai-workspace/memory/user-memory.md` 与 `ai-global-config`

## 待后续确认（非阻塞）

- 回答区「思考过程 / 引用 / 文件卡」是否精简
- 运营端 `12-expert-*` 是否同步 Figma 243 主内容
- 企业演示智能体（医疗分诊等）是否保留在 DEFAULT 列表
