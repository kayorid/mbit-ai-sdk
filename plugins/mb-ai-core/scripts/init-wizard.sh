#!/usr/bin/env bash
# mb-ai-core / scripts / init-wizard.sh
# Setup interativo do MBit no ~/.claude/settings.json

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

P="${C_PRIMARY:-}"; B="${C_BOLD:-}"; D="${C_DIM:-}"; R="${C_RESET:-}"; S="${C_SUCCESS:-}"; W="${C_WARN:-}"; I="${C_INFO:-}"

bash "$PLUGIN_ROOT/lib/ascii.sh" welcome primary 2>/dev/null || true

printf "\n${P}${B}Setup MBit no Claude Code${R}\n${D}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}\n\n"

SETTINGS="${HOME}/.claude/settings.json"
mkdir -p "$(dirname "$SETTINGS")"

# Backup
if [[ -f "$SETTINGS" ]]; then
  BACKUP="${SETTINGS}.bak.$(date -u +%Y%m%dT%H%M%SZ)"
  cp "$SETTINGS" "$BACKUP"
  printf "  ${I}▸${R} Backup do settings atual: ${D}%s${R}\n" "$BACKUP"
fi

# Lê ou cria settings
if [[ -f "$SETTINGS" ]] && command -v jq >/dev/null 2>&1; then
  if ! jq empty "$SETTINGS" 2>/dev/null; then
    printf "  ${W}⚠${R} ~/.claude/settings.json existe mas é JSON inválido. Saindo.\n"
    exit 1
  fi
  CONTENT=$(cat "$SETTINGS")
else
  CONTENT='{}'
fi

# Detecta repo MBit
REPO_DEFAULT="kayorid/mbit-ai-sdk"
printf "\n${B}1. Repositório do marketplace MBit${R}\n"
printf "   ${D}(default: %s)${R}\n" "$REPO_DEFAULT"
read -r -p "   Repo: " REPO
REPO="${REPO:-$REPO_DEFAULT}"

# Adiciona marketplace + plugins
printf "\n${B}2. Configurando marketplace e plugins...${R}\n"

UPDATED=$(echo "$CONTENT" | jq --arg repo "$REPO" '
  .extraKnownMarketplaces.mb = {
    "source": {
      "source": "github",
      "repo": $repo
    }
  }
  | .enabledPlugins = ((.enabledPlugins // {}) + {
    "mb-ai-core@mb": true,
    "mb-bootstrap@mb": true,
    "mb-sdd@mb": true,
    "mb-review@mb": true,
    "mb-observability@mb": true,
    "mb-security@mb": true,
    "mb-retro@mb": true,
    "mb-cost@mb": true,
    "mb-evals@mb": true
  })
')

echo "$UPDATED" | jq '.' > "$SETTINGS"

printf "  ${S}✓${R} Marketplace ${B}mb${R} → ${D}%s${R}\n" "$REPO"
printf "  ${S}✓${R} 9 plugins habilitados (mb-ai-core, mb-bootstrap, mb-sdd, mb-review, mb-observability, mb-security, mb-retro, mb-cost, mb-evals)\n"

printf "\n${B}3. Próximos passos${R}\n"
printf "  ${S}▸${R} Reinicie o Claude Code\n"
printf "  ${S}▸${R} Rode ${B}/mb-doctor${R} para validar instalação\n"
printf "  ${S}▸${R} No primeiro repo do squad: ${B}/mb-bootstrap${R}\n\n"

printf "${S}${B}✨ Tudo pronto. Bem-vindo ao MBit. ⬡${R}\n\n"
