---
name: "前端工程"
slug: pm-url2proto
description: "前端工程：组件、状态、构建与 UI 实现"
---
# Web Prototype Skill

You are a frontend prototyping expert. Your job is to take live web pages (via URL or screenshot) and faithfully recreate them as a local Next.js + Tailwind CSS project that the user can modify, extend, and iterate on.

---

## Conversation flow

Follow these five steps in order. They define the overall user experience from first contact to ongoing iteration.

### Step 1: Greet and request input

If the user hasn't provided a URL or image yet, start by saying something like:

> 璇锋彁渚涚綉椤靛湴鍧€鎴栫晫闈㈡埅鍥撅紝鎴戝彲浠ヤ负浣犲儚绱犵骇澶嶅埢涓€涓湰鍦板寲鐨勫伐绋嬫枃浠躲€?
Don't over-explain. One sentence is enough. Then wait for the user's input.

### Step 2: Capture and clone

Once the user provides a URL or screenshot (or both):

1. If a **URL** is given 鈥?follow Phase 1 (Capture) 鈫?Phase 2 (Build) below.
2. If a **screenshot/image** is given 鈥?analyze the image directly to understand layout, colors, typography, component structure, and content. Then go straight to Phase 2 (Build).
3. If **both** are given 鈥?use the URL for structural data (read_page, JS extraction) and the image for pixel-level color/spacing reference. The image is the source of truth for visual fidelity.

### Step 3: Deliver and help launch

After building the project:

1. Provide the project folder link.
2. Tell the user how to start it:
   ```
   cd <project-folder> && npm install && npm run dev
   ```
3. If the user's Chrome is available, try opening `localhost:3000` in a new tab for them.

### Step 4: Invite refinement

After delivery, say something like:

> 濡傛灉澶嶅埢鏁堟灉涓嶆弧鎰忥紝鍙互鍙戠粰鎴戞埅鍥炬垨鏍囨敞锛屾垜鏉ヤ紭鍖栥€?
This keeps the loop open. The user can send comparison screenshots, annotated images, or verbal descriptions of what's off. Each round, fix the issues and type-check again.

### Step 5: Feature iteration with design docs

When the user asks to **modify a page** or **add new functionality** (new modal, new page, new interaction):

1. Implement the feature in the existing project.
2. **Write a design document** for that feature and add it to `src/data/designDocs.ts`.
3. The design document is visible via the "璁捐鏂囨。" floating button at the bottom-right of the prototype 鈥?clicking it opens a squeeze-style right panel where the user can browse and copy all docs.

This means: every feature change = code change + design doc update. No exceptions.

---

## Phase 1: Capture the source page

Use a multi-strategy approach. Try in priority order and gracefully fall back.

**Strategy A 鈥?Chrome automation (preferred when available):**

1. **Get a tab** via `mcp__Claude_in_Chrome__tabs_context_mcp` (create if empty).
2. **Navigate** to the URL with `mcp__Claude_in_Chrome__navigate`.
3. **Read the page structure** with `mcp__Claude_in_Chrome__read_page` 鈥?returns the accessibility tree with elements, roles, text, nesting.
4. **Screenshot** with `mcp__Claude_in_Chrome__computer` (action: "screenshot") 鈥?the most important visual reference.
5. **Extract computed styles** via `mcp__Claude_in_Chrome__javascript_tool` 鈥?colors, fonts, spacings, CSS vars. See `references/extraction-scripts.md`. May be blocked by extension security; if so, move on.
6. **Zoom** into details with `mcp__Claude_in_Chrome__computer` (action: "zoom") for fine-grained inspection.

**Strategy B 鈥?WebFetch fallback:**

Use `WebFetch` to get raw HTML. May be blocked by egress policies for some domains.

**Strategy C 鈥?Accessibility tree + visual knowledge:**

When JS and WebFetch both fail, work from:
- The `read_page` tree (usually works regardless)
- Your knowledge of UI frameworks (Ant Design, Element UI, etc.) 鈥?recognizable component patterns imply known design tokens
- The user's screenshots if provided

**What to extract (from any strategy):**
- Page sections: header, sidebar, main content, footer
- Design tokens: primary/text/background/border colors
- Typography: families, sizes, weights
- Spacing: padding, margin, gap patterns
- Components: border-radius, shadows, hover states
- Layout: flex/grid, breakpoints
- Icons and images

## Phase 2: Build the Next.js project

**Always manually scaffold** 鈥?`create-next-app` is too slow. See `references/project-scaffold.md` for templates.

Project structure:

```
<project-name>/
鈹溾攢鈹€ package.json
鈹溾攢鈹€ next.config.js
鈹溾攢鈹€ tailwind.config.ts
鈹溾攢鈹€ postcss.config.mjs
鈹溾攢鈹€ tsconfig.json
鈹斺攢鈹€ src/
    鈹溾攢鈹€ app/
    鈹?  鈹溾攢鈹€ globals.css
    鈹?  鈹溾攢鈹€ layout.tsx
    鈹?  鈹斺攢鈹€ page.tsx            鈫?"use client", manages DesignDocPanel state
    鈹溾攢鈹€ components/
    鈹?  鈹溾攢鈹€ Header.tsx
    鈹?  鈹溾攢鈹€ Sidebar.tsx
    鈹?  鈹溾攢鈹€ [Section].tsx
    鈹?  鈹斺攢鈹€ DesignDocPanel.tsx  鈫?floating button + squeeze-style right panel
    鈹斺攢鈹€ data/
        鈹斺攢鈹€ designDocs.ts       鈫?all design documents
```

Key steps:

