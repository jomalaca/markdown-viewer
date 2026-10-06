# Architecture & Technical Design

Markdown Viewer (`v1.6.0`) combines a native Swift AppKit desktop host with a sandboxed WebKit rendering engine, providing a private, local-first workspace for viewing and editing Markdown, JSON, and YAML documents.

---

## System Overview

```mermaid
flowchart TD
    subgraph Host[Native macOS AppKit Host (Swift)]
        App[NSApplication & NSWindow]
        Menu[Native Menu Bar & Global Shortcuts]
        Panels[NSOpenPanel / NSSavePanel]
        Scheme[LocalFileSchemeHandler\nlocal-file:// URL Protocol]
        Auth[File Access Session Whitelist\nopenedFiles Verification]
    end

    subgraph WebKit[Sandboxed WebKit Layer]
        Bridge[WKScriptMessageHandler Bridge\n'nativeApp' Channel]
        WV[WKWebView Container]
        CSP[Strict Content Security Policy\ndefault-src 'none', script-src 'self']
        Vendored[100% Offline Bundled Assets\nvendor/ Marked, KaTeX, Mermaid, Highlight.js]
    end

    subgraph Frontend[Frontend Application Core (HTML5/CSS3/ES6)]
        TabEngine[Multi-Tab State Manager & localStorage]
        EditorHistory[Per-Tab Undo/Redo Stacks]
        WYSIWYG[Dual-Canvas Engine\nEditor Textarea <---> Preview contenteditable]
        ASTConv[convertDomToMarkdown\nDOM-to-Markdown Recursive Serializer]
        FindReplace[FindReplaceController\nRegex Indexing & Decoupled Focus]
        Settings[SettingsController\nTab-Scoped Isolation & Live Preview]
        RenderPipeline[Rendering Pipeline\nGFM + Alerts + Math + Mermaid + JSON/YAML]
        TOC[Outline TOC & Scroll-Spy System]
    end

    subgraph Disk[Local File System]
        MDFile[Markdown / Document Files]
        Images[Local Images (.png, .jpg, .svg)]
    end

    Menu -->|evaluateJavaScript| WV
    WV <-->|postMessage| Bridge
    Bridge <--> Panels
    Bridge <--> Auth
    Auth -->|Authorized Reads/Writes| MDFile
    WYSIWYG <--> ASTConv
    TabEngine --> EditorHistory
    TabEngine --> Settings
    RenderPipeline --> Scheme
    Scheme -->|Stream Image Data| Images
```

---

## 1. AppKit & WebKit Inter-Process Communication (IPC)

The desktop application is architected around a bidirectional bridge connecting Swift's AppKit framework with the sandboxed WebKit runtime.

### JavaScript to Swift (`WKScriptMessageHandler`)
Frontend actions communicate with the host via `window.webkit.messageHandlers.nativeApp.postMessage(message)`:
- `documentEdited`: Notifies AppKit of modified document state (`isDirty`), updating the native macOS window edited status and title indicators.
- `saveFile`: Prompts an `NSSavePanel` for untitled buffers or writes directly to existing file descriptors on disk.
- `saveMultipleFiles`: Triggers batch file writes during multi-tab close operations.
- `reloadTabFromFile`: Requests fresh file content from disk when restoring or refreshing file-backed tabs.
- `didFinishSavingAllDirtyDocuments`: Signals completion of dirty tab prompts during window close or application quit events.
- `print`: Invokes the native macOS print dialog for PDF generation or physical printing.

### Swift to JavaScript (`evaluateJavaScript`)
Native menu items (<kbd>Cmd</kbd>+<kbd>S</kbd>, <kbd>Cmd</kbd>+<kbd>Z</kbd>, <kbd>Cmd</kbd>+<kbd>O</kbd>, etc.) and life-cycle events dispatch evaluated JavaScript directly to the active web view:
- `window.openDocumentFromHost(filePath, content)`: Loads external files opened via Finder or the terminal CLI.
- `window.promptDirtySaveOnWindowClose()`: Executes the async dirty-document verification chain.
- `window.editorUndo()` / `window.editorRedo()`: Dispatches undo/redo operations to the active tab's independent history stack.
- `window.openFindBar()` / `window.openSettingsModal()`: Opens modal overlays via keyboard shortcuts.

