import json
import os
import sqlite3

db = os.path.join(os.environ["USERPROFILE"], ".cc-switch", "cc-switch.db")
c = sqlite3.connect(db)
rows = c.execute(
    "SELECT id, name, settings_config FROM providers WHERE app_type='codex'"
).fetchall()
for pid, name, cfg in rows:
    d = json.loads(cfg)
    auth = d.get("auth", {})
    key = auth.get("OPENAI_API_KEY") or ""
    print(f"=== {pid} | {name} ===")
    print("  auth_mode:", auth.get("auth_mode"))
    print("  key_prefix:", (key[:12] + "...") if key else "(none)")
    for ln in d.get("config", "").splitlines():
        if any(k in ln for k in ("model_provider", "base_url", "wire_api", "requires_openai", "experimental_bearer")):
            if "sk-" in ln:
                print(" ", ln.split("=")[0].strip(), "= sk-***")
            else:
                print(" ", ln.strip())
