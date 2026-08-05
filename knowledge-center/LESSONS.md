> 别名入口 → `跨项目经验/已验证解决方案.md`

# 已验证解决方案

- 更新：2026-07-28T11:50:07
- 来源：UKB 稳定偏好、中央知识中心工具链、各项目镜像 `已验证解决方案.md`
- 说明：下列为跨项目可复用方案；项目专属修复以各镜像为准，会话胶囊追加。

## 1. 中央知识中心（本仓已验收）

- `[CONFIRMED]` 来源：`交付说明_V1.md` / `日志/最终完成报告.md` — 项目事实写入 `项目知识库/`，中央只镜像；冲突生成 `待确认更新/`，禁止静默覆盖。
- `[CONFIRMED]` 来源：安装器 — 幂等写入知识区与托管 AGENTS/CLAUDE 区块，不改业务源码。
- `[CONFIRMED]` 来源：权限证明 — 拒绝读 `.env`/Cookie DB；拒绝危险删除/format；密钥导入脱敏。
- `[CONFIRMED]` 来源：CLI 包装 — Cursor CLI 用 `工具/开始AI任务.py`（`--simulate` 覆盖 success/fail/interrupt）；GUI 用开始/结束归档 + 导出导入。
- `[CONFIRMED]` 来源：统一 CLI — `python 工具/知识中心.py`（梳理/同步/验收/复盘）。
- `[CONFIRMED]` 来源：本轮补齐 — `python 工具/汇总跨项目经验.py` 填充跨项目经验；验收禁止整行空壳占位文案。

## 2. Agent 工作方式（UKB 收口模式）

- `[CONFIRMED]` 来源：UKB §2 — 目标/范围/验收先写清；最小修改；行为验证优先于「代码看起来对」。
- `[CONFIRMED]` 来源：UKB §2 — 同一检查最多自动修 3 次；连续两次无进展停止并报告证据。
- `[CONFIRMED]` 来源：UKB §4 — 全局规则只放稳定偏好；项目事实放项目 AGENTS；复杂流程放 Skill；强约束放 tests/Hooks/verify。
- `[CONFIRMED]` 来源：UKB §4.3 — Token/上下文耗尽前：保存、提交、推送、写 Session Capsule（Prompt H）。
- `[CONFIRMED]` 来源：UKB 标签 — `USER_REPORTED` vs 独立验证完成必须区分（如 Agent Video Studio）。

## 3. 领域方案摘要（有证据，细节回项目）

- `[CONFIRMED]` 交易（AI--main）：Testnet 与 Local Paper 隔离；禁止 Synthetic Local Fill；保护 fail-closed；订单参数由确定性程序算，AI 不定关键数值。来源：UKB §5.1 / `项目镜像/AI--main/`。
- `[CONFIRMED]` Alpha：仅当唯一阻塞是模板描述缺失才自动补描述重提；Base gate/自相关/生产相关失败禁止因补描述重提。来源：UKB §5.2 / `项目镜像/alpha/`。
- `[USER_REPORTED]` Agent Video Studio：工程测试通过 ≠ 真实素材可发；冻结功能后用真实素材压测。来源：UKB §5.3。
- `[CONFIRMED]` 业务 Demo（产能评价类）：按真实 Excel 流程/角色/数据结构重构，AI 侧栏要行内入口+结构化结果+人工确认。来源：UKB §5.5。
- `[CONFIRMED]` 合同审查：确定性规则 + 语义审查分工；低置信度人工复核；结果定位原文。来源：UKB §5.6。

## 4. 项目镜像中的本地方案条目

- `agent platform` — - 验证命令：node prototype/scripts/verify-all.js
- `ai--main` — - 验证命令：项目内 pytest / 既有 verify；禁止伪造成交
- `alpha` — - 验证命令：tests/ + pipeline runners
- `program1-main-latest` — - 验证命令：npm run verify / test:browser-flow
- `yinpinjianting` — - 验证命令：npm run verify
- `产能评价` — - 验证命令：原型走查 + 客户反馈对照
- `合同审查` — - 验证命令：方案文档 v0.3/v0.4；样本验证优先
- `敖钦储能项目` — - 验证命令：文档与 demo 对照
- `海小南` — - 验证命令：原型走查
