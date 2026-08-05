# Cursor transcript 批量导入备注（2026-07-28）

## 结果

- 父会话 `**/agent-transcripts/**/*.jsonl`（`--transcripts-only`）：**129** 条已在索引中（去重后 0 新增 / 129 duplicate）。
- 说明：同日首次误用宽扫 `--dir ~/.cursor/projects`（含 `*.md`）时，JSONL 已一并导入；随后收紧为 `--transcripts-only`。

## 噪声（宽扫副作用）

- 部分 MCP `STATUS.md`、Temp 工作区文件曾被导入原始层。
- **处理**：保留在 `原始记录/`（去重索引已记 hash），**不**升入跨项目经验 / UKB；结构化栏目仅用 curated + 真实 transcript 证据。
- 后续批量导入 **必须**加：`--transcripts-only`。

## 已登记项目映射（infer-project）

| 项目 | 用途 |
|------|------|
| Agent Platform / AI--main / alpha / program1-main-latest / 全局配置 | 已进原始记录 + 胶囊 |
| program / program1-main / demo* / Operating Platform | 仅归档，不新建镜像 |

## 缺口补证据（本轮）

结构化事实以 curated（`global-task-history` / ADR / 项目 memory）为主；transcript 作原始证据层。栏目增量见：

- `决策与复盘/全局决策记录.md`（ADR-G001～G006）
- `跨项目经验/*` 增量
- `项目镜像/{AI--main,敖钦储能项目,海小南,Agent Platform}/` 摘录
- `待确认更新/2026-07-28_Cursor_curated回填_待确认补丁.md`