### Async Continuation State Machine
Window close (<kbd>Shift</kbd>+<kbd>Cmd</kbd>+<kbd>W</kbd>) and application termination (<kbd>Cmd</kbd>+<kbd>Q</kbd>) use an asynchronous continuation state machine (`PendingSaveContinuation`). If unsaved tabs exist, termination halts while the user is prompted sequentially for each dirty document, ensuring no edits are inadvertently discarded.

---

## 2. Dual-Canvas Editing & Bidirectional Synchronization

Markdown Viewer features a dual-canvas editing model supporting seamless transitions between raw markdown syntax and direct visual editing:

1. **Source Canvas**: `<textarea id="editor-input">` providing syntax-aware typing, line numbers, automatic bracket pairing, and multi-line task list toggling.
2. **Rendered Canvas**: `<div id="preview-rendered" contenteditable="true">` providing direct, in-place WYSIWYG editing.

### DOM-to-Markdown Serialization (`convertDomToMarkdown`)
When edits occur within the rendered preview canvas, an AST-preserving recursive DOM serializer traverses the live DOM nodes and reconstructs clean GitHub Flavored Markdown:
- **Headings & Text**: Translates `<h1>` through `<h6>` to ATX `#` headings.
- **Task Lists**: Serializes custom 16px interactive checkboxes back into `- [ ]` and `- [x]` markdown checklist items.
- **Alert Callouts**: Preserves blockquote syntax with alert identifiers (`> [!NOTE]`, `> [!TIP]`, etc.).
- **Code Fences**: Restores language tags and code blocks without HTML artifacts.
- **Tables & Inline Elements**: Converts table rows, cells, bold (`<strong>`), italic (`<em>`), and links (`<a>`).

### Caret Preservation & Input Debouncing
To prevent destructive DOM re-renders while the user is actively typing in the preview pane, the synchronization engine utilizes:
- A non-destructive input debounce timer.
- Caret range snapshotting and restoration.
- Mutex flags (`isSyncingFromPreview`) preventing recursive update loops between the editor textarea and preview DOM.

---

## 3. Search & Navigation Subsystem

The application provides a non-modal floating Find and Replace toolbar (<kbd>Cmd</kbd>+<kbd>F</kbd> / <kbd>Cmd</kbd>+<kbd>Alt</kbd>+<kbd>F</kbd>) engineered for search without disrupting workflow:

- **Decoupled Focus Mechanics**: The search controller indexes text matches while maintaining independent focus between the search inputs and the active editor. Typing in the search bar never inadvertently steals cursor focus from the editor.
- **Match Indexing & Navigation**: Supports case-sensitive matching, whole-word filtering, regex queries, and real-time match counters (`Match X of Y`).
- **Outline Sidebar (TOC)**: An interactive outline tree (<kbd>Shift</kbd>+<kbd>Cmd</kbd>+<kbd>O</kbd>) dynamically parses document headings, provides search filtering, and tracks scroll position via a high-performance IntersectionObserver scroll-spy.

---

## 4. Preferences & Customization Architecture

User preferences are managed by a centralized, tab-scoped controller accessible via <kbd>Cmd</kbd>+<kbd>,</kbd>:

- **Tab-Scoped Settings Isolation**: Saving settings in a specific category (e.g. Editor typography) applies changes strictly to the relevant scope, eliminating cross-tab state pollution or unintended theme reversions.
- **Real-Time Live Preview**: The preferences interface contains an embedded live preview card that demonstrates typography, theme, and line-spacing changes in real time before changes are committed.
- **Built-in Color Themes**: Provides 5 carefully designed color schemes:
  - GitHub Light & GitHub Dark
  - Dracula
  - Nord Frost
  - Sepia (Warm Paper)
