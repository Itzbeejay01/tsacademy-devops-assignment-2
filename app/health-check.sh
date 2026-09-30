#!/usr/bin/env bash

# Lightweight health check for the diagnostic application.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIAGNOSTIC="$SCRIPT_DIR/diagnostic.sh"

if [[ ! -x "$DIAGNOSTIC" ]]; then
  echo "Health check failed: diagnostic.sh is not executable." >&2
  exit 1
fi

if ! "$DIAGNOSTIC" help >/dev/null 2>&1; then
  echo "Health check failed: help command did not succeed." >&2
  exit 1
fi

if ! "$DIAGNOSTIC" disk >/dev/null 2>&1; then
  echo "Health check failed: disk command did not succeed." >&2
  exit 1
fi

echo "Diagnostic CLI health check: OK"
exit 0
