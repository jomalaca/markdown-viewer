# 🧪 Test Markdown Samples for Feature Parity

These sample files are designed to test, benchmark, and verify every capability of **Markdown Viewer** (`v1.6.0`).

---

## 📁 Sample Files Overview

| File | What It Tests | Key Features Included |
| :--- | :--- | :--- |
| [`01-kitchen-sink.md`](./01-kitchen-sink.md) | **Complete feature parity benchmark** | Typography, GFM checklists, blockquotes, tables, code blocks, KaTeX math, Mermaid flowchart & sequence diagrams, details/summary, footnotes. |
| [`02-math-and-diagrams.md`](./02-math-and-diagrams.md) | **Advanced Math & Diagrams** | Maxwell's equations, piecewise functions, series expansions, Mermaid state diagrams, class diagrams, pie charts, git graphs. |
| [`03-tables-and-code.md`](./03-tables-and-code.md) | **Tables & Syntax Highlighting** | Complex multi-column tables, column alignments (left/center/right), markdown inside table cells, code in 5+ languages (Python, TS, Go, SQL, Bash). |
| [`04-outline-and-reading.md`](./04-outline-and-reading.md) | **Outline & Long-form Reading** | Deep 6-level heading hierarchy (H1-H6) for Outline TOC testing, synchronized scroll accuracy, live word/character statistics, print pagination. |
| [`05-images.md`](./05-images.md) | **Local & Relative Image Resolution** | Relative path resolution via `local-file://` scheme handler, raw HTML `<img>` tags with dimension styling, and sanitization verification. |

---

## 🔍 Modern Feature Verification Checklist

1. **Document Loading**:
   - Open any sample file using **Open** (<kbd>Cmd</kbd>+<kbd>O</kbd>), drag-and-drop, or terminal CLI (`markdown-viewer samples/01-kitchen-sink.md`).

2. **Editing & Formatting**:
   - [ ] **Live WYSIWYG Preview Editing**: Click directly inside the rendered preview canvas to type text; verify immediate synchronization to the editor buffer.
   - [ ] **Interactive Checkboxes**: Click checkboxes in preview; verify smooth state toggling and markdown updates (`- [ ]` ↔ `- [x]`).
   - [ ] **Multi-line Checklist Toggle**: Select multiple lines in the editor and click "Insert Task Checklist"; verify all selected lines toggle checklist markers.
   - [ ] **Formatting Shortcuts**: Test <kbd>Cmd</kbd>+<kbd>B</kbd> and <kbd>Cmd</kbd>+<kbd>I</kbd> in both the editor textarea and preview canvas.

3. **Rendering & Layout**:
   - [ ] **GitHub Alert Callouts**: Verify `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, and `[!CAUTION]` render styled alert boxes with icons.
   - [ ] **KaTeX Math**: Verify both inline `$formula$` and block `$$formula$$` equations render crisply.
   - [ ] **Mermaid Diagrams**: Verify flowcharts, sequence diagrams, state machines, and class diagrams render without layout clipping.
   - [ ] **Full-Width Layout**: Toggle Full Width (<kbd>Shift</kbd>+<kbd>Cmd</kbd>+<kbd>W</kbd>) in preview view to verify content expands to the window margin.
   - [ ] **Outline Sidebar**: Toggle Outline (<kbd>Shift</kbd>+<kbd>Cmd</kbd>+<kbd>O</kbd>), type in the filter box, and click headings to scroll.

4. **Preferences & Export**:
   - [ ] **Preferences Modal**: Open Preferences (<kbd>Cmd</kbd>+<kbd>,</kbd>); verify the embedded live preview card reflects theme and typography changes.
   - [ ] **Dynamic Title Export**: Export as PDF (<kbd>Cmd</kbd>+<kbd>P</kbd>) or Standalone HTML; verify the default file title matches the document's first heading.
