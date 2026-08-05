"""List model names in Cursor availableDefaultModels2."""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
KEY = "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser"


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT value FROM ItemTable WHERE key = ?", (KEY,))
    row = cur.fetchone()
    data = json.loads(row[0].decode() if isinstance(row[0], bytes) else row[0])
    models = data.get("availableDefaultModels2", [])
    print(f"count={len(models)}")
    for m in models:
        print(
            f"- {m.get('name')} | defaultOn={m.get('defaultOn')} | "
            f"client={m.get('clientDisplayName')} | vendor={m.get('vendorName')}"
        )

    auth = data.get("authenticationSettings", {})
    print("\nauthenticationSettings:", json.dumps(auth, ensure_ascii=False)[:800])

    print("\nuseOpenAIKey:", data.get("useOpenAIKey"))
    print("availableAPIKeyModels:", data.get("availableAPIKeyModels"))
    print("membershipType:", data.get("membershipType"))
    print("subscriptionStatus:", data.get("subscriptionStatus"))

    conn.close()


if __name__ == "__main__":
    main()
