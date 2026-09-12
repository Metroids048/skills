# Figma import and sync

## Build

From `tools/figma-screenshot-importer`:

```powershell
npm install
npm run verify
```

The build must pass `UI_BUNDLE_SMOKE_PASS`. The UI script is injected with a replacement callback; do not change it to `template.replace(marker, uiScript)`, because `$&` inside bundled JS is interpreted as replacement syntax and corrupts the plugin.

## Run in Figma Desktop

1. Open the target design file.
2. Choose `Plugins → Development → Import plugin from manifest…`.
3. Select `tools/figma-screenshot-importer/manifest.json`.
4. Run `Prototype Screenshot Atlas Importer`.
5. Select `artifacts/prototype-snapshots/figma-import.zip`.
6. Wait for completion statistics before closing the plugin.

The plugin works offline, creates/reuses one `Atlas｜产品截图图谱` Page, groups Frames by module/flow, and syncs by `NN-NN` ID.

## Incremental behavior

- Existing Frame: update title, role/flow, and natural-language steps; preserve its image.
- New scene: create a Frame and import its PNG from ZIP.
- Missing existing image: fill it from ZIP or a unique reusable upload.
- Duplicate raw uploads with the same ID: do not guess; import the ZIP copy.
- Repeated run: do not create a second complete Atlas.

## Chinese filename mojibake

The PNG bytes may be correct while a multipart upload corrupts the Chinese filename. Repair by:

1. Match nodes by stable `NN-NN` prefix.
2. Rename from Manifest inside Figma.
3. For future multipart uploads, use ASCII temporary filenames.
4. Do not re-capture images solely to repair layer names.

The bundled ZIP importer avoids this multipart filename path.
