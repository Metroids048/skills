# 本地外部视角协议

本页放容易出错、必须精确的执行合同。完成一次仿真时按需采用，不把示例里的数字理解成固定配额。

## 目录

1. Session 与目标快照
2. Persona、Scenario 与 Cases
3. Methodology
4. Local Use
5. Preflight 与隔离
6. 真实入口
7. 子代理指令
8. Trace、Evidence 与 Bundle
9. Feedback 与 Loop 证据
10. 收尾检查

## 1. Session 与目标快照

每次验证使用独立目录，固定建在 `~/.mirasim/eval/sessions/<slug>/`（`MIRASIM_HOME` 环境变量设置时以它替换 `~/.mirasim`；slug 用 `<yyMMdd-HHmm>-<被测物短名>`，如 `260803-1420-payflow-onboarding`）。位置是合同的一部分：mirasim 的 eval 查看服务按这个约定列出 run、渲染逐 case 轨迹与截图，落在别处的 session 用户看不见。目录内文件名可以按宿主调整，但信息不能丢：

```text
session/
├── request.md
├── session.json
├── target.json
├── methodology.json
├── case-index.json
├── uses.local.json
├── preflight.json
├── packets/<case-key>/
├── prompts/<case-key>.md
├── runner-logs/<case-key>.jsonl
├── traces/<case-key>.json
├── evidence/<case-key>/
├── versions/                 # 发生修改时保存
├── feedback.md
├── bundle.json
├── manifest.json
└── upload.json
```

`request.md` 原样保存用户请求。`target.json` 至少记录入口、访问方式、被验证版本、内容指纹和允许子代理读取的范围；文件用 SHA-256，代码优先用 git commit 加工作区 diff，服务记录构建号或部署标识。

`session.json` 记录 session id、当前轮次、文件清单与哈希、case 对应的模型/进程/起止时间、目标版本、上送状态和 run id。`runner-logs/` 保存宿主能提供的脱敏工具调用、stdout/stderr、浏览器动作或会话事件；移除隐藏思维、usage 和秘密，但保留实际入口、参数、结果、退出状态与时间。**默认不接平台，状态就记 `local_only`**；只有用户要求接平台、而 CLI 装不上或未登录时才用 `pending_upload`。任何情况下都不要伪造远端 id。

`manifest.json` 才保存文件路径、SHA-256 和证据引用；`bundle.json` 专门保存平台 ingest 请求体。两者不能混用。

Loop 修改前把旧版本放入 `versions/`，或保存可独立还原的 git commit/tag。每轮使用自己的 methodology、prompts、traces、feedback 与 bundle，不能覆盖上一轮证据。

## 2. Persona、Scenario 与 Cases

**字段合同在这里，怎么写厚在 [cast.md](cast.md)** —— 三层的加载机制、密度预算、极客深度采集清单、episodes 的召回规则与自检脚本都在那页；本节只定形状。

Persona 表达跨场景仍稳定、会改变行为的逻辑。三层各有归属，同一事实只出现一次：

```json
{
  "name": "清楚可辨认的名字",
  "profile": {"text": "身份锚：陌生情境下怎么取舍、不随环境改变的性情、一道让他立体的裂缝。300-500 字，恒常驻"},
  "skills": [
    {"name": "有壁垒的本事", "text": "怎么做到、达到什么效果（写机制不写脚本）。首句 40 字内自己站得住，它是渐进模式的目录钩子"}
  ],
  "memory": {
    "text": "进不了检索键的整体背景，可留空",
    "episodes": [
      {"situation": "他将会遇到的那类处境（这是检索键）",
       "behavior": "当时真做了什么，具名工具与动作",
       "outcome": "留下了什么判断"}
    ]
  },
  "tags": ["稳定检索标签"],
  "status": "active"
}
```

`episodes` 是主力而不是补充：引擎按当前处境对它们打分、只浮现最相关的几条（`_MEMORY_TOPK=6`），`skills` 正文同理（`_SKILL_TOPK=4`）；两者合计超 1200 字即切渐进模式，system 里只留 profile 与技能目录。所以经历写多不费单步预算，写少才是把行为让给「积极的平均人」。6–14 条、一条一事、用处境的词。

Scenario 只描述自然发生的事情。它同时是召回查询——`goal` + `env` 的措辞决定哪些经历会被想起：

