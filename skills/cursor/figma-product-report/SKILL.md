---
name: figma-product-report
description: Analyze Figma prototype/design links and turn them into product-manager-facing product analysis reports. Use when the user provides a Figma URL, prototype link, design file, screenshots, exported Figma JSON, or asks to inspect a prototype through MCP/API and produce product understanding, feature architecture, user flows, interaction/state analysis, system scope, gaps, roadmap, PRD-style analysis, or an AI product manager report. Also use when the user input is vague and the task requires planning a repeatable workflow from Figma artifact discovery to a structured product report.
disable-model-invocation: true
---
# Figma Product Report

## Purpose

Turn a Figma prototype into a coherent product analysis report, not a raw Figma inventory. Translate frames, pages, layers, components, and prototype links into product concepts: users, scenarios, modules, workflows, states, permissions, data needs, gaps, MVP scope, and recommended next steps.

The default perspective is an AI product manager unless the user specifies another role.

## Operating Principles

- Treat Figma as evidence, not the report structure. Do not organize the final report around "Page 1", "Frame", "node", or layer names unless the user explicitly asks for a design audit.
- Build product understanding from multiple inputs: Figma structure, visible text, interactions, naming conventions, user-provided business context, linked docs, and inferred workflows.
- When user input is vague, proceed with a staged workflow instead of blocking. Ask only for missing credentials or access if they are required.
- Keep raw extraction artifacts separate from the polished report. The final report should be readable by people who have never opened Figma.
- Protect secrets. Never write Figma API tokens, temporary signed URLs, cookies, or private credentials into generated reports.
- Make uncertainty explicit. Distinguish observed prototype evidence, user-provided requirements, and product-manager inference.

## Workflow

### 1. Interpret the Request

Classify the user intent before extracting anything.

Common intents:

- "Read this Figma" means inspect the prototype and summarize what exists.
- "Analyze carefully" means traverse frames, components, text, and interactions, then explain the product.
- "From a PM perspective" means produce product positioning, users, flows, features, states, system scope, gaps, and roadmap.
- "Not detailed enough" means stop listing Figma internals and rebuild the report around product logic.
- "Create a skill/workflow" means capture the repeatable method, including ambiguity handling and failure recovery.

If the user only provides a link, assume they want a product-level analysis unless the wording says "design critique", "UI audit", or "implementation slicing".

### 2. Acquire Access and Extract Evidence

Preferred evidence sources, in order:

1. MCP Figma tool if configured and accessible.
2. Figma REST API if the user provides a token or the environment has one.
3. Existing local exports such as JSON, CSV, screenshots, or prior summaries.
4. Browser inspection or screenshots if API/MCP access is unavailable.
5. User-provided business requirements, screenshots, or notes if the Figma cannot be accessed.

For Figma REST API extraction:

- Parse the file key from URLs like `https://www.figma.com/design/<file_key>/...`.
- Fetch the file metadata and document tree.
- Traverse all pages and top-level frames.
- Extract frame names, hierarchy, sizes, visible text samples, component instances, styles, and prototype interactions.
- Count entities to understand scale, but avoid making counts the main report narrative.
- Save raw artifacts locally only when useful: `figma-file-raw.json`, screen inventory, interaction map, layer CSV, or summary JSON.
- Scrub or avoid storing credentials. Run a token search before final delivery if a token was used.

If Feishu, Google Docs, or other linked docs are inaccessible due to login, state that direct access failed and rely on user-provided pasted content. Do not invent content from inaccessible docs.

See `references/extraction-and-recovery.md` for specific fallback patterns and problem handling.

### 3. Build a Product Map

Convert design evidence into product modules. Create a normalized module map before writing the report.

Typical module categories:

- User entrance: login, homepage, app launcher, conversation, history, mobile entry, notifications.
- Business intelligent agents: scheduling, report analysis, maintenance expert, field data capture, production data, lab experiment design.
- Agent center: agent marketplace, personal agents, creation, configuration, knowledge binding.
- Agent development platform: workflow editor, model node, knowledge node, tool/MCP/plugin calls, preview, publish.
- Model and data services: model service, datasets, knowledge bases, fine-tuning, evaluation, data portal.
- Operations support: dashboards, feedback center, expert workbench, badcase library, cost/resource monitoring.
- Governance: users, organizations, roles, permissions, resource access, data scope, quotas, API keys, audit logs.

When the prototype contains duplicate frames or historical/abandoned drafts, deduplicate by product meaning. Mention duplication only as a design cleanup recommendation.

### 4. Reconstruct Workflows

Identify the product's important workflows from interactions, text, and business context.

Always look for:

