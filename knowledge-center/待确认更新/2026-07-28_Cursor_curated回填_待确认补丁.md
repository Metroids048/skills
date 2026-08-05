# 待确认补丁：Cursor curated 回填（user-memory / task-history）

- 生成时间：2026-07-28
- 来源：`~/.ai-workspace/memory/user-memory.md`、`global-task-history.md`
- 规则：不直接覆盖 `USER_KNOWLEDGE_BASE.md`；下列为建议增量

## 选项

1. **全部采纳** → 合并进 `用户长期记忆/` 对应文件，并择要升 UKB
2. **部分采纳** → 勾选条目后告知 Agent
3. **拒绝** → 保留本补丁作审计，不入库

---

## A. 用户偏好增量（建议写入 `用户长期记忆/用户偏好与约束.md`）

| ID | 陈述 | 证据 | 敏感性 |
|----|------|------|--------|
| P-01 | 默认简体中文回复 | user-memory Preferences | PRIVATE |
| P-02 | 0→1 严格：新模块先方案+ADR+用户确认再写代码 | user-memory | PRIVATE |
| P-03 | 「最大权限」= 少确认修当前问题，≠ 可删 CC Switch/清配置 | ADR-G003 / user-memory | PRIVATE |
| P-04 | 模糊输入（优化/改 UI/对标/整体弄好）必须先锁主改动类型与验收 | ADR-G004 | PRIVATE |
| P-05 | 每轮只选一个主改动类型：产品主线 / IA / UI / AI·数据 | ADR-G004 | PRIVATE |
| P-06 | Agent Config Pack 分层：Working Agreement → 项目 AGENTS → 工具补丁 → verify → Hooks/CI | user-memory 2026-07-22 | PRIVATE |

## B. 跨项目教训（建议写入 `跨项目经验/`，多数已部分存在）

| ID | 陈述 | 目标文件 | 状态建议 |
|----|------|----------|----------|
| L-01 | Skills hooks 用 `scan-global-skills.ps1`，禁止全库 dump | 工具与Skills经验 | 可直接追加 CONFIRMED |
| L-02 | JSON settings for RTK 必须 UTF-8 **无 BOM** | 工具与Skills经验 | 可直接追加 |
| L-03 | 交付命令：Agent Platform=`verify-all`；program1/demo1=`npm run verify`；勿在平台根跑 `npm run lint` | 已验证解决方案 | 可直接追加 |
| L-04 | DeepSeek 缓存链路：客户端 15721 → CC Switch → 18789 deepseek-cc-proxy | 工具与Skills经验 | PRIVATE，勿进公开素材 |
| L-05 | 原型导航：smoke 绿 ≠ 旅程绿；须 navigation-journey 第 5 步；禁 `window.__*Wired` | Agent错误模式 + Agent Platform 镜像 | 可直接追加 |

## C. 近期任务摘要（建议写入各 `项目镜像/*/当前状态.md` 追加节，不升 UKB）

| 项目 | 摘要 | 验证标签 |
|------|------|----------|
| AI--main | 2026-07-22 策略漏斗与 A-E 影子基线；未改生产策略/风控 | VERIFIED（pytest/ruff/mypy 证据在 task-history） |
| AI--main | 2026-07-26 起多条 ADR：Swing 样本不足不启用；carry 缺 funding 历史；Meta-Label AUC 不足保持规则版 | CONFIRMED |
| 敖钦储能项目 | 2026-07-17 V1.5.1 模板/多维表格；`frontend-demo` npm run verify 27 用例 | VERIFIED |
| 海小南 | 2026-07-06 PM 分册 V1.1；Excel agents 有效 49 条（用户说 50 → 待确认） | USER_REPORTED / 文档验收 |
| Agent Platform | 2026-06-26 Web 用户端 v1.1；verify-all 通过；目录无 git | VERIFIED（无 git diff） |

## D. Withheld

- 不写入：任何 API Key、`.env`、交易所密钥轮换细节原文
- 不公开：DeepSeek 代理端口链路以外的账号信息
- 不新建镜像：program / demo / Operating Platform（见候选项目清单备注）