```json
{
  "name": "任务名称",
  "kind": "task_completion",
  "goal": {"text": "想得到的结果，以及为什么是现在（有人在等 / 有个期限 / 上一个办法失效了）"},
  "env": {"text": "他手上真带了什么材料、多少时间、已经试过什么、谁在等结果"},
  "closure": {
    "text": "何时结束",
    "success": [{"text": "可观察的成功证据"}],
    "abandon": [{"text": "会自然离开的条件"}],
    "max_turns": 8
  },
  "tags": ["稳定检索标签"],
  "status": "active"
}
```

`kind` 取平台枚举：`task_completion` / `open_exploration` / `social_interaction` / `evaluation_probe`。两类资产的 `status` 同为 `draft` / `active` / `archived`（要被正式引用就用 `active`）。`success` / `abandon` 条目还有可选 `check`（机器可判谓词引用，当前平台留空不用）。`max_turns` 根据任务自然复杂度设置，只是防止无穷执行。Scenario 应允许用户走出你未预想的路径；若它已经暗示按钮、命令、缺陷或答案，就重写。`abandon` 空 = 这个人不会走，那就测不出流失。

定稿前跑 `python3 scripts/check-cast.py <persona.json> --scenario <scenario.json> --target "<被测物名>"`：形状错必修，密度与召回提示按 cast.md 的预算判断。

`case-index.json` 是本地索引，给每个 case 一个稳定 `case_key` 和从 0 开始的 `index`，并明确它使用哪些文件、状态副本、use、runner log、trace 和证据目录。Persona 与 scenario 可以复用，但每个 case 的运行上下文和可变状态必须独立。这个索引不是上送用的 `bundle.json`。

## 3. Methodology

Methodology 是执行与分析合同，不等于评分表。默认不接平台，就以本节给出的本地合同为准（不为了取 schema 去装 CLI）；只有用户要求接平台时才先以 `mirofish methodologies schema` 为权威校正字段。本地执行使用 `review`，三个归属轴（执行 / 分析 / 报告各由谁负责：`execute_by` / `analyse_by` / `report_by`）都为 `caller`——即本技能的调用方，你的本地。

```json
{
  "meta": {
    "kind": "review",
    "surface": "document",
    "domain": "与当前问题相符的领域",
    "goal": "为什么组织这些外部视角",
    "execute_by": "caller",
    "analyse_by": "caller",
    "report_by": "caller",
    "measure": [],
    "report": [],
    "analysis": {
      "questions": ["这次需要回答的问题"],
      "dimensions": ["需要区分的行为或判断差异"],
      "deliverable": "反馈要怎样服务当前工作",
      "notes": ""
    }
  },
  "name": "方法论名称",
  "desc": "目的、边界与被验证版本",
  "world": {
    "situation": "所有 case 都能知道的客观开场信息",
    "environment": {"kind": "isolated"},
    "closure": {"max_steps": 12}
  },
  "cases": [
    {
      "persona_id": "per_...",
      "scenario_id": "scn_...",
      "runtime": {
        "kind": "shell",
        "cwd": "/workspace/session/case-a",
        "uses": [{"use": "use_...", "params": {"account_id": "case-a"}}]
      }
    }
  ],
  "tags": ["review", "local"],
  "status": "active"
}
```

**measure 从被测面的固有维度来，不即兴发挥**：默认按 [surfaces.md](surfaces.md) 该族的维度写 judge 指标，`desc` 就写成能直接照着判的 rubric（eval 默认语义化反馈，`measure` 允许留空——不量化就别硬凑指标）。接了平台时才现取预设：`mirofish surfaces <面>` 给该面的默认指标、证据清单与 case 输入清单，`mirofish new methodology --surface <面> -o mth.json` 产出已预填这些的骨架，改 `world.situation` 和 `cases` 即可；取到预设后窄问题砍指标可以，另造一套同义指标不行 —— 同类评测之间要能比。

`surface` 描述被验证目标，当前支持 `app`、`web`、`agent`、`skill`、`model`、`cli`、`document`、`image`。Runtime 描述本地怎样接触它：browser 使用 `start_url`，shell 使用隔离 `cwd`，mobile 按 schema 声明设备；caller 模式下它是可追溯的入口声明，不会触发云端执行。

