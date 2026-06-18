---
name: figma2code
description: Figma 原型到前端代码的完整转换工作流。覆盖：Figma 数据完整提取（REST API + MCP）、Frame 结构分析与分类、无原型链接时的交互规格重建、逐帧代码生成（三种方式）、嵌入现有 HTML 项目、验收与问题排查。触发词：按 Figma 实现、Figma 转代码、原型转前端、设计稿转代码、根据设计稿实现、对照 Figma 写页面、从 Figma 链接生成 HTML。
disable-model-invocation: true
---
# Figma → 前端代码 完整工作流

> 适用任何项目；本项目（Agent Platform）的完整技术规范见 `.claude/plans/` 下的 figma2code 方案文档。

---

## 0. 触发条件与前置检查

**触发**：收到 Figma URL / fileKey / PAT token，需要生成 HTML 页面。

**前置检查清单（必须全部满足）**：

| 项目 | 检查方式 |
|------|---------|
| Figma PAT（Personal Access Token） | 环境变量 `FIGMA_API_KEY`（Windows 用户级，不入仓） |
| 文件 Key | 从 URL 提取：`figma.com/design/<FILE_KEY>/...` |
| Node.js ≥ 18 | `node --version` |
| 本地服务（视觉对比用） | `python -m http.server 8766`（在 prototype/ 目录） |
| 三端 MCP 已同步 | `powershell scripts/sync-figma-mcp.ps1` + `verify-figma-mcp.ps1` |
| Figma Desktop MCP（可选） | 仅付费 Dev Seat；Starter 用 PAT REST 代替 |

**三端 MCP**（`scripts/sync-figma-mcp.ps1` 写入 Cursor / Codex / Claude）：
```json
{
  "figma": { "url": "https://mcp.figma.com/mcp" },
  "figma-desktop": { "url": "http://127.0.0.1:3845/mcp" }
}
```
> **Starter 策略**：批量读用 PAT REST；单帧精修用 Remote MCP 读（≤6 次/月）；写 Figma 用 Remote MCP 写工具（免限额）。

---

## Phase 1：完整提取 Figma 数据

### 1.1 必须提取的五类数据

```powershell
$token = "YOUR_PAT"
$key   = "YOUR_FILE_KEY"
$hdr   = @{ "X-Figma-Token" = $token }
$base  = "https://api.figma.com/v1"
$out   = "design/figma-extract"
New-Item -ItemType Directory -Force $out | Out-Null

# 1. 文件树（Frame 清单）—— depth=3 拿到 Page→Frame→一级子节点
Invoke-RestMethod "$base/files/$key`?depth=3" -Headers $hdr |
  ConvertTo-Json -Depth 8 | Out-File "$out/01-file-tree.json" -Encoding utf8

# 2. 完整节点+交互（按 Page 分批，推荐）
# 先从 01-file-tree.json 拿 pageId，再按页提取：
Invoke-RestMethod "$base/files/$key/nodes?ids=<pageId>&geometry=paths" -Headers $hdr |
  ConvertTo-Json -Depth 20 | Out-File "$out/02-page-nodes.json" -Encoding utf8
# 若文件小（<50MB）可整文件一次提取：
# Invoke-RestMethod "$base/files/$key`?geometry=paths" ...

# 3. 组件库
Invoke-RestMethod "$base/files/$key/components" -Headers $hdr |
  ConvertTo-Json -Depth 6 | Out-File "$out/03-components.json" -Encoding utf8

# 4. 样式库
Invoke-RestMethod "$base/files/$key/styles" -Headers $hdr |
  ConvertTo-Json -Depth 6 | Out-File "$out/04-styles.json" -Encoding utf8

# 5. 设计变量（Token）
Invoke-RestMethod "$base/files/$key/variables/local" -Headers $hdr |
  ConvertTo-Json -Depth 6 | Out-File "$out/05-variables.json" -Encoding utf8
