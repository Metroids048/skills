# Decisions Log (ADR)

## ADR-017: PRD 文档写作去技术化规范 (2026-06-17)

**Status**: Accepted

**Context**: `docs/prd/敖钦AI用户端Web门户_PRD_v1.0.md` 评审发现 PRD 中存在严重的技术化倾向——混入 JS 函数名、sessionStorage Key、本地文件路径、模块依赖图等实现细节，非技术读者完全无法使用。根因在于 PRD 写作技能（`create-prd`、`pm-prd-writer`）和全局写作规则（`global-document-writing-style.mdc`）缺乏明确的受众导向约束。

**Decision**:

1. PRD 写作必须以非技术读者为中心，禁止在 PRD 正文中出现：代码函数名、JS 模块名、CSS 类名、sessionStorage Key、本地文件路径、API 接口名。
2. 架构图应引用外部图片（如 `架构.png`）并用业务语言说明，不在 PRD 中用 Mermaid 画技术模块调用链。
3. 交互描述只写用户可感知的操作反馈（点击、输入、跳转），不写内部函数调用。
4. 页面布局不得用 ASCII 画图，应以设计稿或截图为准。
5. `global-document-writing-style.mdc`、`create-prd`、`pm-prd-writer` 按此决策更新。

**Consequences**: 后续所有 PRD 生成须自动遵守本规范；项目内 `skills/pm-prd-writer/` 和全局规则同步修改。

---

## ADR-018: Tri-end curated skills routing + task-intake bridge (2026-06-22)

**Status**: Accepted

**Context**: Codex / Cursor / Claude Code 的 skills 目录长期不一致，且路由链路不一致：Claude 有 SessionStart + UserPromptSubmit，Cursor 一度缺 beforeSubmitPrompt，Codex 主要依赖静态 instructions。结果是高价值 skill 常因库存噪声、关键词竞争和缺少前置桥接而未被触发。

**Decision**:

1. 在 repo 内建立 `skills/curated/` 作为分类级路由真源，按 `00-core-session` 到 `90-reference-optional` 固定 10 个类别，每类用 `_routing.md` 定义 purpose、use_when、default_chain、selection_rules、skills。
2. 新增 `skills/task-intake-bridge/SKILL.md`，作为 tri-end always-on 的需求桥接层：先判型、再转写、再命中分类 `_routing.md`，最后才选 1–3 个具体 skill。
3. `scan-global-skills.ps1` 升级为 category-first routing：优先读 curated category，再在该类中 shortlist skill；旧的 global scoring 仅作 fallback。
4. `sync-ai-guardrails.ps1`、`sync-hooks-config.ps1`、`install-global-skills-hooks.ps1`、`repair-tri-end-hooks.ps1` 统一同步 curated catalog、task-intake-bridge 与 tri-end hooks。
5. `repair-tri-end-hooks.ps1` 默认启用真实 clarification hard gate，不再默认安装 fail-open stub；`verify-tri-end-config.ps1` 同步切到“hard gate active”校验口径。
6. skills 治理清单改为脚本生成：`skills/curated/_governance/skills-manifest.md`、`skills-inventory.md`、`skills/archive/ARCHIVE-INDEX.md`。

**Consequences**: tri-end 路由从“全库平铺抢 TopN”改为“分类 → shortlist → read SKILL.md”的渐进式披露；复杂任务默认经过 task-intake-bridge + requirement-clarifier；运行时库与归档库开始分离。

---

## ADR-016: Figma 三端 Starter 免费打通策略 (2026-06-11)

**Status**: Accepted

**Context**: Cursor/Codex 已有 Figma MCP，Claude Code 缺失；用户为 Figma Starter 免费版（无 Dev Seat）。Remote MCP 读工具有约 6 次/月限额，但写工具（`use_figma`、`generate_figma_design`）免限额。

**Decision**:

1. **读设计主力**：`FIGMA_API_KEY` + Figma REST API（PAT），配合 `resolve-figma-screen.js` 与 Frame 链接；Remote MCP 读仅用于单帧精修（≤6 次/月）。
2. **写 Figma 主力**：三端 Remote MCP OAuth（`https://mcp.figma.com/mcp`）；Cursor 另可用 `plugin-figma-figma` 插件 + Skills。
3. **Desktop MCP 3845**：可选，仅付费 Dev Seat；Starter verify 时 WARN 不 FAIL。
4. **三端本机配置**：`scripts/sync-figma-mcp.ps1` 合并到 `~/.cursor/mcp.json`、`~/.codex/config.toml`+overlay、`~/.claude.json`；管理员模板 `scripts/global-workspace/templates/mcp/figma-mcp-canonical.json`。
5. **不采用** Talk to Figma MCP 作主通道；Rune/Flaude 仅文档附录备选。
6. **路由**写入 `design/figma.config.json` → `mcp.agentRouting`；健康检查 `verify-figma-mcp.ps1` 覆盖三端 + PAT + canonical 模板。

**Consequences**: 用户须设 `FIGMA_API_KEY` 用户环境变量并完成三端 OAuth 各一次；`sync-ai-guardrails.ps1 -Force` 自动跑 `sync-figma-mcp.ps1`。

---

## ADR-015: Web 用户端 v2 门户化重构与个人资产融合 (2026-06-11)

**Status**: Accepted

**Context**: ADR-013 只完成“智能体广场主干 + 运营端上架数据打通”，但用户反馈指出用户端仍未充分融合 Excel Sheet1 未开发项，也未在宏观平台架构中承担独立用户入口职责；同时 Codex 缺少 Figma MCP 全局配置，导致后续原型对照不稳定。

**Decision**:

