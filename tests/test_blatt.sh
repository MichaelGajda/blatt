#!/bin/bash
set -uo pipefail

# Test suite for blatt
# Usage: bash tests/test_blatt.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BLATT="$SCRIPT_DIR/../src/blatt"
FIXTURES="$SCRIPT_DIR/fixtures"

passed=0
failed=0
set +e

strip_ansi() {
  sed $'s/\033\\[[0-9;]*m//g'
}

assert_contains() {
  local label="$1" output="$2" expected="$3"
  if echo "$output" | strip_ansi | grep -q "$expected"; then
    echo "  PASS: $label"
    ((passed++))
  else
    echo "  FAIL: $label"
    echo "    expected to contain: $expected"
    echo "    got: $output"
    ((failed++))
  fi
}

assert_exit_code() {
  local label="$1" expected="$2"
  shift 2
  set +e
  "$@" >/dev/null 2>&1
  local actual=$?
  set -e
  if [[ "$actual" -eq "$expected" ]]; then
    echo "  PASS: $label"
    ((passed++))
  else
    echo "  FAIL: $label (expected exit $expected, got $actual)"
    ((failed++))
  fi
}

# --- Summary mode ---
echo "Summary mode (fixtures/):"
output=$("$BLATT" "$FIXTURES" 2>&1)
assert_contains "page count is 4" "$output" "^4 "
assert_contains "document count is 2" "$output" " 2 "

# --- Verbose mode ---
echo "Verbose mode (-v):"
output=$("$BLATT" -v "$FIXTURES" 2>&1)
assert_contains "shows one-page.pdf" "$output" "one-page.pdf"
assert_contains "shows three-pages.pdf" "$output" "three-pages.pdf"
assert_contains "shows header" "$output" "Pages"

# --- Recursive mode ---
echo "Recursive mode (-r):"
output=$("$BLATT" -r "$FIXTURES" 2>&1)
assert_contains "page count is 9 (1+3+5)" "$output" "^9 "
assert_contains "document count is 3" "$output" " 3 "

# --- Combined -rv ---
echo "Combined mode (-rv):"
output=$("$BLATT" -rv "$FIXTURES" 2>&1)
assert_contains "shows subdir file" "$output" "five-pages.pdf"
assert_contains "total pages 9" "$output" "^9 "

# --- Help ---
echo "Help flag:"
output=$("$BLATT" -h 2>&1)
assert_contains "shows usage" "$output" "blatt"

# --- Version ---
echo "Version flag:"
output=$("$BLATT" --version 2>&1)
assert_contains "shows version" "$output" "blatt v"

# --- Error cases ---
echo "Error cases:"
assert_exit_code "no args exits 1" 1 "$BLATT"
assert_exit_code "invalid dir exits 1" 1 "$BLATT" "/nonexistent/path"
assert_exit_code "unknown flag exits 1" 1 "$BLATT" "-z"

# --- JSON mode ---
echo "JSON mode (--json):"
output=$("$BLATT" --json "$FIXTURES" 2>&1)
assert_contains "json has total_pages" "$output" '"total_pages": 4'
assert_contains "json has total_documents" "$output" '"total_documents": 2'
assert_contains "json has files array" "$output" '"files":'
assert_contains "json lists one-page.pdf" "$output" '"name": "one-page.pdf"'

echo "JSON recursive (--json -r):"
output=$("$BLATT" --json -r "$FIXTURES" 2>&1)
assert_contains "json recursive total_pages 9" "$output" '"total_pages": 9'
assert_contains "json recursive total_documents 3" "$output" '"total_documents": 3'

# --- Sort mode ---
echo "Sort by name (-v --sort name):"
output=$("$BLATT" -v --sort name "$FIXTURES" 2>&1 | strip_ansi)
# one-page.pdf should come before three-pages.pdf alphabetically
one_line=$(echo "$output" | grep -n "one-page.pdf" | head -1 | cut -d: -f1)
three_line=$(echo "$output" | grep -n "three-pages.pdf" | head -1 | cut -d: -f1)
if [[ -n "$one_line" && -n "$three_line" && "$one_line" -lt "$three_line" ]]; then
  echo "  PASS: one-page.pdf before three-pages.pdf"
  ((passed++))
else
  echo "  FAIL: sort by name order"
  ((failed++))
fi

echo "Sort by pages (-v --sort pages):"
output=$("$BLATT" -v --sort pages "$FIXTURES" 2>&1 | strip_ansi)
# three-pages (3) should come before one-page (1) in descending order
three_line=$(echo "$output" | grep -n "three-pages.pdf" | head -1 | cut -d: -f1)
one_line=$(echo "$output" | grep -n "one-page.pdf" | head -1 | cut -d: -f1)
if [[ -n "$three_line" && -n "$one_line" && "$three_line" -lt "$one_line" ]]; then
  echo "  PASS: three-pages.pdf before one-page.pdf (descending)"
  ((passed++))
else
  echo "  FAIL: sort by pages order"
  ((failed++))
fi

echo "Sort error cases:"
assert_exit_code "--sort with invalid key exits 1" 1 "$BLATT" --sort bogus "$FIXTURES"
assert_exit_code "--sort without value exits 1" 1 "$BLATT" --sort

# --- No PDFs ---
echo "Empty directory:"
tmpdir=$(mktemp -d)
output=$("$BLATT" "$tmpdir" 2>&1)
assert_contains "no PDFs message" "$output" "PDF"
rmdir "$tmpdir"

# --- Results ---
echo ""
echo "Results: $passed passed, $failed failed"
[[ "$failed" -eq 0 ]] && exit 0 || exit 1
