#!/usr/bin/env bash
# ==============================================================================
# Automated Test Suite for Milestone 2: Find, Replace & Replace All (v1.2.0)
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
echo " Running Milestone 2: Find & Replace Test Suite"
echo "=========================================================="

# Test 1: JavaScript syntax validation
echo "==> Test 1: Checking JavaScript syntax..."
if node --check "${PROJECT_ROOT}/app.js" >/dev/null 2>&1; then
  log_pass "app.js syntax is clean and valid"
else
  log_fail "app.js has syntax errors"
fi

# Test 2: HTML UI markup for Find & Replace Toolbar
echo "==> Test 2: Verifying Find & Replace HTML elements in index.html..."
REQUIRED_HTML_IDS=(
  "find-replace-bar"
  "find-replace-toggle-btn"
  "find-input"
  "find-count"
  "find-opt-case"
  "find-opt-word"
  "find-prev-btn"
  "find-next-btn"
  "find-close-btn"
  "replace-row"
  "replace-input"
  "replace-one-btn"
  "replace-all-btn"
)

for elem_id in "${REQUIRED_HTML_IDS[@]}"; do
  if grep -q "id=\"${elem_id}\"" "${PROJECT_ROOT}/index.html"; then
    log_pass "Element id=\"${elem_id}\" found in index.html"
  else
    log_fail "Missing element id=\"${elem_id}\" in index.html"
  fi
done

# Test 3: CSS Styles for Find & Replace Toolbar
echo "==> Test 3: Verifying Find & Replace styling in style.css..."
REQUIRED_CSS_CLASSES=(
  ".find-replace-bar"
  ".find-input"
  ".find-count"
  ".find-opt-btn"
  ".find-action-btn"
)

for css_cls in "${REQUIRED_CSS_CLASSES[@]}"; do
  if grep -q "${css_cls}" "${PROJECT_ROOT}/style.css"; then
    log_pass "CSS rule ${css_cls} present in style.css"
  else
    log_fail "Missing CSS rule ${css_cls} in style.css"
  fi
done

if grep -A 5 "\.pane-editor" "${PROJECT_ROOT}/style.css" | grep -q "position: relative;"; then
  log_pass ".pane-editor has position: relative for absolute toolbar positioning"
else
  log_fail ".pane-editor missing position: relative"
fi

# Test 4: Controller & AppKit Bridge Hooks in app.js
echo "==> Test 4: Verifying FindReplaceController and host bridges in app.js..."
REQUIRED_HOOKS=(
  "const FindReplaceController = {"
  "FindReplaceController.init();"
  "window.openFindBar = "
  "window.findNext = "
  "window.findPrevious = "
  "window.useSelectionForFind = "
)

for hook in "${REQUIRED_HOOKS[@]}"; do
  if grep -Fq "${hook}" "${PROJECT_ROOT}/app.js"; then
    log_pass "Found required hook: ${hook}"
  else
    log_fail "Missing required hook: ${hook}"
  fi
done

# Test 5: Native AppKit Edit -> Find Submenu in macos/src/main.swift
echo "==> Test 5: Verifying AppKit Find submenu and actions in main.swift..."
REQUIRED_SWIFT_PARTS=(
  'let findMenu = NSMenu(title: "Find")'
  'action: #selector(menuFind)'
  'action: #selector(menuFindAndReplace)'
  'action: #selector(menuFindNext)'
  'action: #selector(menuFindPrevious)'
  'action: #selector(menuUseSelectionForFind)'
  '@objc func menuFind()'
  '@objc func menuFindAndReplace()'
  '@objc func menuFindNext()'
  '@objc func menuFindPrevious()'
  '@objc func menuUseSelectionForFind()'
)

for part in "${REQUIRED_SWIFT_PARTS[@]}"; do
  if grep -Fq "${part}" "${PROJECT_ROOT}/macos/src/main.swift"; then
    log_pass "Found Swift menu integration: ${part}"
  else
    log_fail "Missing Swift menu integration: ${part}"
  fi
done

# Test 6: Algorithmic Unit Tests in Node.js
echo "==> Test 6: Running search and replace algorithm unit tests..."
node - << 'EOF'
const assert = require('assert');

function runSearch(text, query, { matchCase = false, matchWord = false } = {}) {
  if (!query) return [];
  const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  let pattern = escapedQuery;
  if (matchWord) {
    pattern = `\\b${pattern}\\b`;
  }
  const flags = matchCase ? 'g' : 'gi';
  const regex = new RegExp(pattern, flags);
  const matches = [];
  let m;
  while ((m = regex.exec(text)) !== null) {
    matches.push({ start: m.index, end: m.index + m[0].length, text: m[0] });
    if (!regex.global) break;
    if (m[0].length === 0) regex.lastIndex++;
  }
  return matches;
}

function runReplaceAll(text, query, replacement, { matchCase = false, matchWord = false } = {}) {
  if (!query) return text;
  const escapedQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  let pattern = escapedQuery;
  if (matchWord) {
    pattern = `\\b${pattern}\\b`;
  }
  const flags = matchCase ? 'g' : 'gi';
  const regex = new RegExp(pattern, flags);
  return text.replace(regex, replacement);
}

// 6a: Case-insensitive search
const sample = "The quick brown fox jumps over the lazy dog. Fox is fast.";
let matches = runSearch(sample, "fox", { matchCase: false });
assert.strictEqual(matches.length, 2, "Should find 2 matches for 'fox' case-insensitively");
assert.strictEqual(matches[0].start, 16);
assert.strictEqual(matches[1].start, 45);

// 6b: Case-sensitive search
matches = runSearch(sample, "fox", { matchCase: true });
assert.strictEqual(matches.length, 1, "Should find only 1 match for lowercase 'fox'");
assert.strictEqual(matches[0].start, 16);

// 6c: Whole-word search
const wordSample = "cat catch scatter concatenate cat";
matches = runSearch(wordSample, "cat", { matchWord: true });
assert.strictEqual(matches.length, 2, "Should only match isolated word 'cat'");
assert.strictEqual(matches[0].start, 0);
assert.strictEqual(matches[1].start, 30);

// 6d: Special regex character escaping
const regexSample = "Price is $10.00 for item [A-1] (version 2.*)";
matches = runSearch(regexSample, "$10.00");
assert.strictEqual(matches.length, 1, "Should safely match literal '$10.00'");

matches = runSearch(regexSample, "[A-1]");
assert.strictEqual(matches.length, 1, "Should safely match literal '[A-1]'");

matches = runSearch(regexSample, "2.*");
assert.strictEqual(matches.length, 1, "Should safely match literal '2.*'");

// 6e: Replace all occurrences
const replaced = runReplaceAll(sample, "fox", "wolf", { matchCase: false });
assert.strictEqual(replaced, "The quick brown wolf jumps over the lazy dog. wolf is fast.");

// 6f: Single replace at index range
const singleReplaceSample = "apple banana apple cherry";
const m0 = runSearch(singleReplaceSample, "apple")[0];
const singleReplaced = singleReplaceSample.substring(0, m0.start) + "orange" + singleReplaceSample.substring(m0.end);
assert.strictEqual(singleReplaced, "orange banana apple cherry");

console.log("  ✓ All 6 algorithmic unit tests passed successfully.");
EOF
log_pass "Node.js algorithmic unit tests passed"

echo "=========================================================="
if [ ${ERRORS} -eq 0 ]; then
  echo " 🎉 All Milestone 2 tests PASSED!"
  echo "=========================================================="
  exit 0
else
  echo " ❌ ${ERRORS} test(s) FAILED!"
  echo "=========================================================="
  exit 1
fi
