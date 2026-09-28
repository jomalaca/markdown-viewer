#!/usr/bin/env bash
# ==============================================================================
# Build & Package Script for Markdown Viewer.app (macOS Native App)
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
APP_DIR="${BUILD_DIR}/Markdown Viewer.app"
CONTENTS="${APP_DIR}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"
DIST_DIR="${PROJECT_ROOT}/dist"
CACHE_DIR="${BUILD_DIR}/module-cache"

echo "==> Building Markdown Viewer.app (macOS Native)..."

# 1. Clean stale module cache & prepare directory structure
rm -rf "${CACHE_DIR}"
mkdir -p "${MACOS}" "${RESOURCES}" "${CACHE_DIR}" "${DIST_DIR}"

# 2. Compile Swift Native AppKit host
echo "==> Compiling Swift binary..."
swiftc \
  -module-cache-path "${CACHE_DIR}" \
  -O \
  "${PROJECT_ROOT}/macos/src/main.swift" \
  -o "${MACOS}/Markdown Viewer"

# 3. Copy Info.plist
echo "==> Installing Info.plist..."
cp "${PROJECT_ROOT}/macos/Info.plist" "${CONTENTS}/Info.plist"

# 4. Install CLI wrapper into .app bundle
echo "==> Bundling markdown-viewer CLI launcher..."
cp "${PROJECT_ROOT}/bin/markdown-viewer" "${MACOS}/markdown-viewer-cli"
chmod +x "${MACOS}/markdown-viewer-cli"

# 5. Bundle Web Application & Sample Files into Resources
echo "==> Bundling web resources..."
cp "${PROJECT_ROOT}/index.html" "${RESOURCES}/index.html"
cp "${PROJECT_ROOT}/style.css" "${RESOURCES}/style.css"
cp "${PROJECT_ROOT}/app.js" "${RESOURCES}/app.js"

if [ -d "${PROJECT_ROOT}/vendor" ]; then
  cp -R "${PROJECT_ROOT}/vendor" "${RESOURCES}/"
fi

if [ -d "${PROJECT_ROOT}/samples" ]; then
  cp -R "${PROJECT_ROOT}/samples" "${RESOURCES}/"
fi

# 5b. Generate & bundle AppIcon.icns
if [ -f "${PROJECT_ROOT}/scripts/generate_app_icon.sh" ]; then
  bash "${PROJECT_ROOT}/scripts/generate_app_icon.sh" || true
fi

if [ -f "${PROJECT_ROOT}/macos/resources/AppIcon.icns" ]; then
  echo "==> Bundling AppIcon.icns..."
  cp "${PROJECT_ROOT}/macos/resources/AppIcon.icns" "${RESOURCES}/AppIcon.icns"
fi

# 6. Create distribution zip archive
echo "==> Packaging distribution zip..."
(cd "${BUILD_DIR}" && zip -r -q -y "${DIST_DIR}/MarkdownViewer-macOS.zip" "Markdown Viewer.app")

echo ""
echo "✓ Successfully built: ${APP_DIR}"
echo "✓ Successfully packaged: ${DIST_DIR}/MarkdownViewer-macOS.zip"
echo ""
echo "To run the GUI app directly:"
echo "  open '${APP_DIR}'"
echo ""
echo "To run via CLI in your current terminal (without 'open'):"
echo "  '${PROJECT_ROOT}/bin/markdown-viewer'"
echo "  '${PROJECT_ROOT}/bin/markdown-viewer' samples/01-kitchen-sink.md"
