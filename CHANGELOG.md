# Changelog

All notable changes to **Markdown Viewer** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.6.0] - 2026-10-05

### Added
- **Always-On Direct Preview Editing**: Live WYSIWYG contenteditable canvas in the preview pane with real-time bidirectional synchronization back to the Markdown source and document state.
- **Modern GitHub-Style Task Checklists**: 16px rounded-square checkboxes with custom SVG checkmarks, accent color fills, and subtle completed transition on completed task text.
- **Multi-Line Task List Formatting**: Toolbar "Insert Task Checklist" toggles task checkboxes across all selected lines simultaneously.
- **In-App "What's New" Tab**: Categorized release notes and version history directly in Preferences (<kbd>Cmd</kbd> + <kbd>,</kbd>).
- **Homebrew Dual-Distribution (Formula + Cask)**: Added `Formula/markdown-viewer.rb` for source compilation alongside `Casks/markdown-viewer.rb` to eliminate macOS Gatekeeper quarantine warnings.

### Fixed
- **Find Input Focus Retention**: Fixed search input stealing focus to the editor on the first typed character.
- **Build Script Portability**: Version extraction in `scripts/build_macos.sh` hardened with `sed` fallback, removing the Node.js requirement during Homebrew formula builds.

### Security
- Security fixes.

---

## [1.5.0] - 2026-10-04

### Added
- **Full-Width Preview Mode**: Extended preview canvas layout option and keyboard shortcut (<kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>).
- **Tab-Scoped Preferences Saving**: Settings modal saves exclusively the active tab without unintentional theme resets.
- **Live Settings Preview Card**: Real-time typography and theme preview card directly inside Preferences.
- **Dynamic Document Export Titles**: Default PDF and HTML export titles dynamically derived from the document's first heading.

### Changed
- Cleaned preview header by removing the legacy live status indicator dot and text.

### Security
- Security fixes.

---

## [1.4.0] - 2026-10-02

