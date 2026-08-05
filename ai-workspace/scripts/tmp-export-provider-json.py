# -*- coding: utf-8 -*-
import json
import os
import sqlite3
from pathlib import Path

db = Path(os.environ["USERPROFILE"]) / ".cc-switch" / "cc-switch.db"
conn = sqlite3.connect(db)
row = conn.execute(
    "SELECT id, name, website_url, settings_config FROM providers WHERE id=?",
    ("one-api-1783589315861",),
).fetchone()
conn.close()

provider = {
    "id": row[0],
    "name": row[1],
    "website_url": row[2],
    "settings_config": json.loads(row[3]),
}
out = Path(os.environ["TEMP"]) / "cc-sync-codex-provider-test.json"
out.write_text(json.dumps(provider, ensure_ascii=False, indent=2), encoding="utf-8")
print(out)
