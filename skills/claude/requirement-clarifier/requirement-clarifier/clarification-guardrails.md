# Clarification Guardrails（风险与假设门禁）

> 精华来源：[DmiyDing/clarify-first](https://github.com/DmiyDing/clarify-first)（Apache-2.0）— 本地化为 `requirement-clarifier` 附录，非完整拷贝。

## 何时启用

B 类模糊实施、动词含 optimize/fix/improve/refactor/部署/删除/迁移，或 **Mini-Spec 待确认项仍含 weight≥2 假设** 时，与本文件一并执行。

## 非协商门禁

若存在以下任一，**暂停 Write/Edit**：

- 意图/范围/验收不清
- 加权假设总分 **≥ 3**，或任一 **weight=2** 关键假设未确认

### 假设权重（内部审计，写入 §9 或 Mini-Spec）

| 假设类型 | 权重 |
|----------|------|
| 环境（dev/prod）、依赖包/版本 | **2** |
| 跨模块改动 >3 文件 | **2** |
| 框架/库选型、文件位置、命名 | 1 |

**例：**「加登录」→ 框架+库+存储+路径+命名 ≥5 → **必须澄清**

## 风险分档

| 级别 | 行为 |
|------|------|
| **LOW** | 只读、注释、路径+行号明确的单点修改 → 可极简澄清后执行 |
| **MEDIUM** | 重构、API 变更、多文件 → **先 Plan（影响矩阵）→ 用户确认 → 再改** |
| **HIGH** | 删除、部署、密钥、生产 → **显式「确认执行」+ 回滚说明** |

「最大权限」「你看着办」**不绕过** MEDIUM/HIGH 确认。

## 两阶段执行（MEDIUM/HIGH）

1. **Phase 1 — Plan**：影响文件矩阵、步骤、验收、回滚（HIGH 必填）
2. **用户确认**
3. **Phase 2 — Code**：不得超出已批准矩阵；新文件需求 → 停止并申请 Plan 修订

## 自检（行动前 30 秒）

1. 是否已读 manifest（`package.json` / `AGENTS.md` / 项目 memory）？
2. 假设清单与权重？
3. 风险级别？
4. 置信度 <80% → 回到 §7 待确认或 **interview-protocol** 单问循环

## 与 Mini-Spec 的衔接

- Mini-Spec `constraints` 填项目门禁（如 verify-all、ADR-003）
- `风险` 填 clarify-first 风险级
- MEDIUM/HIGH 时在 §10 分阶段计划写 **Plan-ID** 与确认点