1. Web 用户端升级为 v2 门户结构：`web端/index.html` 仍为默认对话工作台，`web端/agent-square.html` 负责智能体发现，新增 `web端/my-space.html` 承接个人资料、个人笔记、个人智能体和轻量设置。
2. 用户端视觉定位从运营后台转为普通用户 AI 工作入口，页面文案和布局避免审核、派单、开发配置、候选版本等后台概念。
3. 用户端个人资产由 `user-personal-space.js` 统一管理，状态 key 为 `proto_user_notes`、`proto_user_personal_agents`、`proto_user_profile`、`proto_user_chat_preferences`，不反写运营平台。
4. 智能体供给继续来自 `UserAgentResolver` 聚合的 `proto_ops_v11_agents`、权限字段和默认智能体；广场只展示已上架且当前用户可见的智能体，“我的”包含收藏、最近使用、个人草稿、我创建和授权给我的智能体。
5. 对话输入区新增图片/附件占位、深度思考、指定知识库、引用个人笔记；历史记录新增“保存为笔记”和“沉淀为智能体”动作，作为一期未完成项的原型融合。
6. 公告继续归入 `user-message-center.js` 的消息中心，不把广场首页变成公告栏；反馈继续通过 `OpsUserFeedback` / `OpsFeedbackLoop` 回流运营闭环。
7. Figma MCP 修复纳入 Codex 全局配置：`~/.codex/config.toml` 与 `~/.codex/codex-plus-mcp-overlay.toml` 增加 `figma` / `figma-desktop`，并更新全局 merge 脚本保证后续配置重写后仍保留。

**Consequences**: 新增用户端页面需要纳入 `web-portal-check.js` 与 `package-check.js`；任何用户端 JS 变更必须继续运行 `node prototype/scripts/verify-all.js`。真实 IAM/SSO、海能 API、推荐配置后台、移动端页面仍标记为 `待确认` 或后续阶段。

**Amendment (2026-06-12 · Web 用户端 v3 UI)**:

1. 对话页侧栏恢复「智能体快捷列表」（最近 3–5 个 +「更多智能体」链到广场），不恢复旧版三分组平铺长列表。
2. 侧栏采用 brand + 可滚动中区 + 固定底栏；历史对话 hover 提供保存笔记 / 重命名 / 删除（删除需确认）。
3. 对话输入区改为智谱式单盒 composer；附件与引用笔记合并为 `+` 菜单。
4. 移除对话页「AI 工作入口」banner；广场卡片描述限 2 行；我的空间顶栏「返回对话」。

**Amendment (2026-06-15 · Web 用户端 v4 敖钦对标)**:

1. 新增 mock 企业邮箱登录（`web端/login.html`、`forgot-password.html`、`user-auth.js`）与全站 session 门禁。
2. 我的空间「认证状态」改为「修改账号密码」+ `#changePasswordModal`。
3. 对话页恢复顶栏四档模型选择（Flash / 标准 / 深度 / 专家）；修复 `buildAnswer` 弯引号导致的引用/文件卡样式失效。
4. 回答区动作条接线：复制、重新生成、点赞、点踩、文件下载、引用段落/查看原文；图表关键词触发 SVG mock。
5. 笔记 composer chip 仅显示名称；点击 popover 展示名称+总结。
6. 广场轮播增强：左右箭头、hover 暂停、点击联动分类 Tab。

**Amendment (2026-06-15 · Web 用户端 v5 对标纠偏)**:

1. **+ 菜单**：仅「上传文件 + 引用笔记」；禁止未经用户确认添加语音输入等 plan 可选项。
2. **模型下拉**：顶栏与下拉项 UI 显示 4 个 DeepSeek 全名（`DeepSeek-V4-Flash 模型` 等）；禁止 Flash/标准/深度/专家 tier 化名。
3. **笔记 summary**：卡片 / chip / popover / 选笔记预览仅「标题 + 短总结（≤120 字）」；轮次与全文仅在 `#historySummaryModal` 保存流程展示。
4. **截图 spot-check**：改 Web 用户端 UI 后须对照用户截图或 Figma 376 系列，verify-all PASS 不足以替代。

**Amendment (2026-06-15 · 历史对话保存个人智能体)**:

1. 历史 `⋯` 菜单新增「保存个人智能体」，与「保存笔记」并列；有效轮次 &lt; 2 时 toast 拦截，不写入。
2. 草稿 owner 为 `user-personal-space.js` → `proto_user_personal_agents`（`id` 前缀 `pagt_`，`status: draft`），**不反写** `proto_ops_v11_agents`。
3. `UserAgentResolver` 合并会话草稿进 `personal` 组（`isSessionDraft: true`），供对话页 `index.html?id=pagt_*` 与侧栏选用。
4. 我的空间「我的智能体」面板分区：会话沉淀（草稿）+ 运营 personal/org；草稿支持立即使用、删除确认。
5. 保存后仅 toast，不自动跳转；同一 `sourceSessionId` 去重，禁止重复创建。

**Amendment (2026-06-16 · Web 用户端 v6 Composer 上下文边界)**:

1. 附件/笔记 chip 显示在 composer **底栏 toolbar 内**（`#attachChip.aioq-composer-inline-chips`），不在 textarea 上方。
2. **会话边界**（切换智能体、恢复历史对话、新建对话）调用 `resetComposerContext()`，清空 `attachments` 与 `noteIds`；同一会话内连续发送可保留 chip。
3. `noteIds` **不再**写入 `proto_user_chat_preferences.defaultNoteIds`；仅保留 `deepThinking` / `defaultKnowledgeBase` 用户级偏好。

**Amendment (2026-06-26 · Web 用户端 v1.1 我的空间与历史沉淀修订)**:

1. 历史对话保存为笔记支持全选/多选轮次；当用户问题编辑生成分支时，分支轮次也进入保存范围，保存时只沉淀已选轮次。
2. 我的空间个人笔记支持手动编辑；卡片仍只展示标题和不超过 120 字摘要，完整内容放在编辑弹窗或保存流程中。
3. 我的空间移除个人知识库模块和独立偏好设置模块；“默认开启深度思考”“默认知识库”并入基础信息。
4. 我的智能体中，“我创建的”可跳转运营平台-智能体运营编辑；“组织授权”不提供编辑入口，仅允许使用。
5. 保存个人智能体的 loading 使用与后续配置弹窗一致的尺寸；会话沉淀个人智能体仍作为用户私有配置资产，不走提交审核/上架主线。

---
## ADR-014: v1.1 鎻愬崌涓?prototype 榛樿鍏ュ彛锛堝崟璺緞鎵佸钩鍖栵級(2026-06-11)

**Status**: Accepted

