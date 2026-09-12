---
name: video-research-package
description: >
  当对话中出现任何视频链接（抖音 v.douyin.com / www.douyin.com、B站 bilibili、YouTube、
  小红书 xiaohongshu、X/Twitter 视频、或抖音那种「4.64 复制打开抖音…」分享文案），
  或用户给出本地视频文件、或说「按视频 SOP 处理」「把这个视频内容完整拆出来」
  「分析这几个视频」「照着这个视频做」时，必须调用本 Skill。
  它把视频一次性变成标准研究包（媒体 + 逐字稿 + 词级时间戳 + 关键帧 + 图文对齐 +
  结构化内容），之后所有任务复用同一个包，绝不重新下载或重新转写。
  Turns any video URL or local file into a reusable frozen research package via the
  VCI pipeline, then runs the requested task (detailed copy, study notes, trading
  research, knowledge extraction, multi-video comparison, video replication) against it.
---

# 视频研究包 SOP

## 这个 Skill 存在的唯一理由

**一次把视频变成标准研究包，后面无限复用。绝不为新任务重新抓、重新转写、重新拆视频。**

用户给视频链接时通常不会提 VCI 细节，只会说「处理这几个链接，然后帮我做 XXX」。
你要做的永远是两步：**先查有没有历史 Package → 有则直接用，无则 ingest 一次 → 执行 XXX。**

## 第 0 步（强制）：先查历史 Package

任何情况下都不允许跳过这一步直接 ingest。

```powershell
pwsh -NoProfile -File "C:\Users\Windows11\.ai-workspace\skills-curated\video-research-package\vci.ps1" status
```

对照输出里的 `SOURCE_ID` / `KIND` / `TITLE`。判定：

| 命中情况 | 动作 |
|---|---|
| 该视频已存在且状态 `PACKAGE_VERIFIED` / `PACKAGE_PARTIAL` | **CACHE / HISTORICAL PACKAGE HIT** → 直接进第 3 步做任务，不许重新 ingest |
| 状态 `ACQUIRE_BLOCKED`（有 id 但没有媒体） | 平台当前拿不到。**先问用户要本地文件**，别反复重试平台 |
| 完全没有该来源 | 进第 1 步 ingest 一次 |

看单个包的细节：

```powershell
pwsh -NoProfile -File "...\vci.ps1" show <SOURCE_ID>
```

## 第 1 步：Ingest（只跑一次）

`inputs` 接受 URL、抖音分享文案原文（不用手工抽链接，resolver 会提取）、本地文件、
文件夹、或一个 urls.txt 清单。多条可一次传入。

```powershell
# 单条 / 多条
pwsh -NoProfile -File "...\vci.ps1" ingest "<url 或分享文案原文>"

# 清单
pwsh -NoProfile -File "...\vci.ps1" ingest "D:\urls.txt"

# 需要平台会话时（用用户自己已有的登录态，不做任何登录绕过）
pwsh -NoProfile -File "...\vci.ps1" ingest "<url>" --cookies-from-browser firefox

# 多视频归入一个语料集，便于横向比较
pwsh -NoProfile -File "...\vci.ps1" ingest "<url1>" "<url2>" --corpus <NAME>
```

ingest 内部按序完成 SOP 的 ①→⑦：
Acquire → Normalize → Transcript(字幕/ASR/词级时间戳) → Visual(定时帧+场景帧+关键帧+Contact Sheet)
→ Align(口播↔时间轴↔画面) → Reconstruct → Structured Package。

常用参数：

- `--profile <NAME>` 领域转写 profile，提升专业词准确率并启用 landmark 完整性检查。
  中文交易/外汇/技术分析类内容用它效果明显。profile 是用户自己的 JSON 文件，
  放在 `workspace/profiles/<NAME>.json`，或用 `VCI_PROFILES_DIR` 指定目录。
  格式：`{"domain": "...", "language": "zh", "initial_prompt": "领域词汇…", "landmarks": ["必须出现的句子"]}`
- `--initial-prompt "<TEXT>"` 不建 profile 文件时的一次性领域提示
- `--language zh` 强制语言
- `--asr-model <NAME>` 默认 large-v3；赶时间可用 small
- `--force` 重跑所有阶段（**只在用户明确要求时用**）
- `--attach-to <VID>` 把本地文件补给一个已 ACQUIRE_BLOCKED 的来源，接着往下跑