Cases 可以引用已落库的 persona/scenario，也可以暂时 inline。inline 的字段名是 `persona` / `scenario`（内嵌完整对象），与 `persona_id` / `scenario_id` 每侧恰取一种形态（都给或都缺会被平台拒绝）。默认不接平台，就一律 inline 完整对象、配稳定的本地 key；接了平台时才优先沉淀并用远端 id 引用（补传的 session 恢复连接后再映射）。`runtime.uses` 只写已存在的合法平台 `UseRef`（`{"use": "use_...", "params": {...}}`，可选 `artifact` 填该 use 声明的资源槽）；尚未落库的本地能力先留在 `uses.local.json`，补传时创建并映射，不能把本地 key 冒充远端 id。

示例是本地最小合同；平台完整结构还有三个可选顶层字段，用到时同样严格按平台 schema：`groups`（分组形态 `{key, interaction: "single"|"multi", situation, cases, relations}`——多人耦合协作用 `multi` 组；`groups` 非空时取代扁平 `cases` 成为单一事实源，扁平 `cases` 是平台的过渡兼容形态）、`inputs`（外部输入契约 `{key, label, desc, type: "number"|"text", unit, value}`，run 时灌值供指标计算与分析用，key 不得与 measure/report 撞名）、`status`（`draft` / `active` / `archived`）。其中 `groups` 的 `multi`（多人耦合协作）形态本地不组装——多人协作仿真只在平台跑，本技能组装的 methodology 一律扁平的单人 `cases`；这段字段说明用于读懂平台已有资产。

`measure` 与 `report` 是平台的输出声明，条目结构必须完全跟平台契约：

- `measure` 条目 = `{key, label, desc, method, unit, range}`。`method="deterministic"` 的 key 只能取平台内生指标全集：`completion_rate`、`avg_steps`、`recommend_rate`、`sentiment_positive`、`sentiment_neutral`、`sentiment_negative`、`grounding_failure_rate`（平台自己从轨迹算，本地不用产值）；`method="judge"` 的 key 自定，`desc` 必填、就是判分 rubric——caller 模式下由主代理按它判分并经 `--measures` 回传；`method="checker"` 由平台执行期 verifier 收割，本地执行用不到。
- `report` 条目 = `{key, label, desc}`，`desc` 是该章节的生成指令。
- 各组内 key 唯一，measure 与 report 之间不得撞 key。

`analysis` 只给主代理。`measure` 默认可以为空；只有比较版本、检查门槛或用户明确需要量化时才声明。三个归属轴的合法组合是链式的：`execute_by="caller"` 要求 `analyse_by="caller"`，后者又要求 `report_by="caller"`（平台校验强制）。任何分析问题、指标或 rubric 都不能进入 case packet。

## 4. Local Use

复用引擎 Use 的接口语义，但把“可移植的能力声明”和“本机怎样执行”明确分开：

- `contract.name`、`contract.description`、`contract.params` 与平台 `UseSpec` 的同名字段保持同义，告诉执行者有什么能力、何时使用、需要什么参数。
- `binding` 是 caller 本机的执行装配，绑定命令、工具或适配器。它不是平台 `UseSpec.run` 的 `FnRef`，可能含本地路径，永不上传。
- 平台已有且具有真实 platform-compatible `impl` 的 use 资产时，Methodology Runtime 用 `{"use":"use_...","params":{...}}` 引用；本地再按 use id 或 name 关联 binding。只有你确实拥有合法平台 `FnRef` 实现时才能新建平台 Use。纯本地 contract/binding 只留在 session，不伪造 `impl`、不上传本地代码，也不把本地 key 写成 `UseRef`。

`uses.local.json` 示例：

```json
{
  "uses": [
    {
      "key": "account_status",
      "contract": {
        "name": "account_status",
        "description": "读取指定测试账号当前套餐、下次扣款与取消状态",
        "params": {
          "account_id": {"type": "string", "description": "case 自己的测试账号"}
        }
      },
      "binding": {
        "kind": "command",
        "argv": ["python3", "adapter.py", "status", "{account_id}"],
        "cwd": "/workspace/session/case-a",
        "timeout_s": 20
      },
      "exposure": {
        "kind": "command",
        "path": "tools/account_status",
        "usage": "tools/account_status --account-id <id>"
      }
    }
  ]
}
```

