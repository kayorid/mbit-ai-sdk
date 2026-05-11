#!/usr/bin/env bash
# mb-ai-core / scripts / search-specs.sh
# Busca grep estruturada em specs ativas e arquivadas.

set -euo pipefail

QUERY="${1:-}"
[[ -z "$QUERY" ]] && { echo "Uso: search-specs.sh <termo>"; exit 1; }

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"; A="${C_ACCENT:-}"

printf "\n${P}${B}MBit · Busca em specs${R} ${D}— termo:${R} ${B}%s${R}\n\n" "$QUERY"

count_match() {
  local dir="$1"
  [[ ! -d "$dir" ]] && echo 0 && return
  grep -rli "$QUERY" "$dir" 2>/dev/null | wc -l | tr -d ' '
}

ACTIVE=$(count_match "docs/specs/_active")
ARCH=$(count_match "docs/specs/_archive")

printf "  Specs ativas com match:    ${B}%s${R}\n" "$ACTIVE"
printf "  Specs arquivadas com match: ${B}%s${R}\n\n" "$ARCH"

if [[ "$ACTIVE" -gt 0 ]] || [[ "$ARCH" -gt 0 ]]; then
  printf "${P}${B}Hits (limit 20):${R}\n\n"
  grep -rln --include='*.md' "$QUERY" docs/specs/_active docs/specs/_archive 2>/dev/null | head -20 | while read -r f; do
    SLUG=$(echo "$f" | sed 's|^docs/specs/||;s|/[^/]*\.md$||' | head -c 60)
    EXCERPT=$(grep -i "$QUERY" "$f" | head -1 | head -c 100)
    printf "  ${A}▸${R} ${B}%s${R}\n    ${D}%s${R}\n    ${D}└ %s${R}\n\n" "$f" "$SLUG" "$EXCERPT"
  done
else
  printf "${D}Nenhum hit. Termos relacionados podem ajudar.${R}\n\n"
fi
