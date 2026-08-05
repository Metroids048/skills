"""Extract model/BYOK fields from Cursor persistent storage JSON."""
from __future__ import annotations

import json
import re
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
KEY = "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser"


def walk(obj, path=""):
    if isinstance(obj, dict):
        for k, v in obj.items():
            p = f"{path}.{k}" if path else k
            if re.search(
                r"openai|anthropic|google|model|apiKey|byok|useOpenAI|availableDefault|custom",
                k,
                re.I,
            ):
                preview = v
                if isinstance(v, str) and len(v) > 120:
                    preview = v[:120] + "..."
                print(f"{p}: {preview!r}")
            walk(v, p)
    elif isinstance(obj, list) and len(obj) < 20:
        for i, item in enumerate(obj):
            walk(item, f"{path}[{i}]")


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT value FROM ItemTable WHERE key = ?", (KEY,))
    row = cur.fetchone()
    if not row:
        print("persistent storage key not found")
        return
    text = row[0].decode("utf-8") if isinstance(row[0], bytes) else row[0]
    data = json.loads(text)
    walk(data)

    print("\n=== TOP-LEVEL KEYS ===")
    print(sorted(data.keys()))

    for name in (
        "availableDefaultModels",
        "availableDefaultModels2",
        "modelConfig",
        "aiSettings",
        "openAIBaseUrl",
        "useOpenAIKey",
        "usingOpenAIKey",
    ):
        if name in data:
            print(f"\n=== {name} ===")
            print(json.dumps(data[name], ensure_ascii=False, indent=2)[:3000])

    conn.close()


if __name__ == "__main__":
    main()