`binding` 只供主代理装配；`exposure` 是给子代理的 case-local 接口。主代理可生成一个最小命令 wrapper，也可把它映射到宿主原生 tool。Packet 只暴露 contract 与 exposure，不暴露凭据、内部路径或实现源码：

```json
{
  "persona": "persona.json",
  "scenario": "scenario.json",
  "target": "target.json",
  "uses": [
    {
      "name": "account_status",
      "description": "读取指定测试账号的套餐、扣款与取消状态",
      "params": {"account_id": "case-a"},
      "invoke": {"kind": "command", "argv": ["tools/account_status", "--account-id", "case-a"]}
    }
  ]
}
```

Exposure 默认用 command wrapper——任何宿主都成立；仅当宿主真支持把能力注册成原生 tool 时才写 `invoke: {"kind":"native","name":"account_status"}`，原生调用同样要在 runner log 留痕。先由主代理亲自执行安全的 preflight，确认 binding、exposure、参数替换和输出可观察，再把 packet 交给子代理。Trace 的 `do` 记录 exposure 名和实际参数，runner log 记录真实调用。Use 封装稳定能力，不指定用户下一步，也不返回评价答案。若子代理本来就能通过目标的公开入口完成任务，不要为了形式额外造 Use。

Local Use 只能代表 persona 在该环境里真实可用的周边能力，不能成为绕过被验证入口的后门。例如验证“新用户能否运行 CLI”时，不能给一个直接返回 CLI 结果的 Use；验证客服处理退款时，则可以给一个真实映射到测试账户的“查询账单”能力。Contract 的便捷程度必须与现实可用的界面或授权一致。

## 5. Preflight 与隔离

派发前检查并写入 `preflight.json`：

- 测试装置能呈现目标的真实入口，指纹与 `target.json` 一致；不要在 preflight 里预先替用户完成任务；
- case packet、trace 和 evidence 路径可读写；
- Local Use 已在一次性状态副本上执行成功；
- 每个 case 拥有独立 cwd、文件副本、账号、浏览器 profile、设备或应用状态；
- 子代理看不到 analysis、其他 case、历史 feedback、修改方案和无关仓库内容；
- 子代理能调用的工具与 persona 现实能力相容；代理拥有 shell、浏览器或代码能力，不等于 persona 自动会用；
- 目标源码默认只读，除非 scenario 的任务本身就是编辑；
- 上传材料不包含凭据或不必要的个人/项目机密。

彼此没有共享可变状态的 cases 才并行。并行数量按端估：shell 与成品类 4–8 个、browser 2–4 个（各自独立 profile）、mobile 每台真实设备只跑 1 个；仍以宿主资源为限，其余排队——串行不损失信号。cases 超过 3 个且共用同一入口或装置时，先派 1 个探路 case 走完整链路（进入、操作、留证、trace 落盘），验真通过再放其余——探路 case 本身是正式 case，trace 有效就保留；它挡住的是全队齐撞同一个环境问题。无法完全隔离时串行执行，并在每个 case 前恢复到记录过的初始状态。Preflight 是准备动作，不写进用户 trace。夹具、runner、网络代理、Local Use 或隔离环境故障记为 `error`。测试装置正常时，目标自身打不开、启动失败或返回错误是用户真实经历：按实际路径记为 `abandoned`、`timeout`，或在用户仍完成目标时记为 `succeeded`，不能用 `error` 从反馈里抹掉。

最小可见范围优先使用独立工作副本。若宿主无法真正限制文件访问，在 prompt 中给明确白名单，并在完成后审计实际工具调用；这种软隔离要写进结果边界。

## 6. 真实入口

按用户实际会经历的方式验证（按族分的完整打法、人该怎么写、证据怎么真拿到，见 [surfaces.md](surfaces.md)）：

- 网页使用真实浏览器并保存必要截图；只能读取 HTML 时，结论只能覆盖内容检查，不能声称交互体验已通过。
- CLI 在独立 cwd 运行真实命令，保存 stdout、stderr 与退出码。
- 文档按最终交付形态阅读；版式重要时先渲染，而不是只读源文件。
- 图片使用视觉能力查看真实像素，不用文件名或旁边说明代替观察。
- Agent 使用无历史的新会话，保留完整往返。
- Skill 在隔离安装后完成一件真实任务，观察它是否能自主执行。
- App 使用独立设备、账号与初始状态；缺少可用设备时如实记为 execution limitation。

