# Changelog

All notable changes to **Markdown Viewer** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
