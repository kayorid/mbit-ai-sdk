#!/usr/bin/env bash
# mb-ai-core / achievements / notify.sh
# Verifica desbloqueios e exibe banner celebrativo se houver.
# Não-bloqueante.

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
NEW=$(bash "$PLUGIN_ROOT/achievements/checker.sh" 2>/dev/null || true)

[[ -z "$NEW" ]] && exit 0

# Carrega cores
# shellcheck disable=SC1091
[[ -f "$PLUGIN_ROOT/lib/colors.sh" ]] && source "$PLUGIN_ROOT/lib/colors.sh" && mb_load_palette || {
  C_PRIMARY='\033[38;5;220m'; C_ACCENT='\033[38;5;208m'; C_SUCCESS='\033[38;5;82m'
  C_BOLD='\033[1m'; C_DIM='\033[2m'; C_RESET='\033[0m'
}

DEF_FILE="$PLUGIN_ROOT/achievements/definitions.json"

echo -e "" >&2
echo -e "${C_PRIMARY}╔══════════════════════════════════════════════════════════════════╗${C_RESET}" >&2
echo -e "${C_PRIMARY}║${C_RESET}             ${C_BOLD}🎉  CONQUISTA(S) DESBLOQUEADA(S)  🎉${C_RESET}              ${C_PRIMARY}║${C_RESET}" >&2
echo -e "${C_PRIMARY}╠══════════════════════════════════════════════════════════════════╣${C_RESET}" >&2

while IFS= read -r id; do
  if command -v jq >/dev/null 2>&1; then
    icon=$(jq -r ".achievements[] | select(.id == \"$id\") | .icon" "$DEF_FILE")
    name=$(jq -r ".achievements[] | select(.id == \"$id\") | .name" "$DEF_FILE")
    desc=$(jq -r ".achievements[] | select(.id == \"$id\") | .description" "$DEF_FILE")
    echo -e "${C_PRIMARY}║${C_RESET}  ${icon}  ${C_BOLD}${name}${C_RESET}" >&2
    echo -e "${C_PRIMARY}║${C_RESET}     ${C_DIM}${desc}${C_RESET}" >&2
    echo -e "${C_PRIMARY}║${C_RESET}" >&2
  fi
done <<< "$NEW"

echo -e "${C_PRIMARY}╚══════════════════════════════════════════════════════════════════╝${C_RESET}" >&2
echo -e "${C_DIM}  Veja todas em /mb-achievements${C_RESET}" >&2
echo -e "" >&2

exit 0