**Context**: 鐢ㄦ埛瑕佹眰灏嗗墠绔眹鎬诲埌 `prototype/` 渚夸簬鎵撳寘浜や粯锛屼互 v1.1 涓轰富椤碉紝鍒犻櫎 v1.0 鍐茬獊椤碉紝鏁村悎涓哄崟涓€璺緞銆侫DR-009 鏇捐姹備笉淇敼鏍?`index.html` 涓?`08-audit-*`銆?
**Decision**:

1. `prototype/index.html` 鏇挎崲涓?v1.1 鍗＄墖鍒楄〃锛沗start.ps1` 榛樿鎵撳紑鍗?v1.1銆?2. v1.1 浜旈〉鎻愬崌鑷虫牴鐩綍锛歚dashboard.html`銆乣audit-workbench.html`銆乣audit-review.html`銆乣agent-detail.html`锛涢€昏緫杩佸叆 `assets/ops-v11-app.js`銆乣assets/ops-v11.css`锛涘垹闄?`prototype/鏅鸿兘浣撹繍钀1.1/` 瀛愮洰褰曘€?3. 鍒犻櫎 v1.0 鍐茬獊椤碉細`08-audit-queue.html`銆乣08-audit-review.html`銆乣08-audit-status.html`锛涘鏍搁摼缁熶竴涓?`audit-workbench` / `audit-review`锛涚敵璇蜂汉杩涘害閾炬敼涓?`agent-detail.html?id=`銆?4. **淇濈暀** `05-agent-detail.html`锛堥厤缃?Skills/firstConfig锛孉DR-003锛夛紱**淇濈暀** `08-audit-expert.html`锛堜笓瀹跺鏍革紝閾炬帴鎸囧悜鏂板鏍稿伐浣滃彴锛夈€?5. `ops-platform-shell.js` 渚ф爮銆屾櫤鑳戒綋杩愯惀銆嶆寚鍚戞牴璺緞 `index.html` / `dashboard.html` / `audit-workbench.html`銆?6. `verify-all.js` 绾冲叆绗?9 姝?`v11-ops-check.js`锛沗package-check` 鏍?HTML 璁℃暟 **35**銆?
**Consequences**: ADR-009銆屼笉淇敼鏍?index銆嶇害鏉熷簾姝紱ADR-010 渚ф爮璺緞鏇存柊涓烘牴鐩綍銆傛祦绋嬫枃妗ｈ縼鍏?`prototype/docs/agent-ops-flow.html`銆?
---

## ADR-013: Web 鐢ㄦ埛绔櫤鑳戒綋骞垮満浜岀骇椤典笌杩愯惀涓婃灦鏁版嵁鎵撻€?(2026-06-11)

**Status**: Accepted

**Context**: 鐢ㄦ埛瑕佹眰鎸夊凡纭鏂规閲嶆瀯 Web 鐢ㄦ埛绔€滄櫤鑳戒綋涓績鈥濓紝浣嗕笉鏀瑰彉榛樿鑱婂ぉ鍏ュ彛銆傜涓€闃舵鍙惤鍦扳€滃箍鍦轰富骞?+ 杩愯惀绔凡涓婃灦鏁版嵁鎵撻€氣€濓紝鍚庣画涓汉绌洪棿銆佸畬鏁存姤琛ㄣ€佷笓瀹剁鍜岀Щ鍔ㄧ瀹炵幇鏆備笉灞曞紑銆?
**Decision**:

1. Web 鐢ㄦ埛绔粯璁ゅ叆鍙ｇ户缁槸 `prototype/web绔?index.html`锛岀偣鍑讳晶鏍忊€滆繘鍏ユ櫤鑳戒綋骞垮満鈥濊繘鍏?`prototype/web绔?agent-square.html` 浜岀骇椤点€?2. 鏅鸿兘浣撳箍鍦洪〉闈㈣亴璐ｉ檺瀹氫负鍙戠幇銆佹悳绱€佺瓫閫夈€佹敹钘忓拰閫夋嫨鏅鸿兘浣擄紱鐐瑰嚮鈥滅珛鍗充娇鐢ㄢ€濊烦鍥?`index.html?id=<agent_id>`锛屾部鐢ㄧ幇鏈夎亰澶╅〉 URL 閫変腑鏅鸿兘浣撴祦绋嬨€?3. 骞垮満灞曠ず妯″瀷鐢?`prototype/assets/user-agent-square.js` 璐熻矗锛屼粠 `UserAgentResolver.resolve(ctx)` 鑾峰彇褰撳墠鐢ㄦ埛鍙鏅鸿兘浣撳悗褰掍竴涓哄崱鐗囨ā鍨嬶紱鏀惰棌涓庢渶杩戜娇鐢ㄥ彧鍐欑敤鎴风 sessionStorage锛歚proto_user_agent_square_favorites`銆乣proto_user_agent_square_recent`銆?4. `UserAgentResolver` 鐨勭敤鎴风鍙瑙勫垯鏀剁揣涓哄彧灞曠ず `listed/published` 涓斿綋鍓嶇敤鎴锋湁鏉冮檺鐨勬暟鎹紱`reviewing/offline/pending` 涓嶅嚭鐜帮紱`specific` 鎺堟潈鏈懡涓笉鍏滃簳灞曠ず銆?5. 鎺ㄨ崘杞挱銆佹帹鑽愭爣璁般€佸垎绫诲綊灞炰负绗竴闃舵鍘熷瀷 mock 瑙勫垯锛屽悗缁敱杩愯惀绔帹鑽愰厤缃€佸垎绫荤鐞嗗拰杞挱閰嶇疆鎺ョ銆?6. 鐢ㄦ埛绔箍鍦轰笉寰楁毚闇插鏍搞€佹淳鍗曘€佸紑鍙戦厤缃瓑鍚庡彴姒傚康锛涜繍钀ョ鐘舵€佷笌鏉冮檺浠嶇敱 `proto_ops_v11_agents`銆乣shareMode`銆乣permissionTargets` 渚涚粰銆?
**Consequences**: `web-portal-check.js` 澧炲姞骞垮満缁撴瀯銆佸叆鍙ｃ€佹潈闄愯繃婊や笌鍚庡彴姒傚康闅旂鏂█锛沗package-check.js` Web 鐢ㄦ埛绔〉闈㈡暟鏇存柊涓?6銆傚悗缁嫢鏂板鎺ㄨ崘閰嶇疆鍚庡彴锛屽簲鎵╁睍杩愯惀绔厤缃ā鍨嬶紝鑰屼笉鏄鐢ㄦ埛绔洿鎺ョ淮鎶ゆ帹鑽愮姸鎬併€?
## ADR-012: Web 鐢ㄦ埛绔洰褰曚笌鍚庡彴 mock 鎵撻€?(2026-06-10)

