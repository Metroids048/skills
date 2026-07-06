# Project Memory 鈥?Agent Platform

Last updated: 2026-06-11 (Web 用户端 v2 门户化 · ADR-015)

## Project

- **Name**: Agent Platform
- **Type**: HTML prototype + skills library (杩愯惀/寮€鍙戝弻骞冲彴)
- **Tri-end routing source (2026-06-22)**: `skills/curated/` + `skills/task-intake-bridge/`；运行时同步到 `~/.ai-workspace/skills-curated` 与三端 `skills/`
- **Primary stack**: Static HTML, vanilla JS (`prototype/assets/proto.js`), sessionStorage state
- **Ops v1.1 prototype:** 根目录 `index.html` + `dashboard.html` / `audit-workbench.html` / `audit-review.html` + `assets/ops-v11-app.js` — **默认运营入口**（ADR-014）；必须用 `ops-platform-shell.js`；**点卡片/查看详情 → `05-agent-detail.html`**（基本信息/运行数据/版本与发布）；`agent-detail.html` 仅兼容重定向
- **Ops v1.1 check:** `node prototype/scripts/v11-ops-check.js`（已并入 verify-all 第 9 步）
- **Ops v1.1 UX（ADR-010/011）:** 入口=卡片列表；侧栏分组含运营概览+审核工作台；卡片菜单保留发布/停用/下架/删除/启用，并允许内部智能体显示“权限”；第三方智能体不显示权限；点卡片=查看 **05 详情页**；`file://` 子目录相对路径
- **Agent permission contract（ADR-011）:** 权限字段为 `shareMode` + `permissionTargets`，选择器为 `prototype/assets/org-access-picker.js`；“单位共享”统一为“部门共享”。
- **Postmortem:** `.github/agent/memory/postmortem-ops-v11-2026-06-09.md`

## Ops v1.1 State Contract (ADR-009)

- v1.1 status flow: `dev` → `published_pending_review` / `reviewing` → `listed` → `offline` / `rejected`.
- Publishing means candidate version submission only; platform audit approval means direct listing/user-visible availability.
- v1.1 stores its own state in `proto_ops_v11_agents`, and syncs key status changes back through `Proto.setState`.
- Root `index.html` = v1.1 卡片列表（ADR-014）；详情/运行数据/发布 = **`05-agent-detail.html`**（非 v1.1 简化详情页）。

## Module Architecture Map (0鈫? reference)

