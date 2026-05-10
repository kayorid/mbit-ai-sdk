#!/usr/bin/env bash
# mb-ai-core / lib / colors.sh
# Paleta MBit oficial — laranja MB #E8550C como cor primária.
# Resolve tema dinamicamente a partir de .mb/config.yaml ou MB_THEME.

# shellcheck disable=SC2034

mb_theme() {
  local theme="${MB_THEME:-}"
  if [[ -z "$theme" && -f .mb/config.yaml ]]; then
    theme=$(grep -E '^theme:' .mb/config.yaml 2>/dev/null | sed 's/theme:[[:space:]]*//' | tr -d '"' | tr -d "'" | head -1)
  fi
  echo "${theme:-default}"
}

mb_load_palette() {
  local theme="$(mb_theme)"
  case "$theme" in
    festive)
      C_PRIMARY='\033[38;2;232;85;12m'      # MB orange #E8550C
      C_ACCENT='\033[38;5;201m'             # magenta vibrante (festivo)
      C_SUCCESS='\033[38;5;82m'
      C_WARN='\033[38;5;220m'
      C_DANGER='\033[38;5;196m'
      C_INFO='\033[38;5;87m'
      C_DIM='\033[2m'
      C_BOLD='\033[1m'
      C_RESET='\033[0m'
      ;;
    compact)
      C_PRIMARY='\033[33m'
      C_ACCENT='\033[31m'
      C_SUCCESS='\033[32m'
      C_WARN='\033[33m'
      C_DANGER='\033[31m'
      C_INFO='\033[36m'
      C_DIM='\033[2m'
      C_BOLD='\033[1m'
      C_RESET='\033[0m'
      ;;
    accessible)
      C_PRIMARY='\033[1;31m'
      C_ACCENT='\033[1;33m'
      C_SUCCESS='\033[1;32m'
      C_WARN='\033[1;33m'
      C_DANGER='\033[1;31m'
      C_INFO='\033[1;36m'
      C_DIM=''
      C_BOLD='\033[1m'
      C_RESET='\033[0m'
      ;;
    none|plain|nocolor)
      C_PRIMARY=''
      C_ACCENT=''
      C_SUCCESS=''
      C_WARN=''
      C_DANGER=''
      C_INFO=''
      C_DIM=''
      C_BOLD=''
      C_RESET=''
      ;;
    *)
      # default — paleta MBit oficial
      C_PRIMARY='\033[38;2;232;85;12m'      # MB orange #E8550C (primária da marca)
      C_ACCENT='\033[38;5;208m'             # laranja secundário (gradiente)
      C_SUCCESS='\033[38;5;82m'             # verde
      C_WARN='\033[38;5;220m'               # amarelo
      C_DANGER='\033[38;5;196m'             # vermelho
      C_INFO='\033[38;5;87m'                # cyan
      C_DIM='\033[2m'
      C_BOLD='\033[1m'
      C_RESET='\033[0m'
      ;;
  esac
  export C_PRIMARY C_ACCENT C_SUCCESS C_WARN C_DANGER C_INFO C_DIM C_BOLD C_RESET
}

# Símbolos por tema
mb_load_glyphs() {
  local theme="$(mb_theme)"
  case "$theme" in
    compact|accessible)
      G_OK="[OK]"
      G_WARN="[!]"
      G_FAIL="[X]"
      G_BULLET="*"
      G_DIAMOND="<MB>"
      G_HEXAGON="<>"
      G_SHIELD="(s)"
      ;;
    *)
      G_OK="✓"
      G_WARN="⚠"
      G_FAIL="✗"
      G_BULLET="•"
      G_DIAMOND="⬡"
      G_HEXAGON="⬡"
      G_SHIELD="🛡"
      ;;
  esac
  export G_OK G_WARN G_FAIL G_BULLET G_DIAMOND G_HEXAGON G_SHIELD
}

# Helpers de impressão
mb_say()    { mb_load_palette; mb_load_glyphs; echo -e "${C_PRIMARY}${G_HEXAGON} MBit${C_RESET} ${C_DIM}·${C_RESET} $*"; }
mb_ok()     { mb_load_palette; mb_load_glyphs; echo -e "${C_SUCCESS}${G_OK}${C_RESET} $*"; }
mb_warn()   { mb_load_palette; mb_load_glyphs; echo -e "${C_WARN}${G_WARN}${C_RESET} $*"; }
mb_fail()   { mb_load_palette; mb_load_glyphs; echo -e "${C_DANGER}${G_FAIL}${C_RESET} $*"; }
mb_info()   { mb_load_palette; echo -e "${C_INFO}${C_RESET} $*"; }
mb_rule()   { mb_load_palette; echo -e "${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"; }