**Status**: Accepted

**Context**: Codex 019eaf7c 瑕佹眰灏嗘埅鍥惧紡鐢ㄦ埛绔縼绉讳负 `prototype/web绔?` 鐙珛浜や粯鐩綍锛屽苟涓庤繍钀?v1.1 鏅鸿兘浣撶被鍨嬨€丼kills銆佸弽棣?涓撳闂幆鎵撻€氾紱鍚屾椂 `09-user-chat.html` 椤讳繚鎸?TASK-024 鏋佺畝 smoke 濂戠害銆?
**Decision**:

1. 鐢ㄦ埛绔富鍏ュ彛涓?`prototype/web绔?index.html`锛沗09-user-chat.html` 淇濈暀涓烘棫鍏ュ彛骞堕摼鎺ヨ烦杞€?2. 鍏变韩 `../assets/` 璧勬簮锛屼笉澶嶅埗 CSS/JS 鏍戯紱web 涓撳睘閫昏緫鏀惧湪 `user-portal-bridge.js`锛堢姝㈠啓鍏?`user-chat-portal.js` 鐨?ops 瀛楃涓诧級銆?3. 鏅鸿兘浣撳垪琛ㄧ敱 `UserAgentResolver` 鑱氬悎 `proto_ops_v11_agents`锛坙isted锛? `Proto.DEMO_LIST_AGENTS` + 榛樿浼佷笟婕旂ず闆嗭紝鎸?`shareMode`/`permissionTargets` 鍒嗕笁缁勩€?4. 鍙嶉鎻愪氦璧?`OpsUserFeedback.createFromChat`锛涖€岀敓鎴愬唴瀹归敊璇€嶆垨鏂囨鍚€屾湭瑙ｅ喅銆嶆椂 `OpsFeedbackLoop.createTaskFromFeedback`銆?5. 涓撳宸ヤ綔鍙板鐢?`12-expert-*` 椤甸潰缁撴瀯涓?`ops-expert-workbench.js`锛岃縼绉昏嚦 `web绔?涓撳宸ヤ綔鍙?`锛沗data-portal-surface="user"` 鏃堕《鏍忔樉绀鸿繑鍥炵敤鎴峰璇濄€?6. 涓撻」楠岃瘉锛歚prototype/scripts/web-portal-check.js` 鎸傚叆 `verify-all.js`銆?7. **2026-06-10 琛ュ厖**锛氱敤鎴风 Figma page `376:250` 鈥?鎼滅储妗嗕綅浜庢柊瀵硅瘽涓庢櫤鑳戒綋涓績涔嬮棿锛沗DEFAULT_AGENTS` 濮嬬粓鍚堝苟杩涗紒涓氱粍锛涗晶鏍忋€屾秷鎭腑蹇冦€嶄笁 Tab锛坄user-message-center.js`锛夛紱涓撳宸ヤ綔鍙?4 椤典娇鐢?`user-portal-shell.js` aioq 渚ф爮锛岀姝㈠鐢ㄨ繍钀?`SIDEBAR`銆?
**Consequences**: 杩愯惀 v1.1銆屾墦寮€鐢ㄦ埛瀵硅瘽椤点€嶉摼鎺ユ敼涓?`web绔?index.html`锛沺ackage-check 澧炶ˉ web 瀛愮洰褰曢〉闈㈠瓨鍦ㄦ€ф柇瑷€锛沗design/figma.config.json` 澧炲姞 `userEnd` / `userChat` 绛?screen 鏄犲皠銆?
---

## ADR-011: 鏅鸿兘浣撴潈闄愬叆鍙ｄ笌瀹℃牳閫氳繃鍗充笂鏋?(2026-06-10)

**Status**: Accepted

**Context**: 鐢ㄦ埛瑕佹眰涓汉鍜岀粍缁囧唴鏅鸿兘浣撳彲浠ユ墿澶т娇鐢ㄦ潈闄愶紝璁╁叾浠栭儴闂ㄦ垨鍏蜂綋鐢ㄦ埛鏌ョ湅鍜屼娇鐢紱鍚屾椂鎸囧嚭鈥滃彂甯冦€佷笂鏋躲€佸鏍糕€濋摼璺湪鐜版湁鍓嶇鏋舵瀯涓壊瑁傦紝瑕佹眰鐮嶆帀涓婄骇瀹℃壒骞堕噸鏂版敹鍙ｆ祦绋嬨€?
**Decision**:

1. 鏂板鍏变韩缁勭粐/鐢ㄦ埛閫夋嫨鍣?`prototype/assets/org-access-picker.js`锛屼綔涓哄垱寤哄脊绐椼€佹棫璇︽儏椤靛彂甯冨脊绐椼€乿1.1 鍗＄墖鏉冮檺鍏ュ彛鐨勭粺涓€閫夋嫨鍣ㄣ€?2. 鏅鸿兘浣撴潈闄愬師鍨嬪瓧娈电粺涓€涓?`shareMode` + `permissionTargets`锛屽厛瀛樺叆 `sessionStorage`锛屽苟鍦?`Proto.onAgentCreated`銆乣Proto.runAgentPublish`銆乿1.1 `syncProtoState` 涓悓姝ャ€?3. 鈥滃崟浣嶅叡浜€濈粺涓€鏀逛负鈥滈儴闂ㄥ叡浜€濓紱閫夋嫨鍏ュ彛鏂囨缁熶竴涓衡€滈€夋嫨閮ㄩ棬/鐢ㄦ埛鈥濄€?4. v1.1 棣栭〉鍗＄墖 `鈰痐 鑿滃崟鍏佽鍐呴儴鏅鸿兘浣撴樉绀衡€滄潈闄愨€濓紝绗笁鏂规櫤鑳戒綋涓嶆樉绀猴紱瀹℃牳涓崱鐗囦粛涓嶆樉绀鸿彍鍗曪紝瀹℃牳鍏ュ彛鍙繚鐣欏湪瀹℃牳宸ヤ綔鍙般€?5. 瀹℃牳閾捐矾鏀舵暃涓衡€滃彂甯冨€欓€夌増鏈?鈫?骞冲彴瀹℃牳 鈫?宸蹭笂鏋垛€濓紝绉婚櫎鈥滀笂绾у鎵光€濆拰鈥滃鏍搁€氳繃寰呬笂鏋垛€濓紱骞冲彴瀹℃牳閫氳繃鍚庣洿鎺ュ啓鍏?`listed` 骞惰褰?`approvedAt/listedAt`銆?6. v1.1 涓撻」妫€鏌ュ繀椤绘柇瑷€锛氬唴閮ㄦ櫤鑳戒綋鑿滃崟鍚潈闄愩€佺涓夋柟鏅鸿兘浣撹彍鍗曚笉鍚潈闄愩€佸鏍搁€氳繃鍚庣洿鎺ヤ笂鏋躲€?
**Consequences**: ADR-009 涓€滃鏍搁€氳繃寰呬笂鏋?杩愯惀涓婃灦鈥濈殑鏃?v1.1 鐘舵€佸彛寰勮鏈?ADR 瑕嗙洊锛汚DR-010 鐨勫崱鐗囪彍鍗曡瘝琛ㄦ柊澧炩€滄潈闄愨€濊繖涓€渚嬪锛屼絾涓嶅緱閲嶆柊鍔犲叆鈥滄煡鐪?鍘诲鏍?鎾ゅ洖鈥濈瓑瀹℃牳鍏ュ彛銆?
---

