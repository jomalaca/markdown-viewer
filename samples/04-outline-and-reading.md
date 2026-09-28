# 📖 Document Outline & Long-Form Reading Test

This test document features long-form prose with a rich heading hierarchy to test the **Outline / Table of Contents sidebar**, **synchronized scrolling**, **word count statistics**, and **print pagination**. SAVE THIS NOW!

---

## 1. Introduction to Local-First Computing

The local-first software paradigm prioritizes user ownership of data, privacy by design, and resilience against network outages. Traditional web architectures frequently require continuous round-trips to remote cloud servers to perform even trivial text rendering or document saves.

### 1.1 The Seven Ideals of Local-First Software

1. **No spinners**: Your work at your fingertips instantly without waiting for a server.
2. **Your work is not trapped on one device**: Clean sync when online.
3. **The network is optional**: Full functionality offline.
4. **Seamless collaboration**: Conflict-free resolution.
5. **The long now**: Software survives even if the original company shuts down.
6. **Security and privacy by default**: End-to-end local encryption.
7. **You retain ultimate ownership**: Files exist in standard, open formats like Markdown.

### 1.2 Comparison with Cloud-Tethered Services

> When your notes reside exclusively on a remote multi-tenant server, your privacy is subject to policy updates, administrative access, database leaks, and subscription paywalls. Standardizing on local Markdown files ensures your writing remains readable fifty years from now.

---

## 2. Deep Section Hierarchy

### 2.1 Storage Foundations

#### 2.1.1 Browser LocalStorage
Web browsers provide a simple key-value store with synchronous access. While capacity is typically limited to 5MB–10MB per origin, this is more than sufficient for storing hundreds of rich Markdown documents.

##### 2.1.1.1 Serializing Tab State
When multiple documents are open, storing them as a structured JSON array maintains:
- Unique identifier (`id`)
- Document filename (`title`)
- Raw text payload (`content`)
- Timestamp of last edit

###### 2.1.1.1.1 Compression Strategies
For very large documents, compression techniques (such as LZ-based algorithms or gzip) can be applied before storing data into `localStorage` strings or URL hash fragments.

### 2.2 Rendering Foundations

#### 2.2.1 Abstract Syntax Tree Generation
Markdown engines parse plain text into an Abstract Syntax Tree (AST), converting paragraphs, headers, and code fences into distinct nodes before transforming them into semantic HTML elements.

#### 2.2.2 Sanitization & Safe DOM Insertion
Inserting untrusted HTML directly via `innerHTML` opens potential Cross-Site Scripting (XSS) vectors. Libraries like `DOMPurify` parse the generated HTML, stripping dangerous attributes (`onload`, `onerror`, `javascript:` protocols) while preserving mathematical elements (`<math>`, KaTeX tags) and SVG diagrams.

---

## 3. Synchronized Scrolling Mechanics

Synchronized scrolling allows writers to edit source text on one side of the screen while seeing the exact rendered output track smoothly on the other side.

### 3.1 Proportional Scroll Calculation

The proportional scroll algorithm tracks the scroll position relative to total scrollable height:

$$
\text{ScrollRatio} = \frac{\text{scrollTop}}{\text{scrollHeight} - \text{clientHeight}}
$$

When either container scrolls, the companion container updates its `scrollTop`:

$$
\text{targetScrollTop} = \text{ScrollRatio} \times (\text{targetScrollHeight} - \text{targetClientHeight})
$$

### 3.2 Loop Prevention Guard
Because updating `scrollTop` programmatically triggers a scroll event on the target element, a debounce flag (`isScrolling`) must be checked to prevent infinite mutual recursion between the editor and preview listeners.

---

## 4. Summary & Verification Checklist

- [x] Verify that the Outline sidebar displays all headings from H1 to H6
- [x] Click each heading in the Outline sidebar to confirm smooth scrolling
- [x] Check that the status bar shows word count, line count, and reading time
- [x] Toggle between GitHub Light, GitHub Dark, Dracula, Nord, and Sepia themes
- [x] Test Export &rarr; Print / Save as PDF to preview publication formatting
