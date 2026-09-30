#!/usr/bin/env bash
# ==============================================================================
# Automated Release Script for Markdown Viewer
# Builds macOS app, generates checksums, publishes GitHub release,
# and updates the Cask formula in jomalaca/homebrew-tap.
# ==============================================================================

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAP_REPO="jomalaca/homebrew-tap"
MAIN_REPO="jomalaca/markdown-viewer"

# 1. Parse and validate requested version
if [ $# -lt 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.1.0"
  exit 1
fi

VERSION="${1#v}" # Strip leading 'v' if provided
TAG="v${VERSION}"

if ! [[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
  echo "Error: Version '${VERSION}' must be in SemVer format (e.g. 1.0.1 or 1.1.0-beta.1)." >&2
  exit 1
fi

echo "=========================================================="
echo " Preparing Release: ${TAG} (SemVer: ${VERSION})"
echo "=========================================================="

# 2. Pre-flight checks
if ! git diff-index --quiet HEAD --; then
  echo "Error: Your working tree has uncommitted changes. Please commit or stash them first." >&2
  git status --short
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [ "${CURRENT_BRANCH}" != "main" ]; then
  echo "Warning: You are currently on branch '${CURRENT_BRANCH}', not 'main'."
  read -r -p "Continue releasing from this branch? [y/N] " response
  if [[ ! "${response}" =~ ^[yY]$ ]]; then
    echo "Release aborted."
    exit 1
  fi
fi

# 3. Check for GitHub CLI (gh) & authenticate via browser if needed
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI ('gh') is required for automated releases." >&2
  echo "Install it via: brew install gh" >&2
  exit 1
fi

echo "==> Verifying GitHub CLI authentication..."
if ! gh auth status >/dev/null 2>&1; then
  echo "==> Initiating browser-based GitHub authentication (active for this release session)..."
  gh auth login --web --hostname github.com
fi

# 4. Bump version in package.json, macos/Info.plist, and bin/markdown-viewer
echo "==> Bumping version in package.json, macos/Info.plist, and bin/markdown-viewer..."
TMP_PKG="$(mktemp)"
node -e '
  const pkg = require("./package.json");
  pkg.version = process.argv[1];
  console.log(JSON.stringify(pkg, null, 2));
' "${VERSION}" > "${TMP_PKG}"
mv "${TMP_PKG}" "${PROJECT_ROOT}/package.json"

plutil -replace CFBundleShortVersionString -string "${VERSION}" "${PROJECT_ROOT}/macos/Info.plist"
plutil -replace CFBundleVersion -string "${VERSION}" "${PROJECT_ROOT}/macos/Info.plist" 2>/dev/null || \
  plutil -insert CFBundleVersion -string "${VERSION}" "${PROJECT_ROOT}/macos/Info.plist"

sed -i '' -E "s/VERSION=\"[^\"]+\"/VERSION=\"${VERSION}\"/" "${PROJECT_ROOT}/bin/markdown-viewer"

# 5. Build native macOS app and packaging zip
echo "==> Building macOS native app..."
"${PROJECT_ROOT}/scripts/build_macos.sh"

DIST_ZIP="${PROJECT_ROOT}/dist/MarkdownViewer-macOS.zip"
if [ ! -f "${DIST_ZIP}" ]; then
  echo "Error: Expected distribution archive not found at ${DIST_ZIP}" >&2
  exit 1
fi

# 6. Calculate SHA-256 checksum
echo "==> Calculating distribution SHA-256..."
SHA256="$(shasum -a 256 "${DIST_ZIP}" | awk '{print $1}')"
echo "    SHA-256: ${SHA256}"

# 7. Update Cask formula in markdown-viewer repo
CASK_FILE="${PROJECT_ROOT}/Casks/markdown-viewer.rb"
echo "==> Updating ${CASK_FILE}..."
sed -i '' -E "s/version \"[^\"]+\"/version \"${VERSION}\"/" "${CASK_FILE}"
sed -i '' -E "s/sha256 \"[^\"]+\"/sha256 \"${SHA256}\"/" "${CASK_FILE}"

# 8. Commit and push git tag
echo "==> Creating release commit and git tag ${TAG}..."
git add "${PROJECT_ROOT}/package.json" "${PROJECT_ROOT}/macos/Info.plist" "${PROJECT_ROOT}/bin/markdown-viewer" "${CASK_FILE}"
git commit -m "chore(release): ${TAG} [skip ci]"
git tag -a "${TAG}" -m "Release ${TAG}"

echo "==> Pushing commit and tag to ${MAIN_REPO}..."
git push origin "${CURRENT_BRANCH}"
git push origin "${TAG}"

# 9. Create GitHub Release with attached zip
echo "==> Publishing GitHub Release ${TAG}..."
gh release create "${TAG}" "${DIST_ZIP}" \
  --repo "${MAIN_REPO}" \
  --title "${TAG}" \
  --generate-notes

# 10. Update Homebrew Tap repository
echo "==> Synchronizing formula with ${TAP_REPO}..."
TMP_TAP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_TAP_DIR}"' EXIT

if gh repo view "${TAP_REPO}" >/dev/null 2>&1; then
  gh repo clone "${TAP_REPO}" "${TMP_TAP_DIR}/tap" -- --depth=1
  git -C "${TMP_TAP_DIR}/tap" config user.name "Josh Ma"
  git -C "${TMP_TAP_DIR}/tap" config user.email "jomalaca@users.noreply.github.com"
  mkdir -p "${TMP_TAP_DIR}/tap/Casks"
  cp "${CASK_FILE}" "${TMP_TAP_DIR}/tap/Casks/markdown-viewer.rb"

  git -C "${TMP_TAP_DIR}/tap" add "Casks/markdown-viewer.rb"
  if ! git -C "${TMP_TAP_DIR}/tap" diff --cached --quiet; then
    git -C "${TMP_TAP_DIR}/tap" commit -m "bump(markdown-viewer): ${TAG}"
    git -C "${TMP_TAP_DIR}/tap" push origin HEAD
    echo "✓ Successfully updated Cask formula in ${TAP_REPO}!"
  else
    echo "Notice: Cask formula in ${TAP_REPO} is already up to date."
  fi
else
  echo ""
  echo "⚠️ Warning: Tap repository '${TAP_REPO}' was not found on GitHub."
  echo "To finish setup, create https://github.com/${TAP_REPO} and copy:"
  echo "  ${CASK_FILE} -> ${TAP_REPO}/Casks/markdown-viewer.rb"
fi

echo ""
echo "=========================================================="
echo " 🎉 Release ${TAG} successfully published!"
echo "=========================================================="
echo "Users can now install / upgrade via:"
echo "  brew update && brew upgrade --cask markdown-viewer"
echo ""
