# Markdown Viewer

A fast, private, local-first macOS desktop application and live previewer for Markdown, JSON, and YAML documents.

---

## Quick Start

### Build and Run

```bash
# Build the native macOS application
./scripts/build_macos.sh

# Launch the desktop application
open "build/Markdown Viewer.app"
```

To clean up build artifacts and application caches:
```bash
./scripts/uninstall_macos.sh
```

### Command-Line Interface

Open files directly in Markdown Viewer from your terminal:

```bash
# Open one or more files in tabs
./bin/markdown-viewer README.md package.json

# Pipe terminal output into a new viewer tab
cat /var/log/system.log | ./bin/markdown-viewer
```

Run `./bin/markdown-viewer` directly in your shell prompt (do not prefix with `open`, which launches a secondary Terminal session).

---

## Keyboard Shortcuts

| Shortcut | Scope | Action |
| :--- | :--- | :--- |
| <kbd>Cmd</kbd> + <kbd>S</kbd> | Global | Save document to disk |
| <kbd>Cmd</kbd> + <kbd>O</kbd> | Global | Open file dialog |
| <kbd>Shift</kbd> + <kbd>Cmd</kbd> + <kbd>O</kbd> | Global | Toggle outline sidebar |
| <kbd>Cmd</kbd> + <kbd>T</kbd> | Global | New tab |
| <kbd>Cmd</kbd> + <kbd>W</kbd> | Global | Close current tab (prompts if unsaved) |
| <kbd>Shift</kbd> + <kbd>Cmd</kbd> + <kbd>W</kbd> | Native App | Close window (prompts for unsaved tabs) |
| <kbd>Cmd</kbd> + <kbd>Q</kbd> | Native App | Quit application (prompts for unsaved tabs) |
| <kbd>Cmd</kbd> + <kbd>P</kbd> | Global | Print document or export to PDF |
| <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | Global | Switch to next tab |
| <kbd>Shift</kbd> + <kbd>Ctrl</kbd> + <kbd>Tab</kbd> | Global | Switch to previous tab |
| <kbd>Cmd</kbd> + <kbd>1</kbd> .. <kbd>9</kbd> | Global | Switch directly to tab 1 through 9 |
| <kbd>Cmd</kbd> + <kbd>Z</kbd> | Editor | Undo (independent per tab) |
| <kbd>Shift</kbd> + <kbd>Cmd</kbd> + <kbd>Z</kbd> / <kbd>Cmd</kbd> + <kbd>Y</kbd> | Editor | Redo (independent per tab) |
| <kbd>Cmd</kbd> + <kbd>B</kbd> | Editor | Toggle bold on selection |
| <kbd>Cmd</kbd> + <kbd>I</kbd> | Editor | Toggle italic on selection |
| <kbd>Cmd</kbd> + <kbd>K</kbd> | Editor | Insert Markdown link |
| <kbd>Tab</kbd> | Editor | Indent selection by 2 spaces |
| <kbd>Shift</kbd> + <kbd>Tab</kbd> | Editor | Outdent selection by 2 spaces |

---

## Supported Formats

- **Markdown**: Full GitHub Flavored Markdown (GFM) specification, tables, task lists, and synchronized scroll preview.
- **LaTeX Math**: Inline equations (`$E = mc^2$`) and display blocks (`$$\int_0^\infty e^{-x^2} dx$$`) via KaTeX.
- **Mermaid Diagrams**: Flowcharts, sequence diagrams, class diagrams, state machines, and Gantt charts.
- **JSON**: Automatic document detection, 2-space formatted code view, interactive collapsible tree view, syntax error reporting, and outline navigation by root keys.
- **YAML**: Automatic document detection, formatted code view, collapsible tree view, and outline navigation.

---

## Documentation

For technical design, AppKit-WebKit bridge architecture, and local asset resolution details, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
