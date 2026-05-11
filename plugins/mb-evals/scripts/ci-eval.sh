#!/usr/bin/env bash
# mb-evals / scripts / ci-eval.sh
# Modo CI: roda eval, compara com threshold, exit 0/1.

set -euo pipefail

FEATURE="${1:-}"
[[ -z "$FEATURE" ]] && { echo "Uso: ci-eval.sh <feature-slug>"; exit 1; }

DIR="evals/$FEATURE"
THRESHOLD_FILE="$DIR/threshold.yaml"
[[ ! -f "$THRESHOLD_FILE" ]] && { echo "Sem threshold definido em $THRESHOLD_FILE"; exit 1; }

# Roda
bash "$DIR/runner.sh" 2>&1 | tee /tmp/mb-eval-out.txt

# Extrai pass rate (assume formato "Pass rate: X/Y (Z.ZZ%)")
PCT=$(grep -oE 'Pass rate: [0-9]+/[0-9]+ \([0-9.]+%' /tmp/mb-eval-out.txt | grep -oE '[0-9.]+%' | tr -d '%')
[[ -z "$PCT" ]] && { echo "✗ Não consegui extrair pass rate"; exit 1; }

# Lê thresholds
PASS_THRESHOLD=$(grep -E '^passing:' "$THRESHOLD_FILE" | awk '{print $2 * 100}')
FAIL_THRESHOLD=$(grep -E '^failing:' "$THRESHOLD_FILE" | awk '{print $2 * 100}')

if awk "BEGIN { exit !($PCT >= $PASS_THRESHOLD) }"; then
  echo "✓ EVAL PASSOU: $PCT% >= $PASS_THRESHOLD% threshold"
  exit 0
elif awk "BEGIN { exit !($PCT >= $FAIL_THRESHOLD) }"; then
  echo "⚠ EVAL ACEITO COM AVISO: $PCT% (entre fail $FAIL_THRESHOLD% e pass $PASS_THRESHOLD%)"
  exit 0
else
  echo "✗ EVAL FALHOU: $PCT% < $FAIL_THRESHOLD% threshold"
  exit 1
fi
