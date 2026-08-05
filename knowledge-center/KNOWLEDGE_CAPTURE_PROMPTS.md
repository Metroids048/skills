---
title: 跨 Cursor / Codex / Claude Code 知识采集与复盘 Prompts
version: 1.0
last_updated: 2026-07-28
---

# 跨 Agent 知识采集与复盘 Prompts

## 0. 现实边界

Cursor、Codex、Claude Code 和普通 AI 对话工具不会天然共享完整聊天记录。

本方案同步的是：

- Agent 在会话结束时主动生成的结构化会话胶囊；
- 项目 Git 状态、diff、commit、测试和产物；
- 用户反馈、决策、错误、修复和待办；
- 经整理后的长期知识；
- 可公开的视频内容素材。

不依赖读取各工具的私有内部思维，也不假设能够稳定解析所有客户端的内部数据库。

---

# Prompt A：初始化个人 AI 知识库仓库

```text
请在当前私有仓库中初始化一个跨 Cursor、Codex、Claude Code 和通用 AI 对话工具使用的个人知识库系统。

开始前：

1. 阅读现有 USER_KNOWLEDGE_BASE.md 和 MEMORY_AGENTS.md。
2. 检查当前仓库、Git 状态和已有文件。
3. 不读取或输出任何密钥、Token、Cookie、私钥和 .env 内容。
4. 先给出实施计划和验收标准。
5. 只搭建知识系统，不修改任何业务项目。

目标：

建立一个文件化、可版本控制、可检索、可复盘的长期系统，用于收集：

- 用户偏好和约束；
- 所有项目的目标、状态、决策和结果；
- Cursor、Codex、Claude Code 会话中的任务和反馈；
- Git diff、commit、命令、测试和产物；
- Agent 错误模式、根因和有效修复；
- 可转化为视频的真实内容素材；
- 个人开放事项。

必须创建：

- USER_KNOWLEDGE_BASE.md
- MEMORY_AGENTS.md
- CURRENT_STATE.md
- DECISIONS.md
- LESSONS.md
- CONTENT_VAULT.md
- inbox/
- sessions/YYYY/MM/
- projects/
- personal/
- templates/session-capsule.md
- templates/project-record.md
- schemas/session-capsule.schema.json
- schemas/knowledge-item.schema.json
- scripts/ 或 tools/ 下的采集、校验、去重、隐私检查和索引程序
- README.md
- .gitignore

必须实现统一 CLI，具体命令名称可按仓库现有技术栈确定，但必须支持：

1. 创建会话胶囊；
2. 导入 Agent 生成的会话摘要；
3. 读取指定业务仓库的 Git status、diff、最近 commit；
4. 登记测试、命令和生成产物；
5. 更新项目状态；
6. 记录决策；
7. 记录错误、根因和修复；
8. 提取视频内容候选；
9. 检查重复、冲突、过期和隐私；
10. 生成周复盘；
11. 生成月度知识合并建议；
12. 在不破坏旧记录的前提下更新索引。

隐私要求：

- SECRET 永不写入仓库；
- SENSITIVE 与 PUBLIC_SAFE 分离；
- 不允许把客户、法律、交易和身份信息自动写入公开内容库；
- 发现疑似密钥、Cookie、Token、私钥、助记词或完整 .env 时必须拒绝写入；
- 主知识库只记录摘要，不复制完整客户文档和大段聊天；
- 所有自动修改必须保留 diff，可回滚。

知识项必须包含：

- id
- type
- date
- source_tool
- project
- statement
- confidence
- evidence
- sensitivity
- public_safe
- status
- supersedes
- conflicts_with
- tags

验证：

- 使用 fixture 模拟一次 Codex 会话、一次 Claude Code 会话和一次 Cursor 会话；
- 三次会话都生成结构一致的 session capsule；
- 能发现重复事实；
- 能发现互相冲突的项目状态；
- 能阻止包含测试 API Key 的记录；
- 能从真实 Git fixture 中读取 diff 和 commit；
- 能生成 CURRENT_STATE、DECISIONS、LESSONS 和 CONTENT_VAULT 更新建议；
- 不得自动覆盖 USER_KNOWLEDGE_BASE.md 中已有人工确认内容；
- 测试、lint、typecheck/build 按项目真实配置运行；
- 完成后由独立只读 Reviewer 审查。

完成报告必须包含：

- 状态；
- 文件树；
- 命令；
- 测试结果；
- 示例 session capsule；
- 隐私测试；
- 冲突测试；
- 未验证项；
- 已知限制；
- Git commit hash。
```

