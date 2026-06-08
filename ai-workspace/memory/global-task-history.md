# Global Task History

> All tasks across projects. Newest entries at top. Format: `[project: alias or path]`.

---

## [TASK-G013] 三端 AI 全局配置与避坑梳理导出

- **Date**: 2026-06-08
- **Project**: global (Cursor / Claude Code / Codex)
- **Type**: docs / inventory
- **Summary**: 核对三端 hooks、306 skills、16 条 always-on rules；导出常驻文档 `~/.ai-workspace/docs/tri-end-ai-config-inventory-zh.md`；补全 `projects-registry.md`（demo、platform-docs）；`user-memory.md` 增加总览指针。
- **Verified**: 对照 `global-skills-index.md`（306）、`~/.cursor/rules` alwaysApply 计数（16）、三端 hooks.json 路径一致。

## [TASK-G012] Agent Platform 用户端聊天页回正

- **Date**: 2026-06-05
- **Project**: C:\Users\win\Desktop\Agent Platform
- **Type**: fix / frontend / product
- **Summary**: 按用户反馈将用户端从后台化 AI 工作台回正为截图式极简聊天页：左侧智能体列表、顶部模型选择、中心欢迎态、底部输入框、会话 Skills、能力来源浮层、回答引用/原文、文件卡和反馈弹窗。
- **Verified**: `node --check prototype/assets/user-chat-portal.js` passed；用户端 jsdom 初始化/发送后 DOM 检查 passed；`node prototype/scripts/verify-all.js` passed。

## [TASK-G011] Agent Platform 用户端 AI 工作台闭环升级

- **Date**: 2026-06-05
- **Project**: C:\Users\win\Desktop\Agent Platform
- **Type**: feature / frontend / architecture
- **Summary**: 将 `prototype/09-user-chat.html` 升级为用户端 AI 工作台，补齐智能体中心、会话前配置、生成过程透明化、资产、反馈单、专家复核、消息中心和轻量权限申请；新增 `assets/user-chat-portal.js` 独立持有用户端状态。
- **Verified**: `node prototype/scripts/verify-all.js` passed；`node --check prototype/assets/user-chat-portal.js` passed；用户端 jsdom 初始化检查 passed。

## [TASK-G010] 项目全量审核计划落地

- **Date**: 2026-06-04
- **Project**: C:\Users\win\Desktop\demo
- **Type**: product + frontend + docs
- **Summary**: 落地全量审核优化计划：统一 H5 SEO/能力边界、H5 相邻工具推荐与增强埋点、小程序 H5 承接闭环（去除假完成）、增长资产与验收矩阵文档。
- **Verified**: `npm run verify` passed (typecheck, 32 Vitest tests, production build).

## [TASK-G009] Headroom 三端 MCP 配置（Windows）

