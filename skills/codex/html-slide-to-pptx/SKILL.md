---
name: "HTML 幻灯转 PPTX"
slug: html-slide-to-pptx
description: "HTML 幻灯 → 可编辑 PowerPoint；浏览器一键导出"
---
# HTML Slide to PPTX

Convert HTML slide decks to **real, editable PowerPoint presentations** — with a pixel-perfect screenshot fallback.

## Primary Method: dom-to-pptx (editable PPTX)

1. Design HTML slides (`.slide` divs at 1280×720px)
2. Add dom-to-pptx CDN and download button:
   ```html
   <script src="https://cdn.jsdelivr.net/npm/dom-to-pptx@1.1.10/dist/dom-to-pptx.bundle.js"></script>
   <button onclick="domToPptx.exportToPptx(
     Array.from(document.querySelectorAll('.slide')),
     { fileName:'out.pptx', layout:'LAYOUT_16x9', autoEmbedFonts:false, svgAsVector:false }
   )">Download PPTX</button>
   ```
3. Serve the HTML (`python -m http.server 8080` or any HTTP server)
4. Open in browser, click **Download PPTX**
5. May show OOXML repair warning on first open — content is unaffected

## Backup Method: Screenshot (pixel-perfect, not editable)

If dom-to-pptx produces broken layouts, fall back:

```bash
python scripts/screenshot_to_pptx.py http://127.0.0.1:8080/demo.html --output presentation.pptx
```

Launches headless Chrome, screenshots each `.slide` div at 2x, assembles into a 16:9 PPTX.

## Requirements (Screenshot Backend)

- Python 3.10+
- Chrome/Chromium
- `pip install requests websocket-client python-pptx`

## Layout Design Principles

### 1. Feel over form
A slide is "饱满" (full) when its content block is vertically substantial and visually centered — regardless of text, table, cards, or mixed layout. Let content dictate.

### 2. Padding compensates for content volume
- Heavy (multiple blocks, dense text): 30-40px padding-top
- Medium (standard card layouts): 50-60px
- Light (single table/paragraph): 60-70px
- Minimal (references, short notes): 15-20px

### 3. Context enriches
When a slide feels thin, add context (lead sentence, key data point, summary) instead of forcing format changes.

### 4. Cover and section slides are exceptions
Follow their own layout rules.

## Design System (Taste-Optimized)

> Inspired by [taste-skill](https://github.com/Leonxlnx/taste-skill)'s anti-slop approach. Two dials tune the aesthetic. MOTION is excluded — irrelevant for static PPTX slides.

### Two Dials

| Dial | Range | What it controls |
|---|---|---|
| **DESIGN_VARIANCE** | 1–10 | Layout symmetry: 1=centered, 5=moderate asym, 10=experimental |
| **VISUAL_DENSITY** | 1–10 | Content per slide: 2=airy, 5=standard business, 8=dashboard |

**Default:** VARIANCE=5, DENSITY=5.

**Dial inference by scenario:**

| Scenario | VARIANCE | DENSITY |
|---|---|---|
| Academic / case study | 5–6 | 5–6 |
| Corporate / government | 4–5 | 5–6 |
| Creative / marketing | 7–8 | 3–4 |
| Data dashboard | 3–4 | 7–8 |
| Portfolio / personal | 6–7 | 3–4 |

### Typography Hierarchy

- **Headlines:** 36-38pt, w700, `letter-spacing: -0.02em`
- **Section heads:** 26-28pt, w600, `letter-spacing: -0.01em`
- **Card titles:** 18-20pt, w600
- **Body:** 12-14pt, color #555, `line-height: 1.7`, max-width ~65ch
- **Labels:** 10-11pt, color #999, uppercase, `letter-spacing: 0.06em`
- **Stats:** 36-44pt, w700, `letter-spacing: -0.03em`
- **Font:** System sans-serif stack. No serif defaults.

### Color Principles

- **Base:** Black (#1c1c1c) on white (#fff) or off-white (#fafaf9).
- **Text tiers:** Primary #1c1c1c, secondary #555, tertiary #999.
- **Accent:** ONE accent per deck — sparingly, never as background fill.
- **Section dividers:** Dark bg (#1c1c1c) + white text.
- **BANNED:** Blue-purple gradients, dark mesh heros, colored content bg.

### Layout Rules

- **Default:** LEFT aligned. Center only cover/end/section slides.
- **Grid, not flex-math:** CSS Grid with varied column ratios (1.3:1, 1.2:0.8). No three equal columns unless data requires it.
- **Cards:** Border only (1px #e8e8e5), no shadows/color. Accent cards use left-border accent.
- **Tables:** Thin borders, left text, bold header with 2px bottom border.

### Section Divider Pattern

Every chapter: dark divider slide (#1c1c1c), large chapter number (0.08 opacity), white title, optional muted description.

### Pre-Flight Checklist

- [ ] No blue-purple gradients
- [ ] No centered dark mesh hero
- [ ] No three equal cards (unless data demands)
- [ ] No serif fonts
- [ ] No colored content slide backgrounds
- [ ] ≥3 distinct type sizes
- [ ] Accent color ≤5% of slide area
- [ ] Section dividers between chapters
- [ ] Dense slides not empty; light slides not crammed
- [ ] Left-aligned by default, centered only intentionally
