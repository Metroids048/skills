"""Scan Cursor state.vscdb for model/API related keys."""
from __future__ import annotations

import json
import re
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
PATTERN = re.compile(
    r"model|openai|anthropic|apiKey|api_key|byok|provider|cursorAuth|"
    r"availableModels|enabledModel|custom|baseUrl|base_url|grok|composer|glm|kimi",
    re.I,
)


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [r[0] for r in cur.fetchall()]
    print("tables:", tables)

    for table in tables:
        try:
            cur.execute(f"SELECT key, value FROM {table}")
            rows = cur.fetchall()
        except sqlite3.Error as exc:
            print(f"{table}: skip ({exc})")
            continue

        hits = [(k, v) for k, v in rows if PATTERN.search(str(k))]
        if not hits:
            continue

        print(f"\n=== {table} ({len(hits)} hits) ===")
        for key, value in hits:
            text = value
            if isinstance(value, bytes):
                try:
                    text = value.decode("utf-8", errors="replace")
                except Exception:
                    text = repr(value[:200])
            preview = str(text)
            if len(preview) > 500:
                preview = preview[:500] + "..."
            print(f"\nKEY: {key}\n{preview}")

    conn.close()


if __name__ == "__main__":
    main()
