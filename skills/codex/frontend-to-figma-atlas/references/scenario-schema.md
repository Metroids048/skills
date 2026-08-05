# Scenario schema

Each entry in `scenarios.mjs` represents one reproducible viewport state.

Required fields:

| Field | Meaning |
|---|---|
| `id` | Stable `NN-NN` identifier; never reuse for another state |
| `module` | Atlas module grouping |
| `flow` | User task/flow grouping |
| `roleKey` / `role` | Browser identity and visible role label |
| `screenName` | Human-readable page/work-area name |
| `stateName` | Distinct visible state |
| `route` | Automation route; retained in Manifest, hidden in Figma metadata |
| `viewport` | `{ width, height }`, normally 1440×900 |
| `actions` | Ordered semantic browser actions |
| `waitFor` | Visible text that proves the state is ready |
| `expectedText` | Text assertions |
| `screenshotName` | UTF-8 PNG filename beginning with `id` |

Supported actions:

- `click`: use role, label, exact text, or test ID.
- `fill`: use a visible label or placeholder.
- `scrollIntoView`: use exact text unless a unique role/label exists.
- `selectOption`: use a native select locator.
- `waitForText`: wait for asynchronous visible content.

Rules:

1. Prefer accessible roles and visible labels; avoid CSS selectors tied to layout.
2. Use exact scroll text. Substring matching can select an earlier explanatory sentence.
3. Capture after fonts, network idle, transitions, and animations settle.
4. Keep one scene per meaningful state. Do not create scenes for hover/pressed-only microstates.
5. Keep redirects in route inventory but do not duplicate their destination screenshots.
6. Treat failed assertions as failed scenes; do not silently emit a screenshot and call it successful.

## Identity configuration

The template exports both a `users` map and `captureConfig.auth`:

- `loginRoute`: page visited while preparing each role's storage state.
- `localStorageKey`: optional key for demos that accept a JSON user object in
  localStorage. Leave it empty for public routes, cookie-based sessions, or
  projects that authenticate through scenario actions.

Each scenario's `roleKey` resolves to the matching user and storage-state file.
Unknown role keys do not silently fall back to an administrator. Adapt these
values to the project's role model and login mechanism before capture.
