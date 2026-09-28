#!/usr/bin/env bash
# ==============================================================================
# Generate macOS AppIcon.icns from Concept 1 logo image
# Uses built-in macOS sips and iconutil tools
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESOURCES_DIR="${PROJECT_ROOT}/macos/resources"
ICONSET_DIR="${RESOURCES_DIR}/AppIcon.iconset"
if [ -f "${RESOURCES_DIR}/app_icon.png" ]; then
  DEFAULT_SOURCE="${RESOURCES_DIR}/app_icon.png"
elif [ -f "${RESOURCES_DIR}/app_icon.jpg" ]; then
  DEFAULT_SOURCE="${RESOURCES_DIR}/app_icon.jpg"
else
  DEFAULT_SOURCE="${RESOURCES_DIR}/app_icon.png"
fi

SOURCE_IMAGE="${1:-$DEFAULT_SOURCE}"

if [ ! -f "${SOURCE_IMAGE}" ]; then
  echo "Error: Source image not found at ${SOURCE_IMAGE}" >&2
  exit 1
fi

echo "==> Generating AppIcon.icns from: ${SOURCE_IMAGE}"

# Create directories
mkdir -p "${ICONSET_DIR}"

# Convert and resize using macOS built-in sips tool with explicit PNG format
sips -s format png -z 16 16     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
sips -s format png -z 32 32     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
sips -s format png -z 32 32     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
sips -s format png -z 64 64     "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
sips -s format png -z 128 128   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
sips -s format png -z 256 256   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
sips -s format png -z 256 256   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
sips -s format png -z 512 512   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
sips -s format png -z 512 512   "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
sips -s format png -z 1024 1024 "${SOURCE_IMAGE}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null

# Compile into .icns using macOS built-in iconutil tool
iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns"

# Clean up iconset folder
rm -rf "${ICONSET_DIR}"

echo "✓ Successfully generated: ${RESOURCES_DIR}/AppIcon.icns"
