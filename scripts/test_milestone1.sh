#!/usr/bin/env bash
# ==============================================================================
# Automated Security & Privacy Test Suite for Milestone 1 (v1.1.2)
# ==============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

log_pass() {
  echo "  ✓ PASS: $1"
}

log_fail() {
  echo "  ✗ FAIL: $1" >&2
  ERRORS=$((ERRORS + 1))
}

echo "=========================================================="
echo " Running Milestone 1 Security & Privacy Test Suite"
echo "=========================================================="

# Test 1: Zero external network dependencies in index.html
echo "==> Test 1: Verifying zero external URLs in index.html..."
if grep -iE 'src="https?://|href="https?://' "${PROJECT_ROOT}/index.html" >/dev/null; then
  log_fail "Found external http/https resource references in index.html"
else
  log_pass "index.html has zero external resource links (100% offline)"
fi

# Test 2: Content Security Policy (CSP) presence and strictness
echo "==> Test 2: Verifying Content Security Policy in index.html..."
if grep -i "Content-Security-Policy" "${PROJECT_ROOT}/index.html" | grep -q "default-src 'none'"; then
  log_pass "Content-Security-Policy with default-src 'none' is present"
else
  log_fail "Strict Content-Security-Policy meta tag is missing in index.html"
fi

# Test 3: Local vendored assets integrity
echo "==> Test 3: Checking required vendored offline libraries..."
REQUIRED_VENDOR_FILES=(
  "vendor/marked.min.js"
  "vendor/purify.min.js"
  "vendor/highlight.min.js"
  "vendor/highlight-yaml.min.js"
  "vendor/highlight-github.min.css"
  "vendor/js-yaml.min.js"
  "vendor/katex/katex.min.js"
  "vendor/katex/katex.min.css"
  "vendor/katex/fonts/KaTeX_Main-Regular.woff2"
  "vendor/mermaid.min.js"
)

for file in "${REQUIRED_VENDOR_FILES[@]}"; do
  if [ -s "${PROJECT_ROOT}/${file}" ]; then
    log_pass "Vendored asset exists: ${file}"
  else
    log_fail "Missing or empty vendored asset: ${file}"
  fi
done

# Test 4: Mermaid security level strictness
echo "==> Test 4: Checking Mermaid configuration in app.js..."
if grep -C 3 "mermaid.initialize" "${PROJECT_ROOT}/app.js" | grep -q "securityLevel: 'strict'"; then
  log_pass "Mermaid is configured with securityLevel: 'strict'"
else
  log_fail "Mermaid is not configured with securityLevel: 'strict'"
fi

# Test 5: Native scheme handler image extension whitelist
echo "==> Test 5: Verifying image whitelist in macos/src/main.swift..."
if grep -q "allowedImageExtensions" "${PROJECT_ROOT}/macos/src/main.swift"; then
  log_pass "LocalFileSchemeHandler contains allowedImageExtensions whitelist"
else
  log_fail "LocalFileSchemeHandler is missing allowedImageExtensions whitelist"
fi

# Test 6: Native bridge saveFile openedFiles verification
echo "==> Test 6: Verifying openedFiles session tracking in main.swift..."
if grep -q "openedFiles" "${PROJECT_ROOT}/macos/src/main.swift"; then
  log_pass "AppDelegate tracks openedFiles and validates saveFile paths"
else
  log_fail "AppDelegate is missing openedFiles session validation"
fi

# Test 7: CLI launcher temporary file security
echo "==> Test 7: Checking mktemp usage in bin/markdown-viewer..."
if grep -q 'mktemp -t' "${PROJECT_ROOT}/bin/markdown-viewer"; then
  log_pass "bin/markdown-viewer uses secure mktemp -t for stdin redirection"
else
  log_fail "bin/markdown-viewer still uses insecure predictable /tmp filename"
fi

# Test 8: Git identity configuration in release script
echo "==> Test 8: Checking privacy Git config in scripts/release.sh..."
if grep -q 'git -C "${TMP_TAP_DIR}/tap" config user.email' "${PROJECT_ROOT}/scripts/release.sh"; then
  log_pass "scripts/release.sh explicitly sets Git user.email for tap commits"
else
  log_fail "scripts/release.sh missing explicit Git privacy config"
fi

echo "=========================================================="
if [ ${ERRORS} -eq 0 ]; then
  echo " 🎉 All Milestone 1 tests PASSED!"
  exit 0
else
  echo " ❌ ${ERRORS} test(s) FAILED!"
  exit 1
fi
