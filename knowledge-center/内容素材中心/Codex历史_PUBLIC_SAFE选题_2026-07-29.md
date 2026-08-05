# Codex 历史 PUBLIC_SAFE 选题（2026-07-29）

- source_tool：`codex`
- 规则：只保留可公开抽象；不含客户名、交易账户、订单号、Alpha 公式、合同原文、简历/JD、内部页面或凭据。

| 选题 | 冲突/反差 | 可用证据 | 建议平台 |
|---|---|---|---|
| 为什么测试全绿，用户还是进不了下一页？ | 单页 smoke 通过但跨页 journey 失败 | navigation-journey 回归门禁 | 抖音 / 小红书 |
| Agent 的验收单为什么会被误认成策略交易？ | acceptance traffic 与自然策略成交混在同一时间线 | 订单 provenance + 调度时槽证据 | 抖音 |
| “系统没有开单”其实有多少种原因？ | 无信号、数据过期、模型 veto、风险拒绝、执行失败不可混写 | 决策漏斗与 blocker 分类 | 抖音 / B 站 |
| 一次“失败的 Shadow Run”为何反而是成功的工程结果？ | 零候选、零平台调用，但 fail-closed 正确阻断 | stale gate / missing correlation 证据 | 小红书 / B 站 |
| 自动生成一万个 Alpha，为什么可能只有几千种思路？ | 表达式不同但 canonical/cluster 高度重复 | canonical + lineage + cluster 统计 | B 站 |
| 模拟音频桥测试通过，为什么仍不能说真实会议可用？ | debug ASR 与真实桌面桥/真实会议是两套证据 | browser-flow 与 real-meeting 未验证标签 | 小红书 |
| 把 43 张产品截图增量更新到 53 张，如何避免重建整套 Figma Atlas？ | 更新旧 Frame 与新增 Frame 同时发生 | manifest/ZIP 数量一致 + 增量导入器 | 小红书 |
| 企业 PC 项目为什么要主动删除移动端验收？ | “多做一点”会扩大范围并制造无效返工 | 1440/1280/1024 唯一验收范围 | 小红书 |
| 数字人 Demo 的关键不是会动，而是统一场景源 | 问答、快捷入口、语音和弹窗各自为政 | 统一场景源 + 静态脚本校验 | 抖音 |
| 三个 Agent 的 Skills 为什么要先分类再路由？ | 全库平铺 TopN 容易错配、漏触发 | category-first routing + hard gate smoke | B 站 / 小红书 |

## 禁止公开

- 真实交易账户、订单号、API/认证信息、收益率承诺。
- WorldQuant 有效公式、平台私有接口、Cookie、绕过风控或反滥用细节。
- 客户名称、内部业务数据、合同/报价、未授权截图。
- 用户简历、JD、会议内容和转写文本。