- Entry flow: login -> home -> choose agent/application -> start task.
- Agent use flow: ask/submit task -> model/tool processing -> result -> citations -> save/export/feedback.
- Agent creation flow: create -> configure model/knowledge/tools -> test -> submit/release -> manage.
- Feedback flow: user feedback -> categorization -> expert task -> correction -> dataset/badcase -> model/knowledge/agent improvement.
- Permission flow: user -> role -> permission -> resource -> quota -> audit.
- Business-specific flows such as intelligent scheduling, field data capture, report generation, or maintenance diagnosis.

Use interactions as clues, not as the whole truth. If only a few prototype links exist, infer missing state transitions from the product logic and mark them as recommended additions.

### 5. Analyze States and System Objects

For a development-ready report, define object states. Common state models:

- Agent: draft, debugging, pending review, published, rejected, disabled, archived.
- Conversation/result: generating, generated, adopted, edited, feedback submitted, saved, exported.
- Report/note: draft, saved, exported, shared, archived.
- Feedback: pending, processing, waiting for expert, fixed, closed, rejected.
- Expert task: unclaimed, claimed, in progress, pending review, completed, overdue.
- Fine-tuning task: candidate, pending review, queued, training, evaluating, pending release, released, failed.
- Scheduling plan: generating, conflict detected, pending confirmation, pending approval, confirmed, executing, completed, canceled.
- Field data: local draft, validation failed, pending sync, syncing, sync failed, synced, distributed.

Only include states relevant to the user's product. Do not overload a simple report with every possible state.

### 6. Write the Product Report

Use product language. The report should be understandable without Figma context.

Recommended report sections:

1. Executive conclusion
2. Product positioning
3. Target users and jobs-to-be-done
4. Overall product architecture
5. Core product loop
6. Core business scenarios
7. Platform module requirements
8. Key workflows
9. Interaction and state model
10. Permission/governance model
11. Data/model/feedback loop
12. Current coverage and gaps
13. MVP/P0-P2 scope
14. Recommended prototype/product improvements
15. Final recommendation

For detailed templates and example tables, read `references/report-template.md`.

### 7. Handle Iteration Requests

If the user says the report is "messy", "not specific", "too Figma-like", or "people won't understand Page 1/Page 2":

- Reframe immediately around product, not design artifacts.
- Remove or demote Figma-specific vocabulary.
- Add a product architecture section.
- Add module-by-module requirements.
- Add scenario workflows in business language.
- Add current coverage vs required scope.
- Add system scope and MVP phasing.
- Preserve useful evidence, but translate it into product meaning.

If the user adds business requirements after the first analysis:

- Treat the new content as authoritative.
- Reconcile it with prototype evidence.
- Add gaps where the prototype does not yet support the provided requirements.
- Separate "prototype already covers" from "requirements indicate should add".

## Ambiguous Input Strategy

When the request is under-specified, use this decision tree:

```text
Does the user provide a Figma link?
  Yes -> Try MCP/API extraction; ask for token only if access fails.
  No -> Ask for a link or artifact unless screenshots/files are already present.

Does the user ask for "analysis/report"?
  Yes -> Produce product report, not raw UI inventory.
  No -> If they ask "read/parse", first produce concise inventory and ask whether to deepen.

Is business context missing?
  Yes -> Infer from prototype text and module names; label assumptions.
  No -> Use user-provided business context as the primary interpretation layer.

Are there multiple pages/drafts/duplicates?
  Yes -> Deduplicate into product modules and mention cleanup suggestions.

Are external docs inaccessible?
  Yes -> Use pasted user content; disclose access limitation briefly.
```

## External Tool Guidance

- Use MCP resources/tools before generic web access when the task explicitly says "through MCP".
- Use shell scripts or quick local parsers for large Figma JSON; do not manually inspect huge files line by line.
- Use `rg` to check generated reports do not contain credentials.
- Use local Markdown files for substantial reports so the user can review and reuse them.
- Use diagrams such as Mermaid when architecture or workflow clarity matters.
- Browse or access web only when the user asks, when external docs are necessary and accessible, or when current information must be verified.

## Quality Checklist

Before final response:

- The final report is not organized by Figma page/frame names.
- The report explains what the product is, who uses it, and what business problems it solves.
- Core workflows are described from user action to system output.
- Interactions and states are translated into product state models.
- Permissions, resources, quotas, and audit are covered for enterprise AI products.
- Prototype coverage and missing requirements are clearly separated.
- Roadmap or MVP scope is included when the product is broad.
- Figma tokens and private credentials are not present in generated artifacts.
- The final response links to the report file and states what changed.


