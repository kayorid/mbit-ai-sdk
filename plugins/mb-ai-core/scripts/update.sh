#!/usr/bin/env bash
# mb-ai-core / scripts / update.sh
# Verifica e aplica atualizações do MBit SDK.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

CURRENT=$(jq -r '.version' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "0.0.0")

# Cache de plugins do Claude Code (não muda cwd — usa git -C)
CACHE="${HOME}/.claude/plugins/cache/mb"

# Comparação semver via sort -V (mais robusta que comparação lexicográfica)
version_gt() {
  # retorna 0 se $1 > $2 (semanticamente)
  [[ "$1" != "$2" ]] && [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | tail -1)" == "$1" ]]
}

printf "\n${C_PRIMARY:-}${C_BOLD:-}MBit · Atualização${C_RESET:-}\n\n"
printf "  Versão atual: ${C_BOLD:-}${CURRENT}${C_RESET:-}\n"

if [[ ! -d "$CACHE" ]]; then
  printf "  ${C_WARN:-}⚠${C_RESET:-} Cache de plugin não encontrado em ${CACHE}\n"
  printf "  Reinstale o marketplace via Claude Code settings.\n\n"
  exit 1
fi

# Verifica versão remota — usa git -C para não mudar cwd
git -C "$CACHE" fetch --quiet origin 2>/dev/null || \
  { printf "  ${C_WARN:-}⚠${C_RESET:-} Falha ao fetch do remoto. Sem rede ou cache corrompido.\n\n"; exit 1; }
LATEST=$(git -C "$CACHE" show origin/main:.claude-plugin/marketplace.json 2>/dev/null | jq -r '.plugins[] | select(.name == "mb-ai-core") | .version' || echo "$CURRENT")

# Validação semver mínima
if ! [[ "$LATEST" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf "  ${C_DANGER:-}✗${C_RESET:-} Versão remota inválida: '%s'\n\n" "$LATEST"
  exit 1
fi

printf "  Versão remota: ${C_BOLD:-}${LATEST}${C_RESET:-}\n\n"

if [[ "$CURRENT" == "$LATEST" ]] || ! version_gt "$LATEST" "$CURRENT"; then
  printf "${C_SUCCESS:-}✓${C_RESET:-} Você já está na versão mais recente (ou à frente).\n\n"
  exit 0
fi

# Mostra changelog
printf "${C_INFO:-}Mudanças desde sua versão:${C_RESET:-}\n\n"
git log --oneline "v${CURRENT}..origin/main" 2>/dev/null | head -20 | sed 's/^/  /' || \
  git log --oneline -20 origin/main 2>/dev/null | sed 's/^/  /' || \
  echo "  (changelog não disponível)"
printf "\n"

# Detecta breaking changes (heurística: major version bump)
CURRENT_MAJOR=$(echo "$CURRENT" | cut -d. -f1)
LATEST_MAJOR=$(echo "$LATEST" | cut -d. -f1)

if [[ "$CURRENT_MAJOR" != "$LATEST_MAJOR" ]]; then
  printf "${C_DANGER:-}⚠ MAJOR VERSION BUMP${C_RESET:-} (${CURRENT_MAJOR}.x → ${LATEST_MAJOR}.x)\n"
  printf "  Pode haver breaking changes. Leia o CHANGELOG antes de prosseguir.\n\n"
  read -p "Continuar? (s/N): " CONFIRM
  [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]] && printf "Cancelado.\n" && exit 0
fi

# Aplica via git -C
printf "${C_INFO:-}Atualizando...${C_RESET:-}\n"
git -C "$CACHE" pull --quiet origin main 2>/dev/null && \
  printf "${C_SUCCESS:-}✓${C_RESET:-} Atualizado para ${C_BOLD:-}${LATEST}${C_RESET:-}\n\n" || \
  { printf "${C_DANGER:-}✗${C_RESET:-} Falha ao atualizar (verifique 'git -C %s status')\n\n" "$CACHE"; exit 1; }

printf "${C_DIM:-}Reinicie a sessão do Claude Code para aplicar as mudanças.${C_RESET:-}\n\n"
