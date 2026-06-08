# Extraction and Recovery Guide

Use this guide when acquiring Figma evidence or recovering from access/tooling problems.

## Figma URL Parsing

Common URL forms:

- `https://www.figma.com/design/<file_key>/<name>?node-id=...`
- `https://www.figma.com/file/<file_key>/<name>?node-id=...`
- `https://www.figma.com/proto/<file_key>/<name>?node-id=...`

The file key is the segment immediately after `design`, `file`, or `proto`.

## REST API Extraction

If a Figma token is available, fetch:

- `GET https://api.figma.com/v1/files/<file_key>`
- Header: `X-Figma-Token: <token>`

Extract:

- File name, modified time, version
- Pages and top-level frames
- Node names and types
- Visible text samples
- Components and instances
- Styles
- Prototype interaction records
- Frame dimensions
- Duplicates and abandoned drafts

Recommended local artifacts:

- `figma-file-raw.json`: raw API result
- `figma-screen-inventory.md`: product-facing frame inventory
- `figma-interaction-map.md`: prototype links and overlays
- `figma-deep-summary.json`: counts and normalized summaries
- Final report Markdown

Never include token values in artifacts. After extraction, run a secret check such as:

```powershell
rg "figd_|X-Figma-Token|Authorization|Bearer" .
```

## Large File Handling

Figma JSON can be very large. Avoid opening the whole file repeatedly. Use scripts or `rg`.

Recommended parsing logic:

1. Recursively walk `document.children`.
2. Record each node's id, name, type, page, parent path, size, text characters, component id, and interactions.
3. Summarize top-level frames first.
4. Create category labels from names and text, such as operations backend, mobile, agent center, personal space, business scenario, modal, historical draft.
5. Deduplicate repeated frames by normalized name and module meaning.

## Access Failures

If MCP is unavailable:

- Try REST API if token is available.
- Use local exports if already present.
- Ask for token only if the user has not provided one and the link is private.

If REST API fails:

- Check token validity and file key parsing.
- Check whether the file is private or belongs to another organization.
- Ask the user for export/screenshots only if access cannot be solved.

If external docs fail due to login:

- State that the document could not be directly accessed.
- Ask the user to paste relevant content, or use content already pasted.
- Do not infer specific doc content from the URL.

If the prototype has few explicit interactions:

- Explain that explicit prototype links are limited.
- Infer product flows from UI names, visible text, and business context.
- Mark inferred flows as recommendations rather than observed facts.

If the user says the output is not detailed enough:

- Add business context integration.
- Add system scope.
- Add state models.
- Add end-to-end flows.
- Add module requirement tables.
- Add gaps and roadmap.

If the user says the output is too confusing:

- Remove Figma internals.
- Reorganize by product story and business workflows.
- Add an executive summary.
- Use diagrams and tables.

## Ambiguity Handling

When the user gives a Figma link without detailed instructions:

- Assume the first deliverable is a concise product-level analysis.
- Extract enough evidence to understand product structure.
- Offer or proceed to a deeper report if the user asks for detail.

When the user says "as needed" or "you decide":

- Choose the path that maximizes product understanding:
  1. Acquire Figma evidence.
  2. Build inventory.
  3. Translate inventory into product modules.
  4. Produce a polished product report.

When user-provided business content conflicts with prototype:

- Treat the user's content as target requirements.
- Treat the prototype as current coverage.
- Report the difference as gaps.

## Final Delivery

Final response should be short:

- State the report was created or updated.
- Link to the local report file.
- Mention any important limitations, such as inaccessible external docs.
- Avoid dumping the whole report into chat unless the user asks.