```

**`geometry=paths` 参数的作用**：让节点携带 `fillGeometry`、`strokeGeometry`、`interactions` 字段。
**`interactions` 字段**：数组，包含原型跳转声明；空数组 = 设计稿未配置跳转。

### 1.2 速率限制（429）处理

收到 429 → 等待 60s → 重试（最多 3 次）→ 三次均失败则改为按 Page 分批提取。
已提取的文件不重复请求（检查文件是否存在再发请求）。

### 1.3 PowerShell 5.1 BOM 坑

`-Encoding utf8` 在 PowerShell 5.1 会写入 UTF-8 **with BOM**，Node.js 解析会报错。
Node.js 读取时必须剥离：
```javascript
function stripBOM(t) { return t.charCodeAt(0) === 0xFEFF ? t.slice(1) : t; }
const data = JSON.parse(stripBOM(fs.readFileSync(file, 'utf8')));
```

### 1.4 图片/图标资产导出

```powershell
# 收集 IMAGE fill 节点 ID（Node.js 脚本输出），再批量导出 SVG
$ids = "node1,node2,..."
$resp = Invoke-RestMethod "https://api.figma.com/v1/images/$key`?ids=$ids&format=svg" -Headers $hdr
$resp.images.PSObject.Properties | ForEach-Object {
  $nodeId = $_.Name.Replace(':', '-')
  Invoke-WebRequest $_.Value -OutFile "prototype/assets/icons/$nodeId.svg"
}
```

---

## Phase 2：结构分析

### 2.1 Frame 清单提取

```javascript
// design/scripts/analyze-frames.js
const tree = JSON.parse(stripBOM(fs.readFileSync('design/figma-extract/01-file-tree.json', 'utf8')));
const frames = [];
for (const page of tree.document.children) {
  for (const node of (page.children || [])) {
    if (!['FRAME','COMPONENT','GROUP'].includes(node.type)) continue;
    const bb = node.absoluteBoundingBox || {};
    frames.push({
      pageId: page.id, pageName: page.name,
      frameId: node.id, frameName: node.name, type: node.type,
      width: Math.round(bb.width || 0), height: Math.round(bb.height || 0),
    });
  }
}
fs.writeFileSync('design/figma-frame-list.json', JSON.stringify(frames, null, 2), 'utf8');
```

### 2.2 Frame 分类规则

| 类型 | 判断条件 | HTML 实现方式 |
|------|---------|-------------|
| **fullpage** | 宽 ≥ 1200 且 高 ≥ 800 | 独立 `.html` 文件，含完整 topbar+sidebar+main |
| **modal** | 宽 < 1000 且 高 < 700；或名含"弹窗/确认/处理/删除/申请" | `.modal-overlay.hidden` 内嵌父页面 |
| **drawer** | 宽 ≤ 700 且 高 ≥ 800；或名含"消息/抽屉/侧边/通知" | `.drawer-overlay` 右侧滑入 |
| **tab-content** | 同模块多帧名称相似（"-默认"/"-进行中"/"-Tab A"） | 同一 HTML 页内 Tab 切换 |
| **tooltip/menu** | 宽 < 300 且 高 < 300；或名含"操作/菜单/Tooltip" | 绝对定位 CSS 浮层 |

### 2.3 Gap 分析（Frame vs 现有 HTML）

将 Frame 清单与 `EXISTING_HTML` 做关键词匹配，输出三类：
- ✅ **已覆盖**：Frame 已有对应 HTML
- ⚠️ **部分覆盖**：Frame 对应已有页面但有内容缺失（如弹窗只在 JS 里）
- ❌ **缺失**：需新建 HTML 文件或新增 JS 弹窗

将结果保存为 `design/figma-gap-report.json`，作为 Phase 4 代码生成的优先级依据。

### 2.4 单帧 JSON 提取（转换阶段用）

节点数据文件可能达 100MB+，每次只提取需要的单帧：
```javascript
// node design/scripts/extract-frame.js "243:272"
const raw   = fs.readFileSync('design/figma-extract/02-page-nodes.json', 'utf8');
const data  = JSON.parse(stripBOM(raw));
const page  = Object.values(data.nodes)[0].document;
const frame = page.children.find(f => f.id === process.argv[2]);
fs.mkdirSync('design/figma-extract/frames', { recursive: true });
fs.writeFileSync(`design/figma-extract/frames/${process.argv[2].replace(':','-')}.json`,
                  JSON.stringify(frame, null, 2), 'utf8');