## ADR-010: 鏅鸿兘浣撹繍钀?v1.1 蹇呴』鎺ュ叆 v1.0 澹充笌鍗＄墖鎿嶄綔璇嶈〃 (2026-06-09)

**Status**: Accepted

**Context**: v1.1 澶氳疆杩唬鍑虹幇渚ф爮 404銆佷华琛ㄧ洏/宸ヤ綔鍙般€屾秷澶便€嶃€佸崱鐗囪彍鍗曡啫鑳€锛堝幓瀹℃牳/鏌ョ湅璇︽儏/鎾ゅ洖鍙戝竷锛夈€佷笌 v1.0 浜у搧妯″瀷鑴辫妭銆傜敤鎴疯姹傦細杩唬鑰岄潪閲嶅啓锛涘鑸仈鍔紱鍗＄墖浠?鍙戝竷/鍋滅敤/涓婃灦/涓嬫灦/鍒犻櫎锛涚偣鍗＄墖=鏌ョ湅锛涘鏍镐粎鍦ㄥ伐浣滃彴銆?
**Decision**:

1. v1.1 鍏ㄩ儴椤甸潰蹇呴』浣跨敤 `ops-platform-shell.js`锛堥《鏍?渚ф爮锛夛紝绂佹鑷缓绗簩濂楀鑸€?2. 渚ф爮銆屾櫤鑳戒綋杩愯惀銆嶄负鍙睍寮€鍒嗙粍锛氶粯璁ゅ叆鍙?`鏅鸿兘浣撹繍钀1.1/index.html`锛堝崱鐗囧垪琛級锛涘瓙椤逛粎銆岃繍钀ユ瑙堛€嶃€屽鏍稿伐浣滃彴銆嶃€傜姝㈠湪浠〃鐩?鍗＄墖涓婚〉鍐嶆寕瀹℃牳鍏ュ彛銆?3. 鍗＄墖 `鈰痐 鑿滃崟璇嶈〃瀵归綈 `proto.js` `buildAgentListActionsHtml`锛?*鍙戝竷銆佸仠鐢ㄣ€佷笂鏋躲€佷笅鏋躲€佸垹闄?*锛? 宸插仠鐢ㄦ€?**鍚敤**锛夛紱**绂佹** 鏌ョ湅銆佸幓瀹℃牳銆佹挙鍥炪€佸紑鍙戦厤缃瓑銆傜偣鍑诲崱鐗囦富浣撹繘鍏ヨ鎯呫€?4. 瀹℃牳涓?寰呭鏍告€侊細鍗＄墖涓嶆樉绀?`鈰痐锛堝鏍稿湪宸ヤ綔鍙板畬鎴愶級銆?5. `file://` 瀵艰埅锛歚鏅鸿兘浣撹繍钀1.1/` 瀛愮洰褰曞唴渚ф爮閾炬帴蹇呴』涓虹浉瀵硅矾寰勶紙`dashboard.html`锛夛紝瀹炵幇椤?`decodeURIComponent` 妫€娴嬬洰褰曘€?6. 楠屾敹锛歚node prototype/scripts/v11-ops-check.js` 蹇呰窇锛涜瑙?`postmortem-ops-v11-2026-06-09.md` 涓?`AGENTS.md` 搂 Ops v1.1 UX Contract銆?
**Consequences**: 鍚庣画 v1.1 鍔熻兘鍙兘鍦ㄦ棦鏈変俊鎭灦鏋勫唴鎵╁睍锛涙彁鍗囦负榛樿鍏ュ彛鏃堕渶鍙﹀紑 ADR 骞跺悓姝?`package-check` 椤甸潰琛ㄣ€?
---

## ADR-009: 鏅鸿兘浣撹繍钀?v1.1 鐙珛鐩綍涓庡彂甯?涓婃灦鎷嗗垎 (2026-06-09)

**Status**: Accepted

**Context**: 鏅鸿兘浣撹繍钀ラ渶瑕佸弬鑰冩墸瀛愰」鐩〉閲嶅仛涓婚〉锛屽苟鎶娾€滃彂甯冣€濆拰鈥滀笂鏋垛€濇媶鎴愪袱涓祦绋嬶紱鍚屾椂瑕佹眰鍘熷墠绔〉闈㈡枃浠朵繚鎸佷笉鍙橈紝鏂扮増鏀惧叆 `prototype/鏅鸿兘浣撹繍钀1.1/`锛屼絾浠嶈兘璺宠浆鍒板師寮€鍙戦〉鍜岀敤鎴风椤甸潰銆?
**Decision**:

1. v1.1 閲囩敤鐙珛闈欐€侀〉闈㈢洰褰曪紝涓嶄慨鏀规牴鐩綍 `index.html`銆乣05-agent-detail.html`銆乣08-audit-*.html`銆?2. 鏂板 4 涓〉闈細鏅鸿兘浣撶鐞嗗崱鐗囬〉銆佽繍钀ヤ华琛ㄧ洏銆佸鏍稿伐浣滃彴銆佹櫤鑳戒綋璇︽儏椤点€?3. 娴佺▼鎷嗗垎涓猴細寮€鍙戜腑 鈫?宸插彂甯冨緟瀹℃牳 鈫?瀹℃牳涓?瀹℃牳閫氳繃寰呬笂鏋?鈫?宸蹭笂鏋?鈫?宸蹭笅鏋?宸查┏鍥炪€?4. `鍙戝竷` 鍙敓鎴愬€欓€夌増鏈苟杩涘叆瀹℃牳锛沗瀹℃牳閫氳繃` 鍙繘鍏ュ緟涓婃灦锛沗涓婃灦` 鎵嶅紑鏀剧敤鎴风鍙銆?5. v1.1 浣跨敤鐙珛 `sessionStorage` key 淇濆瓨鏂扮増鐘舵€侊紝鍚屾椂鍦ㄥ叧閿姸鎬佸彉鍖栨椂鍚屾鍘?`Proto.setState`锛屼繚璇佽烦鍥炲師寮€鍙戦〉/鐢ㄦ埛绔笉鍓茶銆?6. 鏂板 `prototype/scripts/v11-ops-check.js` 鍋氭柊鐗堜笓椤归獙璇侊紱鍘?`verify-all.js` 涓嶇撼鍏?v1.1 瀛愮洰褰曪紝閬垮厤鏀瑰彉鏃х増 34 椤典氦浠樺绾︺€?
**Consequences**: 鏃х増鍘熷瀷璺緞淇濇寔绋冲畾锛涙柊鐗堝彲浣滀负涓嬩竴鐗堢晫闈㈢嫭绔嬮獙鏀躲€傚悗缁嫢瑕佹妸 v1.1 鎻愬崌涓洪粯璁ゅ叆鍙ｏ紝闇€瑕佸彟寮€ ADR 鍐冲畾鏍圭洰褰曞叆鍙ｅ拰 package-check 椤甸潰鏁扮瓥鐣ャ€?
---

## ADR-001: Prototype shared JS regression gate (2026-05-28)

**Status**: Accepted

**Context**: During "full delivery review", `proto.js` lost `wireDevPlatformRows()` function header when adding `wireStandardLinks()`. Illegal JS syntax caused `Proto` to fail loading site-wide. Skills table appeared empty. `smoke-check.js` (string grep only) still reported PASS.

**Decision**:

1. Restore broken functions immediately.
2. Add `node --check` on all `prototype/assets/*.js`.
3. Add `regression-check.js` 鈥?vm-load Proto, assert `getSkillCatalog().length >= 6`.
4. Add `browser-check.js` (jsdom) for 5 critical pages.
5. Bundle as `verify-all.js` 鈥?mandatory before claiming prototype delivery.

**Consequences**: Slightly longer CI/local verify; prevents "grep PASS but UI broken" class of failures.

---

## ADR-002: Global + project AI guardrails (2026-05-28)

**Status**: Accepted

**Context**: User requires all projects (Cursor, Codex, Claude Code) to self-review, verify, and not fake completion.

**Decision**:

- `AGENTS.md` + `.github/agent/memory/` for project PDCA
- `.cursor/rules/*.mdc` copied to `~/.cursor/rules/` for global Cursor sessions
- Vendor skills: ai-coding-ok, agent-verifier, ouro-loop, eins78-agent-skills
- `scripts/sync-ai-guardrails.ps1` mirrors skills to `~/.cursor`, `~/.codex`, `~/.claude`

**Consequences**: Single sync script maintains parity across tools.

---

## ADR-003: Agent detail navigation bootstrap + firstConfig lifecycle (2026-05-28)

**Status**: Accepted

**Context**: Direct open of `05-agent-detail.html` worked; returning from `index.html` and re-entering caused empty Skills, dead `+` button, and tabs blocked. Root causes stacked: (1) `window.__protoSkillBindWired` skipped re-binding after same-tab navigation; (2) stale `sessionStorage.firstConfig` blocked tabs even without `?new=1`; (3) scattered page init without session migration; (4) `agentName`/`agentType` used `params.get` instead of `params().get`, breaking skill modal href.

**Decision**:

1. Add `Proto.initAgentDetailPage()` 鈥?fixed order: `migrateAgentSession` 鈫?`ensureOverlaysClosed` 鈫?`resolveFirstConfigMode` 鈫?skill bind 鈫?`wireSkillBindButtons` 鈫?`bindTabs` 鈫?`applyFirstConfigUi`.
2. Remove `__protoSkillBindWired`; `wireSkillBindButtons` uses removable document delegate (safe to call multiple times).
3. `isFirstConfig()` **only** when URL has `?new=1`. List re-entry clears stale `firstConfig` in session via `resolveFirstConfigMode()`.
4. Demo agent `agt_demo_001`: default `boundSkillIds: ['sk_report', 'sk_risk']`; empty array without `skillsCleared` auto-restores defaults.
5. Add `navigation-journey-check.js` to `verify-all.js` (journeys A鈥揇: first entry, polluted session re-entry, `?new=1` guard, double wire).

**Consequences**: Navigation regressions are caught by automation; spot-check focuses on index鈫?5 round-trip. See `prototype/scripts/journey-audit-matrix.json`.

---

## ADR-004: Global AI workspace (memory + scripts + dynamic delivery gate) (2026-06-01)

**Status**: Accepted

**Context**: Skills/hooks were global but PDCA memory, guardrail scripts, and delivery gates remained per-repo (Agent Platform `AGENTS.md`, `prototype/verify-all` hardcoded in session core).

**Decision**:

1. Global memory hub at `~/.ai-workspace/memory/` (user-memory, global-task-history, global-decisions-log, projects-registry).
2. Runtime scripts copied to `~/.ai-workspace/scripts/`; hooks point there; repo `scripts/hooks/` remains canonical source via `sync-from-repo.ps1`.
3. `~/.claude/AGENTS.md` = global rules; repo `AGENTS.md` = project override (prototype ADR-003 still applies when detected).
4. `global-delivery-gate` skill auto-detects verify command; `ai-coding-ok` wrapper reads global memory first, project overlay optional.
5. `init-project-memory.ps1` creates team overlay only 鈥?no per-project AGENTS/rules/scripts copy.