工具不支持目标体验方式时可以降级做更窄的验证，但必须改写结论边界，不能把替代方式冒充真实体验。

记录的是实际入口，不是等价叙事：通过 shell 执行就写命令，通过浏览器点击才写点击，通过文本读取就不能声称看过渲染效果。若 persona 不会使用唯一可用的入口，应让其真实受阻；不能由执行模型替他跨过知识门槛。

## 7. 子代理指令

为每个 case 生成一份最终指令并先保存到 `prompts/<case-key>.md`。提示保持简短：

> 读取本 case packet 中的 persona、scenario、target 和可用能力，从这个人的视角完成 scenario 中的事情。persona 的经历（`memory.episodes`）是你在相应处境下会**自然想起**的东西，不是待办清单——眼前的事让你想起哪条就用哪条，用不上的不必提；`skills` 是你真会的做法，`profile` 是你遇到没经验的事时的取舍倾向。只访问 packet 允许的范围，通过真实入口行动，下一步由你自己判断。不要充当评审，不要补全不存在的内容。把影响行为的简短理由、实际动作、公开反应和真实观察逐步写入指定 trace；每步同时留执行证据：走图形界面时每个实际操作（一次点击/输入/导航）记一条 operates 并截屏存进指定 evidence 目录（相对 evidence/ 根的路径写进该条 shot，步末画面写进 shots），走终端时每条命令记一条 operates（do=字面命令，output=输出关键片段）。办成、自然放弃、预算耗尽或执行环境失败时如实结束。完成后只向主代理返回终态和 trace 路径。

再补一句与宿主工具相符的真实性约束：

> 你的工具能力不会扩大 persona 的知识和权限。每一步写你实际调用的入口与动作；用 shell 就记录真实命令，只有实际操作了图形界面才能写点击。做不到 persona 会做的真实动作时停止并说明限制，不要用别的工具代做后宣称用户成功。

再补一段执行循环合同（要点出自 references/orchestration.md，可按 case 语气改写但不可缺项）：

> 每步先观察再决定，多数步只做一件事。落地一个明确意图时：动作后核对现场是否真的变化，没变化就换方法而不是原样重试，连续几轮毫无进展就停下这个意图、如实记录卡在哪。宣称办成之前，对照 scenario 的成功条件在当前观察里逐条核实——核不过就继续或如实放弃，不凭记忆或意图宣告完成；核实到了就立即收尾，不空转。

Packet 只放这一位用户需要的信息。不要把 Methodology 整包交给子代理。宿主有原生子代理就开干净上下文；没有就启动无会话历史的新进程。模型按活分档：成品类与简单 shell case 用快档；界面类的执行子步（点击—观察循环，token 大头）用快档，规划步可与之同档；复杂视觉、专业判断、长链工具再上强档。换档不换合同——证据与真实性要求不随模型档位放松。

## 8. Trace、Evidence 与 Bundle

每条 trace 使用：

```json
{
  "status": "succeeded",
  "outcome": "最终办成了什么，或为什么停下",
  "steps": [
    {
      "thought": "影响这一步的简短、可公开理由",
      "do": "实际动作；调用 Use 时写名字和关键参数",
      "say": "当时会公开表达的话，可为空",
      "observation": "真实结果及 evidence 引用",
      "operates": [
        {"do": "一次底层操作：GUI 写人话动作，shell 写字面命令",
         "output": "直接结果：stdout/stderr 或界面反应（≤4000 字符，摘要化）",
         "ok": true,
         "shot": "<case-key>/03-1.png"}
      ],
      "shots": ["<case-key>/03.png"]
    }
  ]
}
```

这是闭合合同：每个 step 只有 `thought`、`do`、`say`、`observation` 四个字符串字段（平台侧各项可选、但一步至少一项非空——只想不动的步就只填 `thought`），外加两个**可选执行证据字段**——`operates`（本步实际底层操作序列，≤50 条/步）与 `shots`（本步观察级截图，≤10 张/步）。调用能力时把能力名、真实参数和结果分别写入 `do`/`observation`，不能自创 `capability`、`result` 等替代字段，也不能用文件引用代替 steps。额外的 runner、audit、哈希和证据索引写进 `runner-logs/`、`manifest.json` 或 `verification.json`，不塞入原始 trace。

执行证据按端记录，是平台展示逐步截图与命令输出的唯一来源：