| Module | Primary files | Owns |
|--------|---------------|------|
| **Core state + navigation** | `prototype/assets/proto.js` | sessionStorage agents/skills, Nav, page bootstrap (`init*Page`), firstConfig (ADR-003) |
| **Ops list + modals** | `ops-v11-app.js`（index 卡片）、`ops-list-dashboard.js`（dashboard KPI） | v1.1 列表 UI、创建/第三方弹窗 |
| **Ops detail (05)** | `05-agent-detail.html`, hooks in `proto.js` | Tabs, publish, monitor; jump to dev platform only |
| **Dev editor** | `editor-shell.js`, `agent-core-config.js`, `06-dev-editor.html` | EditorShell, capability config, skill bind |
| **Skills catalog** | `10-skills-management.html`, skill helpers in `proto.js` | Resource CRUD; not long-term bind (that's dev editor) |
| **User chat portal** | `web端/index.html`, `web端/agent-square.html`, `09-user-chat.html`, `user-chat-portal.js`, `user-agent-square.js`, `user-portal-bridge.js`, `user-agent-resolver.js`, `user-message-center.js`, `user-portal-shell.js` | Web 用户端：默认入口仍为聊天页；“智能体中心”进入二级页“智能体广场”；广场含推荐/全部/我的、轮播、分类、收藏、立即使用；搜索在智能体中心上方；企业组默认展开 + DEFAULT_AGENTS 兜底；**消息中心居中 modal**（376:984）；专家工作台 aioq 侧栏 + Figma 243；行操作=查看/做任务/取消领取；切换智能体联动 suggestions；Skills=拼图 20px |
| **Ops platform modules** | `11-*.html`, `12-*.html`, `13-*.html`, `ops-*.js` | 用户反馈、专家工作台（运营）、权限管理、消息中心（ADR-005） |

## Web User Portal UX Contract (2026-06-10)

- **用户端 ≠ 运营后台**：禁止 i 详情 drawer、能力/来源面板、审核/派单入口
- **智能体广场（ADR-013）**：`web端/agent-square.html` 是聊天页侧栏“智能体中心”的二级页；默认打开仍是 `web端/index.html`；广场只展示已上架且当前账号可见的智能体，点击“立即使用”回到 `index.html?id=<agent_id>`
- **用户端 v2（ADR-015）**：`web端/index.html` 是对话工作台，`web端/agent-square.html` 是前台智能体发现页，`web端/my-space.html` 是个人空间；个人资料、个人笔记、个人智能体、偏好由 `user-personal-space.js` 统一管理，不反写运营平台。
- **一期未完成项融合**：图片/附件上传、深度思考、指定知识库、引用个人笔记进入聊天输入区；历史记录支持保存为个人笔记；公告归入消息中心；**登录为 mock 企业邮箱**（`web端/login.html` + `user-auth.js`），真实 IAM/SSO 仍为后续阶段。
- **Figma MCP（ADR-016 · Starter）**：三端同步脚本 `scripts/sync-figma-mcp.ps1`；管理员模板 `scripts/global-workspace/templates/mcp/figma-mcp-canonical.json`；读设计主力 `FIGMA_API_KEY`+REST，写 Figma 用 Remote MCP（免限额）；`verify-figma-mcp.ps1` 检查 Cursor/Codex/Claude + PAT + 3845（Starter WARN）。
- **广场状态 owner**：`user-agent-square.js` 只维护用户端收藏/最近使用；运营端供给仍来自 `proto_ops_v11_agents` + `shareMode` / `permissionTargets`；推荐/轮播为原型 mock，后续由运营配置接管
- **消息中心**：`user-message-center.js` → 居中 modal，非 drawer
- **专家工作台 web**：壳=`user-portal-shell.js`；Figma 243 主内容；行操作=查看/做任务/取消领取
- **智能体 suggestions**：`resolveSuggestions` + `SUGGESTION_CATALOG`；禁止 generic 三连问
- **Postmortem**: `postmortem-user-portal-2026-06-10.md`
- **v5 纠偏（ADR-015 v5 · 2026-06-15）**：
  - **+ 菜单**：仅「上传文件 + 引用笔记」；禁止擅自加语音等 plan 可选项
  - **模型下拉**：UI 显示 4 个 DeepSeek 全名；禁止 Flash/标准/深度/专家 tier 化名
  - **笔记展示**：卡片/chip/popover/选笔记预览 = 标题 + 短总结（≤120 字）；轮次/全文仅在保存笔记 modal
  - **截图 spot-check**：verify-all PASS 后仍须对照用户截图或 Figma 376
- **2026-06-26 用户端 v1.1 修订**：
  - 保存为笔记支持全选/多选历史轮次，并纳入编辑分支轮次；保存时只沉淀已选轮次。
  - 我的空间个人笔记支持编辑；卡片仍只展示标题和 ≤120 字摘要。
  - 我的空间移除个人知识库和独立偏好设置；默认开启深度思考、默认知识库并入基础信息。
  - 我的智能体中“我创建的”可跳转运营平台-智能体运营编辑；“组织授权”不可编辑。
  - 保存个人智能体 loading 与最终配置弹窗同尺寸；会话沉淀仍是私有配置资产，不走提交审核/上架主线。

**Before adding a feature:** declare **state owner** (one module) + **page entry** (URL + nav path). No duplicate state writes. New module 鈫?ADR + `docs/architecture/`.

## PRD 写作约束 (ADR-017)

1. **PRD 是非技术文档**：不得包含代码函数名、JS 模块名、sessionStorage Key、文件路径、API 接口名。
2. **架构用图说话**：架构说明引用外部图片（如 `架构.png`），使用业务语言描述模块关系，不用 Mermaid 画实现细节。
3. **交互只描述用户行为**：写"点击登录后系统校验账号密码"，不写 `login()` / `buildAnswer()`。
4. **布局不画图**：页面布局引用设计稿或截图，禁止 ASCII 画图和含实现细节的 Mermaid 图。
5. **受众是产品/运营/业务**：PRD 写给所有人看，不是技术设计文档。

## Hard Constraints (DO NOT VIOLATE)

1. After editing **any** `prototype/assets/*.js`, run:
   ```bash
   node prototype/scripts/verify-all.js
   ```
2. Never claim "review complete" or "delivery ready" without running verify-all and reading output.
3. Never merge `wireStandardLinks` / similar helpers without verifying function boundaries (`wireDevPlatformRows` incident 2026-05-28).
4. Task completion must include **Completed / Verified / Remaining Risks** or "Task is NOT fully verified."
5. **Do not reintroduce** `window.__protoSkillBindWired` or session-only `firstConfig` tab locks (ADR-003).
6. 当任务涉及大幅度改动、删除/替换已有内容、改变产品流程，或与当前实现/PRD/ADR 冲突时，必须先用通俗非技术语言询问用户如何取舍；说明冲突点、2-3 种改法、用户可见影响和推荐方案。用户说“继续/直接做”也不豁免真实冲突确认。

## Validation Commands

| Command | Purpose |
|---------|---------|
| `node prototype/scripts/verify-all.js` | package-check + smoke + e2e + regression + browser-check + **navigation-journey** |
| `node prototype/scripts/package-check.js` | 16 椤?+ 閾炬帴瀹屾暣鎬э紙鎵撳寘 zip 鍓嶏級 |
| `node prototype/scripts/navigation-journey-check.js` | index鈫?5 浜屾杩涘叆銆乫irstConfig銆佸弻娆?wire |
| `node prototype/scripts/regression-check.js` | vm-load Proto; Skills catalog >= 6 |
| `powershell scripts/sync-ai-guardrails.ps1` | Sync global AI rules/skills |

## Skills State Contract (05 / dev editor)

- Demo agent (`agt_demo_001`): default `boundSkillIds: ['sk_report', 'sk_risk']`
- Empty `boundSkillIds` + not `skillsCleared` 鈫?auto-restore defaults via `migrateAgentSession` / `getAgentSkillIds`
- User cleared all skills (`skillsCleared: true`) 鈫?show empty placeholder UI (expected)
- Page entry: prefer `Proto.initAgentDetailPage({ root, tabs })` on 05; dev editor uses `EditorShell.mount` + `wireSkillBindButtons`

## firstConfig Rules (ADR-003)

| Entry | Tab lock | Banner |
|-------|----------|--------|
| `?new=1` (create flow) | Yes 鈥?non-config tabs blocked | Shown |
| List銆屾煡鐪嬨€嶆棤 `?new=1` | No 鈥?clear stale `firstConfig` in session | Hidden |
| User clicks 鐭ラ亾浜?/ save / publish | `finishFirstConfig()` | Hidden |

## Key Paths

- **三端全局配置总览**（用户机器）：`~/.ai-workspace/docs/tri-end-ai-config-inventory-zh.md`
- Prototype pages: `prototype/*.html` (35 pages root + 6 web)
- **Architecture (2026-06-08)**: `docs/architecture/2026-06-08-ops-panorama.md`, `haineng-integration-spec.md`, `rbac-roles.md`
- **Summary requirements report**: `docs/需求梳理/06-AI应用开发平台总结性需求报告.md` + `docs/需求梳理/assets/ai-platform-ops-panorama.svg`
- **Diagram source appendix**: `docs/需求梳理/图表源码附录.md` + `docs/需求梳理/assets/*.mmd`
- **Platform API mock**: `prototype/assets/platform-api.js` (ADR-008 五环节)
- **Feedback loop**: `prototype/assets/ops-feedback-loop.js` → `proto_ops_work_orders`
- **Ops dashboards**: `14-business-dashboard.html` 等 4 页 + `ops-dashboards.js`
- Delivery checklist: `prototype/DELIVERY-CHECKLIST.md`
- **Standalone deliverable:** zip `prototype/` + `prototype/README.md` + `start.ps1`/`start.sh`
- Journey audit matrix: `prototype/scripts/journey-audit-matrix.json`
- Global guardrails sync: `scripts/sync-ai-guardrails.ps1`
- Curated routing sync: `scripts/hooks/sync-curated-routing.ps1`
- Governance snapshot: `skills/curated/_governance/skills-manifest.md`, `skills/curated/_governance/skills-inventory.md`
- Architecture docs: `docs/architecture/` (ADR supplements + module diagrams)

## User Spot-Check (3 pages 鈥?navigation focus)

1. `prototype/index.html` → 点卡片 → `agent-detail.html` → 返回 index → 再进
2. `prototype/05-agent-detail.html?id=agt_demo_001` — Skills ≥1 tag，`+` opens modal，Tabs switch；回 index 再进 **same as step 2**
3. `prototype/10-skills-management.html` — ≥6 Skill rows

## PRD Writing Style (from PRD v1.2 user correction, 2026-06-17)

See also: ADR-017 in `.github/agent/memory/decisions-log.md`

| Rule | Detail |
|------|--------|
| 标题格式 | `#` Markdown 标题 → 纯文本"一、二、三"编号 |
| 流程图/架构图 | 不放 Mermaid，标注"暂时无法在飞书文档外展示此内容" |
| 截图占位 | 用 `[图片]` 占位，用户自行粘贴 Figma 截图 |
| 语言风格 | 短表格 + 要点列表，避免长段落；字段面向业务逻辑 |
| 页面布局 | 不写布局描述，以 Figma 和 `[图片]` 为准 |
| 必须覆盖 | Skills 选择器、深度思考、上传限制、下载按钮、来源引用 |
| 禁止内容 | Mermaid、`#`标题、布局段落、非功能需求/附录章节 |
| 业务约束 | 如实标注"现在预设和敖钦一期一致"、"视实际情况而定" |
| 数据来源 | 字段中标注"和组织结构统一"、"和运营中心数据打通" |
