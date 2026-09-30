#!/usr/bin/env bash

set -u

IMAGE="tsacademy-diagnostic-test"
PASS=0
FAIL=0

pass() {
  echo "PASS: $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "FAIL: $1"
  FAIL=$((FAIL + 1))
}

cleanup() {
  docker image rm "$IMAGE" >/dev/null 2>&1 || true
}

trap cleanup EXIT

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is required to run the tests." >&2
  exit 2
fi

echo "Building test image..."
if docker build -t "$IMAGE" . >/tmp/assignment2-test-build.log 2>&1; then
  pass "Docker image builds"
else
  fail "Docker image builds"
  cat /tmp/assignment2-test-build.log
  exit 1
fi

run_success_test() {
  local name="$1"
  shift

  if "$@" >/tmp/assignment2-test-output.log 2>&1; then
    pass "$name"
  else
    fail "$name"
    cat /tmp/assignment2-test-output.log
  fi
}

run_success_test "help command succeeds" docker run --rm "$IMAGE" help
run_success_test "system command succeeds" docker run --rm "$IMAGE" system
run_success_test "disk command succeeds" docker run --rm "$IMAGE" disk

docker run --rm "$IMAGE" invalid-command >/tmp/assignment2-test-output.log 2>&1
rc=$?

if [[ $rc -eq 2 ]]; then
  pass "invalid command returns exit code 2"
else
  fail "invalid command should return exit code 2, got $rc"
  cat /tmp/assignment2-test-output.log
fi

echo
echo "=============================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "=============================="

[[ $FAIL -eq 0 ]]
