# 海小南 Demo Bug 修复计划（第二轮）

## Context

上一轮修复已完成（代码读取确认）：Pixi+avatar-runtime 脚本已在 line 2663-2664 加载，
ensureAvatarRuntimeV2 已还原，权限缓存已加入，keywords 模糊匹配已加入，voice 实例重建模式已加入。

**当前代码读取后确认的三个残留 bug**：

1. **数字人形象消失**：`ensureAvatarRuntimeV2` catch 块未清除 `avatar-runtime-enabled` 类
   → img 被 CSS `display:none !important` 隐藏，Pixi canvas 失败后无任何内容可见
2. **模态框内无法语音追问**：`.modal-layer` z-index 55 > `.pet` z-index 45，
   模态框打开时麦克风按钮在底层不可点击；renderDialogV2 模板里没有语音按钮
3. **关闭模态框后语音追问静默失败**：closeModalV2 未清除 currentPlan，
   handleFollowV2 → appendUserTurnV2 找 #dialog-thread-v2（已关闭），静默返回

**追加**：将"交付前必须自查"写入全局 CLAUDE.md。

---

## 当前代码状态（逐行读取确认）

| 位置 | 当前状态 | 问题 |
|------|---------|------|
| line 3227-3230 ensureAvatarRuntimeV2 catch | 只有 `avatarRuntimeV2 = null` | 缺 classList.remove |
| line 3835-3848 renderDialogV2 | follow-input-row 只有 text input + 发送按钮 | 无语音按钮 |
| line 4226-4236 closeModalV2 | 只清 pendingModalPlan，不清 currentPlan | 关闭后 currentPlan 残留 |
| CLAUDE.md line 9 | 只有一条全局规则 | 无自查规则 |

---

## 修复方案

### Fix 1：ensureAvatarRuntimeV2 catch 块（line 3228 后加一行）

```js
} catch (error) {
  console.error("Avatar runtime failed to start", error);
  elsV2.digitalHuman.classList.remove("avatar-runtime-enabled");  // ← 新增
  avatarRuntimeV2 = null;
}
```

---

### Fix 2：renderDialogV2 加语音按钮（line 3843-3845）

在 follow-input-row 里，发送按钮前插入：

```html
<button class="follow-mic" id="modal-follow-mic-v2" type="button"
  title="语音追问" aria-label="语音追问">
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
    stroke="currentColor" stroke-width="2">
    <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3z"/>
    <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
    <line x1="12" y1="19" x2="12" y2="23"/>
    <line x1="8" y1="23" x2="16" y2="23"/>
  </svg>
</button>
```

在 CSS 区加 `.follow-mic` 样式（参考 .follow-send 旁边）：

```css
.follow-mic {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: 8px;
  background: rgba(255,255,255,0.08);
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.15s;
}
.follow-mic:hover { background: rgba(255,255,255,0.15); }
.follow-mic.listening {
  background: rgba(239,68,68,0.3);
  border-color: rgba(239,68,68,0.6);
}
```

在 `bindModalV2`（跟在 followInput/followSend 绑定之后）加：

```js
const followMic = document.getElementById("modal-follow-mic-v2");
if (followMic) {
  followMic.addEventListener("click", () => startModalVoiceV2(plan, followInput));
}
```

新增函数 `startModalVoiceV2`（紧接在 handleFollowV2 定义之后）：

```js
function startModalVoiceV2(plan, inputEl) {
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SR) { toastV2("当前浏览器不支持语音识别", "warning", "语音追问"); return; }
  const micBtn = document.getElementById("modal-follow-mic-v2");
  if (micBtn) micBtn.classList.add("listening");
  const rec = new SR();
  rec.lang = "zh-CN";
  rec.continuous = false;
  rec.interimResults = true;
  rec.onresult = (e) => {
    let text = "";
    for (let i = 0; i < e.results.length; i++) text += e.results[i][0].transcript;
    if (inputEl) inputEl.value = text;
  };
  rec.onend = () => {
    if (micBtn) micBtn.classList.remove("listening");
    const value = inputEl ? inputEl.value.trim() : "";
    if (value) { handleFollowV2(plan, value); if (inputEl) inputEl.value = ""; }
  };
  rec.onerror = () => { if (micBtn) micBtn.classList.remove("listening"); };
  try { rec.start(); } catch (_) {}
}
```

---

### Fix 3：closeModalV2 清除 currentPlan（line 4234 之后加一行）

```js
stateV2.pendingModalPlan = null;
stateV2.currentPlan = null;  // ← 新增，防止关闭后 handleFollowV2 静默失败
```

---

### Fix 4：CLAUDE.md 追加交付自查规则

在 `C:\Users\win\.claude\CLAUDE.md` 末尾追加：

```
**交付自查规则（Mandatory）：** 任何任务声明完成前，必须用 Read 工具重新读取所有被修改的关键代码段，
逐一确认预期逻辑已落地（不能只凭记忆），再告知用户完成。若发现预期逻辑未落地，
必须继续修复直到读取验证通过才能声明完成。禁止在未读取验证的情况下说"已修复"或"已完成"。
```

---

## 文件改动范围（仅 2 个文件）

`hai-xiaonan-demo.html`：
- catch 块加 1 行（classList.remove）
- renderDialogV2 的 follow-input-row 加麦克风按钮 HTML（约 8 行）
- CSS 区加 .follow-mic 样式（约 12 行）
- bindModalV2 加 followMic 绑定（约 4 行）
- 新增 startModalVoiceV2 函数（约 18 行）
- closeModalV2 加 1 行（currentPlan = null）

`C:\Users\win\.claude\CLAUDE.md`：末尾追加 3 行

---

## 验证步骤（实施后必须逐项 Read 确认，不允许仅凭记忆声明完成）

1. `Read hai-xiaonan-demo.html line 3227-3232` → 确认 catch 块含 `classList.remove("avatar-runtime-enabled")`
2. `Read hai-xiaonan-demo.html line 3835-3852` → 确认 renderDialogV2 含 `modal-follow-mic-v2` button
3. `Grep "startModalVoiceV2" hai-xiaonan-demo.html` → 确认函数定义存在
4. `Read hai-xiaonan-demo.html line ~4408-4445` → 确认 bindModalV2 含 followMic click handler
5. `Read hai-xiaonan-demo.html line 4226-4238` → 确认 closeModalV2 含 `currentPlan = null`
6. `Read C:\Users\win\.claude\CLAUDE.md` → 确认末尾有交付自查规则