- **CSS Sanitization**: Custom CSS inputs are sanitized to strip `@import` external rules and tag breakout attempts, enforcing local aesthetic customization safely.

---

## 5. Multi-Format Rendering Pipeline

Documents pass through an offline, sandboxed rendering pipeline:

```
Raw Input (MD/JSON/YAML)
       │
       ▼
   Type Detector
   ├── Markdown  ──► Marked.js (GFM) ──► Alert Post-Processor ──► KaTeX Math ──► Mermaid.js ──► DOMPurify ──► Preview DOM
   ├── JSON      ──► JSON AST Parser ──► Collapsible Tree Viewer + Schema Validator ──────────► DOMPurify ──► Preview DOM
   └── YAML      ──► JS-YAML Parser  ──► Collapsible Tree Viewer + Outline Indexer ──────────► DOMPurify ──► Preview DOM
```

- **GitHub Alert Callouts**: Parses `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, and `> [!CAUTION]` into styled alert containers with localized SVG iconography.
- **Mathematical Typesetting**: Mathematical expressions delimited by `$...$` (inline) and `$$...$$` (display) are extracted prior to markdown tokenization, preserved through parsing, and rendered offline via KaTeX.
- **Diagrams**: Fenced `mermaid` code blocks are validated and rendered directly into vector SVGs with dynamic dark/light theme adjustments.

---

## 6. Defense-in-Depth Security & Threat Model

Markdown Viewer enforces a defense-in-depth security model:

1. **Zero-Network Architecture**:
   - The application makes zero outbound network requests. All dependencies (Marked, KaTeX, Mermaid, Highlight.js, js-yaml, DOMPurify) are vendored locally in `vendor/`.
2. **Strict Content Security Policy (CSP)**:
   - Configured with `default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: local-file:; font-src 'self' data:; connect-src 'none'; object-src 'none'`.
3. **DOM Sanitization**:
   - All rendered HTML passes through DOMPurify with strict attribute policies. Interactive `<input>` elements are strictly limited to disabled checkbox task markers and active preview task toggles.
4. **Local Scheme Security (`local-file://`)**:
   - Local image resolution routes through a custom `WKURLSchemeHandler`. File paths are verified to ensure valid file existence, canonical symlink resolution, and strict image MIME-type whitelisting (`png`, `jpg`, `jpeg`, `gif`, `svg`, `webp`).
5. **Session File Authorization Whitelist**:
   - The native Swift host maintains an in-memory session whitelist (`openedFiles`) verifying that file write and save operations target authorized paths opened explicitly by the user.
6. **Production Web Inspector Gating**:
   - Web Inspector developer tools and fallback path resolution are conditionally compiled under `#if DEBUG`, disabling debug instrumentation in production release binaries.

---

## 7. Dual-Channel Homebrew Distribution & Release Engineering

The project is packaged for macOS distribution through two distinct channels:

| Distribution Channel | Specification | Architecture | Target Audience |
| :--- | :--- | :--- | :--- |
| **Homebrew Cask** | `Casks/markdown-viewer.rb` | Prebuilt `.app` Bundle | General users wanting quick, one-line graphical installation. |
| **Homebrew Formula** | `Formula/markdown-viewer.rb` | Source Build (`swiftc`) | Users desiring gatekeeper-free local compilation using Command Line Tools (no Xcode.app required). |

### Automated Release Pipeline (`scripts/release.sh`)
Releases are coordinated through an automated release script that:
1. Validates SemVer tag parity across `package.json`, `Info.plist`, and `app.js`.
2. Compiles universal binaries via `scripts/build_macos.sh`.
3. Archives both the `.app` bundle (`MarkdownViewer-macOS.zip`) and source tarball.
4. Computes SHA-256 checksums and automatically updates tap formula definitions.
5. Extracts release notes directly from `CHANGELOG.md` for GitHub Releases publication.
