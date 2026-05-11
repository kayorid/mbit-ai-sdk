#!/usr/bin/env bash
# mb-retro / scripts / retro-digest.sh
# Resumo automático de retros recentes (últimas 5 ou últimos 30d).

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/../mb-ai-core/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

LIMIT="${1:-5}"

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"; A="${C_ACCENT:-}"; I="${C_INFO:-}"

printf "\n${P}${B}MBit · Retro Digest${R} ${D}— últimas $LIMIT retrospectivas${R}\n\n"

# Coleta retros recentes
RETROS=$(find docs/specs -name 'retro.md' -type f 2>/dev/null | xargs -I{} ls -t {} 2>/dev/null | head -"$LIMIT")

if [[ -z "$RETROS" ]]; then
  printf "${D}Nenhuma retrospectiva encontrada ainda.${R}\n\n"
  exit 0
fi

while IFS= read -r retro; do
  [[ -z "$retro" ]] && continue
  SLUG=$(echo "$retro" | sed 's|^docs/specs/[^/]*/||;s|/retro.md$||')
  printf "${A}▸ ${B}%s${R}\n" "$SLUG"

  # Extrai sections
  if grep -q '^## 1' "$retro" 2>/dev/null; then
    awk '/^## 1\. Funcionou bem/,/^## 2/' "$retro" | sed '1d;$d' | head -3 | sed 's/^/    /'
  fi

  printf "\n"
done <<< "$RETROS"

printf "${D}Para análise consolidada trimestral: /mb-retro-quarterly${R}\n\n"