---

# Prompt B：每次编码 / 项目会话结束时归档

```text
现在执行“会话知识归档”，不是继续开发业务功能。

请读取：

1. MEMORY_AGENTS.md；
2. USER_KNOWLEDGE_BASE.md 中与当前项目相关的摘要；
3. 当前用户任务和本次可见对话；
4. 当前项目的 AGENTS.md / CLAUDE.md / .cursor/rules；
5. 当前 Git status、diff、最近 commit；
6. 本次实际运行的命令、测试、日志摘要和生成产物；
7. 用户在本次会话中的反馈、否定、纠正和新偏好。

请生成一个 Session Capsule，并更新知识库。

必须区分：

- 用户明确事实；
- 项目事实；
- AI 建议；
- 已执行动作；
- 已验证结果；
- 未验证判断；
- 失败和根因；
- 临时状态；
- 可长期保存的经验；
- 可以公开的视频素材；
- 敏感且禁止公开的内容。

强制规则：

- 不记录私有 chain-of-thought；
- 不写入密钥、Token、Cookie、私钥和 .env；
- 不把“Agent 说完成”写成已验证完成；
- 没有真实命令和结果时，状态不得写 COMPLETE；
- 旧记录与新结果冲突时，保留旧记录并标记 STALE/CONFLICTED；
- 不重复复制已有知识；
- 一次性日志放 session，不放主知识库；
- 只有稳定、重要、以后会再次使用的信息才提议更新 USER_KNOWLEDGE_BASE.md；
- 不直接覆盖人工确认的主知识库内容，先生成 patch 或 proposed_updates。

输出和更新：

1. sessions/YYYY/MM/<timestamp>_<tool>_<project>.md
2. projects/<project>.md
3. CURRENT_STATE.md
4. DECISIONS.md（仅新决策）
5. LESSONS.md（仅已验证的可复用经验）
6. CONTENT_VAULT.md（仅 PUBLIC_SAFE）
7. proposed_updates/<timestamp>.patch.md

最终汇报：

- 会话状态；
- 写入文件；
- 新增事实；
- 新增决策；
- 新增经验；
- 发现的冲突；
- 标记过期的记录；
- 被隐私规则拦截的内容；
- 提取的视频选题；
- 尚未解决的问题；
- 下一步最小动作。
```

---

# Prompt C：非代码 AI 对话归档

适用于 ChatGPT、Claude 网页版或其他没有项目 Git 的对话。

```text
请把本次对话整理为个人知识库的 Session Capsule。

你只能使用本次可见对话和用户提供的文件，不得补猜。

请提取：

- 用户提出的问题；
- 用户透露的稳定背景；
- 用户明确的偏好和限制；
- 讨论中的事实；
- AI 给出的建议；
- 用户接受、拒绝或修正了什么；
- 最终决策；
- 具体日期、金额、地点、账号、项目名和约束；
- 待办；
- 风险；
- 可用于自媒体的真实内容；
- 绝对不能公开的敏感内容。

分类为：

USER_FACT
USER_PREFERENCE
USER_CONSTRAINT
DECISION
TASK
OPEN_QUESTION
LESSON
CONTENT_IDEA
SENSITIVE
DO_NOT_PUBLISH

要求：

- 对可能变化的信息标记 STALE_RECHECK；
- 对 AI 建议标记 ASSISTANT_SUGGESTION，不当成用户决策；
- 对没有用户确认的推断标记 INFERRED；
- 不写入私有思维过程；
- 不输出密钥或隐私原文；
- 输出一份可以保存到 sessions/YYYY/MM/ 的 Markdown；
- 再输出最多 10 条 proposed durable memory updates；
- 再输出最多 10 条 PUBLIC_SAFE 视频选题。
```

---

# Prompt D：项目阶段复盘

```text
请对指定项目进行阶段复盘。

读取：

- 项目 AGENTS.md、CLAUDE.md 和规则；
- 项目计划、需求和 ADR；
- 最近一段时间的 session capsules；
- Git log、diff 和关键 commit；
- 测试、构建、部署或平台结果；
- 用户反馈；
- CURRENT_STATE、DECISIONS 和 LESSONS。

输出：

1. 原始目标；
2. 当前真实状态；
3. 已完成且有证据的部分；
4. 用户报告完成但尚未独立验证的部分；
5. 仍然阻塞端到端目标的问题；
6. 已经解决的根因；
7. 重复出现的 Agent 错误；
8. 做过但无效的方案；
9. 需要删除或标记过期的旧知识；
10. 当前风险；
11. 下一阶段唯一目标；
12. 明确非目标；
13. 可观察验收标准；
14. 最小执行计划；
15. 可以做成视频的故事线。

禁止：

- 为了显得全面而继续扩展问题；
- 提出与当前目标无关的重构；
- 把测试通过等同于业务结果；
- 把 AI 推断写成事实。
```

