"""Deep dump of Cursor model-related persistent fields after restart."""
from __future__ import annotations

import json
import sqlite3
from pathlib import Path

DB = Path.home() / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
KEY = (
    "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl."
    "persistentStorage.applicationUser"
)

FIELDS = [
    "membershipType",
    "subscriptionStatus",
    "useOpenAIKey",
    "openAIBaseUrl",
    "availableAPIKeyModels",
    "isEnterprise",
    "teamBlockRepos",
    "teamBlocklist",
    "teamAdminSettings",
    "authenticationSettings",
    "hasTieredSelfServeTeamSpillover",
    "hasTokenBasedPricing",
    "dashboardUserId",
]


def main() -> None:
    conn = sqlite3.connect(str(DB))
    cur = conn.cursor()
    cur.execute("SELECT value FROM ItemTable WHERE key = ?", (KEY,))
    row = cur.fetchone()
    if not row:
        print("missing persistent key")
        return
    data = json.loads(row[0].decode() if isinstance(row[0], bytes) else row[0])

    for f in FIELDS:
        print(f"{f}: {json.dumps(data.get(f), ensure_ascii=False)[:500]}")

    models = data.get("availableDefaultModels2") or []
    print(f"\navailableDefaultModels2 count={len(models)}")
    for m in models:
        print(
            f"  - {m.get('name')} defaultOn={m.get('defaultOn')} "
            f"client={m.get('clientDisplayName')} vendor={m.get('vendorName')}"
        )

    # secrets
    cur.execute(
        "SELECT key FROM ItemTable WHERE key LIKE 'secret://cursorAuth/%'"
    )
    secrets = [r[0] for r in cur.fetchall()]
    print("\nsecrets:", secrets or "(none)")

    # any ItemTable keys mentioning model catalog
    cur.execute("SELECT key FROM ItemTable")
    for (k,) in cur.fetchall():
        lk = k.lower()
        if any(
            x in lk
            for x in (
                "availabledefault",
                "modelcatalog",
                "modelslist",
                "featureflag",
                "geo",
                "region",
                "blockedmodel",
            )
        ):
            print("key hit:", k)

    conn.close()


if __name__ == "__main__":
    main()
