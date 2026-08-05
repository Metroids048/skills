# 海小南 Demo 第二轮优化 — 执行规划

## Context（背景）

上一轮完成了 5 个基础模块（删 V1 死代码、CSS 动画接管 PixiJS、流式追问、补全 scriptSteps、更新话术文档）。用户提出 4 个新问题：

1. 鼠标悬浮/拖拽数字人时手眼肢体动作丢失（PixiJS 移除后遗症）
2. 语音应像 Siri：页面加载自动请求麦克风 + 常驻被动监听 + 唤起词激活 + 指令仅在 P1 区域显示（不进文本框）
3. 无匹配场景不能弹 toast "暂未匹配到预设场景"（暴露脚本化本质），应改为自然引导
4. 整体语音交互体验需要更完整地模拟真实智能体调度流程

关键文件：`C:/Users/win/Desktop/海小南/hai-xiaonan-demo.html`（约 4970 行）

---

## 已探明的关键代码位置

| 功能 | 函数/元素 | 行号（近似） |
| --- | --- | --- |
| 页面初始化 | `initV2Demo()` | ~5005 |
| 数字人交互绑定 | `bindDigitalHumanV2()` | ~4812 |
| 鼠标移动处理 | `mousemove` handler in `bindDigitalHumanV2` | ~4852 |
| 拖拽倾斜 | `moveDrag()`, `--drag-tilt` CSS 变量 | ~4897 |
| 眼睛元素 | `.pet-eye-left`, `.pet-eye-right` in `.pet-face-overlay` | ~2640 |
| 语音识别 | `createRecognitionV2()`, `toggleVoiceV2()` | ~4658, 4704 |
| 被动监听状态 | `stateV2.standbyEnabled` | ~3115 |
| 麦克风权限 | `ensureVoicePermissionV2()` | ~4647 |
| 唤起词检测 | `processVoiceSpeechV2()`, `WAKE_WORDS` | ~4685, 2662 |
| 语音结果 → 文本框 | `stateV2.textRecognition.onresult` | ~4721 |
| P1 区域更新 | `showListenOverlayV2()`, `#listen-text`, `#listen-status` | ~3456 |
| 命令处理（含 no-match） | `processCommandV2()` | ~4588 |
| no-match toast（待删） | `toastV2("暂未匹配到预设场景...")` | ~4602 |

---

## Issue A：数字人眼睛跟踪 + 拖拽肢体动作

### 现状

PixiJS 移除后，`mousemove` handler 只调用 `dispatchAvatarEventV2("pointermove", ...)` 但已无人监听。`.pet-eye-left` 和 `.pet-eye-right` 是 CSS 绘制的 `<span>` 元素，可以接受 `transform: translate()` 来模拟眼睛跟踪。`.pet-face-overlay` 可整体轻微偏转模拟"注视"感。

### 改动

**CSS（在 `.pet-eye` 现有规则附近添加）：**

```css
.pet-eye {
  transform: translate(var(--eye-x, 0px), var(--eye-y, 0px));
  transition: transform 0.12s ease-out;
}
.pet-face-overlay {
  transform: translate(var(--face-x, 0px), var(--face-y, 0px));
  transition: transform 0.18s ease-out;
}
```

**JS（在 `bindDigitalHumanV2()` 的 `mousemove` handler，约行 4852，在 `dispatchAvatarEventV2` 后追加）：**

```js
const rect = pet.getBoundingClientRect();
const cx = rect.left + rect.width / 2;
const cy = rect.top + rect.height * 0.38;
const dx = (e.clientX - cx) / (rect.width * 0.6);
const dy = (e.clientY - cy) / (rect.height * 0.6);
const eyeX = Math.max(-4, Math.min(4, dx * 4)).toFixed(2);
const eyeY = Math.max(-3, Math.min(3, dy * 3)).toFixed(2);
pet.style.setProperty("--eye-x", eyeX + "px");
pet.style.setProperty("--eye-y", eyeY + "px");
pet.style.setProperty("--face-x", (dx * 2).toFixed(2) + "px");
pet.style.setProperty("--face-y", (dy * 1.5).toFixed(2) + "px");
```

**JS（`mouseleave` handler 中，重置变量）：**

```js
pet.style.removeProperty("--eye-x");
pet.style.removeProperty("--eye-y");
pet.style.removeProperty("--face-x");
pet.style.removeProperty("--face-y");
```

