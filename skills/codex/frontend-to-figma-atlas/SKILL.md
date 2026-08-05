---
name: frontend-to-figma-atlas
description: Audit a frontend web app in a real browser, inventory routes and meaningful UI states, capture reproducible screenshots, generate a Manifest/ZIP, and incrementally sync a screenshot atlas into an existing Figma design file. Use when users ask to turn frontend pages, demos, dashboards, or prototypes into Figma; check for missing screenshots or states; fix screenshot-atlas labels; or reuse a frontend-to-Figma delivery workflow across projects.
---

# Frontend to Figma Atlas

Build a traceable screenshot atlas from a running frontend. Preserve the source product; change capture tooling, artifacts, and the local Figma importer unless the user separately authorizes product changes.

## Inputs

Collect:

- frontend root, start/build/verify commands, and local URL;
- router, navigation, redirects, roles, and meaningful UI states;
- target Figma design file or an already-imported local plugin;
- required viewport sizes and screenshot scope.

Do not invent unimplemented loading, approval, AI, permission, or external-service states.

## Workflow

1. Inspect repository rules and documented verification commands.
2. Inventory routes from router + navigation + page components. Treat redirects and unreachable legacy components separately.
3. Start the frontend without opening a visible browser unless the user requests it.
4. Run a real Chromium/Chrome audit:
   - visit every direct route;
   - record final URL, title, visible headings and important controls;
   - capture page/console/resource errors;
   - check horizontal overflow at required widths;
   - exercise important tabs, drawers, modals, success states, error states, and full-screen work areas.
5. Compare browser evidence with existing scenarios. Add screenshots only when a state:
   - changes the primary business content;
   - opens a key modal/drawer/work area;
   - represents a meaningful result, exception, permission, or configuration surface.
6. Scaffold reusable tools when absent:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/scaffold.ps1 `
  -ProjectRoot C:/path/to/project
```

7. Edit `tools/prototype-capture/src/scenarios.mjs` using [scenario-schema.md](references/scenario-schema.md). Prefer accessible role/text/label locators. Use exact text for scroll targets to avoid matching explanatory copy.
8. Run the capture tool. Require a screenshot, Manifest row, and deterministic outcome for every scene.
9. Validate generated artifacts:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-atlas.ps1 `
  -ArtifactsDir C:/path/to/project/artifacts/prototype-snapshots
```

10. Build the bundled local Figma importer and import `figma-import.zip`. Follow [figma-import.md](references/figma-import.md).
11. Visually inspect representative screenshots and the final Figma Atlas. Re-run project verification and capture verification before reporting completion.

## Atlas presentation rules

- Keep one independent Figma Page named `Atlas｜产品截图图谱` by default.
- Group by module + flow into Sections; place primary states first and exceptions/supplementary states below.
- Show `场景编号 + 页面名称 + 状态`, then `角色 + 流程`.
- Do not show route paths in visible Figma metadata.
- Render actions in natural language: `点击`, `填写`, `定位至`, `等待显示`, `选择`.
- Preserve image ratio with `FIT`.
- Sync by `NN-NN` scene ID: update existing Frames, preserve existing images, and add only new or missing scenes.
- Keep route paths in Manifest/report for automation and traceability.

## Encoding and upload safety

- Keep project files, Manifest, ZIP, and PNG names in UTF-8.
- Prefer the bundled local ZIP importer for Chinese names.
- If an external multipart upload is unavoidable on Windows, upload ASCII temporary filenames, then rename nodes from Manifest inside Figma. Never trust multipart filename decoding for Chinese layer names.
- Do not re-screenshot solely to repair mojibake layer names.

## Verification contract

Required evidence:

- project test/build command passes;
- scenario tests pass;
- every captured scene reports success or an explicit documented failure;
- Manifest count equals ZIP PNG count for successful scenes;
- PNG dimensions match the declared viewport and are not blank;
- browser console/page/resource checks are clean or documented;
- representative new screenshots receive visual inspection;
- Figma runtime import/sync is verified by the user or an available Figma tool.

If Figma runtime access is unavailable, report the result as ready for import, not fully synchronized.

## Bundled resources

- `assets/prototype-capture-template/`: Playwright capture engine and scenario template.
- `assets/figma-screenshot-importer/`: local, offline, incremental Figma importer.
- `scripts/scaffold.ps1`: installs both tools into a project without deleting existing files.
- `scripts/validate-atlas.ps1`: validates Manifest/ZIP/image agreement.
- `references/scenario-schema.md`: scenario and action format.
- `references/figma-import.md`: build, run, mojibake recovery, and incremental sync procedure.