- **GUI（browser / mobile）**：每个实际底层操作（一次点击、一次输入、一次导航）记一条 operate，操作后截屏存 evidence 并把文件名写进该条 `shot`；步末看到的画面存 `shots`。截图统一放 session 的 `evidence/` 下（每 case 一个子目录），trace 里写**相对 `evidence/` 根的路径**——本地 `mirasim eval` 页面据此逐步渲染；接了平台上送时，`mirofish runs ingest --evidence <session>/evidence` 会按同一批路径自动上传并换成平台 ref。
- **CLI（shell）**：每条真实命令记一条 operate，`do` 写字面命令，`output` 放 stdout/stderr 的关键片段（≤4000 字符，别整屏贴——完整输出留在 `runner-logs/`），`ok` 按退出码。
- `ok=false` 忠实记录。注意平台口径：abandoned/timeout 的 case 若 operates 大面积失败或收束理由指向「点不中/打不进」，会按接地失败（grounding）从产品分摘出——所以你自己的执行环境故障要记 `status=error`，不能写成用户放弃。

状态只用 `succeeded`、`abandoned`、`timeout`、`error`。前三者描述用户路径；`error` 只描述测试夹具、runner、代理、网络代理或 Use 的执行故障。已验证环境中目标入口自身的失败仍是用户路径。主代理可以修正契约外状态和漏字段，但不能润色行为与结局。

主代理接受 trace 前必须按宿主可见性验真。能取得工具日志时，逐项对照实际调用、stdout/stderr、截图或会话事件；只能取得独立输出、截图或退出码时，用这些证据核验并收窄结论；没有任何独立证据时，不得声称“真实使用已通过”。入口、动作、观察、状态不一致的 case 作废，保留原始材料和原因；环境能改善时才用干净上下文重跑，不能在同一不可观测条件下无限重试。无效 trace 不进入用户反馈，也不作为 Loop 已改善的证据。

截图、命令输出、会话记录或渲染文件放进该 case 的 evidence 目录，并在 observation 中引用。不要把整页源码或大段日志塞进 observation；保留足以复核结论的原始证据文件。

`bundle.json` 是上送请求体，cases 与 Methodology flat cases 严格同序同长。上送合同目前以顺序关联 case，不接收本地 `case_key`；生成 bundle 时按 `case-index.json` 显式排序，并在本地 case 条目保留 `index` 供 CLI 静态校验（服务端只消费合同字段）：

```json
{
  "cases": [
    {
      "index": 0,
      "status": "succeeded",
      "outcome": "最终落点",
      "steps": [
        {"thought": "简短理由", "do": "真实动作", "say": "公开反应", "observation": "真实结果",
         "operates": [{"do": "底层操作", "output": "直接结果", "ok": true, "shot": "case-a/03-1.png"}],
         "shots": ["case-a/03.png"]}
      ]
    }
  ],
  "runner": {"agent": "实际宿主", "model": "实际模型"}
}
```

Bundle 必须内联每个 case 的 `status`、`outcome` 和完整 `steps`（含 operates/shots 执行证据）；不能把 trace 路径、instruction 路径、证据哈希或按 case 分组的 runner 日志放进来。顶层 `runner` 只写实际宿主与模型，例如 `{"agent":"codex","model":"gpt-5.6-terra"}`；可选顶层 `started_at` / `finished_at`（ISO 时间，本地仿真起止，平台据此算执行墙钟）。想保留路径和校验和就写 `manifest.json`。

没跑成的 case 用 `error` 占位，不能删掉。平台校验规则要提前满足：只有 `error` 允许零步，其余终态每 case 至少一条 step；`succeeded` / `abandoned` 必须写非空 `outcome`；单 case 步数上限 200，且不超过对应 scenario/Methodology 的预算。默认没有 CLI 可用，这些规则连同数量、index 顺序、截图文件存在与大小自己逐条核过；接平台上送前再运行 `mirofish runs ingest --check -f bundle.json --index case-index.json --evidence <session>/evidence` 复核（`--evidence` 顺带静态校验截图文件存在、类型与大小），且不能把“bundle 未带 index”的 warning 当成顺序已证明。Bundle 不放 token、费用、usage、隐藏推理、Local Use binding 或无关源码。