### 验收

- 鼠标移入数字人区域，眼睛微微向鼠标方向偏移（上下左右各 ≤4px）
- 拖拽时，`--drag-tilt` 已有倾斜，叠加眼睛跟随效果
- 离开后眼睛复位到中心

---

## Issue B：Siri 式语音交互

### 现状（B）

- 需点击麦克风按钮才开始语音
- 语音结果直接写入 `#main-input` 文本框（`stateV2.textRecognition.onresult` 约行 4729）
- 无唤起词时仍处理任何语音（`processVoiceSpeechV2` 内 `command` 非空就处理）

### 目标行为

| 阶段 | UI 反应 | 数字人状态 |
| --- | --- | --- |
| 页面加载 | 静默请求麦克风权限，开始被动监听 | idle，无变化 |
| 仅背景声音 / 无唤起词 | 完全静默，不更新任何 UI | idle |
| 说出"小南小南" | P1 overlay 显示"已唤醒 · 请说出指令" | awake |
| 正在说指令 | P1 overlay 实时显示识别中的文字 | listening |
| 指令识别完成 | P1 overlay 显示"正在理解..." | thinking → 进入场景 |
| 处理完毕 | P1 overlay 隐藏，数字人进入对应状态 | speaking/success |

**关键原则：指令文字只出现在 P1 overlay（`#listen-text`），永远不写入 `#main-input`。**

### 改动（B）

**1. 在 `stateV2` 初始化对象（约行 3103）中新增两个字段：**

```js
passiveEnabled: false,
awaitingCommand: false,
```

**2. 新增 `autoPassiveListenV2()` 函数（在 `ensureVoicePermissionV2` 附近）：**

```js
async function autoPassiveListenV2() {
  try {
    await ensureVoicePermissionV2();
  } catch (e) { return; }
  const passive = createRecognitionV2({ continuous: true, interimResults: true });
  if (!passive) return;
  stateV2.passiveRecognition = passive;
  stateV2.passiveEnabled = true;
  passive.onresult = (e) => {
    let interim = "";
    let finalChunk = "";
    for (let i = e.resultIndex; i < e.results.length; i++) {
      if (e.results[i].isFinal) finalChunk += e.results[i][0].transcript;
      else interim += e.results[i][0].transcript;
    }
    const display = (finalChunk || interim).trim();
    if (!display) return;
    const val = normalizeV2(display);
    const hasWake = includesAnyV2(val, WAKE_WORDS);
    if (hasWake || stateV2.awaitingCommand) {
      showListenOverlayV2(stateV2.awaitingCommand ? "正在聆听..." : "已唤醒", display);
    }
    if (finalChunk.trim()) {
      processVoiceSpeechPassiveV2(finalChunk.trim());
    }
  };
  passive.onend = () => {
    if (stateV2.passiveEnabled) {
      window.setTimeout(() => { try { passive.start(); } catch (_) {} }, 600);
    }
  };
  passive.onerror = () => {};
  try { passive.start(); } catch (_) {}
}
```

**3. 新增 `processVoiceSpeechPassiveV2(text)` 函数：**

```js
function processVoiceSpeechPassiveV2(text) {
  const value = normalizeV2(text);
  if (!value) return;
  const hasWakeWord = includesAnyV2(value, WAKE_WORDS);
  let command = value;
  WAKE_WORDS.forEach((w) => { command = command.replaceAll(normalizeV2(w), "").trim(); });

  if (hasWakeWord && !command) {
    stateV2.awaitingCommand = true;
    setStateV2("awake", 2000);
    showListenOverlayV2("已唤醒", "请说出你的业务指令...");
    setPetStatusV2("我在，你直接说业务需求就行");
    if (stateV2.awaitCommandTimer) window.clearTimeout(stateV2.awaitCommandTimer);
    stateV2.awaitCommandTimer = window.setTimeout(() => {
      stateV2.awaitingCommand = false;
      hideListenOverlayV2();
    }, 8000);
    window.setTimeout(() => {
      if (stateV2.awaitingCommand) setStateV2("listening");
    }, 600);
    return;
  }

  if (command && (hasWakeWord || stateV2.awaitingCommand)) {
    stateV2.awaitingCommand = false;
    if (stateV2.awaitCommandTimer) window.clearTimeout(stateV2.awaitCommandTimer);
    showListenOverlayV2("正在理解...", command);
    updateVoicePresenceV2("voice", "thinking", command);
    queueVoiceCommandV2(command, "voice");
    return;
  }
  // 无唤起词且不在等待状态：完全静默
}
```

