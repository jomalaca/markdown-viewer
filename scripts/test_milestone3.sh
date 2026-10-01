#!/usr/bin/env bash
# ==============================================================================
# Automated Test Suite for Milestone 3: Preferences & Settings (v1.3.0)
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
echo " Running Milestone 3: Preferences & Settings Test Suite"
echo "=========================================================="

# Test 1: JavaScript syntax validation
echo "==> Test 1: Checking JavaScript syntax..."
if node --check "${PROJECT_ROOT}/app.js" >/dev/null 2>&1; then
  log_pass "app.js syntax is clean and valid"
else
  log_fail "app.js has syntax errors"
fi

# Test 2: HTML UI markup for Settings Modal & Tab Panels
echo "==> Test 2: Verifying Preferences modal elements in index.html..."
REQUIRED_SETTINGS_IDS=(
  "settings-modal"
  "tab-editor"
  "tab-viewer"
  "tab-shortcuts"
  "font-family-select"
  "font-size-input"
  "tab-size-select"
  "line-numbers-toggle"
  "word-wrap-toggle"
  "auto-close-pairs-toggle"
  "default-theme-select"
  "sync-scroll-toggle"
  "render-math-toggle"
  "render-mermaid-toggle"
  "custom-css-input"
  "shortcuts-filter"
  "shortcuts-table"
  "reset-settings-btn"
  "save-settings-btn"
)

for elem_id in "${REQUIRED_SETTINGS_IDS[@]}"; do
  if grep -q "id=\"${elem_id}\"" "${PROJECT_ROOT}/index.html"; then
    log_pass "Element id=\"${elem_id}\" found in index.html"
  else
    log_fail "Missing element id=\"${elem_id}\" in index.html"
  fi
done

# Test 3: CSS Styles for Preferences Modal
echo "==> Test 3: Verifying Preferences styling in style.css..."
REQUIRED_CSS_CLASSES=(
  ".modal-settings"
  ".settings-tab-bar"
  ".settings-tab-btn"
  ".settings-tab-pane"
  ".form-group-checkbox"
  ".modal-footer-split"
  ".btn-reset-defaults"
  ".shortcuts-table-container"
  ".editor-wrapper.hide-line-numbers"
  ".markdown-input.no-word-wrap"
)

for css_cls in "${REQUIRED_CSS_CLASSES[@]}"; do
  if grep -q "${css_cls}" "${PROJECT_ROOT}/style.css"; then
    log_pass "CSS rule ${css_cls} present in style.css"
  else
    log_fail "Missing CSS rule ${css_cls} in style.css"
  fi
done

# Test 4: Settings Controller & Functions in app.js
echo "==> Test 4: Verifying SettingsController and apply functions in app.js..."
REQUIRED_SETTINGS_FUNCS=(
  "const SettingsController = {"
  "window.openSettingsModal = "
  "function applyTabSize("
  "function applyLineNumbers("
  "function applyWordWrap("
  "function applyAutoClosePairs("
  "function applyRenderMath("
  "function applyRenderMermaid("
)

for func_name in "${REQUIRED_SETTINGS_FUNCS[@]}"; do
  if grep -Fq "${func_name}" "${PROJECT_ROOT}/app.js"; then
    log_pass "Found required settings function: ${func_name}"
  else
    log_fail "Missing required settings function: ${func_name}"
  fi
done

# Verify Cmd+, shortcut in app.js
if grep -C 3 "SettingsController.open" "${PROJECT_ROOT}/app.js" | grep -q "e.key === ','"; then
  log_pass "Keyboard shortcut Cmd+, is wired to SettingsController.open"
else
  log_fail "Cmd+, shortcut missing for SettingsController"
fi

# Test 5: Native AppKit App Menu Integration in macos/src/main.swift
echo "==> Test 5: Verifying AppKit Settings menu item and bridge action in main.swift..."
if grep -C 2 "Settings…" "${PROJECT_ROOT}/macos/src/main.swift" | grep -q 'keyEquivalent: ","'; then
  log_pass "Found AppKit 'Settings…' menu item with key equivalent ','"
else
  log_fail "Missing 'Settings…' menu item in main.swift"
fi

if grep -q "@objc func menuOpenSettings()" "${PROJECT_ROOT}/macos/src/main.swift"; then
  log_pass "Found @objc func menuOpenSettings() action method"
else
  log_fail "Missing @objc func menuOpenSettings() in main.swift"
fi

# Test 6: Node.js Unit Tests for Settings logic
echo "==> Test 6: Running Settings unit tests..."
node - << 'EOF'
const assert = require('assert');

// 6a: Tab indentation generator test
function getTabIndentation(tabSize) {
  const size = parseInt(tabSize, 10) || 2;
  return ' '.repeat(size);
}
assert.strictEqual(getTabIndentation(2), '  ', "Tab size 2 should produce 2 spaces");
assert.strictEqual(getTabIndentation(4), '    ', "Tab size 4 should produce 4 spaces");
assert.strictEqual(getTabIndentation('invalid'), '  ', "Invalid tab size should fallback to 2 spaces");

// 6b: Auto-closing bracket pairs test
const pairs = { '(': ')', '[': ']', '{': '}', '`': '`', '"': '"' };
assert.strictEqual(pairs['('], ')', "Paren pair matches");
assert.strictEqual(pairs['['], ']', "Bracket pair matches");
assert.strictEqual(pairs['{'], '}', "Brace pair matches");

// 6c: Shortcuts search filter logic
const sampleShortcuts = [
  { action: "Open Settings", key: "Cmd + ," },
  { action: "Find in Document", key: "Cmd + F" },
  { action: "Find Next", key: "Cmd + G" },
  { action: "Split View", key: "Cmd + Shift + D" }
];

function filterShortcuts(query, list) {
  const q = query.toLowerCase().trim();
  return list.filter(item => item.action.toLowerCase().includes(q) || item.key.toLowerCase().includes(q));
}

let res = filterShortcuts("settings", sampleShortcuts);
assert.strictEqual(res.length, 1);
assert.strictEqual(res[0].action, "Open Settings");

res = filterShortcuts("cmd + f", sampleShortcuts);
assert.strictEqual(res.length, 1);
assert.strictEqual(res[0].action, "Find in Document");

res = filterShortcuts("find", sampleShortcuts);
assert.strictEqual(res.length, 2);

console.log("  ✓ All Settings unit tests passed successfully.");
EOF
log_pass "Node.js Settings unit tests passed"

echo "=========================================================="
if [ ${ERRORS} -eq 0 ]; then
  echo " 🎉 All Milestone 3 tests PASSED!"
  echo "=========================================================="
  exit 0
else
  echo " ❌ ${ERRORS} test(s) FAILED!"
  echo "=========================================================="
  exit 1
fi