Evidence 目录是本地证据源，默认也是唯一证据位置；**接了平台时截图随 ingest 上送**：bundle 里 `shots`/`operates[].shot` 写相对 `evidence/` 根的路径，`--evidence` 让 CLI 自动上传并替换成平台 ref，平台评测记录页据此逐步渲染画面。上传机制的权威细节（允许格式与大小、脱敏与打码检查、什么不上传）以 cli.md §4 为单一真源；此处只立两条行为边界：录像与其他附件不随 ingest 上传、不要声称平台保存了截图之外的 evidence 文件。

## 9. Feedback 与 Loop 证据

`feedback.md` 的第一节固定是 `## TL;DR`，随后是：直接回答、外部行为证据、对当前工作的含义、**产品新需求清单**、未决事项和验证边界。每个重要判断回指 case/step/evidence，并标注它是直接观察、合理推断还是尚未验证。

TL;DR 三到五条，每条一句话、先结论后依据出处，覆盖最该被看见的判断、最疼的受阻点和最高优先级需求；不写背景铺垫、不复述方法、不放没有结论的数字。查看服务的 run 列表取 `feedback.md` 第一行非标题文本作为该 run 的结论摘要，因此 TL;DR 第一条就是这条 run 在列表页的门面。

需求清单里每条是一个产品层诉求，固定四件套：

```markdown
- **需求**：<哪类用户>在<什么处境>需要<得到什么结果>。
  **证据**：case/step/evidence 回指 + 一句实际发生了什么。
  **不满足的后果**：这条不成立时用户会怎样（放弃/绕路/误解/回到旧工具）。
  **优先级**：高/中/低 + 一句依据（关键路径？多视角共现？）。
```

需求陈述用户要的结果，由目标 owner 决定实现。例：观察到新手找不到 API key 配置时，需求写「首次使用者需要不查外部资料就能完成 API key 配置并跑通第一条命令」，而不是「README 加一节配置说明」——后者是实现方案，只有它本身就是被验证物（如文档评测）或用户已授权 Loop 修改时才出现在反馈里，且另起一段与需求分开。

优先级综合用户目标、失败后果、证据强度和覆盖范围。一个关键用户在关键路径上的失败，可能比多个低影响摩擦更重要；成功路径同样要保留，避免修改时把已有价值破坏掉。

Loop 时：

0. **创作类首轮多方案盲测**：被测物是主代理自己生成的创作物（图、文档、文案）且用户已授权多轮时，首轮就按 A/B 的姿势跑——两三个结构前提不同的候选（各自一句话写明前提），同批 case 盲测对跑，目录直接用下方 `rounds/r1/<候选名>/` 的双候选结构；先让证据选结构，再进入打磨轮。单一候选进场的首轮，等于把结构问题延后到否决项发作才处理。给子代理的文件名保持中性，不泄露哪版是「原版」或实验设置。
1. **先判该补还是该另起**（判据见 SKILL.md「需要 Loop 时」）。结论一句话写进本轮 `feedback.md`：判补丁就写清受阻点为什么是局部的；判另起就写清要换掉的是哪条前提。这一句缺失视为没判过。**判之前先做换手检查**（假装目标不是自己做的重判一次，或让只读证据的子代理出建议），换手结论与反驳一并落档。
2. 根据反馈修改已获授权的目标，保存 diff 与新指纹。
3. 为新版本创建新一轮目录和新 bundle。
4. 使用全新子代理复验受影响路径；不要把上轮 feedback 给它。「受影响」的默认选法：每条已修需求 ≥1 个受影响 case，再加 ≥1 个没看过修改过程的新视角 case；未受影响的 case 不重跑。**「新视角」指新的人**——同一个 persona 换一个全新子代理实例只是干净复验，不产生新的覆盖面。固定阵容跑上几轮之后，边际信息基本只能靠换人拿到。
5. 用行为描述变化：原先在哪停下，现在是否走过；不要只报主观分数。
6. 若要作广泛结论，加入未参与修改过程的新视角。
7. 达成用户目标、边际信息耗尽或出现必须由用户决定的取舍时停止。默认收敛闸：连续两轮没有新增的高优先级需求、且上轮已修需求都拿到了新行为证据，就收口并写 `converged: true`；不满足这个闸而要提前停，写明这是谁的决定、为什么。

   **两条否决项，命中任一则这一轮不计入上面的「连续两轮」**：

   - **这轮只做了微雕**：改动清单全是加一块、挪个位置、改字号、调文案。这种轮次没有检验过任何前提，「无新增高优需求」只说明没人被这几处小改绊倒，不说明目标够好了。
   - **这批人已经任务饱和**：几个人连着两轮都顺利办成事，剩下的受阻点只剩「这是他的个人习惯」和「这属于目标之外的事」。枯竭的是这批视角能给的信息，不是目标的问题。要么换一个用途不同的人进来，要么如实写「在这批视角下已饱和」——**别把局部饱和写成 converged**。

   **反复出现、却每轮都被归成「他的习惯」的行为，是最高优信号而不是噪声。** 同一个人每轮都要自己先返工一遍才用得上它，说明这东西交到他手上时就不够用；把它记成他的个人偏好、或挪出目标范围之外（「那得另做一个东西」），等于把最贵的证据洗掉——而这期间别的维度会照常上涨，因为他毕竟返工完就把事办成了。

