#!/usr/bin/env bash
# mb-ai-core / lib / ascii.sh
# Exibe ASCII art colorido para momentos-chave do SDK.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")}"
ASCII_DIR="$PLUGIN_ROOT/assets/ascii"

# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true

# mb_ascii_show <name> [color]
# name: welcome, bootstrap-done, spec-start, ship, hotfix, retro, mature-squad
# color: primary, accent, success, warn, danger, info (default: primary)
mb_ascii_show() {
  local name="${1:-welcome}"
  local color="${2:-primary}"
  local file="$ASCII_DIR/${name}.txt"

  [[ ! -f "$file" ]] && { echo "ASCII não encontrado: $name" >&2; return 1; }

  mb_load_palette 2>/dev/null || true

  local C=""
  case "$color" in
    primary) C="${C_PRIMARY:-}" ;;
    accent)  C="${C_ACCENT:-}"  ;;
    success) C="${C_SUCCESS:-}" ;;
    warn)    C="${C_WARN:-}"    ;;
    danger)  C="${C_DANGER:-}"  ;;
    info)    C="${C_INFO:-}"    ;;
    *)       C="${C_PRIMARY:-}" ;;
  esac

  printf "${C}"
  cat "$file"
  printf "${C_RESET:-}\n"
}

# Atalho conveniente — uso direto na linha de comando
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  mb_ascii_show "${1:-welcome}" "${2:-primary}"
fi
