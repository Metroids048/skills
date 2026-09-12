---
name: supabase-local
description: Wrap the official Supabase CLI for provider-independent project discovery and safe read-only diagnostics while refusing production DDL, DML, and credential disclosure by default.
---

# Supabase Local

Use `supabase --version` and read-only project/status commands first. Never print access tokens or `.env` values. Refuse production database writes, migrations, resets, deletes, or arbitrary SQL unless the user explicitly authorizes a named non-production target and a dry-run/test fixture. If authentication is missing, classify the capability as `APP_AUTH_REQUIRED` rather than fabricating success.
