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

APP_VERSION="$(sed -nE 's/.*"version": *"([^"]+)".*/\1/p' "${PROJECT_ROOT}/package.json" | head -n 1 2>/dev/null || true)"
if [ -z "${APP_VERSION}" ]; then
  APP_VERSION="$(node -p "require('${PROJECT_ROOT}/package.json').version" 2>/dev/null || echo "1.0.0")"
fi

echo "==> Building Markdown Viewer.app v${APP_VERSION} (macOS Native)..."

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

# 3. Copy & dynamically stamp Info.plist
echo "==> Installing and stamping Info.plist (v${APP_VERSION})..."
cp "${PROJECT_ROOT}/macos/Info.plist" "${CONTENTS}/Info.plist"
plutil -replace CFBundleShortVersionString -string "${APP_VERSION}" "${CONTENTS}/Info.plist"
plutil -replace CFBundleVersion -string "${APP_VERSION}" "${CONTENTS}/Info.plist" 2>/dev/null || \
  plutil -insert CFBundleVersion -string "${APP_VERSION}" "${CONTENTS}/Info.plist"

# 4. Install CLI wrapper into .app bundle with synchronized version
echo "==> Bundling markdown-viewer CLI launcher (v${APP_VERSION})..."
sed -E "s/VERSION=\"[^\"]+\"/VERSION=\"${APP_VERSION}\"/" "${PROJECT_ROOT}/bin/markdown-viewer" > "${MACOS}/markdown-viewer-cli"
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

# 5c. Ad-hoc codesign entire .app bundle (seals Info.plist, binaries, and resources)
echo "==> Code signing application bundle..."
codesign --force --deep --sign - "${APP_DIR}"

# 6. Create distribution zip archive
echo "==> Packaging distribution zip..."
(cd "${BUILD_DIR}" && zip -r -q -y "${DIST_DIR}/MarkdownViewer-macOS.zip" "Markdown Viewer.app")

# 7. Generate Audit Build Manifest
LOGS_DIR="${BUILD_DIR}/logs"
mkdir -p "${LOGS_DIR}"
GIT_COMMIT="$(git rev-parse HEAD 2>/dev/null || echo "unknown")"
BUILD_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
ZIP_SHA256="$(shasum -a 256 "${DIST_DIR}/MarkdownViewer-macOS.zip" | awk '{print $1}')"

cat > "${LOGS_DIR}/build-manifest.json" << EOF
{
  "version": "${APP_VERSION}",
  "gitCommit": "${GIT_COMMIT}",
  "buildTimestamp": "${BUILD_TIMESTAMP}",
  "distributionZip": {
    "file": "MarkdownViewer-macOS.zip",
    "sha256": "${ZIP_SHA256}"
  },
  "signing": {
    "status": "ad-hoc signed",
    "bundleId": "org.markdownviewer.app"
  }
}
EOF

echo ""
echo "✓ Successfully built: ${APP_DIR}"
echo "✓ Successfully packaged: ${DIST_DIR}/MarkdownViewer-macOS.zip"
echo "✓ Generated audit manifest: ${LOGS_DIR}/build-manifest.json"
echo ""
echo "To run the GUI app directly:"
echo "  open '${APP_DIR}'"
echo ""
echo "To run via CLI in your current terminal (without 'open'):"
echo "  '${PROJECT_ROOT}/bin/markdown-viewer'"
echo "  '${PROJECT_ROOT}/bin/markdown-viewer' samples/01-kitchen-sink.md"
