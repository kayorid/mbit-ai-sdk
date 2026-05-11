#!/usr/bin/env bash
# mb-ai-core / scripts / version.sh
# Mostra versões de todos os plugins MBit instalados e versão do marketplace.

set -uo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

PLUGIN_PARENT=$(dirname "$PLUGIN_ROOT")
MARKET="${PLUGIN_PARENT}/../.claude-plugin/marketplace.json"

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"; S="${C_SUCCESS:-}"; W="${C_WARN:-}"; I="${C_INFO:-}"

printf "\n${P}${B}MBit · Versões${R}\n${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n\n"

# Marketplace info
if [[ -f "$MARKET" ]] && command -v jq >/dev/null 2>&1; then
  MARKET_NAME=$(jq -r '.name' "$MARKET" 2>/dev/null)
  PLUGIN_COUNT=$(jq -r '.plugins | length' "$MARKET" 2>/dev/null)
  printf "  ${I}Marketplace:${R} ${B}%s${R} · ${B}%s plugins${R}\n\n" "$MARKET_NAME" "$PLUGIN_COUNT"
fi

# Cada plugin
ANY_MISMATCH=0
printf "  ${B}%-20s  %-10s  %-10s  %s${R}\n" "Plugin" "Marketplace" "Local" "Status"
printf "  ${D}─────────────────────────────────────────────────────${R}\n"

for plugin_dir in "$PLUGIN_PARENT"/*/; do
  PLUGIN_NAME=$(basename "$plugin_dir")
  PLUGIN_FILE="${plugin_dir}.claude-plugin/plugin.json"

  [[ ! -f "$PLUGIN_FILE" ]] && continue

  LOCAL_VER=$(jq -r '.version' "$PLUGIN_FILE" 2>/dev/null || echo "?")
  MARKET_VER=$(jq -r ".plugins[] | select(.name == \"$PLUGIN_NAME\") | .version" "$MARKET" 2>/dev/null || echo "—")

  if [[ "$LOCAL_VER" == "$MARKET_VER" ]]; then
    STATUS="${S}✓ sync${R}"
  elif [[ "$MARKET_VER" == "—" ]]; then
    STATUS="${W}⚠ não no marketplace${R}"
  else
    STATUS="${W}⚠ dessincronizado${R}"
    ANY_MISMATCH=1
  fi

  printf "  %-20s  %-10s  %-10s  ${STATUS}\n" "$PLUGIN_NAME" "$MARKET_VER" "$LOCAL_VER"
done

printf "\n"

# Versão de Claude Code (se disponível)
if command -v claude >/dev/null 2>&1; then
  CC_VER=$(claude --version 2>/dev/null | head -1 || echo "?")
  printf "  ${D}Claude Code:${R} %s\n" "$CC_VER"
fi

# Dependências
printf "  ${D}Dependências:${R}\n"
for cmd in jq git bash; do
  if command -v "$cmd" >/dev/null 2>&1; then
    VER=$("$cmd" --version 2>&1 | head -1 | head -c 60)
    printf "    ${S}✓${R} %-6s %s\n" "$cmd" "$VER"
  else
    printf "    ${W}✗${R} %-6s ausente\n" "$cmd"
  fi
done

if [[ $ANY_MISMATCH -eq 1 ]]; then
  printf "\n${W}⚠${R} Há plugins dessincronizados. Rode ${B}/mb-update${R} ou abra issue.\n\n"
  exit 1
fi

printf "\n${S}Tudo sincronizado.${R} ⬡\n\n"
