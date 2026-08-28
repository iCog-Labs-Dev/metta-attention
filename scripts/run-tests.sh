#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_TIMEOUT="${METTA_TEST_TIMEOUT:-180}"

RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[96m"
GREEN="\033[92m"
RED="\033[91m"
YELLOW="\033[93m"

TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0
FAILED_TESTS=()

ATTENTION_BANK_TEST_GLOBS=(
  "attention-bank/**/*-test.metta"
)

AGENT_TEST_GLOBS=(
  "attention/**/*-test.metta"
)

KNOWN_EXCLUDED_TESTS=(
  "attention/ForgettingAgent/tests/ForgettingAgent-test.metta"
)

ATTENTION_BANK_TESTS=()
AGENT_TESTS=()

print_header() {
  printf "${BOLD}${CYAN}\n=== %s ===${RESET}\n" "$1"
}

sort_unique_array() {
  local -n values="$1"

  if [[ ${#values[@]} -eq 0 ]]; then
    return
  fi

  mapfile -t values < <(printf "%s\n" "${values[@]}" | LC_ALL=C sort -u)
}

collect_globbed_tests() {
  local -n tests="$1"
  shift

  local pattern
  local test_file

  tests=()
  shopt -s globstar nullglob

  for pattern in "$@"; do
    for test_file in "$ROOT_DIR"/$pattern; do
      if [[ -f "$test_file" ]]; then
        tests+=("${test_file#"$ROOT_DIR"/}")
      fi
    done
  done

  sort_unique_array tests
}

is_known_excluded_test() {
  local candidate="$1"
  local test_file

  for test_file in "${KNOWN_EXCLUDED_TESTS[@]}"; do
    if [[ "$candidate" == "$test_file" ]]; then
      return 0
    fi
  done

  return 1
}

filter_known_excluded_tests() {
  local -n tests="$1"
  local filtered=()
  local test_file

  for test_file in "${tests[@]}"; do
    if ! is_known_excluded_test "$test_file"; then
      filtered+=("$test_file")
    fi
  done

  tests=("${filtered[@]}")
}

discover_metta_tests() {
  collect_globbed_tests ATTENTION_BANK_TESTS "${ATTENTION_BANK_TEST_GLOBS[@]}"
  collect_globbed_tests AGENT_TESTS "${AGENT_TEST_GLOBS[@]}"

  if [[ "${METTA_INCLUDE_KNOWN_EXCLUDED:-0}" != "1" ]]; then
    filter_known_excluded_tests AGENT_TESTS
  fi
}

resolve_petta_runner() {
  if [[ -n "${PETTA_RUNNER:-}" ]]; then
    # shellcheck disable=SC2206
    PETTA_CMD=(${PETTA_RUNNER})
  elif command -v petta >/dev/null 2>&1; then
    PETTA_CMD=("$(command -v petta)")
  elif [[ -f "$ROOT_DIR/../PeTTa/run.sh" ]]; then
    PETTA_CMD=("sh" "$ROOT_DIR/../PeTTa/run.sh")
  else
    printf "${RED}Could not find a PeTTa runner.${RESET}\n" >&2
    printf "Set PETTA_RUNNER, install petta on PATH, or keep PeTTa as a sibling checkout.\n" >&2
    exit 1
  fi
}

has_failure_marker() {
  local output_file="$1"
  local failure_mark
  local mojibake_failure_mark

  failure_mark="$(printf '\342\235\214')"
  mojibake_failure_mark="$(printf '\303\242\302\235\302\214')"

  LC_ALL=C grep -q "$failure_mark" "$output_file" ||
    LC_ALL=C grep -q "$mojibake_failure_mark" "$output_file" ||
    grep -q "ERROR:" "$output_file"
}

run_with_optional_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$TEST_TIMEOUT" "$@"
  else
    "$@"
  fi
}

record_pass() {
  PASSED=$((PASSED + 1))
  printf "${GREEN}passed${RESET}\n"
}

record_fail() {
  local label="$1"
  local output_file="$2"

  FAILED=$((FAILED + 1))
  FAILED_TESTS+=("$label")
  printf "${RED}failed${RESET}\n"
  printf "${YELLOW}Output:${RESET}\n"
  cat "$output_file"
  printf "\n"
}

run_metta_test() {
  local relative_path="$1"
  local absolute_path="$ROOT_DIR/$relative_path"
  local output_file
  local status

  TOTAL=$((TOTAL + 1))
  printf "${YELLOW}Test %d: %s${RESET}\n" "$TOTAL" "$relative_path"

  output_file="$(mktemp "${TMPDIR:-/tmp}/metta-attention-test.XXXXXX")"

  if [[ ! -f "$absolute_path" ]]; then
    printf "Missing test file: %s\n" "$absolute_path" >"$output_file"
    record_fail "$relative_path" "$output_file"
    rm -f "$output_file"
    return
  fi

  run_with_optional_timeout "${PETTA_CMD[@]}" "$absolute_path" -s >"$output_file" 2>&1
  status=$?

  if [[ $status -eq 124 ]]; then
    printf "Timed out after %s seconds.\n" "$TEST_TIMEOUT" >>"$output_file"
    record_fail "$relative_path" "$output_file"
  elif [[ $status -ne 0 ]] || has_failure_marker "$output_file"; then
    record_fail "$relative_path" "$output_file"
  else
    record_pass
  fi

  rm -f "$output_file"
}

run_metta_suite() {
  local suite_name="$1"
  shift

  print_header "$suite_name"
  for test_file in "$@"; do
    run_metta_test "$test_file"
  done
}

print_skipped_known_excluded() {
  if [[ "${METTA_INCLUDE_KNOWN_EXCLUDED:-0}" == "1" ]]; then
    return
  fi

  print_header "Skipped Known Excluded Tests"
  for test_file in "${KNOWN_EXCLUDED_TESTS[@]}"; do
    if [[ -f "$ROOT_DIR/$test_file" ]]; then
      SKIPPED=$((SKIPPED + 1))
      printf "${YELLOW}skipped: %s${RESET}\n" "$test_file"
    fi
  done
}

main() {
  export MPLCONFIGDIR="${MPLCONFIGDIR:-${TMPDIR:-/tmp}/metta-attention-mpl}"
  unset PYTHONHOME
  unset PYTHONPATH

  resolve_petta_runner
  discover_metta_tests

  print_header "Test Runner"
  printf "${CYAN}Repo root    : %s${RESET}\n" "$ROOT_DIR"
  printf "${CYAN}PeTTa runner : " 
  printf "%q " "${PETTA_CMD[@]}"
  printf "${RESET}\n"
  printf "${CYAN}Timeout      : %s seconds${RESET}\n" "$TEST_TIMEOUT"

  print_skipped_known_excluded
  run_metta_suite "Attention Bank Tests" "${ATTENTION_BANK_TESTS[@]}"
  run_metta_suite "Agent Tests" "${AGENT_TESTS[@]}"

  print_header "Test Summary"
  printf "%d file(s) tested.\n" "$TOTAL"
  printf "${GREEN}%d passed.${RESET}\n" "$PASSED"
  printf "${YELLOW}%d skipped.${RESET}\n" "$SKIPPED"
  printf "${RED}%d failed.${RESET}\n" "$FAILED"

  if [[ $FAILED -gt 0 ]]; then
    printf "${RED}Failed tests:${RESET}\n"
    printf " - %s\n" "${FAILED_TESTS[@]}"
    exit 1
  fi

  printf "${GREEN}All requested tests passed.${RESET}\n"
}

main "$@"
