#!/usr/bin/env bash
# Run all IBM Bob integration tests.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== IBM Bob integration tests ==="

for t in "$SCRIPT_DIR"/test-*.sh; do
  echo
  echo ">>> $t"
  bash "$t"
done

echo
echo "=== All IBM Bob tests passed ==="
