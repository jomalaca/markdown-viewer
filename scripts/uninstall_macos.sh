#!/usr/bin/env bash
# ==============================================================================
# Uninstall / Cleanup Script for Markdown Viewer (macOS)
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Markdown Viewer"
BUNDLE_ID="org.markdownviewer.app"

echo "==> Uninstalling / Cleaning Markdown Viewer..."

# 1. Quit running instances
if pgrep -x "${APP_NAME}" >/dev/null 2>&1; then
  echo "==> Terminating running instance of ${APP_NAME}..."
  killall "${APP_NAME}" 2>/dev/null || true
  sleep 1
fi

# 2. Remove local build and dist outputs
echo "==> Removing local build artifacts (build/, dist/)..."
rm -rf "${PROJECT_ROOT}/build" "${PROJECT_ROOT}/dist"

# 3. Remove application if copied to /Applications or ~/Applications
if [ -d "/Applications/${APP_NAME}.app" ]; then
  echo "==> Removing /Applications/${APP_NAME}.app..."
  rm -rf "/Applications/${APP_NAME}.app"
fi

if [ -d "${HOME}/Applications/${APP_NAME}.app" ]; then
  echo "==> Removing ${HOME}/Applications/${APP_NAME}.app..."
  rm -rf "${HOME}/Applications/${APP_NAME}.app"
fi

# 4. Remove CLI launcher symlink if present in user bin paths
for bin_path in "/usr/local/bin/markdown-viewer" "${HOME}/.local/bin/markdown-viewer"; do
  if [ -L "${bin_path}" ] || [ -f "${bin_path}" ]; then
    echo "==> Removing CLI launcher at ${bin_path}..."
    rm -f "${bin_path}"
  fi
done

# 5. Clean up macOS application state, preferences, and WebKit cache
echo "==> Cleaning up app preferences and caches..."
rm -rf "${HOME}/Library/Application Support/MarkdownViewer"
rm -rf "${HOME}/Library/Preferences/${BUNDLE_ID}.plist"
rm -rf "${HOME}/Library/Saved Application State/${BUNDLE_ID}.savedState"
rm -rf "${HOME}/Library/WebKit/${BUNDLE_ID}"
rm -rf "${HOME}/Library/Caches/${BUNDLE_ID}"

echo ""
echo "✓ Markdown Viewer successfully uninstalled and local caches cleaned."