### Added
- **GitHub Alert Callouts**: Support for `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, and `[!CAUTION]` alert blocks.
- **Interactive Document Outline**: Collapsible Table of Contents sidebar with deep anchor linking (<kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd>).
- **Structured Data Viewer**: Dedicated syntax highlighting and interactive collapsible JSON tree views.
- **Keyboard Shortcuts Cheatsheet**: Searchable shortcuts modal and settings reference.

### Security
- Security fixes.

---

## [1.3.1] - 2026-09-29

### Fixed
- Path normalization and image scheme resolution in sandboxed environments.

### Security
- Security fixes.

---

## [1.3.0] - 2026-09-30

### Added
- **macOS Preferences & Settings Modal**: Comprehensive tabbed preferences sheet (<kbd>Cmd</kbd> + <kbd>,</kbd>) matching native macOS AppKit design standards with three dedicated categories:
  - **Editor Tab**: Font family picker, dynamic font size slider (12px–24px) with live preview, tab indentation size selector (2 vs 4 spaces), line numbers toggle, soft word wrap toggle, and bracket/quote auto-closing toggle.
  - **Viewer & Appearance Tab**: Default theme selector (7 color schemes), sync-scroll toggle, live LaTeX math (KaTeX) toggle, live Mermaid diagram toggle, and custom CSS override editor.
  - **Keyboard Shortcuts Tab**: Searchable reference table of all application, editing, view mode, and formatting shortcuts with instant filtering.
- **Native macOS App Menu**: Added `Settings…` (<kbd>Cmd</kbd> + <kbd>,</kbd>) to the main Application Menu (`Markdown Viewer -> Settings…`) wired to `window.openSettingsModal()`.
- **Live Settings Application & Persistence**: All settings apply immediately in real-time across the editor and preview, persist in `localStorage`, and can be restored to defaults via `Reset to Defaults`.
- **Automated Milestone 3 Test Suite**: Added `scripts/test_milestone3.sh` validating settings DOM components, CSS rules, controller hooks, AppKit menu bindings, and unit tests for indentation, auto-closing pairs, and shortcut filtering.

---

## [1.2.0] - 2026-09-30

### Added
- **Find & Replace Toolbar**: Floating, non-modal search and replace bar positioned over the editor with match count indicators (`X of Y` or `No results`).
- **Match Controls**: Added case-sensitive matching (`Aa`) and whole-word matching (`\b`) toggles.
- **Search Navigation**: Keyboard and button navigation across search results with automatic line scrolling and textarea selection range highlighting.
- **Replace & Replace All**: Single-match replacement and global batch replacement with native undo stack integration (`EditorHistory.push` and `document.execCommand`).
- **Native macOS Menu Integration**: Added `Edit` -> `Find` submenu in AppKit with standard macOS shortcuts:
  - `Find…` (<kbd>Cmd</kbd> + <kbd>F</kbd>)
  - `Find and Replace…` (<kbd>Cmd</kbd> + <kbd>Option</kbd> + <kbd>F</kbd>)
  - `Find Next` (<kbd>Cmd</kbd> + <kbd>G</kbd>)
  - `Find Previous` (<kbd>Shift</kbd> + <kbd>Cmd</kbd> + <kbd>G</kbd>)
  - `Use Selection for Find` (<kbd>Cmd</kbd> + <kbd>E</kbd>)
- **Automated Milestone 2 Test Suite**: Added `scripts/test_milestone2.sh` validating HTML markup, CSS rules, JavaScript controller lifecycle, AppKit bridge bindings, and regex/replacement algorithmic accuracy.

---

## [1.1.2] - 2026-09-30

### Security
- **Mermaid Hardening**: Switched Mermaid configuration from `securityLevel: 'loose'` to `securityLevel: 'strict'` to prevent SVG/HTML script injection.
- **Local Scheme Whitelist**: Restricted `local-file://` scheme handler exclusively to image formats (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.svg`, `.ico`, `.bmp`, `.avif`, `.tiff`). Blocked hidden files and dropped wildcard CORS header (`Access-Control-Allow-Origin: *`).
- **Save Path Verification**: Implemented `openedFiles` session tracking in the native AppKit host. Direct file overwrites via `saveFile` are restricted strictly to files explicitly opened by the user; unverified paths trigger native `NSSavePanel`.
- **Content Security Policy (CSP)**: Added strict meta CSP (`default-src 'none'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; img-src 'self' data: local-file:; font-src 'self' data:;`) to `index.html`.
- **CLI Temp File Hardening**: Replaced predictable `/tmp` filename in `bin/markdown-viewer` with secure `mktemp -t` generation.

### Privacy
- **100% Offline Vendoring**: Removed all external CDN connections (`jsdelivr`, `cdnjs`). All frontend dependencies (Marked, DOMPurify, Highlight.js, KaTeX + WOFF2 fonts, JS-YAML, Mermaid) are now bundled locally into `vendor/`.
- **Release Script Privacy Guard**: Configured explicit Git user name and GitHub privacy alias (`jomalaca@users.noreply.github.com`) in `scripts/release.sh` when updating the Homebrew tap repository.

### CI/CD & Build Automation
- **GitHub Actions CI**: Added `.github/workflows/ci.yml` to run test suites and compile macOS app bundles on PRs with downloadable workflow artifacts.
- **Audit Manifest**: Enhanced `scripts/build_macos.sh` to generate `build/logs/build-manifest.json` capturing git commit, timestamp, and SHA-256 binary checksums.
- **Deduplicated Releases**: Converted `.github/workflows/release.yml` to manual `workflow_dispatch` to prevent race conditions with local release automation.

---

## [1.1.1] - 2026-09-29

### Fixed
- **Version Metadata**: Synchronized `macos/Info.plist` (`CFBundleShortVersionString` and `CFBundleVersion`) and `bin/markdown-viewer` (`VERSION`) from `package.json` dynamically during build.
- **Homebrew Cask Deprecations**: Fixed deprecated `depends_on macos:` format and removed redundant `postflight` hook.

---

## [1.1.0] - 2026-09-28

### Added
- **Local Image Rendering**: Custom `local-file://` scheme handler allowing Markdown documents to render relative and local images securely.
- **JSON & YAML Live Previews**: Prettified syntax highlighting and tree inspection for JSON and YAML files.
- **Architecture Documentation**: Added standalone `ARCHITECTURE.md`.

---

## [1.0.0] - 2026-09-28

### Added
- Initial public release of Markdown Viewer for macOS.