---

# Prompt E：每周知识与内容复盘

```text
请执行本周个人知识库复盘。

时间范围：
<开始日期> 至 <结束日期>

读取：

- 本周所有 Session Capsule；
- CURRENT_STATE；
- DECISIONS；
- LESSONS；
- CONTENT_VAULT；
- 各项目 Git 状态和用户反馈；
- 已发布视频数据，如有。

请输出：

## 1. 本周发生了什么
按项目列出事实，不写流水账。

## 2. 完成与未完成
严格区分 VERIFIED COMPLETE、USER-REPORTED COMPLETE、PARTIAL、BLOCKED、NOT STARTED。

## 3. 新决策
写明决策、原因、放弃的替代方案和影响。

## 4. 重复错误
只保留至少出现两次，或一次造成重大损失的问题。

## 5. 新的有效经验
必须有验证证据。

## 6. 需要标记过期的知识
列出旧内容和新证据。

## 7. 下周唯一优先目标
不超过三个项目，每个项目只允许一个主要目标。

## 8. 视频内容候选
每条包含标题、冲突、真实证据、当前结论、公开风险、补录素材和适合平台。

## 9. 知识库修改建议
生成 proposed patch，不自动重写全部主知识库。
```

---

# Prompt F：月度合并与清理

```text
请执行月度知识库维护。

目标：去重、合并经验、标记过期、解决冲突、缩短主知识库、细节下沉、保留来源、清理无价值临时信息。

规则：

1. 不删除历史事实，只能归档或标记 STALE。
2. 不覆盖用户明确决定。
3. 没有证据不能把 INFERRED 升级为 CONFIRMED。
4. 临时 Debug 日志不进入主知识库。
5. 主知识库只保留用户画像、长期规则、项目摘要、当前状态、决策、开放事项和内容方向。
6. 详细过程移动到 projects/ 或 sessions/。
7. SENSITIVE 内容不能进入 PUBLIC 内容库。
8. 输出完整 diff 和变更原因。
```

---

# Prompt G：从知识库提取视频内容

```text
请从个人知识库中提取真实、可公开、适合抖音和小红书的视频内容。

读取：

- USER_KNOWLEDGE_BASE.md
- CONTENT_VAULT.md
- 指定项目记录
- 相关 Session Capsules
- 已有发布数据

筛选条件：

- 有明确目标；
- 有真实问题或冲突；
- 有证据；
- 有用户自己的判断；
- 有阶段结果；
- 普通 AI 用户能理解；
- 不依赖深度代码；
- 不是纯工具新闻；
- 不泄露客户、身份、账号、交易和法律隐私；
- 不构成投资建议；
- 不把未验证结果说成成功。

为每个候选输出：

- 选题；
- 适合的受众；
- 3 秒开头；
- 一句话冲突；
- 可用证据；
- 叙事结构；
- 当前结论；
- 仍未解决的部分；
- 需要补录的画面；
- 抖音标题；
- 小红书标题；
- 风险检查；
- 是否值得进入本周制作。

优先从以下内容中提取：

1. Agent 说完成但实际没完成；
2. 项目越改越乱；
3. 非程序员怎样验收；
4. 自动交易不开单和幽灵单；
5. Alpha 高自相关与自动提交；
6. Agent Video Studio 从搭建到真实使用；
7. 客户 Demo 与真实需求不匹配；
8. AI 合同审查中的确定性规则和语义分析；
9. 工具和 Skills 放入真实任务后的结果；
10. 用户的真实成本、时间和失败。
```

---

# Prompt H：Agent 接近上下文 / Token 耗尽前紧急归档

