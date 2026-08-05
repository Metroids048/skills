# Claude Code → 全局配置：历史批量知识同步 Prompt

> 用法：在 **Claude Code** 新开会话，整段复制下方「可复制 Prompt」执行。  
> 对应规范：`KNOWLEDGE_CAPTURE_PROMPTS.md` → **Prompt I**  
> 中央根：`C:/Users/win/Desktop/全局配置`

---

## 可复制 Prompt

```text
现在执行「Claude Code 历史知识批量同步进全局配置」，不是继续开发业务功能。

## 中央与必读

中央根：C:/Users/win/Desktop/全局配置

开始前必须阅读：
1. C:/Users/win/Desktop/全局配置/MEMORY_AGENTS.md
2. C:/Users/win/Desktop/全局配置/SESSION_CAPSULE_TEMPLATE.md
3. C:/Users/win/Desktop/全局配置/当前全局状态.md
4. C:/Users/win/Desktop/全局配置/日志/Cursor历史源盘点_2026-07-28.md（了解栏目与禁区）
5. 相关项目的 C:/Users/win/Desktop/全局配置/项目镜像/<项目名>/（若已有）

登记项目清单：C:/Users/win/Desktop/全局配置/待确认更新/候选项目清单.md
未登记项目：只写待确认备注，禁止擅自新建项目镜像。

## 你的工具标识

source_tool = claude-code

## 本机源（只读扫描，按优先级）

P0：
- %USERPROFILE%/.claude/projects/**/*.jsonl（父会话优先；subagents 作补充，勿重复计入）
- %USERPROFILE%/.claude/plans/*.md
- 各 Desktop 项目/.github/agent/memory/*.md
- 各 Desktop 项目/项目知识库/*.md（若存在）
- %USERPROFILE%/.ai-workspace/memory/*.md（user-memory、global-task-history、global-decisions-log）

P1：
- %USERPROFILE%/.claude/history.jsonl（仅作索引）
- %USERPROFILE%/.claude/file-history/（仅当需要变更证据时抽样，勿整目录入库）

禁止读取/写入：
- %USERPROFILE%/.claude/.credentials.json
- settings.json 中的密钥/OAuth 段
- 任意 .env、Token、Cookie、私钥
- telemetry/、cache/ 全量 dump

## 目标（做什么）

1. 盘点 Claude Code 会话覆盖的项目与时间范围，写简短盘点到：
   C:/Users/win/Desktop/全局配置/日志/ClaudeCode历史源盘点_<日期>.md
2. 对每个已登记项目：从会话与项目 memory 抽取可复用结构化事实（不是全文转录）。
3. 按 MEMORY_AGENTS 记录类型分类：DECISION / ERROR_PATTERN / ROOT_CAUSE / PROVEN_FIX / VERIFICATION / PROJECT_STATUS / OPEN_QUESTION / USER_PREFERENCE / CONTENT_IDEA / SENSITIVE。
4. 写入顺序：
   a. 为有价值会话写 Session Capsule → 全局会话归档/YYYY/MM/ 或 项目/项目知识库/会话记录/
   b. 更新项目 项目知识库/（当前状态、决策、错误与根因、已验证解决方案、开放事项）
   c. 运行：python C:/Users/win/Desktop/全局配置/工具/知识中心.py 同步 --项目 <名>
   d. 跨项目可复用经验 → 跨项目经验/（仅 CONFIRMED/VERIFIED）
   e. 全局 ADR → 决策与复盘/全局决策记录.md（增量）
   f. 稳定偏好 → 用户长期记忆/（冲突则只写 待确认更新/）
   g. PUBLIC_SAFE 选题 → 内容素材中心/（禁止客户/密钥/未脱敏交易）
5. 冲突与不确定：只写 待确认更新/ 与 冲突与过期记录/；禁止静默覆盖 USER_KNOWLEDGE_BASE.md。

可选原始层导入（若你已把 jsonl 转成 Markdown 导出）：
python C:/Users/win/Desktop/全局配置/工具/知识中心.py 导入 --file <导出.md> --项目 <名> --tool claude-code

## 硬门禁

- 禁止整段聊天 dump 进长期栏目
- 无真实命令/测试证据不得写 COMPLETE / VERIFIED
- 禁止改业务源码；只写知识区与中央仓库
- 禁止伪造验证结果
- SENSITIVE / SECRET 必须 withheld 并在汇报中列出类别（不写原文）
- 注意：Claude projects 目录名是路径编码（如 c--Users-win-Desktop-AI--main），须映射回登记项目名

## 验收与汇报（必须）

完成后用中文汇报：
1. 遍历了哪些源（路径 + 大约文件数 + 时间跨度）
2. 写入/更新了哪些文件
3. 新增决策 / 错误模式 / 已验证修复 条数摘要
4. 待确认补丁列表
5. withheld 敏感项类别
6. 未覆盖项目与下一步最小动作
7. 实际运行的命令与结果（同步/冲突检查）

不要开始新的业务开发任务。
```

---

## 建议配套命令（同步后）

```text
python C:/Users/win/Desktop/全局配置/工具/知识中心.py 冲突
python C:/Users/win/Desktop/全局配置/工具/知识中心.py 隐私
```