**Consequences**: New projects zero-config; Agent Platform remains skills/guardrails source repo. SessionStart injects memory paths + always-on `global-session-core`.

---

## ADR-005: Figma 杩愯惀骞冲彴 Page 杞崲妯″潡杈圭晫 (2026-06-04)

**Status**: Accepted

**Context**: Figma 鏂囦欢 `gDc0xlVkOeJdgrQOZMy3wh` 鍚?3 涓?Page锛涖€屾櫤鑳戒綋杩愯惀銆嶃€孲kills 閰嶇疆銆嶅凡杞?HTML锛屻€岃繍钀ュ钩鍙般€峆age锛坄241:250`锛?8 甯у緟杞崲銆侳igma `reactions[]` 涓虹┖锛屾棤娉曡嚜鍔ㄦ彁鍙栬烦杞紱闇€鎵归噺鏂板 HTML/JS 涓斾笉鐮村潖 ADR-003銆?
**Decision**:

1. 閲囩敤 **REST JSON + interaction-spec.json + 鍒嗘ā鍧?JS** 娴佹按绾匡紙Desktop MCP 鍙€夌簿淇瑙夛級銆?2. 6 妯″潡锛歚user-feedback`銆乣expert-workbench`銆乣permission-mgmt`銆乣message-center`锛坉rawer锛夈€乣task-dispatch`锛坢odal锛夈€乣ops-review-expert`銆?3. 鏂扮姸鎬?**绂佹** 鍐欏叆 `proto.js`锛涘悇妯″潡鐙珛 `ops-*.js` + `sessionStorage` key锛堣 `docs/architecture/2026-06-04-figma-ops-platform-conversion.md`锛夈€?4. 浜や簰鍞竴鏉ユ簮锛歚design/interaction-spec.json`锛涘抚鏄犲皠锛歚design/figma.config.json`銆?5. 姣忔壒娆″繀椤?`verify-all.js` 鍏?PASS锛涗笉鏂板 `window.__*Wired`銆?
**Consequences**: 鍘熷瀷 HTML 浠?18 澧炶嚦 30 椤碉紱`package-check` / smoke 闇€鍚屾鏇存柊锛沗proto.js` 淇濇寔绋冲畾渚?05/Skills 鍥炲綊銆?
---

## ADR-006: 闇€姹傛緞娓呯‖鎷﹂摼璺紙鎰忓浘鍒嗗瀷 + PreToolUse锛?2026-06-05)

**Status**: Accepted

**Context**: `requirement-clarifier` 涓?`UserPromptSubmit` 浠呰蒋鎻愰啋锛孊 绫绘ā绯婂疄鏂戒粛甯哥洿鎺?Write/Edit锛涙壒閲忓畨瑁?GitHub 楂樻槦 skills 涓庣幇鏈?clarifier 閲嶅彔銆?
**Decision**:

1. **涓嶆墿瑁?*閲嶅楂樻槦 skills锛涚簿鍗庡凡鏈湴鍖栧湪 `skills/requirement-clarifier/`銆?2. **娑堟伅鍒嗗瀷** A/B/C 淇濈暀浜?`message-type-signals.json` + `Classify-UserMessageType`銆?3. **闂ㄦ帶鐘舵€佹満**锛歚UserPromptSubmit` 鍐?`~/.ai-workspace/clarifications/gate-state.json`锛圔鈫抈pending`锛涚‘璁よ瘝鈫抈cleared`锛夛紱鍚屾鍐?intent draft銆?4. **纭嫤**锛歚PreToolUse`锛圕laude `Write|Edit|MultiEdit`锛汣ursor `preToolUse` matcher `Write|Edit`锛夎皟鐢?`clarification-hard-gate.ps1`锛沗pending` 鏃?deny 闈炵櫧鍚嶅崟璺緞锛坄clarifications/`銆乣docs/intent/`銆乣.github/agent/memory/` 绛夛級銆?5. 涓枃鍏抽敭璇嶅缃?`clarification-gate-keywords.json`锛堥伩鍏?PS1 缂栫爜瑙ｆ瀽澶辫触锛夛紱绱ф€ョ粫杩?`CLARIFICATION_GATE_OFF=1`銆?
**Consequences**: 鐢ㄦ埛椤绘樉寮忕‘璁わ紙濡傘€屾寜婢勬竻缁撴灉鎵ц銆嶃€岀洿鎺ュ仛銆嶏級鍚庢墠鑳芥敼浠ｇ爜锛涙柊浼氳瘽闇€閲嶅惎 Cursor/Claude/Codex 浠ュ姞杞?`preToolUse` 閽╁瓙銆?
---

## ADR-007: Skills 璐ㄩ噺瀹¤涓庝笁绔皟鐢ㄨ矾鐢?(2026-06-05)

**Status**: Accepted

**Context**: 306 涓叏灞€ skills 涓鏁颁笉绗﹀悎銆屽厛璁捐瑙﹀彂銆佸啀璁捐娴佺▼銆嶈川閲忔爣鍑嗭紱濂?skill 甯告湭琚皟鐢ㄣ€傛牴鍥狅細Top 8 绔炰簤銆乣intent-profiles` 缂哄彛銆乨escription CSO 杩濊銆丷ules 鏇胯韩鎵ц銆乫igma2code 缂栫爜鎹熷潖銆?
**Decision**:

1. **瀹¤娴佹按绾?*锛歚scripts/hooks/audit-skills-quality.ps1` 鈫?`docs/skills-audit/*-inventory.json`锛沗merge-audit-to-stocktake.ps1` 鈫?`~/.claude/skills/skill-stocktake/results.json`銆?2. **DAILY/LIBRARY**锛歚agent-sort-agent-platform.ps1` 浜у嚭 Agent Platform 24 椤?DAILY 娓呭崟锛堣 `docs/skills-audit/*-daily-library.md`锛夈€?3. **璺敱琛ユ礊**锛歚intent-profiles.json` 鏂板 `figma_design`銆乣skill_engineering`銆乣research_general`锛沗skills-sync.config.json` 鎵╁睍 `descriptionOverrides` + `promptKeywordBoosts`锛圕SO 浠?WHEN锛夈€?4. **Figma 鍏ュ彛**锛氶」鐩?`figma-workflow` + 鍏ㄥ眬 `figma2code`锛圲TF-8 姝ｆ枃淇锛夛紱nested `figma2code/figma2code` 闄嶄负 stub銆?5. **瑙﹀彂 TDD**锛歚trigger-tdd-tier1.ps1` 瀵?Tier1 鐢ㄤ緥瑕佹眰 scan-global-skills Top 8 鍛戒腑鐜?鈮?0%锛堝綋鍓?16/16 PASS锛夈€?6. **Tier3 BROKEN 淇**锛歚issue-triage`銆乣pr-review`銆乣pr-triage`銆乣rtk-tdd`銆乣rtk-triage` frontmatter 琛ュ叏 description銆?
**Consequences**: 鏂?skill 椤诲厛浠诲姟鍗?鈫?CSO description 鈫?intent/keyword 娉ㄥ唽 鈫?1 娆″帇娴嬶紱`sync-hooks-config.ps1` 鍚屾涓夌 hooks 閰嶇疆銆?
---