```text
当前会话可能接近上下文或 Token 上限。

停止新增分析和非必要修改，立即执行安全收口：

1. 保存所有已完成文件；
2. 检查 Git status 和 diff；
3. 运行当前阶段最小必要验证；
4. 不声称未验证内容通过；
5. 创建 WIP commit，commit message 明确标记当前状态；
6. 如仓库和用户规则允许，推送当前分支；
7. 生成 Session Capsule；
8. 更新项目 CURRENT_STATE；
9. 记录已完成、未完成、当前失败、下一步精确入口、运行命令、关键文件和不能重复走的错误方案；
10. 不开始新任务，不全面复盘，不重构。

最终只报告：

- 保存位置；
- commit hash；
- push 状态；
- 验证结果；
- 未完成项；
- 下一次继续执行的第一条命令或文件入口。
```

---

# Prompt I：历史批量回填同步（Codex / Claude Code）

> 单次会话结束请用 Prompt B。本 Prompt 用于把**本机历史会话**结构化同步进中央知识库。  
> 可复制全文：  
> - [`提示词/Codex_历史知识同步进全局配置.md`](提示词/Codex_历史知识同步进全局配置.md)  
> - [`提示词/ClaudeCode_历史知识同步进全局配置.md`](提示词/ClaudeCode_历史知识同步进全局配置.md)

## 共用骨架

```text
现在执行「<TOOL> 历史知识批量同步进全局配置」，不是继续开发业务功能。

中央根：C:/Users/win/Desktop/全局配置
必读：MEMORY_AGENTS.md、SESSION_CAPSULE_TEMPLATE.md、当前全局状态.md、对应 项目镜像/<名>/
登记清单：待确认更新/候选项目清单.md（未登记不新建镜像）

source_tool = <codex | claude-code>

源（按工具替换，见下方分叉）：
- 会话 JSONL / plans / 项目 .github/agent/memory / 项目知识库 / ~/.ai-workspace/memory
禁读：auth/credentials/.env/secrets/OAuth

流程：
1) 写日志/<Tool>历史源盘点_<日期>.md
2) 抽取结构化事实（禁止全文 dump）
3) Session Capsule → 全局会话归档/ 或 项目知识库/会话记录/
4) 更新项目知识库 → python 工具/知识中心.py 同步 --项目 <名>
5) 跨项目经验 / 全局决策 / 用户长期记忆 / 内容素材（仅 PUBLIC_SAFE）
6) 冲突只写 待确认更新/；禁止覆盖 USER_KNOWLEDGE_BASE.md

汇报：源覆盖、写入文件、条数摘要、待确认、withheld、命令结果、下一步。
```

### Codex 源分叉

- `~/.codex/sessions/**/rollout-*.jsonl`、`archived_sessions/`
- 禁：`auth.json`、`secrets/`

### Claude Code 源分叉

- `~/.claude/projects/**/*.jsonl`、`plans/`
- 禁：`.credentials.json`、settings 密钥段
- 注意路径编码目录名须映射回登记项目名

---

# 工具接入建议

## Claude Code

在项目 `CLAUDE.md` 中导入共享规则：

```markdown
@AGENTS.md
@<共享知识库路径>/MEMORY_AGENTS.md
```

每次重要会话结束执行 Prompt B。对**历史批量回填**执行 Prompt I（见 `提示词/ClaudeCode_历史知识同步进全局配置.md`）。对重大变更使用新的只读 Reviewer。

## Cursor

在 `.cursor/rules/knowledge-memory.mdc` 中写入精简规则：

```markdown
---
description: Capture durable project and user knowledge after meaningful sessions
alwaysApply: true
---

- Read <共享知识库路径>/MEMORY_AGENTS.md when the task involves the user's projects or long-term preferences.
- At the end of a meaningful task, run the Session Capture workflow.
- Never store secrets or unverified completion claims.
```

详细流程仍放在知识库，不要把整个主知识库复制进 Cursor User Rules。

## Codex

在全局或项目 `AGENTS.md` 中加入精简入口：

```markdown
## Shared personal knowledge

For tasks involving this user's projects, read:
- <共享知识库路径>/MEMORY_AGENTS.md
- <共享知识库路径>/CURRENT_STATE.md
- the relevant file under <共享知识库路径>/projects/

At the end of a meaningful task, create a Session Capsule and update proposed durable memory.
For historical backfill across all past Codex sessions, paste Prompt I from
`C:/Users/win/Desktop/全局配置/提示词/Codex_历史知识同步进全局配置.md`.
```

不要假设 Codex 插件会自动让其他 Agent 获得相同上下文。

## 普通 AI 对话工具

在对话结束时粘贴 Prompt C，把结果保存到 `sessions/` 或 `inbox/`，再由本地 Agent 运行合并流程。
