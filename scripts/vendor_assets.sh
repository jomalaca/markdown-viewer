#!/usr/bin/env bash
# ==============================================================================
# Vendor Third-Party Frontend Assets for 100% Offline & Private Operation
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${PROJECT_ROOT}/vendor"

echo "==> Vendoring offline frontend libraries into ${VENDOR_DIR}..."

mkdir -p "${VENDOR_DIR}/katex/fonts"

# 1. Marked (v12.0.2)
echo "  -> Downloading Marked v12.0.2..."
curl -fsSL "https://cdn.jsdelivr.net/npm/marked@12.0.2/marked.min.js" -o "${VENDOR_DIR}/marked.min.js"

# 2. DOMPurify (v3.1.2)
echo "  -> Downloading DOMPurify v3.1.2..."
curl -fsSL "https://cdn.jsdelivr.net/npm/dompurify@3.1.2/dist/purify.min.js" -o "${VENDOR_DIR}/purify.min.js"

# 3. Highlight.js core + yaml + github.min.css (v11.9.0)
echo "  -> Downloading Highlight.js v11.9.0..."
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js" -o "${VENDOR_DIR}/highlight.min.js"
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/yaml.min.js" -o "${VENDOR_DIR}/highlight-yaml.min.js"
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" -o "${VENDOR_DIR}/highlight-github.min.css"

# 4. JS-YAML (v4.1.0)
echo "  -> Downloading JS-YAML v4.1.0..."
curl -fsSL "https://cdn.jsdelivr.net/npm/js-yaml@4.1.0/dist/js-yaml.min.js" -o "${VENDOR_DIR}/js-yaml.min.js"

# 5. KaTeX (v0.16.10) JS, CSS, and Fonts
echo "  -> Downloading KaTeX v0.16.10..."
curl -fsSL "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.js" -o "${VENDOR_DIR}/katex/katex.min.js"
curl -fsSL "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css" -o "${VENDOR_DIR}/katex/katex.min.css"

# Download KaTeX standard fonts
KATEX_FONTS=(
  "KaTeX_AMS-Regular.woff2"
  "KaTeX_Caligraphic-Bold.woff2"
  "KaTeX_Caligraphic-Regular.woff2"
  "KaTeX_Fraktur-Bold.woff2"
  "KaTeX_Fraktur-Regular.woff2"
  "KaTeX_Main-Bold.woff2"
  "KaTeX_Main-BoldItalic.woff2"
  "KaTeX_Main-Italic.woff2"
  "KaTeX_Main-Regular.woff2"
  "KaTeX_Math-BoldItalic.woff2"
  "KaTeX_Math-Italic.woff2"
  "KaTeX_SansSerif-Bold.woff2"
  "KaTeX_SansSerif-Italic.woff2"
  "KaTeX_SansSerif-Regular.woff2"
  "KaTeX_Script-Regular.woff2"
  "KaTeX_Size1-Regular.woff2"
  "KaTeX_Size2-Regular.woff2"
  "KaTeX_Size3-Regular.woff2"
  "KaTeX_Size4-Regular.woff2"
  "KaTeX_Typewriter-Regular.woff2"
)

for font in "${KATEX_FONTS[@]}"; do
  echo "     * font: ${font}"
  curl -fsSL "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/fonts/${font}" -o "${VENDOR_DIR}/katex/fonts/${font}"
done

# 6. Mermaid (v10.9.1)
echo "  -> Downloading Mermaid v10.9.1..."
curl -fsSL "https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js" -o "${VENDOR_DIR}/mermaid.min.js"

echo "✓ All frontend assets successfully vendored in ${VENDOR_DIR}!"
