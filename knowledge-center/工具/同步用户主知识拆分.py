#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 USER_KNOWLEDGE_BASE.md 拆分写入用户长期记忆与项目总账（不覆盖主库原文）。"""

from __future__ import annotations

import re
from datetime import datetime
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
UKB = CENTRAL / "USER_KNOWLEDGE_BASE.md"
MEM = CENTRAL / "用户长期记忆"
LEDGER = CENTRAL / "决策与复盘" / "项目总账.md"


def section(text: str, start: str, end: str | None) -> str:
    if end:
        pat = rf"({re.escape(start)}.*?)(?={re.escape(end)})"
    else:
        pat = rf"({re.escape(start)}.*)"
    m = re.search(pat, text, re.S)
    return (m.group(1).strip() if m else "")


def main() -> int:
    text = UKB.read_text(encoding="utf-8")
    now = datetime.now().strftime("%Y-%m-%d")
    MEM.mkdir(parents=True, exist_ok=True)

    mapping = {
        "用户画像.md": ("# 1. 用户核心画像", "# 2. 用户长期工作规则"),
        "用户偏好与约束.md": ("# 2. 用户长期工作规则：收口模式", "# 3. 长期目标"),
        "长期目标.md": ("# 3. 长期目标", "# 4. 工具与工作环境"),
        "个人开放事项.md": ("# 10. 当前开放事项", "# 11. 知识库更新规则"),
    }
    for fname, (a, b) in mapping.items():
        body = section(text, a, b)
        out = MEM / fname
        header = f"> 自 USER_KNOWLEDGE_BASE.md 同步摘录 · {now} · 主库仍为 SSOT\n\n"
        out.write_text(header + (body or f"（未解析到 {a}）\n"), encoding="utf-8")
        print("write", out)

    # 工具环境
    tools = section(text, "# 4. 工具与工作环境", "# 5. 项目总账")
    (MEM / "工具与工作环境.md").write_text(
        f"> 摘录 · {now}\n\n" + (tools or ""), encoding="utf-8"
    )

    # 自媒体
    media = section(text, "# 6. 自媒体账号知识库", "# 7. 可持续内容素材库")
    media_dir = CENTRAL / "内容素材中心"
    (media_dir / "自媒体账号定位.md").write_text(
        f"> 摘录 · {now}\n\n" + (media or ""), encoding="utf-8"
    )

    # 项目总账
    ledger = section(text, "# 5. 项目总账", "# 6. 自媒体账号知识库")
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    LEDGER.write_text(
        f"# 项目总账\n\n> 摘录自 USER_KNOWLEDGE_BASE · {now}\n\n"
        + "本地登记根见 `项目注册表.yaml`。桌面路径与 UKB 项目名对照由 `梳理项目知识.py` 维护。\n\n"
        + (ledger or ""),
        encoding="utf-8",
    )
    print("write", LEDGER)

    # 内容素材母库摘录
    ideas = section(text, "# 7. 可持续内容素材库", "# 8. 非核心但持续相关的个人事项")
    (media_dir / "内容素材母库摘录.md").write_text(
        f"> 摘录 · {now}\n\n" + (ideas or ""), encoding="utf-8"
    )

    print("OK: UKB split done (main file untouched)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
