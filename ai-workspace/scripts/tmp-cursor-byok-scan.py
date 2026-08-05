"""Dump Cursor model/BYOK related keys from state.vscdb."""
from __future__ import annotations

import json
import re
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT key, value FROM ItemTable")
    rows = cur.fetchall()

    print("=== SECRETS ===")
    for key, value in rows:
        if str(key).startswith("secret://cursorAuth"):
            text = value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)
            print(f"{key} | len={len(text)} | prefix={text[:24]!r}")

    print("\n=== MODEL-RELATED KEYS ===")
    for key, value in rows:
        ks = str(key)
        if not re.search(
            r"availableDefault|modelState|modelConfig|useOpenAI|usingOpenAI|"
            r"anthropicKey|googleKey|openAIKey|customModel|addedModels|"
            r"disabledModel|enabledModel|modelPicker|preferredModel|defaultModel",
            ks,
            re.I,
        ):
            continue
        text = value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)
        if len(text) > 2000:
            text = text[:2000] + "..."
        print(f"\n{ks}\n{text}")

    print("\n=== VALUE HITS (useOpenAI / availableDefaultModels) ===")
    for key, value in rows:
        text = value.decode("utf-8", errors="replace") if isinstance(value, bytes) else str(value)
        if re.search(r"useOpenAI|availableDefaultModels|usingOpenAIKey|anthropicApiKey|googleApiKey", text, re.I):
            preview = text
            if len(preview) > 1500:
                preview = preview[:1500] + "..."
            print(f"\n{key}\n{preview}")

    conn.close()


if __name__ == "__main__":
    main()
