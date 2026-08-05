"""Targeted scan of Cursor state for API keys and model config."""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
TARGETS = (
    "cursorAuth/",
    "cursor/initialModelState",
    "cursor/model",
    "cursorai/",
    "secret://cursorAuth",
    "availableModels",
    "enabledModels",
    "disabledModels",
    "userAdded",
    "customModel",
    "openai",
    "anthropic",
    "google",
)


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    for table in ("ItemTable", "cursorDiskKV"):
        cur.execute(f"SELECT key, value FROM {table}")
        for key, value in cur.fetchall():
            ks = str(key)
            if not any(t.lower() in ks.lower() for t in TARGETS):
                continue
            text = value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)
            if ks.startswith("secret://"):
                text = f"<secret present, len={len(text)}>"
            elif len(text) > 1200:
                text = text[:1200] + "..."
            print(f"\n[{table}] {ks}\n{text}")
    conn.close()


if __name__ == "__main__":
    main()