```
输出小文件（< 1MB），供代码生成时读取。

---

## Phase 3：交互规格重建

> **关键**：很多 Figma 设计稿的 `interactions[]` 全为空数组——设计师只交付了视觉稿，没有配置原型跳转。
> 此时**不能**自动提取交互，必须手工重建。

### 3.1 先检查交互是否存在

```javascript
let found = 0;
function walk(node) {
  if ((node.interactions || []).length > 0) { found++; console.log(node.id, node.name); }
  (node.children || []).forEach(walk);
}
// 递归所有节点，found === 0 → 需要手工重建
```

### 3.2 手工重建 — Frame 命名规律推断

本项目（及大多数企业设计稿）Frame 命名遵循 `模块-子视图[-状态/角色]` 格式：

| 命名规律 | 推断交互类型 | HTML 实现 |
|---------|------------|----------|
| `A` → `A-B` | 点击进入详情（navigate） | `<a href="B.html">` |
| `A-指定X` / `A-处理X` | 动作触发覆层（overlay） | `modal.classList.remove('hidden')` |
| 同前缀多帧（"-默认"/"-进行中"） | Tab/状态切换（tab-switch） | `data-tab` 切换 |
| 帧尺寸 < 300×300 | 操作菜单/悬浮提示（menu/tooltip） | 绝对定位浮层 |
| 含"查看/编辑/新增/删除" | CRUD 操作进入子页（navigate/overlay） | 按操作类型判断 |
| 含"（角色）弹窗名" | 同一弹窗的角色状态变体 | 条件渲染同一 modal |

### 3.3 interaction-spec.json 规范

手工定义的交互规格，**是整个转换阶段的导航实现依据**：

```json
{
  "$version": "1.0",
  "modules": {
    "module-name": {
      "description": "模块说明",
      "htmlEntry": "11-xxx.html",
      "flows": [
        {
          "id": "M-01",
          "from": { "file": "11-xxx.html", "element": "表格行查看按钮" },
          "trigger": "click",
          "to": { "file": "11-xxx-detail.html", "params": ["id"] },
          "navType": "navigate",
          "htmlImpl": "<a href=\"detail.html?id=${id}\">查看</a>",
          "figmaFrameRef": "243:xxxx"
        },
        {
          "id": "M-02",
          "from": { "file": "11-xxx-detail.html", "element": "处理按钮" },
          "trigger": "click",
          "to": { "modalId": "processModal" },
          "navType": "overlay",
          "htmlImpl": "document.getElementById('processModal').classList.remove('hidden')",
          "figmaFrameRef": "243:yyyy"
        }
      ]
    }
  }
}
```

与 PRD 文档交叉验证，确认每条 flow 在业务上合理后再进入代码生成。

---

## Phase 4：代码生成

### 4.1 方式选择树

```
Figma Desktop 运行中 且 127.0.0.1:3845 可访问？
  ├─ 是 → 方式 1：Desktop MCP（精度最高）
  └─ 否
     ├─ REST API JSON 已提取 → 方式 2：节点 JSON（精度高）
     └─ 均不可用 → 方式 3：截图 + Claude Vision（兜底）
```

### 4.2 方式 1：Figma Desktop MCP

```
1. Figma Desktop 中选中目标 Frame
2. Claude Code 调用 MCP：get_figma_data({ nodeId: "243:272" })
   → 返回：布局参数、颜色值、字体规格、组件实例名
3. 结合 interaction-spec.json 中该帧的 flows
4. 给 Claude 的标准指令：

"请按以下设计上下文生成 [frameName] 对应的 HTML 页面。
 [粘贴 MCP 返回的设计数据]
 [粘贴 interaction-spec.json 该帧的 flows]

 约束：
 1. 只用 prototype/assets/style.css 中已有 CSS class，禁止内联 style 和新建 CSS 文件
 2. 引入 proto.js，调用 Proto.initTopbar('ops')
 3. 所有内部链接用 Proto.href() 生成
 4. 弹窗用 .modal-overlay.hidden 模式（参考 04-create-modal.html）
 5. 骨架参考 index.html（topbar + sidebar + main 三层）"
```

### 4.3 方式 2：节点 JSON → Claude

```
1. node design/scripts/extract-frame.js "243:272"
   → 生成 design/figma-extract/frames/243-272.json（< 1MB）
2. Claude 读取单帧 JSON，分析：
   - layoutMode（AutoLayout 方向 / 绝对定位）
   - TEXT 节点内容（确定 label / placeholder / title）
   - INSTANCE 节点名称（映射到已有 HTML 组件 class）
   - fills / cornerRadius / effects（颜色/圆角/阴影）