- **Date**: 2026-06-04
- **Project**: global (Cursor / Claude Code / Codex)
- **Type**: infra
- **Summary**: 调研 [headroom](https://github.com/chopratejas/headroom)；因 0.22.x 无 Windows wheel 安装 `headroom-ai==0.20.15[mcp,proxy]`；Claude `claude mcp add`（绝对路径）、Cursor `~/.cursor/mcp.json`、Codex `~/.codex/config.toml` 接入 MCP；未改现有 `ANTHROPIC_BASE_URL=15721`；文档 `~/.ai-workspace/docs/headroom-setup-zh.md` + `start-headroom-proxy.ps1`。
- **Verified**: `headroom --version` → 0.20.15；`claude mcp list` → headroom Connected；`python -c import headroom` OK

## [TASK-G007] Lightweight image compression miniapp MVP

- **Date**: 2026-06-04
- **Project**: C:\Users\win\Desktop\demo
- **Type**: product + frontend
- **Summary**: Implemented the approved 0-to-1 plan as a Vite/React H5 image compression MVP with shared core types/processors, local recent history, analytics event definitions, compliance disclosures, PRD/architecture/metrics docs, and a native WeChat mini program shell.
- **Verified**: `npm run verify` passed (typecheck, 7 Vitest tests, production build); `npm audit --audit-level=critical` found 0 vulnerabilities; local Vite preview responded 200 at http://127.0.0.1:5173/.

## [TASK-G006] Skill library completion audit

- **Date**: 2026-06-03
- **Project**: Agent Platform (global install)
- **Type**: infra
- **Summary**: Completed the final audit by correcting the last malformed `figma2code` frontmatter in Cursor and verifying that the bad-frontmatter scan across Cursor, Codex, and Agents returned no remaining matches.
- **Verified**: directory rescan plus malformed-description scan across all managed skill roots.
## [TASK-G005] Final skill library cleanup

- **Date**: 2026-06-03
- **Project**: Agent Platform (global install)
- **Type**: infra
- **Summary**: Finished the skill-library cleanup by fixing the remaining malformed frontmatter (`ai-review`, `continuous-learning`, `verification-loop`) and removing non-runtime source-package directories plus the stale `react-best-practices` alias from Codex.
- **Verified**: rescanned Cursor/Codex/Agents skill directories; no Cursor skills missing in Codex; no remaining malformed descriptions in the managed set.
## [TASK-G004] Full Cursor-to-Codex skill mirror

- **Date**: 2026-06-03
- **Project**: Agent Platform (global install)
- **Type**: infra
- **Summary**: Mirrored all remaining missing `~/.cursor/skills` directories into `~/.codex/skills` after the first cleanup batch, so Codex now contains every Cursor skill plus its existing Codex-only entries.
- **Verified**: compared directory names across Cursor and Codex; Cursor missing-in-Codex count is 0.
## [TASK-G003] Global skill cleanup and Codex sync

- **Date**: 2026-06-03
- **Project**: Agent Platform (global install)
- **Type**: infra
- **Summary**: Cleaned high-frequency skill frontmatter (`requirement-clarifier`, `zero-to-one-gate`, `karpathy-guidelines`), repaired malformed Codex skill descriptions for `pm-*` and `figma2code`, converted `space-url2proto` to a deprecated alias, and added 7 missing workflow skills to Codex.
- **Verified**: frontmatter spot-checks in `~/.cursor/skills` and `~/.codex/skills`; Codex skill count increased to 60.
## [TASK-G002] Batch 2 global skills gap-fill

- **Date**: 2026-06-03
- **Project**: Agent Platform (global install)
- **Type**: infra
- **Summary**: Installed 6 junction skills (awesome-cursor 脳3, rezvani compliance 脳3), books rules 脳2, keyword boosts; global skills 251.
- **Verified**: scan-global-skills.ps1; hooks.json unchanged (scan only)

## [TASK-G001] Global AI workspace bootstrap

- **Date**: 2026-06-01
- **Project**: Agent Platform
- **Type**: infra
- **Summary**: Established `~/.ai-workspace/memory/` for cross-project PDCA; hooks inject global memory paths; ai-coding-ok reads global first, project overlay optional.
- **Verified**: install-global-workspace.ps1 + SessionStart smoke
---







## 2026-06-04 - TASK-G008 手机办公文件处理助手重定位实现
- 将 H5 从单一图片压缩页重构为“手机办公文件处理助手”任务中心，首批入口为拍图识字、扫描成 PDF、PDF 工具、图片工具。
- 新增 shared core 多工具能力：ToolRegistry、OCR/PDF/Image processor、Text/Pdf/Image/Qr 联合结果类型、工具维度埋点字段。
- 引入 Tesseract.js 与 pdf-lib，补齐 OCR/PDF 单元测试和开源披露；PDF 首版明确仅支持 JPG/PNG 直接生成。
- 将微信小程序从单页压缩壳扩展为 home/ocr/scan-pdf/pdf-tools/image-tools/result 多页轻壳，重处理预留 H5/云 OCR/worker 路径。
- 同步 README、PRD、架构、合规清单、指标风险与 14 天上线 SOP 到新定位。
- 验证：npm run verify 通过；npm audit --audit-level=critical 0 vulnerabilities；小程序 JS/JSON 语法解析通过。

## 2026-06-04 - AI 中台系统演示材料制作
- **Project**: C:\Users\win\Desktop\平台项目资料
- **Type**: document + demo prep
- **Summary**: 基于 3 个说明书 docx、功能清单 xlsx、截图 doc、AI 编程辅助 pptx，以及系统只读登录菜单，生成 `AI中台系统介绍与演示讲稿.docx`，包含系统介绍、6 大入口全景、重点模块讲解、演示路线、3 分钟/10 分钟讲稿、切换话术、问答口径和截图速览。
- **Verified**: Word COM 可打开，15 页、19 表、8 图；python-docx 结构检查 105 段、19 表、8 图；扫描未包含明文密码、SM3 哈希或长 token；来源清单覆盖全部 6 份资料。

## 2026-06-04 - AI 中台演示纯文本稿二次调整
- **Project**: C:\Users\win\Desktop\平台项目资料
- **Type**: document edit
- **Summary**: 将纯文本演示稿从功能罗列调整为产品设计主线，突出运营平台串联子系统、用户反馈/专家工作台、数据闭环、智能体开发规范、灵活权限控制，并同步 `.md` 与 `.txt`。
- **Verified**: Markdown 602 行，开头中文正常，问号乱码数 0；扫描未包含明文密码或哈希；PowerShell 确认关键主题均存在。

## 2026-06-04 - AI 中台演示讲稿精简连贯版
- **Project**: C:\Users\win\Desktop\平台项目资料
- **Type**: document edit
- **Summary**: 新增 `AI中台系统演示讲稿-精简连贯版.md/.txt`，将长篇功能说明压缩为一条现场可讲的连贯主线，突出产品整合、运营闭环、反馈/专家工作台、智能体/知识/模型/资源/权限/智能编码的主次关系和价值。
- **Verified**: UTF-8 读取正常，2625 字符、37 行、问号乱码数 0；未包含明文密码或哈希。

## 2026-06-05 - TASK-G009 小程序优先版办公文件助手重做
- [project: C:\Users\win\Desktop\demo]
- 将小程序从 H5 菜单壳重做为主体验：OCR、扫描成 PDF、PDF 工具走上传 + CloudBase 云函数 + 统一结果页；图片工具走本机压缩/最长边调整/保存。
- 新增云函数 `ocrRecognize`、`pdfProcess`、`feedbackSubmit`，OCR 未配置凭证返回 `OCR_NOT_CONFIGURED`，不展示模拟结果；PDF 需真实 fileID 才进入结果页。
- 新增小程序工具层 `cloud/errors/results`，统一云调用、错误提示、结果存储、反馈提交和相邻工具跳转。
- H5 降级为备用/SEO，PDF 依赖动态加载，构建不再出现 500KB chunk 警告。
- 补齐 README、PRD、小程序上架资料、交互设计、合规、增长留存、发布管理和验收矩阵。
- Verified: npm run verify 通过（13 files / 40 tests）；npm audit --audit-level=critical 0 vulnerabilities；小程序与云函数语法解析通过；H5 dev server 200。
