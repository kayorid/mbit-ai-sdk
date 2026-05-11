#!/usr/bin/env bash
# mb-security / pre-write-guard
# Orquestrador único de PreToolUse Write|Edit.
# Substitui as três entradas separadas (M-1 do REVIEW.md).
# Roda pii-scan + private-key-scan + secret-scan lendo o INPUT uma vez.
# Cada scanner permanece executável standalone para debug.

set -euo pipefail

INPUT="$(cat)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_scanner() {
  local scanner="$1"
  local rc=0
  printf '%s' "$INPUT" | bash "$SCRIPT_DIR/$scanner" || rc=$?
  if [[ $rc -ne 0 ]]; then
    exit "$rc"
  fi
}

run_scanner pii-scan.sh
run_scanner private-key-scan.sh
run_scanner secret-scan.sh

exit 0