3. 结合 interaction-spec.json 生成 HTML
```

### 4.4 Figma 节点属性 → HTML/CSS 映射（核心参考）

**布局**

| Figma | CSS |
|-------|-----|
| `layoutMode: HORIZONTAL` | `display:flex; flex-direction:row` |
| `layoutMode: VERTICAL` | `display:flex; flex-direction:column` |
| 无 layoutMode | `position:relative`（父）+ `position:absolute; left:Xpx; top:Ypx`（子）|
| `primaryAxisAlignItems: SPACE_BETWEEN` | `justify-content:space-between` |
| `counterAxisAlignItems: CENTER` | `align-items:center` |
| `itemSpacing: N` | `gap:Npx` |
| `paddingLeft/Right/Top/Bottom` | `padding:T R B L` |
| `clipsContent: true` | `overflow:hidden` |
| `layoutSizingHorizontal: FILL` | `flex:1` |

**视觉**

| Figma | CSS |
|-------|-----|
| `fills[{type:SOLID, color:{r,g,b,a}}]` | `background:rgba(r*255, g*255, b*255, a)` |
| `fills[{type:GRADIENT_LINEAR}]` | `background:linear-gradient(...)` |
| `strokes` | `border:Npx solid rgba(...)` |
| `cornerRadius: N` | `border-radius:Npx` |
| `effects[DROP_SHADOW]` | `box-shadow:X Y blur spread rgba(...)` |
| `effects[BACKGROUND_BLUR]` | `backdrop-filter:blur(Npx)` |
| `opacity: N` | `opacity:N` |

**文字（TEXT 节点）**

| Figma style 字段 | CSS |
|----------------|-----|
| `fontSize` | `font-size:Npx` |
| `fontWeight` | `font-weight:N` |
| `lineHeightPx` | `line-height:Npx` |
| `letterSpacing` | `letter-spacing:Nem` |
| `textAlignHorizontal` | `text-align:left/center/right` |

**已有 CSS 变量优先**（不硬编码颜色值）：
```
#003da6 → var(--primary)        #171c1f → var(--text-primary)
#434654 → var(--text-secondary) #6b7280 → var(--text-muted)
#2f9e44 → var(--success)        #f08c00 → var(--warning)
#e03131 → var(--danger)         #f5f7fa → var(--bg-page)
#ffffff → var(--bg-white)       #e8ecf1 → var(--border)
```

**组件实例映射**（INSTANCE 节点名 → HTML class）：

| Figma 组件名 | HTML |
|------------|------|
| Primary Button | `<button class="btn btn-primary">` |
| Secondary Button | `<button class="btn">` |
| Danger Button | `<button class="btn btn-danger">` |
| Status Tag | `<span class="tag tag-{status}">` |
| Source Badge | `<span class="source-badge source-{type}">` |
| Input / Textarea | `<input class="input">` |
| Select | `<select class="select">` |

**交互类型 → JS/HTML 实现**：

| navType | 实现 |
|---------|------|
| `navigate` | `<a href="Proto.href('page.html', params)">` |
| `overlay`（modal） | `document.getElementById('modal').classList.remove('hidden')` |
| `overlay`（drawer） | `document.getElementById('drawer').classList.add('drawer-open')` |
| `tab-switch` | `data-tab` 属性切换 + 对应面板 show/hide |
| `back` | `history.back()` 或固定 `<a href="parent.html">` |
| `close-modal` | `modal.classList.add('hidden')` |

---

## Phase 5：嵌入现有项目

### 5.1 文件命名规范

接续现有编号（01~10 已用），新模块用 11+ 并以模块语义命名：
```
11-user-feedback.html / 11-user-feedback-detail.html
12-expert-workbench.html / 12-expert-task-detail.html
13-permission-mgmt.html / 13-permission-add.html / 13-org-structure.html
assets/ops-user-feedback.js / ops-expert.js / ops-permission.js / ops-message.js
```

### 5.2 每个新 HTML 页面的必须结构

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>页面标题 - 敖钦 AI</title>
  <link rel="stylesheet" href="assets/style.css"><!-- 唯一 CSS，禁止新建 CSS 文件 -->
</head>
<body>
<header class="topbar" id="topbar"></header>
<div class="app-frame">
  <div class="layout">
    <aside class="sidebar" id="sidebar"></aside>
    <main class="main" id="mainContent">
      <div class="page-header">
        <div class="page-header-left">
          <h1 class="page-title">模块名称</h1>
        </div>
        <div class="page-header-right">
          <button class="btn btn-primary">＋ 主操作</button>
        </div>
      </div>
      <!-- 内容区域 -->
    </main>
  </div>
</div>
<!-- 弹窗（初始 hidden，按需） -->
<div class="modal-overlay hidden" id="someModal" role="dialog">
  <div class="modal-box">
    <div class="modal-header"><h2>标题</h2><button class="icon-btn" data-close="someModal">✕</button></div>
    <div class="modal-body"></div>
    <div class="modal-footer">
      <button class="btn" data-close="someModal">取消</button>
      <button class="btn btn-primary" id="confirmBtn">确认</button>
    </div>
  </div>
</div>
<!-- 脚本：proto.js 必须第一个 -->
<script src="assets/proto.js"></script>
<script src="assets/ops-<module>.js"></script>
<script>
  Proto.initTopbar('ops');
  Proto.setActiveSidebarLink('11-xxx.html');
</script>
</body>
</html>
```