## 第 2 步：确认包质量，不要假设

```powershell
pwsh -NoProfile -File "...\vci.ps1" review <SOURCE_ID>
```

质量门 Q01–Q12 逐维出结论。要注意的两点：

- `PACKAGE_PARTIAL` 是常见且正常的终态，不等于失败。它表示某些维度还需人工/Agent 补齐
  （典型是画面解读 `agent/vision_worksheet.md` 还没填）。**可以基于 PARTIAL 包做任务**，
  但在产出里要如实说明哪部分是缺的。
- **Q12 = 转写结构完整性。** DEGRADED 表示解码器打转重复、或整段内容被丢掉
  （字错率看不出这两种问题，因为重复和遗漏在编辑距离里互相抵消）。
  Q12 DEGRADED 时**不要**把这个包当一手证据用，先报告给用户。
- Q12 有第三种结果：`no integrity verdict recorded`（内部叫 ABSENT）。
  **所有在 commit `89747b1` 之前 ingest 的旧包都会这样**，因为当时完整性检查还没接入生产链。
  这不是转写坏了，也不是 bug —— 是那个包无法自证。这类包的证据权重按 `PARTIAL_PACKAGE` 处理。
  需要真实完整性结论时，用 `--force` 重新 ingest 一次即可；不需要就照常用，但要如实说明。

## 第 3 步：做用户实际要的任务

```powershell
# 预设任务
pwsh -NoProfile -File "...\vci.ps1" task <SOURCE_ID> --preset detailed-copy

# 多视频横向比较
pwsh -NoProfile -File "...\vci.ps1" task <ID1> <ID2> <ID3> --preset compare

# 任意自定义任务
pwsh -NoProfile -File "...\vci.ps1" task <SOURCE_ID> --prompt "D:\my_task.md"
```

可用 preset：

| preset | 用途 |
|---|---|
| `detailed-copy` | 高保真完整内容复写 |
| `summary` | 短摘要 |
| `study-notes` | 学习笔记 |
| `knowledge-extract` | 结构化知识抽取 |
| `trading-research` | 交易策略研究抽取 |
| `compare` | 多视频对比（传多个 source_id） |

`task` 产出的是一份**任务简报**（工作指令 + 该读哪些文件），不是最终成品。
你要按简报读包内文件，然后自己产出内容。包是**冻结**的：只读，不许下载、转码、重新转写、重采样。

包内可读文件：`aligned/timeline.md`（工作主文档）、`transcript/raw.txt`（口播权威来源）、
`transcript/cleaned.md`、`transcript/transcript.json`（含词级时间戳）、
`structured/content.json`、`reconstruction/full_content.md`、
`visual/contact_sheet*.jpg` 和 `visual/keyframes/*.jpg`（当图片读）。

如果任务需要画面解读，先读 contact sheet / keyframes，把结论写成文件再合并回包：

```powershell
pwsh -NoProfile -File "...\vci.ps1" apply <SOURCE_ID> --kind vision --file <file>
# --kind 可选 vision | reconstruction | structure
```

多视频语料集：`vci.ps1 corpus <NAME>`。

## ACQUIRE_BLOCKED 是合法终态，不是 bug

平台拿不到时，pipeline 会诚实记 `ACQUIRE_BLOCKED` + reason + remedy，**CLI 退出码仍是 0**。
这时正确做法：

1. 把 reason 原样告诉用户
2. 请用户提供本地文件，然后 `--attach-to <VID>` 接上去继续
3. **不要**反复重抓、不要换着浏览器试 cookie、不要为此改 VCI 代码

**绝不允许**：平台拿不到就凭标题、网页描述或想象编造视频内容。没有媒体就是没有内容。

## 抖音（Douyin）现在可以直接用了（2026-08-11 新增）

**已生效，无需额外配置。** 归档里 9 条抖音来源此前全是 `ACQUIRE_BLOCKED`，
现已实测 9/9 可解析（含元数据），其中 3 条跑通完整 ingest 到 `PACKAGE_PARTIAL`。
要把旧的 blocked 包转成可用包，对该 source_id 用 `--force` 重跑一次即可。

