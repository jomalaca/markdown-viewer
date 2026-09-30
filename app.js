/**
 * Markdown Viewer — Complete Client-Side Application
 * 100% Private, Local-First, Zero External Trackers
 */

(() => {
  'use strict';

  // --- Initial Showcase Content ---
  const DEFAULT_MARKDOWN = `# Welcome to Markdown Viewer

A 100% private, local-first workspace for writing, previewing, and exporting Markdown.

> **Privacy Guarantee**: All processing happens strictly inside your browser. No documents, keystrokes, or tracking telemetry ever leave your machine.

---

## ⚡ Key Capabilities

- **Live Split-Screen Preview** with synchronized scrolling
- **GitHub Flavored Markdown (GFM)**: Tables, strikethrough, autolinks, task lists
- **LaTeX Math Equations** typeset with KaTeX
- **Mermaid Diagrams** rendered directly from code
- **Multi-Tab Documents** with instant local auto-save
- **Export Options**: Download \`.md\`, Standalone \`.html\`, or Print to PDF

---

## 📊 Interactive Task Checklist

- [x] Create a private, zero-tracking Markdown editor
- [x] Add GitHub Flavored Markdown support
- [x] Support LaTeX math equations & Mermaid diagrams
- [ ] Try creating a new tab with the **+** button above
- [ ] Export your document to PDF using **Export &rarr; Print / Save as PDF**

---

## 🧮 LaTeX Math Formulas

Inline equation: The famous mass-energy equivalence is $E = mc^2$, and the Euler identity is $e^{i\\pi} + 1 = 0$.

Display formula:
$$
\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}
$$

$$
f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!} (x - a)^n
$$

---

## 📈 Mermaid Diagrams

\`\`\`mermaid
graph TD
    A[Start Markdown Drafting] --> B{Need Diagrams or Math?}
    B -->|Yes| C[Render KaTeX & Mermaid]
    B -->|No| D[Render GFM Typography]
    C --> E[Live Preview & Sync Scroll]
    D --> E
    E --> F[Export Standalone HTML or PDF]
\`\`\`

---

## 💻 Syntax Highlighted Code

\`\`\`javascript
// Clean, reactive document statistics calculation
function calculateStats(markdownText) {
  const words = markdownText.trim() ? markdownText.trim().split(/\\s+/).length : 0;
  const chars = markdownText.length;
  const lines = markdownText.split('\\n').length;
  const readTime = Math.max(1, Math.ceil(words / 200));

  return { words, chars, lines, readTime };
}
\`\`\`

---

## 📑 Feature Comparison Table

| Feature | Markdown Viewer (Clone) | markdownviewer.org |
| :--- | :--- | :--- |
| **Privacy & Security** | 🔒 100% Local, Zero Trackers | ⚠️ AdSense + Analytics + Closed Source |
| **GFM Live Preview** | ✅ Yes | ✅ Yes |
| **LaTeX Math (KaTeX)** | ✅ Yes ($...$, $$...$$) | ✅ Yes |
| **Mermaid Diagrams** | ✅ Flowcharts, Sequence, etc. | ✅ Flowcharts, Sequence, etc. |
| **Multi-Tab Workspace** | ✅ Unlimited tabs + Auto-save | ✅ Yes |
| **Export HTML & PDF** | ✅ Standalone self-contained | ✅ Yes |
| **Custom CSS & Themes** | ✅ 5 Themes + CSS Overrides | ✅ Themes + CSS Overrides |

---

*Tip: Press <kbd>Cmd</kbd>+<kbd>B</kbd> or <kbd>Ctrl</kbd>+<kbd>B</kbd> to bold, or use the top toolbar for formatting!*
`;

  // --- State ---
  const state = {
    tabs: [],
    activeTabId: null,
    syncScroll: true,
    viewMode: 'split', // 'editor' | 'split' | 'preview'
    theme: 'github-light',
    fontSize: 15,
    fontFamily: 'system',
    customCss: '',
    sidebarOpen: true,
    isEditorScrolling: false,
    isPreviewScrolling: false
  };

  // --- DOM Elements ---
  const DOM = {
    appRoot: document.querySelector('.app-root'),
    panesContainer: document.getElementById('panes-container'),
    paneEditor: document.getElementById('pane-editor'),
    panePreview: document.getElementById('pane-preview'),
    splitterHandle: document.getElementById('splitter-handle'),
    editorInput: document.getElementById('markdown-input'),
    lineNumbers: document.getElementById('line-numbers'),
    previewBody: document.getElementById('preview-body'),
    previewRendered: document.getElementById('markdown-rendered'),
    tabsList: document.getElementById('tabs-list'),
    newTabBtn: document.getElementById('new-tab-btn'),
    sidebarOutline: document.getElementById('sidebar-outline'),
    outlineNav: document.getElementById('outline-nav'),
    toggleSidebarBtn: document.getElementById('toggle-sidebar-btn'),
    closeSidebarBtn: document.getElementById('close-sidebar-btn'),
    toggleSyncScrollBtn: document.getElementById('toggle-sync-scroll'),
    viewModeBtns: document.querySelectorAll('.view-pill'),
    openFileBtn: document.getElementById('open-file-btn'),
    fileInput: document.getElementById('file-input'),
    exportDropdown: document.getElementById('export-dropdown'),
    exportBtn: document.getElementById('export-btn'),
    exportMd: document.getElementById('export-md'),
    exportSaveAs: document.getElementById('export-save-as'),
    exportHtml: document.getElementById('export-html'),
    exportPdf: document.getElementById('export-pdf'),
    copyHtml: document.getElementById('copy-html'),
    copyRaw: document.getElementById('copy-raw'),
    quickCopyHtml: document.getElementById('quick-copy-html'),
    themeDropdown: document.getElementById('theme-dropdown'),
    themeBtn: document.getElementById('theme-btn'),
    currentThemeName: document.getElementById('current-theme-name'),
    themeOptions: document.querySelectorAll('.theme-option'),
    hljsThemeLink: document.getElementById('hljs-theme'),
    injectedCustomCss: document.getElementById('injected-custom-css'),
    openSettingsBtn: document.getElementById('open-settings-btn'),
    settingsModal: document.getElementById('settings-modal'),
    saveSettingsBtn: document.getElementById('save-settings-btn'),
    fontFamilySelect: document.getElementById('font-family-select'),
    fontSizeInput: document.getElementById('font-size-input'),
    fontSizeVal: document.getElementById('font-size-val'),
    customCssInput: document.getElementById('custom-css-input'),
    openCheatsheetBtn: document.getElementById('open-cheatsheet-btn'),
    cheatsheetModal: document.getElementById('cheatsheet-modal'),
    toolbarBtns: document.querySelectorAll('.editor-toolbar .tool-btn'),
    statsWords: document.getElementById('stats-words'),
    statsChars: document.getElementById('stats-chars'),
    statsLines: document.getElementById('stats-lines'),
    statsReadTime: document.getElementById('stats-read-time'),
    cursorPos: document.getElementById('cursor-pos'),
    saveIndicator: document.getElementById('save-indicator'),
    confirmCloseModal: document.getElementById('confirm-close-modal'),
    confirmCloseTitle: document.getElementById('confirm-close-title'),
    confirmCloseMsg: document.getElementById('confirm-close-message'),
    confirmCloseSave: document.getElementById('confirm-close-save'),
    confirmCloseDiscard: document.getElementById('confirm-close-discard'),
    confirmCloseCancel: document.getElementById('confirm-close-cancel'),
    confirmCloseX: document.getElementById('confirm-close-x')
  };

  // --- Initialize Mermaid ---
  if (window.mermaid) {
    mermaid.initialize({
      startOnLoad: false,
      theme: 'default',
      securityLevel: 'strict'
    });
  }

  // --- Configure Marked ---
  if (window.marked) {
    marked.setOptions({
      gfm: true,
      breaks: true
    });
  }

  // --- Math Processing Helper (KaTeX) ---
  function processMath(markdownText) {
    const mathBlocks = [];

    // Replace display math $$...$$
    let text = markdownText.replace(/\$\$([\s\S]*?)\$\$/g, (match, formula) => {
      const id = `MATHBLOCK_${mathBlocks.length}_XYZ`;
      let rendered = formula;
      if (window.katex) {
        try {
          rendered = katex.renderToString(formula.trim(), { displayMode: true, throwOnError: false });
        } catch (err) {
          rendered = `<span class="katex-error">${escapeHtml(err.message)}</span>`;
        }
      }
      mathBlocks.push({ id, html: rendered });
      return id;
    });

    // Replace inline math $...$ (ensure not double $ and not immediately followed/preceded by digits for currency)
    text = text.replace(/(?<!\$)\$([^\$\n\r]+?)\$(?!\$)/g, (match, formula) => {
      // Avoid currency like "$100" or "$ 20"
      if (/^\s*\d+/.test(formula)) return match;
      const id = `MATHINLINE_${mathBlocks.length}_XYZ`;
      let rendered = formula;
      if (window.katex) {
        try {
          rendered = katex.renderToString(formula.trim(), { displayMode: false, throwOnError: false });
        } catch (err) {
          rendered = `<span class="katex-error">${escapeHtml(err.message)}</span>`;
        }
      }
      mathBlocks.push({ id, html: rendered });
      return id;
    });

    return { text, mathBlocks };
  }

  function restoreMath(html, mathBlocks) {
    let result = html;
    for (const block of mathBlocks) {
      result = result.replace(block.id, block.html);
    }
    return result;
  }

  function escapeHtml(str) {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // --- Document Format Detection (Markdown vs JSON vs YAML) ---
  function detectDocumentFormat(content, tab) {
    const trimmed = (content || '').trim();
    if (!trimmed) return 'markdown';

    const fileName = (tab?.filePath || tab?.title || '').toLowerCase();
    if (fileName.endsWith('.json')) return 'json';
    if (fileName.endsWith('.yaml') || fileName.endsWith('.yml')) return 'yaml';

    // JSON auto-detection: starts with { or [ and parses successfully
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        JSON.parse(trimmed);
        return 'json';
      } catch (e) {
        if (fileName.endsWith('.json')) return 'json';
      }
    }

    // YAML auto-detection
    if (trimmed.startsWith('---')) {
      if (window.jsyaml) {
        try {
          const parsed = jsyaml.load(trimmed);
          if (typeof parsed === 'object' && parsed !== null) return 'yaml';
        } catch (e) {
          return 'yaml';
        }
      } else {
        return 'yaml';
      }
    }

    // Structured YAML key-value mapping heuristic
    const lines = trimmed.split('\n');
    const hasYamlLines = lines.some(l => /^[a-zA-Z0-9_-]+:\s+/.test(l));
    const hasMarkdownHeadings = lines.some(l => /^#+\s+/.test(l));
    const hasMarkdownTables = lines.some(l => /^\s*\|.*\|\s*$/.test(l));

    if (hasYamlLines && !hasMarkdownHeadings && !hasMarkdownTables && lines.length > 1) {
      if (window.jsyaml) {
        try {
          const parsed = jsyaml.load(trimmed);
          if (typeof parsed === 'object' && parsed !== null) return 'yaml';
        } catch (e) {}
      }
    }

    return 'markdown';
  }

  // --- Structured Data (JSON & YAML) Renderer ---
  function renderStructuredData(content, format) {
    let parsed = null;
    let syntaxError = null;
    let prettifiedText = content;

    if (format === 'json') {
      try {
        parsed = JSON.parse(content);
        prettifiedText = JSON.stringify(parsed, null, 2);
      } catch (err) {
        syntaxError = err.message;
      }
    } else if (format === 'yaml') {
      if (window.jsyaml) {
        try {
          parsed = jsyaml.load(content);
          if (parsed !== undefined && parsed !== null) {
            prettifiedText = jsyaml.dump(parsed, { indent: 2, lineWidth: -1 });
          }
        } catch (err) {
          syntaxError = err.message;
        }
      }
    }

    const currentMode = state.structuredViewMode || 'code';
    const isTree = currentMode === 'tree' && parsed !== null;

    // Item count and size calculation
    let itemCountStr = '';
    if (parsed !== null) {
      if (Array.isArray(parsed)) {
        itemCountStr = `${parsed.length} ${parsed.length === 1 ? 'item' : 'items'}`;
      } else if (typeof parsed === 'object') {
        const keyCount = Object.keys(parsed).length;
        itemCountStr = `${keyCount} ${keyCount === 1 ? 'key' : 'keys'}`;
      }
    }
    const byteSize = new Blob([content]).size;
    const sizeStr = byteSize < 1024 ? `${byteSize} B` : `${(byteSize / 1024).toFixed(1)} KB`;

    // 1. Build Header Bar
    const headerHtml = `
      <div class="structured-header">
        <div class="structured-header-left">
          <span class="format-badge ${format === 'yaml' ? 'format-yaml' : ''}">${format.toUpperCase()}</span>
          <span class="format-meta">
            ${itemCountStr ? `<span>${itemCountStr}</span><span class="format-meta-dot">•</span>` : ''}
            <span>${sizeStr}</span>
          </span>
        </div>
        <div class="structured-header-center">
          <button class="structured-view-pill ${!isTree ? 'active' : ''}" onclick="window.setStructuredView('code')" title="Syntax-highlighted code view">Code</button>
          <button class="structured-view-pill ${isTree ? 'active' : ''}" onclick="window.setStructuredView('tree')" ${parsed === null ? 'disabled' : ''} title="Interactive collapsible tree view">Tree</button>
        </div>
        <div class="structured-header-right">
          ${isTree ? `
            <button class="structured-btn" onclick="window.toggleAllTreeNodes(true)" title="Expand all nodes">Expand All</button>
            <button class="structured-btn" onclick="window.toggleAllTreeNodes(false)" title="Collapse all nodes">Collapse All</button>
          ` : ''}
          <button class="structured-btn" onclick="window.copyPrettifiedStructuredData()" title="Copy formatted 2-space indented ${format.toUpperCase()}">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>
            <span>Copy</span>
          </button>
          <button class="structured-btn" onclick="window.prettifyEditorContent()" title="Format raw content in editor textarea with 2-space indentation">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m18 14 4-4-4-4"/><path d="m6 10-4 4 4 4"/><path d="m14 4-4 16"/></svg>
            <span>Prettify Editor</span>
          </button>
        </div>
      </div>
    `;

    // 2. Syntax Error Banner (if invalid during typing)
    const errorHtml = syntaxError ? `
      <div class="structured-error-banner">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <span>Invalid ${format.toUpperCase()}: ${escapeHtml(syntaxError)}</span>
      </div>
    ` : '';

    // 3. Body View: Code View or Tree View
    let bodyHtml = '';
    if (isTree && parsed !== null) {
      bodyHtml = `
        <div class="json-tree-container" id="json-tree-root">
          ${renderTreeNodeHtml(null, parsed, true, '')}
        </div>
      `;
    } else {
      let highlighted = escapeHtml(prettifiedText);
      if (window.hljs) {
        try {
          highlighted = hljs.highlight(prettifiedText, { language: format }).value;
        } catch (e) {
          try {
            highlighted = hljs.highlightAuto(prettifiedText).value;
          } catch (e2) {}
        }
      }
      bodyHtml = `
        <div class="code-block-container structured-code-view">
          <pre><code class="hljs language-${format}">${highlighted}</code></pre>
        </div>
      `;
    }

    // Inject into preview
    DOM.previewRendered.innerHTML = `
      <div class="structured-viewer">
        ${headerHtml}
        ${errorHtml}
        ${bodyHtml}
      </div>
    `;

    // Attach tree toggle handlers
    if (isTree) {
      setupTreeToggleListeners();
    }

    // Update outline sidebar with top-level keys
    updateStructuredOutline(parsed, format);
  }

  // Helper to render tree node HTML recursively
  function renderTreeNodeHtml(key, value, isRoot, path) {
    const keyLabel = key !== null ? `<span class="json-tree-key" data-key="${escapeHtml(String(key))}">${escapeHtml(String(key))}</span><span class="json-tree-colon">:</span>` : '';
    const nodePath = isRoot ? 'root' : `${path}.${key}`;

    if (value === null) {
      return `
        <div class="json-tree-node">
          <div class="json-tree-row">
            <span class="json-tree-placeholder"></span>
            ${keyLabel}
            <span class="json-tree-null">null</span>
          </div>
        </div>
      `;
    }

    const type = typeof value;
    if (type === 'string') {
      return `
        <div class="json-tree-node">
          <div class="json-tree-row">
            <span class="json-tree-placeholder"></span>
            ${keyLabel}
            <span class="json-tree-string">"${escapeHtml(value)}"</span>
          </div>
        </div>
      `;
    } else if (type === 'number') {
      return `
        <div class="json-tree-node">
          <div class="json-tree-row">
            <span class="json-tree-placeholder"></span>
            ${keyLabel}
            <span class="json-tree-number">${value}</span>
          </div>
        </div>
      `;
    } else if (type === 'boolean') {
      return `
        <div class="json-tree-node">
          <div class="json-tree-row">
            <span class="json-tree-placeholder"></span>
            ${keyLabel}
            <span class="json-tree-boolean">${value}</span>
          </div>
        </div>
      `;
    } else if (Array.isArray(value)) {
      const childCount = value.length;
      let childrenHtml = '';
      value.forEach((item, idx) => {
        childrenHtml += renderTreeNodeHtml(idx, item, false, nodePath);
      });
      return `
        <div class="json-tree-node" data-path="${nodePath}">
          <div class="json-tree-row" onclick="window.toggleTreeNode(this)">
            <span class="json-tree-toggle">▼</span>
            ${keyLabel}
            <span class="json-tree-badge">Array[${childCount}]</span>
          </div>
          <div class="json-tree-children">
            ${childrenHtml}
          </div>
        </div>
      `;
    } else if (type === 'object') {
      const keys = Object.keys(value);
      const childCount = keys.length;
      let childrenHtml = '';
      keys.forEach((childKey) => {
        childrenHtml += renderTreeNodeHtml(childKey, value[childKey], false, nodePath);
      });
      return `
        <div class="json-tree-node" data-path="${nodePath}" id="outline-node-${isRoot ? 'root' : escapeHtml(String(key))}">
          <div class="json-tree-row" onclick="window.toggleTreeNode(this)">
            <span class="json-tree-toggle">▼</span>
            ${keyLabel}
            <span class="json-tree-badge">Object{${childCount}}</span>
          </div>
          <div class="json-tree-children">
            ${childrenHtml}
          </div>
        </div>
      `;
    }

    return '';
  }

  function setupTreeToggleListeners() {
    window.toggleTreeNode = function(rowEl) {
      if (!rowEl) return;
      const toggle = rowEl.querySelector('.json-tree-toggle');
      const children = rowEl.nextElementSibling;
      if (toggle && children) {
        const isCollapsed = children.classList.toggle('collapsed');
        toggle.classList.toggle('collapsed', isCollapsed);
      }
    };
  }

  window.setStructuredView = function(mode) {
    state.structuredViewMode = mode;
    const activeTab = state.tabs.find(t => t.id === state.activeTabId);
    if (activeTab && DOM.editorInput) {
      renderMarkdown(DOM.editorInput.value);
    }
  };

  window.toggleAllTreeNodes = function(expand) {
    const toggles = DOM.previewRendered.querySelectorAll('.json-tree-toggle');
    const children = DOM.previewRendered.querySelectorAll('.json-tree-children');
    toggles.forEach(t => t.classList.toggle('collapsed', !expand));
    children.forEach(c => c.classList.toggle('collapsed', !expand));
  };

  window.copyPrettifiedStructuredData = function() {
    const activeTab = state.tabs.find(t => t.id === state.activeTabId);
    const content = DOM.editorInput.value;
    const format = detectDocumentFormat(content, activeTab);
    let prettified = content;
    if (format === 'json') {
      try {
        prettified = JSON.stringify(JSON.parse(content), null, 2);
      } catch (e) {}
    } else if (format === 'yaml' && window.jsyaml) {
      try {
        prettified = jsyaml.dump(jsyaml.load(content), { indent: 2, lineWidth: -1 });
      } catch (e) {}
    }
    navigator.clipboard.writeText(prettified).then(() => {
      showQuickNotification('Copied formatted ' + format.toUpperCase());
    });
  };

  window.prettifyEditorContent = function() {
    if (!DOM.editorInput) return;
    const activeTab = state.tabs.find(t => t.id === state.activeTabId);
    const content = DOM.editorInput.value;
    const format = detectDocumentFormat(content, activeTab);
    let prettified = null;

    if (format === 'json') {
      try {
        prettified = JSON.stringify(JSON.parse(content), null, 2);
      } catch (e) {
        showQuickNotification('Cannot prettify invalid JSON');
        return;
      }
    } else if (format === 'yaml' && window.jsyaml) {
      try {
        prettified = jsyaml.dump(jsyaml.load(content), { indent: 2, lineWidth: -1 });
      } catch (e) {
        showQuickNotification('Cannot prettify invalid YAML');
        return;
      }
    }

    if (prettified !== null && prettified !== content) {
      DOM.editorInput.value = prettified;
      handleEditorInput();
      showQuickNotification('Prettified editor ' + format.toUpperCase());
    }
  };

  function updateStructuredOutline(parsed, format) {
    if (!parsed || typeof parsed !== 'object') {
      DOM.outlineNav.innerHTML = `<p class="outline-empty">${format.toUpperCase()} document contains scalar or empty content.</p>`;
      return;
    }

    const frag = document.createDocumentFragment();
    const keys = Array.isArray(parsed) ? parsed.map((_, i) => `[${i}]`) : Object.keys(parsed);

    if (keys.length === 0) {
      DOM.outlineNav.innerHTML = `<p class="outline-empty">No keys found in ${format.toUpperCase()} root.</p>`;
      return;
    }

    keys.forEach(key => {
      const item = document.createElement('a');
      item.className = 'outline-item h2';
      item.textContent = key;
      item.title = `${format.toUpperCase()} key: ${key}`;

      item.addEventListener('click', (e) => {
        e.preventDefault();
        // In editor: find key line and select it
        if (DOM.editorInput) {
          const text = DOM.editorInput.value;
          const searchPattern = format === 'json' ? `"${key}"` : `${key}:`;
          const index = text.indexOf(searchPattern);
          if (index !== -1) {
            DOM.editorInput.focus();
            DOM.editorInput.setSelectionRange(index, index + searchPattern.length);
          }
        }
        // In preview tree: scroll to node if in tree mode
        const targetNode = DOM.previewRendered.querySelector(`#outline-node-${escapeHtml(key)}`);
        if (targetNode) {
          targetNode.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      });

      frag.appendChild(item);
    });

    DOM.outlineNav.innerHTML = '';
    DOM.outlineNav.appendChild(frag);
  }

  // --- Local & Relative Image URL Resolver ---
  function resolveImageSrc(src, activeTab) {
    if (!src) return '';
    let trimmed = src.trim();

    // Unwrap angle brackets: <path/to/img>
    if (trimmed.startsWith('<') && trimmed.endsWith('>')) {
      trimmed = trimmed.substring(1, trimmed.length - 1).trim();
    }

    // Preserve web schemes and data URIs directly
    if (/^(https?:|data:|blob:|local-file:)/i.test(trimmed)) {
      return trimmed;
    }

    // Decode URI if already percent-encoded
    let decoded = trimmed;
    try {
      decoded = decodeURI(trimmed);
    } catch (e) {}

    const filePath = activeTab?.filePath;
    let absolutePath = '';

    if (decoded.startsWith('/')) {
      absolutePath = decoded;
    } else if (filePath) {
      const lastSlash = filePath.lastIndexOf('/');
      const docDir = lastSlash !== -1 ? filePath.substring(0, lastSlash) : '';
      const combined = docDir + '/' + decoded;
      const parts = combined.split('/');
      const resolved = [];
      for (const part of parts) {
        if (part === '' || part === '.') {
          if (resolved.length === 0) resolved.push('');
          continue;
        }
        if (part === '..') {
          if (resolved.length > 1) resolved.pop();
          continue;
        }
        resolved.push(part);
      }
      absolutePath = resolved.join('/');
    } else {
      return trimmed;
    }

    if (!absolutePath.startsWith('/')) {
      absolutePath = '/' + absolutePath;
    }

    // When running inside macOS AppKit host with local-file scheme handler
    if (window.webkit && window.webkit.messageHandlers) {
      return 'local-file://' + encodeURI(absolutePath);
    }

    return absolutePath;
  }

  // --- Render Markdown to HTML ---
  let mermaidCounter = 0;
  function renderMarkdown(content) {
    const activeTab = state.tabs.find(t => t.id === state.activeTabId);
    const format = detectDocumentFormat(content, activeTab);
    if (format === 'json' || format === 'yaml') {
      renderStructuredData(content, format);
      return;
    }

    if (!window.marked) return content;

    // Extract & process LaTeX math
    const { text, mathBlocks } = processMath(content);

    // Custom marked renderer for images, mermaid and code blocks
    const renderer = new marked.Renderer();

    renderer.image = function(arg1, arg2, arg3) {
      const href = (typeof arg1 === 'object' && arg1 !== null) ? arg1.href : arg1;
      const title = (typeof arg1 === 'object' && arg1 !== null) ? arg1.title : arg2;
      const text = (typeof arg1 === 'object' && arg1 !== null) ? arg1.text : arg3;
      const resolvedSrc = resolveImageSrc(href, activeTab);
      const titleAttr = title ? ` title="${escapeHtml(title)}"` : '';
      const altAttr = text ? ` alt="${escapeHtml(text)}"` : '';
      return `<img src="${resolvedSrc}"${altAttr}${titleAttr} loading="lazy" />`;
    };

    renderer.code = function(arg1, arg2, arg3) {
      let code = (typeof arg1 === 'object' && arg1 !== null) ? arg1.text : arg1;
      const infostring = (typeof arg1 === 'object' && arg1 !== null) ? arg1.lang : arg2;
      const lang = (infostring || '').trim().toLowerCase();
      if (lang === 'mermaid') {
        const id = `mermaid-diagram-${++mermaidCounter}`;
        return `<div class="mermaid-diagram-wrapper"><div class="mermaid" id="${id}">${escapeHtml(code)}</div></div>`;
      }

      // Prettify fenced JSON if valid
      if (lang === 'json') {
        try {
          const parsed = JSON.parse(code);
          code = JSON.stringify(parsed, null, 2);
        } catch (e) {}
      }

      // Syntax highlighting with highlight.js
      let highlighted = escapeHtml(code);
      if (window.hljs) {
        if (lang && hljs.getLanguage(lang)) {
          try {
            highlighted = hljs.highlight(code, { language: lang }).value;
          } catch (e) {
            highlighted = escapeHtml(code);
          }
        } else {
          try {
            highlighted = hljs.highlightAuto(code).value;
          } catch (e) {
            highlighted = escapeHtml(code);
          }
        }
      }

      return `
        <div class="code-block-container">
          <div class="code-block-header">
            <span>${lang || 'text'}</span>
            <button class="copy-code-btn" onclick="navigator.clipboard.writeText(decodeURIComponent('${encodeURIComponent(code)}')).then(() => { this.innerText = 'Copied!'; setTimeout(() => { this.innerText = 'Copy'; }, 1500); })">Copy</button>
          </div>
          <pre><code class="hljs language-${lang || 'plaintext'}">${highlighted}</code></pre>
        </div>
      `;
    };

    // Render marked
    let rawHtml = marked.parse(text, { renderer });

    // Restore math equations
    rawHtml = restoreMath(rawHtml, mathBlocks);

    // Sanitize with DOMPurify
    if (window.DOMPurify) {
      rawHtml = DOMPurify.sanitize(rawHtml, {
        ADD_TAGS: ['math', 'annotation', 'semantics', 'mrow', 'mi', 'mo', 'mn', 'msup', 'msub', 'mfrac', 'mover', 'munder', 'msqrt', 'mtable', 'mtr', 'mtd', 'span', 'div', 'input', 'img'],
        ADD_ATTR: ['target', 'type', 'checked', 'class', 'style', 'aria-hidden', 'viewbox', 'fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin', 'd', 'src', 'alt', 'title', 'loading', 'width', 'height'],
        ALLOWED_URI_REGEXP: /^(?:(?:(?:f|ht)tps?|mailto|tel|callto|cid|xmpp|local-file|data|file):|[^a-z]|[a-z+.\-]+(?:[^a-z+.\-:]|$))/i,
        ADD_DATA_URI_TAGS: ['img']
      });
    }

    DOM.previewRendered.innerHTML = rawHtml;

    // Resolve any raw HTML <img> tags with relative paths
    DOM.previewRendered.querySelectorAll('img').forEach(img => {
      const srcAttr = img.getAttribute('src');
      if (srcAttr) {
        const resolved = resolveImageSrc(srcAttr, activeTab);
        if (resolved && resolved !== srcAttr) {
          img.setAttribute('src', resolved);
        }
      }
    });

    // Render Mermaid diagrams
    if (window.mermaid) {
      try {
        mermaid.run({
          nodes: DOM.previewRendered.querySelectorAll('.mermaid')
        });
      } catch (err) {
        console.warn('Mermaid render issue:', err);
      }
    }

    // Attach interactive checklist handlers
    setupChecklistListeners();

    // Update Document Outline
    updateOutline();
  }

  // --- Interactive Checkboxes ---
  function setupChecklistListeners() {
    const checkboxes = DOM.previewRendered.querySelectorAll('input[type="checkbox"]');
    checkboxes.forEach((cb, index) => {
      cb.addEventListener('change', () => {
        toggleTaskCheckboxInMarkdown(index, cb.checked);
      });
    });
  }

  function toggleTaskCheckboxInMarkdown(index, isChecked) {
    const text = DOM.editorInput.value;
    const taskRegex = /^(\s*[-*+]\s+\[)([ xX])(\]\s+.*)$/gm;
    let match;
    let count = 0;
    let newText = '';
    let lastIndex = 0;

    while ((match = taskRegex.exec(text)) !== null) {
      if (count === index) {
        newText += text.substring(lastIndex, match.index);
        newText += match[1] + (isChecked ? 'x' : ' ') + match[3];
        lastIndex = match.index + match[0].length;
        break;
      }
      count++;
    }

    if (newText) {
      newText += text.substring(lastIndex);
      const start = DOM.editorInput.selectionStart;
      const end = DOM.editorInput.selectionEnd;
      DOM.editorInput.value = newText;
      DOM.editorInput.setSelectionRange(start, end);
      handleEditorInput();
    }
  }

  // --- Document Outline (TOC) ---
  function updateOutline() {
    const headings = DOM.previewRendered.querySelectorAll('h1, h2, h3, h4, h5, h6');
    if (!headings.length) {
      DOM.outlineNav.innerHTML = '<p class="outline-empty">Add headings (H1-H6) to see the table of contents here.</p>';
      return;
    }

    const frag = document.createDocumentFragment();
    headings.forEach((heading, idx) => {
      const level = heading.tagName.toLowerCase();
      const id = heading.id || `heading-${idx}`;
      heading.id = id;

      const item = document.createElement('a');
      item.className = `outline-item ${level}`;
      item.href = `#${id}`;
      item.textContent = heading.textContent.trim();
      item.title = heading.textContent.trim();

      item.addEventListener('click', (e) => {
        e.preventDefault();
        heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
      });

      frag.appendChild(item);
    });

    DOM.outlineNav.innerHTML = '';
    DOM.outlineNav.appendChild(frag);
  }

  // --- Line Numbers & Caret Stats ---
  function updateLineNumbers() {
    const lines = DOM.editorInput.value.split('\n').length;
    let numbersText = '';
    for (let i = 1; i <= lines; i++) {
      numbersText += i + '\n';
    }
    DOM.lineNumbers.textContent = numbersText;
  }

  function updateDocumentStats() {
    const text = DOM.editorInput.value;
    const words = text.trim() ? text.trim().split(/\s+/).length : 0;
    const chars = text.length;
    const lines = text.split('\n').length;
    const readMinutes = Math.max(1, Math.ceil(words / 200));

    DOM.statsWords.textContent = `${words.toLocaleString()} ${words === 1 ? 'word' : 'words'}`;
    DOM.statsChars.textContent = `${chars.toLocaleString()} ${chars === 1 ? 'character' : 'characters'}`;
    DOM.statsLines.textContent = `${lines.toLocaleString()} ${lines === 1 ? 'line' : 'lines'}`;
    DOM.statsReadTime.textContent = words === 0 ? '< 1 min read' : `${readMinutes} min read`;
  }

  function updateCursorPos() {
    const pos = DOM.editorInput.selectionStart;
    const textBefore = DOM.editorInput.value.substring(0, pos);
    const line = textBefore.split('\n').length;
    const col = pos - textBefore.lastIndexOf('\n');
    DOM.cursorPos.textContent = `Ln ${line}, Col ${col}`;
  }

  // --- Synchronized Scrolling ---
  function setupSyncScroll() {
    DOM.editorInput.addEventListener('scroll', () => {
      // Sync line numbers
      DOM.lineNumbers.scrollTop = DOM.editorInput.scrollTop;

      if (!state.syncScroll || state.isPreviewScrolling) return;
      state.isEditorScrolling = true;

      const editorScrollable = DOM.editorInput.scrollHeight - DOM.editorInput.clientHeight;
      if (editorScrollable > 0) {
        const ratio = DOM.editorInput.scrollTop / editorScrollable;
        const previewScrollable = DOM.previewBody.scrollHeight - DOM.previewBody.clientHeight;
        DOM.previewBody.scrollTop = ratio * previewScrollable;
      }

      setTimeout(() => { state.isEditorScrolling = false; }, 60);
    });

    DOM.previewBody.addEventListener('scroll', () => {
      if (!state.syncScroll || state.isEditorScrolling) return;
      state.isPreviewScrolling = true;

      const previewScrollable = DOM.previewBody.scrollHeight - DOM.previewBody.clientHeight;
      if (previewScrollable > 0) {
        const ratio = DOM.previewBody.scrollTop / previewScrollable;
        const editorScrollable = DOM.editorInput.scrollHeight - DOM.editorInput.clientHeight;
        DOM.editorInput.scrollTop = ratio * editorScrollable;
        DOM.lineNumbers.scrollTop = DOM.editorInput.scrollTop;
      }

      setTimeout(() => { state.isPreviewScrolling = false; }, 60);
    });
  }

  // --- Editor History (Undo/Redo Manager) ---
  const EditorHistory = {
    history: [],
    index: -1,
    maxSize: 150,
    isApplying: false,
    debounceTimer: null,

    init(initialText) {
      clearTimeout(this.debounceTimer);
      this.history = [{
        text: initialText || '',
        start: 0,
        end: 0
      }];
      this.index = 0;
    },

    getState() {
      return {
        history: [...this.history],
        index: this.index
      };
    },

    restoreState(savedState, fallbackText = '') {
      clearTimeout(this.debounceTimer);
      if (savedState && Array.isArray(savedState.history) && savedState.history.length > 0) {
        this.history = [...savedState.history];
        this.index = Math.max(0, Math.min(savedState.index, this.history.length - 1));
      } else {
        this.init(fallbackText);
      }
    },

    commitPending() {
      clearTimeout(this.debounceTimer);
      if (!DOM.editorInput) return;
      const currentText = DOM.editorInput.value;
      if (this.index >= 0 && this.history[this.index]?.text === currentText) {
        this.history[this.index].start = DOM.editorInput.selectionStart;
        this.history[this.index].end = DOM.editorInput.selectionEnd;
        return;
      }
      this.history = this.history.slice(0, this.index + 1);
      this.history.push({
        text: currentText,
        start: DOM.editorInput.selectionStart,
        end: DOM.editorInput.selectionEnd
      });
      if (this.history.length > this.maxSize) {
        this.history.shift();
      } else {
        this.index++;
      }
    },

    push(text, start, end, immediate = false) {
      if (this.isApplying) return;

      const performPush = () => {
        if (this.index >= 0 && this.history[this.index]?.text === text) {
          if (this.history[this.index]) {
            this.history[this.index].start = start;
            this.history[this.index].end = end;
          }
          return;
        }

        // Truncate redo states
        this.history = this.history.slice(0, this.index + 1);
        this.history.push({ text, start, end });
        if (this.history.length > this.maxSize) {
          this.history.shift();
        } else {
          this.index++;
        }
      };

      clearTimeout(this.debounceTimer);
      if (immediate) {
        performPush();
      } else {
        this.debounceTimer = setTimeout(performPush, 350);
      }
    },

    undo() {
      if (!DOM.editorInput) return false;
      // If there are uncommitted changes currently in the textarea, commit them first
      if (this.index >= 0 && this.history[this.index]?.text !== DOM.editorInput.value) {
        this.commitPending();
      } else {
        clearTimeout(this.debounceTimer);
      }

      if (this.index > 0) {
        this.index--;
        const item = this.history[this.index];
        this.apply(item);
        return true;
      }
      return false;
    },

    redo() {
      clearTimeout(this.debounceTimer);
      if (this.index < this.history.length - 1) {
        this.index++;
        const item = this.history[this.index];
        this.apply(item);
        return true;
      }
      return false;
    },

    apply(item) {
      if (!item || !DOM.editorInput) return;
      this.isApplying = true;
      DOM.editorInput.value = item.text;
      DOM.editorInput.setSelectionRange(item.start, item.end);
      DOM.editorInput.focus();
      handleEditorInput(true);
      this.isApplying = false;
    }
  };

  // --- Tabs Management ---
  function createTab(title = 'Untitled.md', content = '') {
    const id = 'doc_' + Date.now() + '_' + Math.random().toString(36).substring(2, 7);
    const newTab = { id, title, content, savedContent: content, filePath: null, isDirty: false };
    state.tabs.push(newTab);
    setActiveTab(id);
    saveToStorage();
    renderTabs();
    updateSaveIndicator();
    return newTab;
  }

  function updateSaveIndicator() {
    const active = state.tabs.find(t => t.id === state.activeTabId);
    if (!active || !DOM.saveIndicator) return;

    const textEl = DOM.saveIndicator.querySelector('span:last-child');
    if (active.isDirty) {
      DOM.saveIndicator.classList.remove('clean');
      DOM.saveIndicator.classList.add('dirty');
      if (textEl) textEl.textContent = 'Unsaved changes';
    } else {
      DOM.saveIndicator.classList.remove('dirty');
      DOM.saveIndicator.classList.add('clean');
      if (textEl) textEl.textContent = active.filePath ? 'Saved to disk' : 'Saved locally';
    }

    const hasAnyDirtyTab = state.tabs.some(t => !!t.isDirty);
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        action: 'setDocumentEdited',
        isEdited: hasAnyDirtyTab
      });
    }
  }

  function setActiveTab(id) {
    // Save history of outgoing tab
    const previousTab = state.tabs.find(t => t.id === state.activeTabId);
    if (previousTab && DOM.editorInput) {
      if (EditorHistory.index >= 0 && EditorHistory.history[EditorHistory.index]?.text !== DOM.editorInput.value) {
        EditorHistory.commitPending();
      }
      previousTab.historyState = EditorHistory.getState();
    }

    state.activeTabId = id;
    const active = state.tabs.find(t => t.id === id);
    if (active) {
      DOM.editorInput.value = active.content;
      EditorHistory.restoreState(active.historyState, active.content);
      renderMarkdown(active.content);
      updateLineNumbers();
      updateDocumentStats();
      updateCursorPos();
      renderTabs();
      updateSaveIndicator();

      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
        window.webkit.messageHandlers.nativeApp.postMessage({
          action: 'activeTabChanged',
          title: active.title,
          filePath: active.filePath || null
        });
      }
    }
  }

  let pendingCloseTabId = null;
  let pendingCloseAfterSaveTabId = null;

  function closeTab(id, force = false) {
    const tab = state.tabs.find(t => t.id === id);
    if (!tab) return;

    if (tab.isDirty && !force) {
      pendingCloseTabId = id;
      if (DOM.confirmCloseTitle) {
        DOM.confirmCloseTitle.textContent = `Save changes to "${tab.title}"?`;
      }
      if (DOM.confirmCloseMsg) {
        DOM.confirmCloseMsg.textContent = `The document has unsaved modifications. Your changes will be lost if you don't save them.`;
      }
      if (DOM.confirmCloseModal) {
        DOM.confirmCloseModal.style.display = 'flex';
      }
      return;
    }

    if (state.tabs.length <= 1) {
      // Don't close last tab; just reset it
      state.tabs[0].title = 'Untitled.md';
      state.tabs[0].content = '';
      state.tabs[0].savedContent = '';
      state.tabs[0].filePath = null;
      state.tabs[0].isDirty = false;
      setActiveTab(state.tabs[0].id);
      saveToStorage();
      renderTabs();
      updateSaveIndicator();
      return;
    }

    const idx = state.tabs.findIndex(t => t.id === id);
    if (idx === -1) return;

    state.tabs.splice(idx, 1);
    if (state.activeTabId === id) {
      const nextIdx = Math.max(0, idx - 1);
      setActiveTab(state.tabs[nextIdx].id);
    }
    saveToStorage();
    renderTabs();
    updateSaveIndicator();
  }

  function selectTabByIndex(index) {
    if (!state.tabs.length) return;
    let targetIdx = index;
    if (index < 0 || index >= state.tabs.length) {
      targetIdx = state.tabs.length - 1;
    }
    const targetTab = state.tabs[targetIdx];
    if (targetTab) {
      setActiveTab(targetTab.id);
    }
  }

  function cycleTab(direction = 1) {
    if (state.tabs.length <= 1) return;
    const currentIdx = state.tabs.findIndex(t => t.id === state.activeTabId);
    let nextIdx = (currentIdx + direction) % state.tabs.length;
    if (nextIdx < 0) nextIdx = state.tabs.length - 1;
    setActiveTab(state.tabs[nextIdx].id);
  }

  window.selectTabByIndex = selectTabByIndex;
  window.cycleTab = cycleTab;

  function renameTab(id, newTitle) {
    const tab = state.tabs.find(t => t.id === id);
    if (tab && newTitle.trim()) {
      tab.title = newTitle.trim();
      saveToStorage();
      renderTabs();
      if (tab.id === state.activeTabId && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
        window.webkit.messageHandlers.nativeApp.postMessage({
          action: 'setTitle',
          title: tab.title
        });
      }
    }
  }

  // --- Native Host Integration (macOS Swift App) ---
  window.openDocumentFromHost = function(title, content, filePath) {
    if (!title) title = 'Untitled.md';
    if (content === undefined || content === null) content = '';

    // Check if a tab with this title or path already exists
    const existing = state.tabs.find(t => (t.filePath && t.filePath === filePath) || t.title === title);
    if (existing) {
      existing.content = content;
      existing.savedContent = content;
      existing.filePath = filePath;
      existing.title = title;
      existing.isDirty = false;
      setActiveTab(existing.id);
      updateSaveIndicator();
    } else {
      const newTab = createTab(title, content);
      newTab.filePath = filePath;
      newTab.savedContent = content;
      newTab.isDirty = false;
      saveToStorage();
      renderTabs();
      updateSaveIndicator();
    }
  };

  window.onFileSavedFromHost = function(tabId, filePath, title) {
    const tab = state.tabs.find(t => t.id === tabId) || state.tabs.find(t => t.id === state.activeTabId);
    if (tab) {
      tab.filePath = filePath;
      tab.title = title;
      tab.savedContent = tab.content;
      tab.isDirty = false;
      renderTabs();
      updateSaveIndicator();
      saveToStorage();
      showQuickNotification('Saved: ' + title);

      if (pendingCloseAfterSaveTabId === tab.id) {
        const toClose = pendingCloseAfterSaveTabId;
        pendingCloseAfterSaveTabId = null;
        closeTab(toClose, true);
      }
    }
  };

  window.saveDocumentFromHost = function(saveAs = false) {
    saveCurrentDocument(saveAs);
  };

  window.saveAllDirtyDocumentsFromHost = function() {
    const dirtyTabs = state.tabs.filter(t => !!t.isDirty);
    if (dirtyTabs.length === 0) {
      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
        window.webkit.messageHandlers.nativeApp.postMessage({ action: 'allDirtyTabsSaved' });
      }
      return;
    }

    // Ensure active tab content includes in-flight editor textarea value
    const active = state.tabs.find(t => t.id === state.activeTabId);
    if (active && DOM.editorInput) {
      active.content = DOM.editorInput.value;
    }

    const payload = dirtyTabs.map(t => ({
      id: t.id,
      title: t.title,
      filePath: t.filePath || null,
      content: (t.id === state.activeTabId && DOM.editorInput) ? DOM.editorInput.value : t.content
    }));

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        action: 'saveMultipleFiles',
        tabs: payload
      });
    }
  };

  window.exportHtmlFromHost = function() {
    exportStandaloneHtml();
  };

  window.editorUndo = function() {
    return EditorHistory.undo();
  };

  window.editorRedo = function() {
    return EditorHistory.redo();
  };

  window.updateTabContentFromFile = function(tabId, content, filePath) {
    const tab = state.tabs.find(t => t.id === tabId);
    if (tab) {
      tab.content = content;
      tab.savedContent = content;
      tab.filePath = filePath;
      tab.isDirty = false;
      if (tab.id === state.activeTabId && DOM.editorInput) {
        DOM.editorInput.value = content;
        renderMarkdown(content);
        updateLineNumbers();
        updateDocumentStats();
        updateCursorPos();
        updateSaveIndicator();
      }
      renderTabs();
      saveToStorage();
    }
  };

  function renderTabs() {
    DOM.tabsList.innerHTML = '';
    state.tabs.forEach(tab => {
      const tabEl = document.createElement('div');
      tabEl.className = `tab-item ${tab.id === state.activeTabId ? 'active' : ''}`;
      tabEl.setAttribute('data-tab-id', tab.id);

      const titleSpan = document.createElement('span');
      titleSpan.className = 'tab-title';
      titleSpan.textContent = tab.title;

      // Double-click to rename
      titleSpan.addEventListener('dblclick', (e) => {
        e.stopPropagation();
        const currentName = tab.title;
        const input = document.createElement('input');
        input.type = 'text';
        input.value = currentName;
        input.className = 'form-control';
        input.style.width = '120px';
        input.style.height = '24px';
        input.style.fontSize = '12px';
        input.style.padding = '2px 6px';

        const finishRename = () => {
          if (input.value.trim()) {
            renameTab(tab.id, input.value.trim());
          } else {
            renderTabs();
          }
        };

        input.addEventListener('blur', finishRename);
        input.addEventListener('keydown', (ke) => {
          if (ke.key === 'Enter') finishRename();
          if (ke.key === 'Escape') renderTabs();
        });

        tabEl.replaceChild(input, titleSpan);
        input.focus();
        input.select();
      });

      const closeBtn = document.createElement('button');
      closeBtn.className = 'tab-close';
      closeBtn.innerHTML = '&times;';
      closeBtn.title = 'Close tab';
      closeBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        closeTab(tab.id);
      });

      tabEl.appendChild(titleSpan);
      if (tab.isDirty) {
        const dot = document.createElement('span');
        dot.className = 'tab-dirty-dot';
        dot.title = 'Unsaved changes';
        tabEl.appendChild(dot);
      }
      tabEl.appendChild(closeBtn);

      tabEl.addEventListener('click', () => {
        setActiveTab(tab.id);
      });

      DOM.tabsList.appendChild(tabEl);
    });
  }

  // --- Local Storage Persistence ---
  let isRestoring = false;

  function saveToStorage() {
    if (isRestoring) return;
    const currentTab = state.tabs.find(t => t.id === state.activeTabId);
    if (currentTab && DOM.editorInput) {
      currentTab.content = DOM.editorInput.value;
    }

    try {
      localStorage.setItem('mv_documents', JSON.stringify(state.tabs));
      localStorage.setItem('mv_active_tab_id', state.activeTabId);
      localStorage.setItem('mv_theme', state.theme);
      localStorage.setItem('mv_sync_scroll', String(state.syncScroll));
      localStorage.setItem('mv_view_mode', state.viewMode);
      localStorage.setItem('mv_font_family', state.fontFamily);
      localStorage.setItem('mv_font_size', String(state.fontSize));
      localStorage.setItem('mv_custom_css', state.customCss);
    } catch (e) {
      console.warn('LocalStorage save failed:', e);
    }
  }

  function loadFromStorage() {
    isRestoring = true;
    try {
      const savedDocs = localStorage.getItem('mv_documents');
      const savedActive = localStorage.getItem('mv_active_tab_id');
      const savedTheme = localStorage.getItem('mv_theme');
      const savedSync = localStorage.getItem('mv_sync_scroll');
      const savedView = localStorage.getItem('mv_view_mode');
      const savedFontFamily = localStorage.getItem('mv_font_family');
      const savedFontSize = localStorage.getItem('mv_font_size');
      const savedCustomCss = localStorage.getItem('mv_custom_css');

      if (savedDocs) {
        state.tabs = JSON.parse(savedDocs);
        state.tabs.forEach(t => {
          if (t.savedContent === undefined) t.savedContent = t.content;
        });
      }
      if (!state.tabs.length) {
        state.tabs = [{
          id: 'doc_welcome',
          title: 'Welcome.md',
          content: DEFAULT_MARKDOWN,
          savedContent: DEFAULT_MARKDOWN,
          filePath: null,
          isDirty: false
        }];
      }

      state.activeTabId = savedActive && state.tabs.some(t => t.id === savedActive)
        ? savedActive
        : state.tabs[0].id;

      // 1. Restore active tab into DOM.editorInput FIRST so textarea matches document content
      setActiveTab(state.activeTabId);
      renderTabs();

      // 2. Apply appearance and view settings safely
      if (savedTheme) applyTheme(savedTheme);
      if (savedSync !== null) setSyncScroll(savedSync === 'true');
      if (savedView) setViewMode(savedView);
      if (savedFontFamily) applyFontFamily(savedFontFamily);
      if (savedFontSize) applyFontSize(parseInt(savedFontSize, 10));
      if (savedCustomCss) applyCustomCss(savedCustomCss);

      // 3. Disk auto-recovery check: if any restored tab has a filePath on disk but its content is empty, reload it from disk
      state.tabs.forEach(t => {
        if (t.filePath && (!t.content || t.content.trim() === '')) {
          if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
            window.webkit.messageHandlers.nativeApp.postMessage({
              action: 'reloadTabFromFile',
              tabId: t.id,
              filePath: t.filePath
            });
          }
        }
      });
    } catch (e) {
      console.error('Error restoring settings:', e);
      createTab('Welcome.md', DEFAULT_MARKDOWN);
    } finally {
      isRestoring = false;
    }
  }

  // --- Formatting Helpers ---
  function toggleFormatting(type) {
    const input = DOM.editorInput;
    const start = input.selectionStart;
    const end = input.selectionEnd;
    const val = input.value;
    const selected = val.substring(start, end);

    const delim = (type === 'bold') ? '**' : '*';
    const delimLen = delim.length;

    EditorHistory.push(val, start, end, true);

    if (start === end) {
      const pair = delim + delim;
      input.value = val.substring(0, start) + pair + val.substring(end);
      const newPos = start + delimLen;
      input.setSelectionRange(newPos, newPos);
      input.focus();
      handleEditorInput();
      EditorHistory.push(input.value, newPos, newPos, true);
      return;
    }

    let isWrapped = false;
    let isSurrounded = false;

    if (type === 'bold') {
      if (selected.length >= 4 && selected.startsWith('**') && selected.endsWith('**')) {
        isWrapped = true;
      } else if (start >= 2 && end + 2 <= val.length &&
                 val.substring(start - 2, start) === '**' &&
                 val.substring(end, end + 2) === '**') {
        isSurrounded = true;
      }
    } else if (type === 'italic') {
      const startsSingle = selected.startsWith('*') && !selected.startsWith('**');
      const endsSingle = selected.endsWith('*') && !selected.endsWith('**');
      if (selected.length >= 2 && startsSingle && endsSingle) {
        isWrapped = true;
      } else if (start >= 1 && end + 1 <= val.length &&
                 val[start - 1] === '*' && (start < 2 || val[start - 2] !== '*') &&
                 val[end] === '*' && (end + 1 >= val.length || val[end + 1] !== '*')) {
        isSurrounded = true;
      }
    }

    if (isWrapped) {
      const unwrapped = selected.substring(delimLen, selected.length - delimLen);
      input.value = val.substring(0, start) + unwrapped + val.substring(end);
      const newEnd = start + unwrapped.length;
      input.setSelectionRange(start, newEnd);
      input.focus();
      handleEditorInput();
      EditorHistory.push(input.value, start, newEnd, true);
      return;
    }

    if (isSurrounded) {
      input.value = val.substring(0, start - delimLen) + selected + val.substring(end + delimLen);
      const newStart = start - delimLen;
      const newEnd = newStart + selected.length;
      input.setSelectionRange(newStart, newEnd);
      input.focus();
      handleEditorInput();
      EditorHistory.push(input.value, newStart, newEnd, true);
      return;
    }

    const wrapped = delim + selected + delim;
    input.value = val.substring(0, start) + wrapped + val.substring(end);
    const newStart = start + delimLen;
    const newEnd = newStart + selected.length;
    input.setSelectionRange(newStart, newEnd);
    input.focus();
    handleEditorInput();
    EditorHistory.push(input.value, newStart, newEnd, true);
  }

  function insertFormatting(prefix, suffix = '', defaultText = '') {
    const input = DOM.editorInput;
    const start = input.selectionStart;
    const end = input.selectionEnd;
    const selected = input.value.substring(start, end);
    const replacement = prefix + (selected || defaultText) + suffix;

    EditorHistory.push(input.value, start, end, true);

    input.value = input.value.substring(0, start) + replacement + input.value.substring(end);

    const newCursor = selected
      ? start + replacement.length
      : start + prefix.length;

    input.setSelectionRange(newCursor, newCursor);
    input.focus();
    handleEditorInput();

    EditorHistory.push(input.value, newCursor, newCursor, true);
  }

  function handleEditorInput(fromHistory = false) {
    const isFromHistory = fromHistory === true;
    const text = DOM.editorInput.value;
    const currentTab = state.tabs.find(t => t.id === state.activeTabId);
    if (currentTab) {
      currentTab.content = text;
      const wasDirty = currentTab.isDirty;
      const expectedCleanText = currentTab.savedContent !== undefined ? currentTab.savedContent : '';
      currentTab.isDirty = (text !== expectedCleanText);
      if (wasDirty !== currentTab.isDirty) {
        renderTabs();
        updateSaveIndicator();
      }
    }

    if (!isFromHistory) {
      const pos = DOM.editorInput.selectionStart;
      const lastChar = text[pos - 1];
      const isWordBoundary = lastChar === ' ' || lastChar === '\n' || lastChar === '\t';
      EditorHistory.push(text, DOM.editorInput.selectionStart, DOM.editorInput.selectionEnd, isWordBoundary);
    }

    renderMarkdown(text);
    updateLineNumbers();
    updateDocumentStats();
    updateCursorPos();

    // Debounced local storage save
    clearTimeout(saveTimeout);
    saveTimeout = setTimeout(saveToStorage, 300);
  }
  let saveTimeout = null;

  // --- Toolbar Commands Map ---
  const TOOLBAR_COMMANDS = {
    undo: () => EditorHistory.undo(),
    redo: () => EditorHistory.redo(),
    bold: () => toggleFormatting('bold'),
    italic: () => toggleFormatting('italic'),
    strike: () => insertFormatting('~~', '~~', 'strikethrough text'),
    h1: () => insertFormatting('# ', '', 'Heading 1'),
    h2: () => insertFormatting('## ', '', 'Heading 2'),
    h3: () => insertFormatting('### ', '', 'Heading 3'),
    'inline-code': () => insertFormatting('`', '`', 'code'),
    'code-block': () => insertFormatting('```javascript\n', '\n```\n', '// code here'),
    quote: () => insertFormatting('> ', '', 'Quote'),
    link: () => insertFormatting('[', '](https://example.com)', 'link title'),
    image: () => insertFormatting('![', '](https://placehold.co/600x400)', 'alt text'),
    table: () => insertFormatting('| Header 1 | Header 2 |\n| :--- | :--- |\n| Cell 1 | Cell 2 |\n'),
    'task-list': () => insertFormatting('- [ ] ', '', 'New task'),
    math: () => insertFormatting('$$\n', '\n$$', 'E = mc^2'),
    mermaid: () => insertFormatting('```mermaid\ngraph TD\n    A[Start] --> B[End]\n```\n')
  };

  // --- View Mode Controls ---
  function setViewMode(mode) {
    state.viewMode = mode;
    DOM.panesContainer.classList.remove('view-editor', 'view-split', 'view-preview');
    DOM.panesContainer.classList.add(`view-${mode}`);

    DOM.viewModeBtns.forEach(btn => {
      btn.classList.toggle('active', btn.dataset.mode === mode);
    });
    saveToStorage();
  }

  function setSyncScroll(enabled) {
    state.syncScroll = enabled;
    DOM.toggleSyncScrollBtn.classList.toggle('active', enabled);
    saveToStorage();
  }

  // --- Splitter Drag Logic ---
  let isDraggingSplitter = false;
  function setupSplitter() {
    DOM.splitterHandle.addEventListener('mousedown', (e) => {
      if (state.viewMode !== 'split') return;
      isDraggingSplitter = true;
      DOM.splitterHandle.classList.add('dragging');
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
    });

    window.addEventListener('mousemove', (e) => {
      if (!isDraggingSplitter) return;
      const containerRect = DOM.panesContainer.getBoundingClientRect();
      const offset = e.clientX - containerRect.left;
      const percentage = Math.min(80, Math.max(20, (offset / containerRect.width) * 100));

      DOM.paneEditor.style.flex = `0 0 ${percentage}%`;
      DOM.panePreview.style.flex = `0 0 ${100 - percentage}%`;
    });

    window.addEventListener('mouseup', () => {
      if (isDraggingSplitter) {
        isDraggingSplitter = false;
        DOM.splitterHandle.classList.remove('dragging');
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
      }
    });
  }

  // --- Themes & Highlighting ---
  const THEME_NAMES = {
    'github-light': 'GitHub Light',
    'github-dark': 'GitHub Dark',
    'dracula': 'Dracula',
    'nord': 'Nord',
    'sepia': 'Sepia Warm'
  };

  function applyTheme(themeKey) {
    if (!THEME_NAMES[themeKey]) themeKey = 'github-light';
    state.theme = themeKey;
    document.documentElement.setAttribute('data-theme', themeKey);
    DOM.currentThemeName.textContent = THEME_NAMES[themeKey];

    DOM.themeOptions.forEach(opt => {
      const themeVal = opt.dataset.targetTheme || opt.dataset.theme;
      opt.classList.toggle('active', themeVal === themeKey);
    });

    // Update highlight.js theme stylesheet
    if (DOM.hljsThemeLink) {
      if (themeKey === 'github-dark' || themeKey === 'dracula' || themeKey === 'nord') {
        DOM.hljsThemeLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css';
      } else {
        DOM.hljsThemeLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css';
      }
    }

    saveToStorage();
  }

  function applyFontFamily(font) {
    state.fontFamily = font;
    let family = '-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif';
    if (font === 'serif') {
      family = 'Merriweather, Georgia, "Times New Roman", serif';
    } else if (font === 'mono') {
      family = 'ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace';
    }
    document.documentElement.style.setProperty('--font-family-body', family);
    DOM.fontFamilySelect.value = font;
  }

  function applyFontSize(size) {
    state.fontSize = size;
    document.documentElement.style.setProperty('--editor-font-size', `${size}px`);
    document.documentElement.style.setProperty('--preview-font-size', `${size + 1}px`);
    DOM.fontSizeInput.value = size;
    DOM.fontSizeVal.textContent = `${size}px`;
  }

  function applyCustomCss(css) {
    state.customCss = css;
    DOM.injectedCustomCss.textContent = css;
    DOM.customCssInput.value = css;
  }

  // --- File Open & Drag-and-Drop ---
  function openFile(file) {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (e) => {
      createTab(file.name, e.target.result);
    };
    reader.readAsText(file);
  }

  function openFileDialog() {
    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({ action: 'openFileDialog' });
    } else {
      DOM.fileInput.click();
    }
  }

  function setupFileHandling() {
    DOM.openFileBtn.addEventListener('click', openFileDialog);

    DOM.fileInput.addEventListener('change', (e) => {
      const file = e.target.files[0];
      if (file) openFile(file);
      DOM.fileInput.value = '';
    });

    // Window drag and drop
    window.addEventListener('dragover', (e) => {
      e.preventDefault();
      e.stopPropagation();
    });

    window.addEventListener('drop', (e) => {
      e.preventDefault();
      e.stopPropagation();
      if (e.dataTransfer && e.dataTransfer.files.length) {
        Array.from(e.dataTransfer.files).forEach(file => openFile(file));
      }
    });
  }

  // --- Export Actions ---
  function downloadFile(content, fileName, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function saveCurrentDocument(saveAs = false) {
    const currentTab = state.tabs.find(t => t.id === state.activeTabId) || { title: 'Untitled.md' };
    const content = DOM.editorInput.value;
    let fileName = currentTab.title;
    const hasExt = /\.(md|markdown|json|yaml|yml|txt)$/i.test(fileName);
    if (!hasExt) {
      const format = detectDocumentFormat(content, currentTab);
      fileName += (format === 'json' ? '.json' : (format === 'yaml' ? '.yaml' : '.md'));
    }

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        action: 'saveFile',
        tabId: currentTab.id,
        title: currentTab.title,
        filePath: currentTab.filePath || null,
        content: content,
        saveAs: saveAs
      });
      return;
    }

    // Web fallback
    const mime = fileName.endsWith('.json') ? 'application/json' : (fileName.endsWith('.yaml') || fileName.endsWith('.yml') ? 'text/yaml' : 'text/markdown;charset=utf-8');
    downloadFile(content, fileName, mime);
    currentTab.isDirty = false;
    showQuickNotification('Downloaded: ' + fileName);
  }

  function exportMarkdown() {
    saveCurrentDocument(false);
  }

  function exportStandaloneHtml() {
    const currentTab = state.tabs.find(t => t.id === state.activeTabId) || { title: 'Document' };
    const renderedContent = DOM.previewRendered.innerHTML;
    const title = currentTab.title.replace(/\.md$/i, '');

    const fullHtml = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(title)}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      line-height: 1.65;
      color: #1f2328;
      background-color: #ffffff;
      padding: 40px 20px;
    }
    .markdown-body {
      max-width: 860px;
      margin: 0 auto;
      word-wrap: break-word;
    }
    h1, h2, h3, h4, h5, h6 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25; }
    h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid #d0d7de; }
    h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid #e1e4e8; }
    pre { background-color: #f6f8fa; padding: 16px; border-radius: 8px; overflow: auto; border: 1px solid #d0d7de; }
    code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 85%; }
    p code { background-color: #f6f8fa; padding: 0.2em 0.4em; border-radius: 6px; }
    blockquote { padding: 0 1em; color: #656d76; border-left: 0.25em solid #d0d7de; margin: 0 0 16px 0; }
    table { border-collapse: collapse; width: 100%; margin: 16px 0; }
    th, td { border: 1px solid #d0d7de; padding: 6px 13px; }
    th { background-color: #f6f8fa; font-weight: 600; }
    tr:nth-child(2n) { background-color: #f6f8fa; }
    img { max-width: 100%; border-radius: 6px; }
    ${state.customCss}
  </style>
</head>
<body>
  <div class="markdown-body">
    ${renderedContent}
  </div>
</body>
</html>`;

    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
      window.webkit.messageHandlers.nativeApp.postMessage({
        action: 'exportHtml',
        title: title,
        content: fullHtml
      });
      return;
    }

    let fileName = title + '.html';
    downloadFile(fullHtml, fileName, 'text/html;charset=utf-8');
  }

  function setupExportMenu() {
    DOM.exportBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      DOM.exportDropdown.classList.toggle('open');
      DOM.themeDropdown.classList.remove('open');
    });

    DOM.exportMd.addEventListener('click', () => {
      saveCurrentDocument(false);
      DOM.exportDropdown.classList.remove('open');
    });

    if (DOM.exportSaveAs) {
      DOM.exportSaveAs.addEventListener('click', () => {
        saveCurrentDocument(true);
        DOM.exportDropdown.classList.remove('open');
      });
    }

    DOM.exportHtml.addEventListener('click', () => {
      exportStandaloneHtml();
      DOM.exportDropdown.classList.remove('open');
    });

    DOM.exportPdf.addEventListener('click', () => {
      DOM.exportDropdown.classList.remove('open');
      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
        window.webkit.messageHandlers.nativeApp.postMessage({ action: 'print' });
      } else {
        window.print();
      }
    });

    DOM.copyHtml.addEventListener('click', () => {
      navigator.clipboard.writeText(DOM.previewRendered.innerHTML);
      DOM.exportDropdown.classList.remove('open');
      showQuickNotification('Rendered HTML copied to clipboard!');
    });

    DOM.copyRaw.addEventListener('click', () => {
      navigator.clipboard.writeText(DOM.editorInput.value);
      DOM.exportDropdown.classList.remove('open');
      showQuickNotification('Markdown source copied to clipboard!');
    });

    DOM.quickCopyHtml.addEventListener('click', () => {
      navigator.clipboard.writeText(DOM.previewRendered.innerHTML);
      showQuickNotification('Rendered HTML copied!');
    });
  }

  function showQuickNotification(msg) {
    const orig = DOM.saveIndicator.querySelector('span:last-child').textContent;
    DOM.saveIndicator.querySelector('span:last-child').textContent = msg;
    setTimeout(() => {
      DOM.saveIndicator.querySelector('span:last-child').textContent = orig;
    }, 2000);
  }

  // --- Keyboard Shortcuts & Smart Indentation ---
  function setupKeyboardShortcuts() {
    window.addEventListener('keydown', (e) => {
      const isMetaOrCtrl = e.metaKey || e.ctrlKey;

      // Undo: Cmd+Z or Ctrl+Z (without Shift)
      if (isMetaOrCtrl && e.key.toLowerCase() === 'z' && !e.shiftKey) {
        e.preventDefault();
        EditorHistory.undo();
        return;
      }

      // Redo: Cmd+Shift+Z, Ctrl+Shift+Z, Cmd+Y, or Ctrl+Y
      if ((isMetaOrCtrl && e.key.toLowerCase() === 'z' && e.shiftKey) ||
          (isMetaOrCtrl && e.key.toLowerCase() === 'y')) {
        e.preventDefault();
        EditorHistory.redo();
        return;
      }

      // Save: Cmd+S or Ctrl+S
      if (isMetaOrCtrl && e.key.toLowerCase() === 's' && !e.shiftKey) {
        e.preventDefault();
        saveCurrentDocument(false);
        return;
      }

      // Save As: Cmd+Shift+S or Ctrl+Shift+S
      if (isMetaOrCtrl && e.key.toLowerCase() === 's' && e.shiftKey) {
        e.preventDefault();
        saveCurrentDocument(true);
        return;
      }

      // Toggle Outline: Cmd+Shift+O or Ctrl+Shift+O
      if (isMetaOrCtrl && e.shiftKey && e.key.toLowerCase() === 'o') {
        e.preventDefault();
        DOM.sidebarOutline.classList.toggle('collapsed');
        return;
      }

      // Open: Cmd+O or Ctrl+O (without Shift)
      if (isMetaOrCtrl && !e.shiftKey && e.key.toLowerCase() === 'o') {
        e.preventDefault();
        openFileDialog();
        return;
      }

      // Print: Cmd+P or Ctrl+P
      if (isMetaOrCtrl && e.key.toLowerCase() === 'p') {
        e.preventDefault();
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeApp) {
          window.webkit.messageHandlers.nativeApp.postMessage({ action: 'print' });
        } else {
          window.print();
        }
        return;
      }

      if (isMetaOrCtrl && e.key.toLowerCase() === 'b') {
        e.preventDefault();
        TOOLBAR_COMMANDS.bold();
        return;
      }
      if (isMetaOrCtrl && e.key.toLowerCase() === 'i') {
        e.preventDefault();
        TOOLBAR_COMMANDS.italic();
        return;
      }
      if (isMetaOrCtrl && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        TOOLBAR_COMMANDS.link();
        return;
      }
      if (isMetaOrCtrl && e.key.toLowerCase() === 't') {
        e.preventDefault();
        createTab();
        return;
      }
      // Tab Navigation: Cmd+1 through Cmd+8 (Select Tab 1-8)
      if (e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && e.key >= '1' && e.key <= '8') {
        e.preventDefault();
        const tabNum = parseInt(e.key, 10);
        selectTabByIndex(tabNum - 1);
        return;
      }

      // Tab Navigation: Cmd+9 (Select Last Tab)
      if (e.metaKey && !e.ctrlKey && !e.altKey && !e.shiftKey && e.key === '9') {
        e.preventDefault();
        selectTabByIndex(-1);
        return;
      }

      // Tab Cycling: Ctrl+Tab (forward) & Ctrl+Shift+Tab (backward)
      if (e.ctrlKey && e.key === 'Tab') {
        e.preventDefault();
        e.stopPropagation();
        cycleTab(e.shiftKey ? -1 : 1);
        return;
      }

      // View Modes (Option C): Cmd+Shift+E (Editor), Cmd+Shift+D (Split), Cmd+Shift+V (Preview)
      if (isMetaOrCtrl && e.shiftKey && e.key.toLowerCase() === 'e') {
        e.preventDefault();
        setViewMode('editor');
        return;
      }
      if (isMetaOrCtrl && e.shiftKey && e.key.toLowerCase() === 'd') {
        e.preventDefault();
        setViewMode('split');
        return;
      }
      if (isMetaOrCtrl && e.shiftKey && e.key.toLowerCase() === 'v') {
        e.preventDefault();
        setViewMode('preview');
        return;
      }
    });

    // Smart pair auto-closing & Tab indentation in textarea
    DOM.editorInput.addEventListener('keydown', (e) => {
      if (e.key === 'Tab' && !e.ctrlKey && !e.metaKey && !e.altKey) {
        e.preventDefault();
        const start = DOM.editorInput.selectionStart;
        const end = DOM.editorInput.selectionEnd;

        EditorHistory.push(DOM.editorInput.value, start, end, true);

        // Insert 2 spaces
        DOM.editorInput.value = DOM.editorInput.value.substring(0, start) + '  ' + DOM.editorInput.value.substring(end);
        DOM.editorInput.setSelectionRange(start + 2, start + 2);
        handleEditorInput();

        EditorHistory.push(DOM.editorInput.value, start + 2, start + 2, true);
      }

      // Auto-closing brackets & quotes
      const pairs = { '(': ')', '[': ']', '{': '}', '`': '`', '"': '"' };
      if (pairs[e.key] && !e.ctrlKey && !e.metaKey && !e.altKey) {
        const start = DOM.editorInput.selectionStart;
        const end = DOM.editorInput.selectionEnd;
        if (start !== end) {
          e.preventDefault();
          EditorHistory.push(DOM.editorInput.value, start, end, true);

          const selected = DOM.editorInput.value.substring(start, end);
          const closed = e.key + selected + pairs[e.key];
          DOM.editorInput.value = DOM.editorInput.value.substring(0, start) + closed + DOM.editorInput.value.substring(end);
          DOM.editorInput.setSelectionRange(start + 1, end + 1);
          handleEditorInput();

          EditorHistory.push(DOM.editorInput.value, start + 1, end + 1, true);
        }
      }
    });
  }

  // --- Modals Setup ---
  function setupModals() {
    // Open Settings
    DOM.openSettingsBtn.addEventListener('click', () => {
      DOM.settingsModal.style.display = 'flex';
    });

    // Save Settings
    DOM.saveSettingsBtn.addEventListener('click', () => {
      applyFontFamily(DOM.fontFamilySelect.value);
      applyFontSize(parseInt(DOM.fontSizeInput.value, 10));
      applyCustomCss(DOM.customCssInput.value);
      DOM.settingsModal.style.display = 'none';
      saveToStorage();
    });

    // Font size live preview in modal
    DOM.fontSizeInput.addEventListener('input', () => {
      DOM.fontSizeVal.textContent = `${DOM.fontSizeInput.value}px`;
    });

    // Open Cheatsheet
    DOM.openCheatsheetBtn.addEventListener('click', () => {
      DOM.cheatsheetModal.style.display = 'flex';
    });

    // Confirm Close Tab modal actions
    if (DOM.confirmCloseCancel) {
      DOM.confirmCloseCancel.addEventListener('click', () => {
        if (DOM.confirmCloseModal) DOM.confirmCloseModal.style.display = 'none';
        pendingCloseTabId = null;
      });
    }
    if (DOM.confirmCloseX) {
      DOM.confirmCloseX.addEventListener('click', () => {
        if (DOM.confirmCloseModal) DOM.confirmCloseModal.style.display = 'none';
        pendingCloseTabId = null;
      });
    }
    if (DOM.confirmCloseDiscard) {
      DOM.confirmCloseDiscard.addEventListener('click', () => {
        if (DOM.confirmCloseModal) DOM.confirmCloseModal.style.display = 'none';
        const tabId = pendingCloseTabId;
        pendingCloseTabId = null;
        if (tabId) closeTab(tabId, true);
      });
    }
    if (DOM.confirmCloseSave) {
      DOM.confirmCloseSave.addEventListener('click', () => {
        if (DOM.confirmCloseModal) DOM.confirmCloseModal.style.display = 'none';
        const tabId = pendingCloseTabId;
        pendingCloseTabId = null;
        if (tabId) {
          if (state.activeTabId !== tabId) setActiveTab(tabId);
          pendingCloseAfterSaveTabId = tabId;
          saveCurrentDocument(false);
        }
      });
    }

    // Modal Close buttons
    document.querySelectorAll('[data-close]').forEach(btn => {
      btn.addEventListener('click', () => {
        const modalId = btn.getAttribute('data-close');
        const modal = document.getElementById(modalId);
        if (modal) modal.style.display = 'none';
      });
    });

    // Click outside modal container to close
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
      overlay.addEventListener('click', (e) => {
        if (e.target === overlay) overlay.style.display = 'none';
      });
    });
  }

  // --- Attach All UI Listeners ---
  function setupListeners() {
    // Input & Caret Tracking
    DOM.editorInput.addEventListener('input', handleEditorInput);
    DOM.editorInput.addEventListener('click', updateCursorPos);
    DOM.editorInput.addEventListener('keyup', updateCursorPos);

    // Toolbar buttons
    DOM.toolbarBtns.forEach(btn => {
      const action = btn.dataset.action;
      if (TOOLBAR_COMMANDS[action]) {
        btn.addEventListener('click', () => TOOLBAR_COMMANDS[action]());
      }
    });

    // View mode pills
    DOM.viewModeBtns.forEach(btn => {
      btn.addEventListener('click', () => setViewMode(btn.dataset.mode));
    });

    // Sync scroll button
    DOM.toggleSyncScrollBtn.addEventListener('click', () => {
      setSyncScroll(!state.syncScroll);
    });

    // New tab button
    DOM.newTabBtn.addEventListener('click', () => {
      createTab();
    });

    // Sidebar Outline Toggle
    DOM.toggleSidebarBtn.addEventListener('click', () => {
      DOM.sidebarOutline.classList.toggle('collapsed');
    });

    DOM.closeSidebarBtn.addEventListener('click', () => {
      DOM.sidebarOutline.classList.add('collapsed');
    });

    // Theme dropdown
    DOM.themeBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      DOM.themeDropdown.classList.toggle('open');
      DOM.exportDropdown.classList.remove('open');
    });

    DOM.themeOptions.forEach(opt => {
      opt.addEventListener('click', () => {
        applyTheme(opt.dataset.targetTheme || opt.dataset.theme);
        DOM.themeDropdown.classList.remove('open');
      });
    });

    // Close open dropdowns on document click
    document.addEventListener('click', () => {
      DOM.exportDropdown.classList.remove('open');
      DOM.themeDropdown.classList.remove('open');
    });

    setupExportMenu();
    setupSplitter();
    setupSyncScroll();
    setupFileHandling();
    setupKeyboardShortcuts();
    setupModals();
  }

  // --- Init Application ---
  function init() {
    setupListeners();
    loadFromStorage();
  }

  init();
})();