判了另起，本轮出两个候选：现结构上改的补丁版，和换掉前提的另起版。**另起版隔离生成**：由没见过任何现版本的全新子代理从零做——只给素材事实清单、需求清单与前提陈述，不给旧图旧稿，主代理只核对事实。case 里已出现的具体替代结构描述（「分成几页」「换成什么主轴」）**必须实现为候选之一**——它是证据指定的结构，不占用「换皮不算另起」的判定。同一批 case、同一口径、各自全新子代理各跑一遍，两份结果并列存：

```
rounds/rN/
  patch/    traces/  measures.json     # 现结构上改
  rebuild/  traces/  measures.json     # 换掉前提
  ab.md                                # 口径一致性声明 + 采用哪版 + 依据
```

`ab.md` 写明两版事实基础差在哪：理想是零差异；有差异就说清，并在结论里承认这部分优势不归结构。落选版本连 trace 一起留着不删——下一轮判「上次另起已经输过」要用它。判决与依据必须落进本地留档（`ab.md` + 本轮 feedback），不能只活在对话里；接了平台时的回写姿势见 cli.md §6：采用版作为本轮 run 上送，落选版 trace 留在本地轮目录，判决经 `--data` 的 `evol.pivot` 进谱系。

## 10. 收尾检查

- 用户授权与实际修改范围一致；单轮任务没有改目标。
- Persona 数量有行为差异依据，没有固定配额或重复角色。
- 每个 persona 的经历写到了可召回的密度（`check-cast.py` 无形状错、召回预览里有经历真的浮现）；人和事里没有对被测物的评价。
- 所有 prompts 已保存，packet 无 analysis/其他 case/feedback 泄漏。
- Preflight 与用户行为分开，case 状态和可变数据已隔离。
- Trace 状态、字段、顺序与 evidence 可复核；runner log 或降级证据边界已保存；bundle 可解析且同序同长。
- Trace 中的入口和动作与实际工具记录一致；无效执行已隔离，没有被当作用户成功。
- Feedback 回答原问题，区分事实、解释、未知和执行限制；改进建议以「需求四件套」呈现且与实现方案分离。
- `feedback.md` 开篇有 TL;DR（三到五条、每条一句话、条条带结论），第一条就是这轮最该被看见的判断。
- 本地跑（未接平台）且 `MIRASIM_EVAL_VIEWER` 存在时，交付里给了这次 run 的深链 `<MIRASIM_EVAL_VIEWER>run/<slug>`；不存在时给了 session 目录绝对路径与 `mirasim eval`。
- 子代理指令含执行循环合同；trace 每 step 是一个规划决策，底层操作按 `operates`/`shots` 记进该步，完整输出在 runner-logs。
- 项目能力盘点已做（目标在项目仓库里时）；注入 case 的 use 全部指向运行中的产品能力（不绑仓库脚本或源码）且过了 persona 现实性判断；子代理可见范围只有运行产物、无源码；引入的外部 skill 有装前审查与 session 留痕。
- Loop 保存了前后版本、diff 与干净复验；没有假成功。
- 创作类多轮：首轮做了多方案盲测，或写明了为何单方案进场；case 给出的具体替代结构已实现为对跑候选，而不是只进了需求清单；另起版出自没见过现版本的子代理；补/另起的判定有换手检查落档。
- Session 记录真实 runner、模型、时间、哈希和上传状态，不包含用量与秘密。