- **无需 cookie**：SSR 分享页自带公开数据，yt-dlp 要求的 `ttwid` cookie（需 JS 流程）现在跳过了。
- **元数据更丰富**：除 title/uploader/duration 外，还拿到点赞/评论/分享/收藏数（`statistics`）、结构化 hashtag（`hashtags`）、发布时间戳（`created_at`）、背景音乐作者/ID（`music`）、作品 ID（`aweme_id`）。这些全在 `manifest.json` 的 `adapter_metadata` 里。
- **图文帖（image carousel）**：图片存到 `original/images/`、文案存到 `original/caption.txt`、
  元数据存到 `original/post_metadata.json`，**内容已完整提取**。但因为没有音视频流可 normalize，
  包状态仍是 `ACQUIRE_BLOCKED`。这种情况直接读那三个文件就是全部内容，不需要再找媒体文件。
  （此路径为离线测试覆盖，尚无真实图文链接实测。）
- **yt-dlp 兜底**：SSR 拿不到时（私密/删除/区域限制）自动降级到 yt-dlp，
  blocked 信息会同时标明 SSR 和 yt-dlp 两条路径各自的失败原因。

**yt-dlp 对抖音失败的真实原因**（修正此前 SKILL.md 的记录）：

- 短链 `v.douyin.com` 跳到 `iesdouyin.com/share/video/<id>` → yt-dlp 报 `Unsupported URL`（没有该分享域的 extractor）
- 手工规范化成 `www.douyin.com/video/<id>` → yt-dlp 报 `Fresh cookies (not necessarily logged in) are needed`

所以不是单纯 cookie 问题，是两道独立失败，Chrome cookie 那条限制只是第二道。
新 adapter 绕过了这两道。**注意：已有的 blocked 旧包不会自动变好**，要用 `--force` 重跑该 source_id。

## 已知本机环境限制（2026-08-09 实测 + 2026-08-11 修正）

- **Chrome cookie 不可用**：Chrome 151 启用 App-Bound Encryption（`Local State` 里有 `app_bound_encrypted_key`），yt-dlp 无法解密其 cookie（yt-dlp issue #10927）。但抖音现在走 SSR 不需要 cookie。
- **抖音 SSR 限流**：连续约 10-15 次请求后，分享页会返回 2492 字节的 `argus-csp-token` 风控页，约 150 秒后自动恢复。adapter 内部已实现指数退避重试（15s → 45s → 150s），批量 ingest 会自动处理。如果仍然失败，用户侧的 remedy 是等几分钟后再试，或提供本地文件。


## 硬禁止（用户 2026-08-09 明令）

- ❌ 已有 Research Package 还重新 ingest
- ❌ 为了「证明平台还能下载」反复重抓旧视频
- ❌ 把第三方平台 cookie 问题当成 VCI 未完成、或反向去改 VCI Core
- ❌ 修改 VCI Core；除非发现明确、可复现的 adapter bug（2026-08-11 抖音 adapter 属此例外，用户已批准）
- ❌ 因为一次工具 UI 输出异常（重复行/交错/截断）就推倒整个 session 重来
- ❌ 造第二套验证协议 / SOP 的 SOP

## VCI 仓库自身的测试（只在真要改 VCI 时相关）

**裸跑 `pytest` 在本机永远不会结束** —— 同进程内第二次真实 ASR ingest 会死锁
（ctranslate2 层，已在零 diff 的 HEAD 上复现，属 `TEST_HARNESS_LIMITATION`）。
标准回归方式叫 `FULL_SUITE_SEGMENTED_EXECUTION`：

1. `pytest -m "not slow"` 跑非 slow 全量
2. 5 个 slow test 各自独立 pytest 进程运行
3. 汇总所有 exit code

## 报告格式

完成后如实报告：

- 命中的历史包 / 新建的包，各自 `SOURCE_ID` 与状态
- 每个包的 Q12 转写完整性结论（CLEAN / DEGRADED）
- 用了哪个 preset 或自定义 prompt
- 实际产出内容
- 明确区分：口播原文（SOURCE_EXPLICIT）/ 画面推断（SOURCE_INFERRED）/ 模型解读（MODEL_INTERPRETATION）
- 任何 ACQUIRE_BLOCKED 的 reason 与 remedy 原文
- 无法验证的部分标为 unknown，不要填空
