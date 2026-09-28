# 🧪 Test Markdown Samples for Feature Parity

These sample files are designed to test and compare every capability between [markdownviewer.org](https://markdownviewer.org) and your local clone.

---

## 📁 Sample Files Overview

| File | What It Tests | Key Features Included |
| :--- | :--- | :--- |
| [`01-kitchen-sink.md`](./01-kitchen-sink.md) | **Complete feature parity benchmark** | Typography, GFM checklists, blockquotes, tables, code blocks, KaTeX math, Mermaid flowchart & sequence diagrams, details/summary, footnotes. |
| [`02-math-and-diagrams.md`](./02-math-and-diagrams.md) | **Advanced Math & Diagrams** | Maxwell's equations, piecewise functions, series expansions, Mermaid state diagrams, class diagrams, pie charts, git graphs. |
| [`03-tables-and-code.md`](./03-tables-and-code.md) | **Tables & Syntax Highlighting** | Complex multi-column tables, column alignments (left/center/right), markdown inside table cells, code in 5+ languages (Python, TS, Go, SQL, Bash). |
| [`04-outline-and-reading.md`](./04-outline-and-reading.md) | **Outline & Long-form Reading** | Deep 6-level heading hierarchy (H1-H6) for Outline TOC testing, synchronized scroll accuracy, live word/character statistics, print pagination. |

---

## 🔍 Step-by-Step Comparison Guide

1. **Open both sides**:
   - Open [markdownviewer.org](https://markdownviewer.org) in one browser tab.
   - Open your local clone: run `open ../index.html` or visit `http://localhost:3000`.


2. **Drag & Drop or Open**:
   - Click **Open** or drag and drop any of the `.md` files above into the window.

3. **Check Parity Points**:
   - [ ] **GFM Rendering**: Do bold, italic, strikethrough, blockquotes, and tables match?
   - [ ] **Interactive Checkboxes**: Can you click task checkboxes in preview and see the editor update?
   - [ ] **KaTeX Math**: Do both inline `$formula$` and block `$$formula$$` equations render crisply?
   - [ ] **Mermaid Diagrams**: Do flowcharts, sequence diagrams, state diagrams, and pie charts render correctly?
   - [ ] **Sync Scroll**: Does scrolling the editor smoothly scroll the preview?
   - [ ] **Themes**: Compare Light, Dark, Sepia, etc.
   - [ ] **Export**: Compare Standalone HTML and Print-to-PDF output.
