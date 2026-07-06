# Postmortem: 原型导航链路失败（2026-05-28）

**Status**: Resolved (ADR-003)  
**Related**: TASK-002, TASK-003, `prototype/scripts/journey-audit-matrix.json`

---

## 现象

| 路径 | 结果 |
|------|------|
| 直接打开 `05-agent-detail.html?id=agt_demo_001` | 正常：Skills 有标签，`+` 可弹窗，Tab 可切换 |
| 任意方式回 `index.html` 再点「查看」进入 05 | **异常**：Skills 空、`+` 无响应、Tab 像「全废了」 |

与返回方式无关（顶栏、列表链接、浏览器后退）——**同一浏览器 Tab 内第二次加载页面即可能触发**。

---

## 根因（至少 4 项叠加）

1. **`window.__protoSkillBindWired` 跨页泄漏**  
   第一次进 05 绑定 document click；回列表后旧 listener 随 document 销毁，但 window 标志仍为 true → 第二次进 05 跳过 `wireSkillBindButtons()`。

2. **sessionStorage `firstConfig: true` 粘住**  
   创建流写入 session，列表再进不带 `?new=1` 仍被 `isFirstConfig()` 拦截非 config Tab。

3. **05 页 init 分散**  
   migrate / overlay / skill bind / tabs 顺序不一致，补丁只治表象。

4. **`agentName` / `agentType` 笔误**  
   使用 `params.get` 而非 `params().get`，点击 `+` 时 `openSkillBindModal` 抛错。

---

## 为何全局护栏未拦住

| 已有机制 | 测了什么 | 漏了什么 |
|---------|---------|---------|
| smoke-check | 字符串存在、语法 | 不模拟 session、不跑导航 |
| e2e-check | 源码关键字 | 不执行 JS |
| regression-check | vm 加载 Proto | 不测 05 init 顺序 |
| browser-check | 单页 DOM | **不测 index→05→index→05** |
| AGENTS / ai-delivery-gate | 「要跑 verify-all」 | 未定义「用户真实路径」 |

**结论**：Skills/rules 约束 AI **行为**，但旧 verify-all **覆盖范围**不含导航旅程 → grep/smoke 全绿仍可能导航全红。

---

## 解决方案（已实施）

见 **ADR-003**（`decisions-log.md`）：

- `Proto.initAgentDetailPage()` 统一 bootstrap
- 移除 `__protoSkillBindWired`；可重复 `wireSkillBindButtons`
- `isFirstConfig()` 仅 `?new=1`；`resolveFirstConfigMode()` 清除列表再进残留
- `navigation-journey-check.js` 接入 verify-all 第 5 步（旅程 A–D）
- `journey-audit-matrix.json` 记录同类风险

---

## 操作清单（后续任务必遵）

### 改 `prototype/assets/*.js` 或关键 HTML 后

```bash
node prototype/scripts/verify-all.js
```

verify-all **5 步**：smoke → e2e → regression → browser-check → **navigation-journey**

首次 browser-check / navigation-journey 需 jsdom：

```bash
cd prototype && npm install jsdom --no-save
```

### 人工 spot-check（2 分钟，不可省）

见 `prototype/DELIVERY-CHECKLIST.md`：

1. 直接开 05（`id=agt_demo_001`）
2. 回 index 再进 05 — **与步骤 1 一致**
3. `10-skills-management.html` ≥ 6 条 Skill

### 打包交付前

```bash
node prototype/scripts/package-check.js
```

### 查同类问题

`prototype/scripts/journey-audit-matrix.json`

---

## 禁止再犯

| 禁止 | 改为 |
|------|------|
| `window.__*Wired` 防重复绑定 | removeEventListener + 可重复 init |
| session-only 锁 Tab | 仅 URL `?new=1` 锁 Tab |
| 每页 scatter init | 05 用 `initAgentDetailPage` |
| 新用户路径无 journey 测试 | 加 navigation-journey 或 package-check |
| 护栏更新后不 sync | `powershell scripts/sync-ai-guardrails.ps1 -Force` |

---

## 全局配置同步

项目内 rules/skills 更新后，必须同步到本机全局：

```powershell
powershell scripts/sync-ai-guardrails.ps1 -Force
```

否则 `~/.cursor/skills/ai-delivery-gate` 可能仍是旧版（不含 navigation-journey）。
