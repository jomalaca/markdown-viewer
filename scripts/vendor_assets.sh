#!/usr/bin/env bash
# ==============================================================================
# Vendor Third-Party Frontend Assets for 100% Offline & Private Operation
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${PROJECT_ROOT}/vendor"

verify_assets() {
  echo "==> Verifying vendor asset checksums against vendor/manifest.json..."
  python3 -c "
import sys, json, hashlib, os
manifest_path = '${VENDOR_DIR}/manifest.json'
if not os.path.exists(manifest_path):
    print('ERROR: vendor/manifest.json not found', file=sys.stderr)
    sys.exit(1)
with open(manifest_path, 'r') as fp:
    manifest = json.load(fp)
failed = 0
for rel_path, meta in manifest.get('files', {}).items():
    full_path = os.path.join('${PROJECT_ROOT}', rel_path)
    if not os.path.exists(full_path):
        print(f'MISSING: {rel_path}', file=sys.stderr)
        failed += 1
        continue
    with open(full_path, 'rb') as f:
        actual_hash = hashlib.sha256(f.read()).hexdigest()
    if actual_hash != meta['sha256']:
        print(f'MISMATCH: {rel_path} (expected {meta[\"sha256\"]}, got {actual_hash})', file=sys.stderr)
        failed += 1
if failed > 0:
    print(f'Verification FAILED: {failed} files invalid', file=sys.stderr)
    sys.exit(1)
print(f'✓ All {len(manifest.get(\"files\", {}))} vendor assets verified matching SHA-256 manifest!')
"
}

if [ "${1:-}" = "--verify" ]; then
  verify_assets
  exit 0
fi

echo "==> Vendoring offline frontend libraries into ${VENDOR_DIR}..."

mkdir -p "${VENDOR_DIR}/katex/fonts"

# 1. Marked (v12.0.2)
echo "  -> Downloading Marked v12.0.2..."
curl -fsSL "https://cdn.jsdelivr.net/npm/marked@12.0.2/marked.min.js" -o "${VENDOR_DIR}/marked.min.js"

# 2. DOMPurify (v3.2.4)
echo "  -> Downloading DOMPurify v3.2.4..."
curl -fsSL "https://cdn.jsdelivr.net/npm/dompurify@3.2.4/dist/purify.min.js" -o "${VENDOR_DIR}/purify.min.js"

# 3. Highlight.js core + yaml + github themes (v11.9.0)
echo "  -> Downloading Highlight.js v11.9.0..."
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js" -o "${VENDOR_DIR}/highlight.min.js"
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/yaml.min.js" -o "${VENDOR_DIR}/highlight-yaml.min.js"
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" -o "${VENDOR_DIR}/highlight-github.min.css"
curl -fsSL "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css" -o "${VENDOR_DIR}/highlight-dark.min.css"

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

verify_assets

echo "✓ All frontend assets successfully vendored in ${VENDOR_DIR}!"
