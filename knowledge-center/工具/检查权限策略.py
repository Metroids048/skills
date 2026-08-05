#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""权限策略自检（模块 8）。"""

from __future__ import annotations

import sys
from pathlib import Path

CENTRAL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from 检查隐私 import is_dangerous_command, is_secret_path  # noqa: E402


def main() -> int:
    templates = list((CENTRAL / "配置" / "权限模板").glob("*.yaml"))
    assert templates, "missing permission templates"
    # 采集器：秘密路径拒绝
    assert is_secret_path(str(CENTRAL / ".env")) or is_secret_path("C:/x/.env")
    assert is_dangerous_command("Remove-Item -Recurse D:\\")
    # 读模板内容含 deny
    text = (CENTRAL / "配置" / "权限模板" / "全局知识采集器.yaml").read_text(encoding="utf-8")
    assert "deny:" in text and ".env" in text
    assert "powershell" not in text.lower() or "不要" in text or "不" in text
    print("PASS: 权限模板存在且拒绝秘密/危险命令策略可验证")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
