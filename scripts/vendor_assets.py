#!/usr/bin/env python3
"""
Downloads and vendors third-party client assets into vendor/
Ensures 100% offline, air-gapped, and private operation.
"""

import os
import urllib.request
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
VENDOR_DIR = BASE_DIR / "vendor"

ASSETS = {
    "marked.min.js": "https://cdn.jsdelivr.net/npm/marked@12.0.2/marked.min.js",
    "purify.min.js": "https://cdn.jsdelivr.net/npm/dompurify@3.1.2/dist/purify.min.js",
    "highlight.min.js": "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js",
    "highlight-github.min.css": "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css",
    "highlight-github-dark.min.css": "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css",
    "katex/katex.min.js": "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.js",
    "katex/katex.min.css": "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/katex.min.css",
    "mermaid.min.js": "https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js",
}

# Key KaTeX fonts needed for offline math formulas
KATEX_FONTS = [
    "KaTeX_Main-Regular.woff2",
    "KaTeX_Main-Bold.woff2",
    "KaTeX_Main-Italic.woff2",
    "KaTeX_Math-Italic.woff2",
    "KaTeX_Math-BoldItalic.woff2",
    "KaTeX_AMS-Regular.woff2",
    "KaTeX_Size1-Regular.woff2",
    "KaTeX_Size2-Regular.woff2",
    "KaTeX_Size3-Regular.woff2",
    "KaTeX_Size4-Regular.woff2",
    "KaTeX_Typewriter-Regular.woff2"
]
KATEX_FONT_BASE = "https://cdn.jsdelivr.net/npm/katex@0.16.10/dist/fonts/"

def download_file(url: str, dest_path: Path):
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {dest_path.name} from {url}...")
    headers = {"User-Agent": "Mozilla/5.0"}
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as response, open(dest_path, "wb") as f:
        f.write(response.read())
    print(f"  ✓ Saved to {dest_path.relative_to(BASE_DIR)} ({dest_path.stat().st_size:,} bytes)")

def main():
    print("Vendoring offline assets for Markdown Viewer...")
    VENDOR_DIR.mkdir(parents=True, exist_ok=True)

    for relative_dest, url in ASSETS.items():
        dest = VENDOR_DIR / relative_dest
        download_file(url, dest)

    fonts_dir = VENDOR_DIR / "katex" / "fonts"
    fonts_dir.mkdir(parents=True, exist_ok=True)
    for font_file in KATEX_FONTS:
        dest = fonts_dir / font_file
        url = KATEX_FONT_BASE + font_file
        download_file(url, dest)

    print("\n✓ All assets successfully vendored into vendor/!")

if __name__ == "__main__":
    main()
