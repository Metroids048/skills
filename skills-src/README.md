# Canonical Active Skills

`skills-src/` 是 Personal AI Runtime v2 的 Skill 内容唯一事实源（SSOT）。

- 这里仅保留经过路由元数据和 benchmark 验证的 Active Skills。
- `skills/cursor|claude|codex|agents` 是 v1 legacy source pool / 回滚证据，不再作为安装目标，也不允许被 export 脚本反向覆盖 `skills-src/`。
- Skill 是否参与路由由 `registry/skills.json` 决定；alias 通过 `canonical_id` 去重，不复制第二份 Skill。
- 新增 Skill 必须同时说明 positive triggers、negative triggers、profiles、priority，并补 routing benchmark；不能仅因为“可能有用”进入 Active Catalog。
- 默认每个任务最多返回 5 个 Skill，避免把整个能力库塞进上下文。