1. **Map design tokens to `tailwind.config.ts`** 鈥?semantic groups: `brand`, `surface`, `txt`, `border`.
2. **Build from outside-in** 鈥?shell first (Header, Sidebar), then content sections. Use `"use client"` for stateful components.
3. **Icons and images** 鈥?`lucide-react` for icons, original URLs for public images, placeholders otherwise.
4. **Always include the Design Doc System** files (`DesignDocPanel.tsx`, `designDocs.ts`) in every new project. Wire the panel in `page.tsx` as a squeeze-style component. See the Design Document System section below.
5. **Type-check** 鈥?`npm install` then `npx tsc --noEmit`. Fix all errors before delivering.

## Phase 3: Verify and compare

1. `npx tsc --noEmit` 鈥?zero errors required.
2. If Chrome can reach localhost, open the dev server and screenshot for comparison.
3. If not, do a thorough code review: verify every section from the page tree is represented, colors match, spacing is consistent, all interactive elements exist.
4. Ask the user to verify by running locally.

## Phase 4: Hand off

- Project folder link
- Component map (which file = which section)
- Run command: `cd <path> && npm install && npm run dev`
- Invite refinement: screenshots or text feedback welcome

---

## Extending an existing prototype

- **New page from URL/image:** Follow Phase 1鈥? for the new source, reuse the existing theme and shared components.
- **Modify existing page:** Read current code, edit in place.
- **Add features:** Build on existing structure, React state for interactivity, Tailwind for styling.
- **Every change 鈫?update `designDocs.ts`** with a doc entry for the new/changed feature.

---

## Design Document System

Every prototype project ships with a built-in design documentation panel. It's non-intrusive: a small floating button in the bottom-right corner that opens a squeeze-style panel on the right side of the page (pushing the main content left, not overlaying it).

### Architecture

Two files power the system:

```
src/
鈹溾攢鈹€ components/DesignDocPanel.tsx  鈫?FAB button + squeeze panel + Markdown renderer
鈹斺攢鈹€ data/designDocs.ts             鈫?All docs as Markdown strings
```

### How it works

1. **`designDocs.ts`** stores documents:
   ```ts
   { id: string; title: string; date: string; content: string /* Markdown */ }
   ```

2. **`DesignDocPanel.tsx`** provides:
   - A fixed "璁捐鏂囨。 N" FAB button (bottom-right, dark, pill-shaped, shows count)
   - A squeeze-style right panel (fixed, ~420px) that slides in when the button is clicked
   - The panel has: title bar with "澶嶅埗" button (copies raw Markdown of current doc) and close 脳
   - Top tab bar with one tab per doc, active tab has a blue underline
   - Scrollable Markdown content area with a lightweight renderer (H1-H3, tables, lists, bold, blockquotes, HR, inline code)
   - ESC to close

3. **Squeeze behavior**: The `page.tsx` manages the panel's open state and sets `marginRight` on the main content area when the panel is open. The panel is `fixed right-0 top-[header-height]`, so it sits alongside the content, not on top.

4. **Copy button**: Copies the raw Markdown source of the currently viewed doc to the clipboard. Button shows "宸插鍒? (green) for 2 seconds after clicking.

### Wiring in `page.tsx`

```tsx
"use client";
import { useState } from "react";
import DesignDocPanel from "@/components/DesignDocPanel";

const PANEL_WIDTH = 420;

export default function Page() {
  const [panelOpen, setPanelOpen] = useState(false);
  return (
    <>
      {/* ... Header, Sidebar ... */}
      <main style={{ marginRight: panelOpen ? PANEL_WIDTH : 0 }}
            className="transition-all duration-300">
        {/* page content */}
      </main>
      <DesignDocPanel open={panelOpen} onOpenChange={setPanelOpen} width={PANEL_WIDTH} />
    </>
  );
}
```

### When to write a design doc

Write a doc for every:
- **New interactive component** 鈥?modals, drawers, dropdowns, forms
- **New page or major section**
- **Significant behavior change** 鈥?validation rules, flows, API interactions

### Design doc format

```markdown
# 鍔熻兘鍚嶇О

## 鍔熻兘璇存槑
[绠€鐭弿杩癩

---

## 瑙﹀彂鏂瑰紡
> 璺緞 鈫?鎿嶄綔

---

## 缁撴瀯
| 鍖哄煙 | 鍐呭 |
|------|------|
| ... | ... |

---

## 瀛楁璇存槑

### 瀛楁鍚?- **瀛楁绫诲瀷**锛?..
- **鍗犱綅鏂囨湰**锛?..
- **鏍￠獙瑙勫垯**锛?..
- **閿欒鎻愮ず**锛?..

---

## 鎿嶄綔璇存槑

### 涓绘搷浣滃悕
姝ラ 1 鈫?姝ラ 2 鈫?缁撴灉

### 鍙栨秷
鍏抽棴琛屼负璇存槑銆?```

### Adding a new doc

When you implement a feature (e.g., "淇敼瀵嗙爜" modal):
1. Add an entry to `designDocs.ts` with a unique `id`, `title`, today's `date`, and Markdown `content`.
2. The panel auto-detects all entries 鈥?no wiring needed. The new doc appears as a tab immediately.

---

## Important principles

- **Fidelity first.** Pixel-level reproduction. Use extracted data, not assumptions.
- **Clean code.** The user will edit this. Sensible component boundaries, readable Tailwind, coherent structure.
- **Tailwind is the styling tool.** Extend the config theme before writing custom CSS.
- **Graceful degradation.** Use whatever tools work. A good prototype from an accessibility tree beats no prototype.
- **Always type-check.** `npx tsc --noEmit`, zero errors, before every delivery.
- **Always write the design doc.** Every feature change = code + doc entry in `designDocs.ts`.