### 5.3 关键规范

| 规范 | 说明 |
|------|------|
| **内部链接** | 必须用 `Proto.href('page.html', params)`，禁止硬编码 URL |
| **侧边栏接入** | grep proto.js 定位侧边栏配置数组，追加新模块项 |
| **sessionStorage 键** | 前缀 `proto_<module>_*`，避免与现有 `proto_agent_*` 冲突 |
| **JS 模块** | IIFE 包裹；Demo 数据用 `DEMO_` 前缀；不在 JS 里拼接 URL |
| **CSS 禁止新建** | 所有样式来自 `assets/style.css`；需要新样式先检查变量表 |

### 5.4 验收脚本更新（每批新页面必须做）

1. `prototype/scripts/package-check.js` → 在 `EXPECTED_FILES` 数组追加新文件名
2. `prototype/scripts/smoke-check.js` → 追加新页面的关键 DOM ID 或 class 检查
3. `.github/agent/memory/decisions-log.md` → 新建 ADR 登记模块边界决策

---

## Phase 6：验收

### 6.1 自动验收（全部 PASS 才能声明完成）

```bash
node prototype/scripts/verify-all.js
```
覆盖 6 步：package-check / smoke / e2e / regression / browser-check / navigation-journey

### 6.2 视觉对比

```bash
cd prototype && python -m http.server 8766
# 浏览器：http://127.0.0.1:8766/新页面.html?figma=1
# 与 Figma 对应 Frame 并排比对
```

检查项：间距 / 颜色 / 字号 / 圆角 / 阴影 / 按钮位置 / 表格列宽 / 状态标签颜色

### 6.3 交互路径验收

对照 `design/interaction-spec.json`，逐条执行 trigger → 确认 target 正确 → 标记 `verified:true`。

---

## 问题排查快速索引

| 症状 | 原因 | 解决方案 |
|------|------|---------|
| `403 Forbidden` | PAT 无效或无权限 | 重新生成 PAT，勾选 File content: Read |
| `429 Too Many Requests` | 速率限制 | 等 60s 重试；改用 `/nodes?ids=pageId` 按页提取 |
| `Unexpected token '﻿'`（BOM） | PowerShell utf8 编码带 BOM | Node.js 读取前调用 `stripBOM()` |
| `interactions[]` 全空 | 设计稿未配置原型跳转 | 用 Phase 3 方法手工重建 interaction-spec.json |
| 响应超时 / 文件 > 100MB | 整文件过大 | 改用 `/nodes?ids=pageId&geometry=paths` |
| `Proto is not defined` | 脚本引入顺序错误 | `proto.js` 必须是第一个 `<script>` |
| verify-all FAIL（页面缺失） | package-check.js 未更新 | 在 `EXPECTED_FILES` 追加新文件名 |
| 布局整体偏移 | 绝对定位帧误用了 flexbox | 检查 `layoutMode`，为空则用 `position:absolute` |
| 颜色值不匹配 | Figma 颜色 0~1 范围，CSS 需 0~255 | `Math.round(component * 255)` 换算 |
| Figma MCP 速率超出 | 云端 Starter 约 6 次/月 | 切换到 Figma Desktop MCP（127.0.0.1:3845）|
| Node.js 内存溢出 | 大 JSON 超过默认内存 | `node --max-old-space-size=4096 script.js` |

---

## 本项目特定配置（Agent Platform）

```
fileKey:     gDc0xlVkOeJdgrQOZMy3wh
Pages:       运营平台(241:250) / 智能体运营(0:1) / Skills配置(46:312)
待转换:      38 帧（运营平台 Page，6 个新模块，17 全页 + 21 弹窗/抽屉）
设计系统:    prototype/assets/style.css + proto.js
验收门:      prototype/scripts/verify-all.js（6 步，必须全 PASS）
分析产出:    design/figma-frame-list.json / figma-gap-report.json / figma-frame-details.json
交互规格:    design/interaction-spec.json（待手工补充，Phase 3 产出）
单帧提取:    node design/scripts/extract-frame.js "<frameId>"
```
