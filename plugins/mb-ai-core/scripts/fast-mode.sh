#!/usr/bin/env bash
# mb-ai-core / scripts / fast-mode.sh
# Verifica critérios de maturidade e destrava /mb-fast

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

CONFIG=".mb/config.yaml"
[[ ! -d .mb ]] && { printf "${C_DANGER:-}✗${C_RESET:-} Squad não bootstrapado. Rode /mb-bootstrap primeiro.\n"; exit 1; }
[[ ! -f "$CONFIG" ]] && touch "$CONFIG"

# Critérios de maturidade
ARCH=$(find docs/specs/_archive -mindepth 2 -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')
EXC=$(find docs/specs -path '*exceptions.log' -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
PROMOTED=$(grep -lr 'mb-retro-promote\|promovido ao core' docs/specs/_archive 2>/dev/null | wc -l | tr -d ' ')
ACH_UNLOCKED=0
[[ -f .mb/achievements.json ]] && command -v jq >/dev/null && \
  ACH_UNLOCKED=$(jq -r '.unlocked | length' .mb/achievements.json 2>/dev/null || echo 0)

printf "\n${C_PRIMARY:-}${C_BOLD:-}MBit · Verificação de maturidade${C_RESET:-}\n\n"

OK=0
TOTAL=4

check() {
  local label="$1"; local val="$2"; local req="$3"; local pass="$4"
  if [[ $pass -eq 1 ]]; then
    printf "  ${C_SUCCESS:-}✓${C_RESET:-} %s: ${C_BOLD:-}%s${C_RESET:-} (requerido: %s)\n" "$label" "$val" "$req"
    OK=$((OK+1))
  else
    printf "  ${C_DANGER:-}✗${C_RESET:-} %s: ${C_BOLD:-}%s${C_RESET:-} (requerido: %s)\n" "$label" "$val" "$req"
  fi
}

[[ $ARCH -ge 3 ]] && PASS=1 || PASS=0
check "Ciclos SDD completos" "$ARCH" ">= 3" $PASS

[[ $EXC -eq 0 ]] && PASS=1 || PASS=0
check "Exceções abertas" "$EXC" "== 0" $PASS

[[ $PROMOTED -ge 2 ]] && PASS=1 || PASS=0
check "Learnings promovidos" "$PROMOTED" ">= 2" $PASS

[[ $ACH_UNLOCKED -ge 5 ]] && PASS=1 || PASS=0
check "Achievements desbloqueados" "$ACH_UNLOCKED" ">= 5" $PASS

printf "\n  ${C_INFO:-}Score:${C_RESET:-} $OK/$TOTAL\n\n"

if [[ $OK -eq $TOTAL ]]; then
  # Destrava
  TMP=$(mktemp)
  if grep -q '^modes_unlocked:' "$CONFIG" 2>/dev/null; then
    sed 's/^modes_unlocked:.*$/modes_unlocked: [fast]/' "$CONFIG" > "$TMP" && mv "$TMP" "$CONFIG"
  else
    echo "modes_unlocked: [fast]" >> "$CONFIG"
  fi

  bash "$PLUGIN_ROOT/lib/ascii.sh" mature-squad accent 2>/dev/null || true

  printf "\n${C_SUCCESS:-}${C_BOLD:-}🏆 SQUAD MADURO — /mb-fast destravado.${C_RESET:-}\n"
  printf "${C_DIM:-}Tarefas pequenas (< 1 dia) podem usar /mb-fast direto. Features continuam pelo ciclo SDD completo.${C_RESET:-}\n\n"
else
  printf "${C_WARN:-}Squad ainda não maduro.${C_RESET:-} Continue acumulando ciclos completos com qualidade.\n"
  printf "${C_DIM:-}Reavalie quando todos os critérios passarem.${C_RESET:-}\n\n"
  exit 1
fi