## ADR-008: 娴疯兘鍩哄骇鍒嗗眰 + 鍙屽钩鍙颁簲鐜妭 API 濂戠害 (2026-06-08)

**Status**: Accepted

**Context**: AI 搴旂敤寮€鍙戝钩鍙伴渶鏄庣‘涓庢捣鑳藉钩鍙板叧绯伙紙娴疯兘 = 绠楀姏/鎺ㄧ悊/浼佷笟鐭ヨ瘑 API 鍩哄骇锛涙湰浠撳簱 = 搴旂敤缂栨帓涓庤繍钀ユ不鐞嗘墿灞曪級锛屽苟灏嗚繍钀モ噭寮€鍙戝崗浣滀粠鍘熷瀷鏂囨钀藉疄涓哄彲瀵规帴濂戠害銆?
**Decision**:

1. **鍒嗗眰**锛氱敤鎴烽棬鎴凤紙娴疯兘鍝佺墝锛夆啋 搴旂敤杩愯鏃?鈫?娴疯兘 API 缃戝叧 鈫?妯″瀷璺敱/鐭ヨ瘑搴?璁￠噺锛涜繍钀ヤ笌寮€鍙戝钩鍙颁笉鐩存帴璋冨害 GPU銆?2. **鍙屽钩鍙拌竟鐣?*锛氳繍钀ョ鐘舵€?鍙戝竷/瀹℃牳/鐩戞帶鎽樿锛涘紑鍙戠鎻愮ず璇?宸ヤ綔娴?Skills锛涢厤缃啓寮€鍙戙€佹憳瑕佽杩愯惀锛沗agent_id` 鍏ㄥ眬鍞竴銆?3. **浜旂幆鑺?API**锛堝師鍨?mock锛歚prototype/assets/platform-api.js`锛夛細
   - 鈶?`syncCreateAgent` 鈥?杩愯惀鍒涘缓鏃跺弻绔敞鍐?   - 鈶?`getAvailableResources` 鈥?缂栬緫鍣ㄦ媺鍙栨ā鍨?鐭ヨ瘑/Skills锛堟潈闄愯繃婊わ級
   - 鈶?`syncConfig` 鈥?寮€鍙戜繚瀛?鈫?杩愯惀鎽樿
   - 鈶?`startChat` 鈥?娌欑/闂ㄦ埛瀵硅瘽缁忚繍琛屾椂璋冩捣鑳芥帹鐞?   - 鈶?`reportMetrics` 鈥?浼氳瘽缁撴潫 3s 鍐呭紓姝ヤ笂鎶?Token/寤惰繜
4. **妯″瀷妗ｄ綅**锛氱敤鎴峰彲瑙佹爣鍑?澧炲己/涓撲笟/鏃楄埌锛涙槧灏勮〃閰嶇疆鍖栵紝涓嶅鐢ㄦ埛鏆撮湶渚涘簲鍟嗭紙瑙?`docs/architecture/2026-06-08-haineng-integration-spec.md`锛夈€?5. **鍙嶉闂幆**锛歚ops-feedback-loop.js` 涓茶仈 鍙嶉 鈫?鍒嗘淳 鈫?涓撳浠诲姟 鈫?鍥炴祦宸ュ崟锛坄proto_ops_work_orders`锛夛紱涓嶅啓鍏?`proto.js` 杩愯惀涓氬姟鎬侊紙寤剁画 ADR-005锛夈€?6. **杩愯惀鐪嬫澘鍥涗欢濂?*锛歚14-business-dashboard.html` 绛?4 椤?+ `ops-dashboards.js`锛涗晶鏍忕敱 placeholder 鏀逛负瀹為摼銆?
**Consequences**: 娴疯兘 API 宸ヤ綔鍧婂榻?`haineng-integration-spec` 搂4锛涙柊璺ㄥ钩鍙拌兘鍔涢』鎵╁睍 `platform-api.js` 濂戠害鑰岄潪鏁ｈ惤 sessionStorage锛沗package-check` 椤甸潰鏁?30鈫?4銆?

---

## ADR-016: Skills routing tier — LIBRARY out of TopN (2026-06-16)

**Status**: Accepted

**Context**: After vendor install of 63 awesome-* skills, global catalog hit 413 entries; Top 8 competition and overlapping design skill descriptions caused ROUTING_GAP.

**Decision**:
1. Sync layer: excludeNamePrefixes awesome- + excludePathPatterns skills/vendor/awesome-* — vendor only, no global sync.
2. Routing layer: routingExclude* filters; descriptionOverrides overlay at score time.
3. exclusiveGroups: one winner per design/figma/clarifier/debug/delivery group.
4. topMatches: 10; CSO NOT-when boundaries on DAILY skills.
5. prune-global-skills-routing.ps1 for three-end cleanup.
6. trigger-tdd-tier1.ps1 single catalog load; target hit rate >= 90%.

**Consequences**: Hook scoring pool excludes awesome-*; index may still list vendor LIBRARY; copy project skills-sync.config.json to ~/.ai-workspace/scripts/ after hook install.

---
