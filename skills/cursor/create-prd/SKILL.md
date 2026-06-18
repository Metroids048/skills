---
name: create-prd
description: Create a Product Requirements Document using a comprehensive 8-section template covering problem, objectives, segments, value propositions, solution, and release planning. Use when writing a PRD, documenting product requirements, preparing a feature spec, or reviewing an existing PRD.
disable-model-invocation: true
---
# Create a Product Requirements Document

## Purpose

You are an experienced product manager responsible for creating a comprehensive Product Requirements Document (PRD) for $ARGUMENTS. This document will serve as the authoritative specification for your product or feature, aligning stakeholders and guiding development.

## Context

A well-structured PRD clearly communicates the what, why, and how of your product initiative. This skill uses an 8-section template proven to communicate product vision effectively to engineers, designers, leadership, and stakeholders.

## Instructions

1. **Gather Information**: If the user provides files, read them carefully. If they mention research, URLs, or customer data, use web search to gather additional context and market insights.

2. **Think Step by Step**: Before writing, analyze:
   - What problem are we solving?
   - Who are we solving it for?
   - How will we measure success?
   - What are our constraints and assumptions?

3. **Apply the PRD Template**: Create a document with these 8 sections:

   **1. Summary** (2-3 sentences)
   - What is this document about?

   **2. Contacts**
   - Name, role, and comment for key stakeholders

   **3. Background**
   - Context: What is this initiative about?
   - Why now? Has something changed?
   - Is this something that just recently became possible?

   **4. Objective**
   - What's the objective? Why does it matter?
   - How will it benefit the company and customers?
   - How does it align with vision and strategy?
   - Key Results: How will you measure success? (Use SMART OKR format)

   **5. Market Segment(s)**
   - For whom are we building this?
   - What constraints exist?
   - Note: Markets are defined by people's problems/jobs, not demographics

   **6. Value Proposition(s)**
   - What customer jobs/needs are we addressing?
   - What will customers gain?
   - Which pains will they avoid?
   - Which problems do we solve better than competitors?
   - Consider the Value Curve framework

   **7. Solution**
   - 7.1 UX/Prototypes (wireframes, user flows)
   - 7.2 Key Features (detailed feature descriptions)
   - 7.3 Technology (optional, only if relevant)
   - 7.4 Assumptions (what we believe but haven't proven)

   **8. Release**
   - How long could it take?
   - What goes in the first version vs. future versions?
   - Avoid exact dates; use relative timeframes

4. **Use Accessible Language**: Write for a primary school graduate. Avoid jargon. Use clear, short sentences.
   - **Forbidden in PRD body**: code function names (`login()`, `fetchData()`), file paths (`src/`, `web端/`), CSS class names, API endpoint names, database keys, module dependency graphs — anything that belongs in a technical spec, not a product document.
   - **Architecture/flow diagrams**: do NOT put Mermaid diagrams in the PRD markdown. Write "暂时无法在飞书文档外展示此内容" (placeholder for Feishu). The user will draw diagrams in Feishu directly.
   - **Heading format**: use plain text numbering ("一、二、三"), NOT `#` Markdown heading syntax.
   - **Screenshot placeholders**: use `[图片]` as a placeholder. The user pastes Figma screenshots themselves.
   - **Interaction descriptions**: describe what users see and do (click → input → feedback), not what internal functions are called. Write "the system verifies the email and password" not "login() validates credentials".
   - **Page layout**: reference Figma, mockups, or screenshots. Never use ASCII art or Mermaid to simulate layout. Use `[图片]` placeholder.
   - **Writing style**: use short tables + bullet lists. Avoid long paragraphs. Field rules should focus on business logic, not implementation.
   - **Must cover**: Skills selector (search/filter/multi-select/cap), deep thinking toggle, file upload limits, download button, source citations, message center (announcements/todos/feedback box).
   - **Sections to omit**: non-functional requirements, appendices (browser compat, performance metrics, acceptance criteria lists) — these belong in tech specs, not PRD.
   - **Business constraints**: label prototype limitations honestly — "pre-filled to match current system, actual list depends on deployment".
   - **Data source annotation**: when describing fields, label data origins — "syncs with organizational structure", "connected to operations center".

5. **Structure Output**: Present the PRD as a well-formatted markdown document with clear headings and sections.

6. **Save the Output**: If the PRD is substantial (which it will be), save it as a markdown document in the format: `PRD-[product-name].md`

## Notes

- Be specific and data-driven where possible
- Link each section back to the overall strategy
- Flag assumptions clearly so the team can validate them
- Keep the document concise but complete

---

### Further Reading

- [How to Write a Product Requirements Document? The Best PRD Template.](https://www.productcompass.pm/p/prd-template)
- [A Proven AI PRD Template by Miqdad Jaffer (Product Lead @ OpenAI)](https://www.productcompass.pm/p/ai-prd-template)

