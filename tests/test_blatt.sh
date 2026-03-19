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
assert_contains "shows header" "$output" "Name"

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