**4. 修改 `stateV2.textRecognition.onresult` 回调（约行 4721-4730），将 `elsV2.mainInput.value = display;` 替换为：**

```js
showListenOverlayV2("正在聆听...", display);
```

**5. 修改 `processCommandV2()` 文本框写入（约行 4591）：**

```js
if (source !== "voice") elsV2.mainInput.value = commandText;
```

**6. 在 `initV2Demo()` 末尾（约行 5021）追加：**

```js
window.setTimeout(() => autoPassiveListenV2(), 1400);
```

### 验收（B）

- 页面加载约 1.4s 后，浏览器弹出麦克风权限请求（若已授权则静默）
- 说非唤起词：完全无 UI 反应
- 说"小南小南"：P1 overlay 出现"已唤醒"，数字人进入 awake → listening 状态
- 接着说指令：P1 overlay 显示识别文字，命令被处理，`#main-input` 保持空白
- 8 秒内无指令：P1 overlay 自动收起，数字人复位

---

## Issue C：去除 no-match 暴露逻辑

### 现状（C）

`processCommandV2()` 约行 4597-4608：

```js
if (!route) {
  toastV2("暂未匹配到预设场景，你可以尝试下面的业务指令。", "warning", "海小南提示");
  showBubbleV2({ title: "我还没完全听懂", copy: "你可以先点下面几个重点场景...", ... });
  return;
}
```

### 改动（C）

删除 `toastV2(...)` 那一行，更新 `showBubbleV2` 文案：

```js
if (!route) {
  if (stateV2.currentPlan) {
    handleFollowV2(stateV2.currentPlan, commandText);
    return;
  }
  setStateV2("idle");
  showBubbleV2({
    title: "能再说具体一点吗",
    copy: "告诉我想处理什么业务、查什么数据，还是打开哪个页面，我来帮你调度。",
    quickItems: DEMO_COMMANDS_V2,
    sticky: false
  });
  return;
}
```

### 验收（C）

- 输入任意不匹配的文字，不弹 toast
- 数字人气泡出现，提示自然引导文案
- 快捷命令列表仍然显示

---

## Issue D：整体语音 + 状态过渡完善

### 改动说明

Issue B 的被动语音流程已覆盖大部分需求。额外两处细节：

**1. 指令处理完毕后，P1 overlay 在 modal 打开时自动隐藏（`openModalV2()` 约行 4168 开头）：**

```js
hideListenOverlayV2();
```

**2. `executeAnswerV2()` 函数（约行 4493）开头追加：**

```js
hideListenOverlayV2();
```

### 验收（D）

- 语音指令触发 awake → listening → thinking → speaking/success 状态顺序流畅
- P1 overlay 在 modal 或直接回答开始后自动消失

---

## 执行顺序

| 步骤 | 内容 | 风险 |
| --- | --- | --- |
| A | 眼睛跟踪 CSS + JS（`bindDigitalHumanV2` mousemove/mouseleave） | 低 |
| B1 | 新增 `autoPassiveListenV2` + `processVoiceSpeechPassiveV2` 函数 | 中 |
| B2 | 修改 `onresult` 不写文本框，修改 `processCommandV2` voice 跳过文本框 | 低 |
| B3 | `initV2Demo()` 末尾追加自动启动调用 | 低 |
| C | 删除 no-match toast，更新 showBubbleV2 文案 | 极低 |
| D | modal/answer 开启时隐藏 overlay | 低 |

---

## 验证方式

用 Chrome 直接打开 `hai-xiaonan-demo.html`：

1. **眼睛跟踪**：鼠标移入数字人，眼睛跟随移动，离开复位
2. **Siri 被动模式**：不点任何按钮，说"帮我查一下"→ 无反应；说"小南小南"→ P1 overlay 出现；再说"看一下本月预算完成率"→ 指标页打开，`#main-input` 未被写入
3. **no-match 自然引导**：文本框输入"帮我做点什么"→ 无 toast，气泡显示引导文案
4. **状态流畅性**：语音指令触发 awake → listening → thinking → speaking/success，P1 overlay 在 modal 打开后消失
