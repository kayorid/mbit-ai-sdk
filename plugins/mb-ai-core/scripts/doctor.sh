#!/usr/bin/env bash
# mb-ai-core / scripts / doctor.sh
# Diagnóstico completo do MB AI SDK no ambiente atual.
# Inspirado em `brew doctor`. Retorna exit 0 se tudo OK, 1 se houver erros.

set -uo pipefail
# Nota: doctor não usa -e propositalmente — quer continuar mostrando todas
# as verificações mesmo que algumas falhem.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true
mb_load_glyphs 2>/dev/null || true

PASS=0; WARN=0; FAIL=0

ok()   { printf "  ${C_SUCCESS:-}${G_OK:-✓}${C_RESET:-} %s\n" "$1"; PASS=$((PASS+1)); }
warn() { printf "  ${C_WARN:-}${G_WARN:-⚠}${C_RESET:-} %s\n" "$1"; printf "      ${C_DIM:-}↳ %s${C_RESET:-}\n" "$2"; WARN=$((WARN+1)); }
fail() { printf "  ${C_DANGER:-}${G_FAIL:-✗}${C_RESET:-} %s\n" "$1"; printf "      ${C_DIM:-}↳ %s${C_RESET:-}\n" "$2"; FAIL=$((FAIL+1)); }
sec()  { printf "\n${C_PRIMARY:-}${C_BOLD:-}%s${C_RESET:-}\n" "$1"; }

printf "${C_PRIMARY:-}${C_BOLD:-}\n  MB AI SDK · Diagnóstico\n${C_RESET:-}\n"

sec "Ambiente"
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  ok "Variável CLAUDE_PLUGIN_ROOT definida"
else
  warn "CLAUDE_PLUGIN_ROOT não definida" "Normal se rodando fora do Claude Code"
fi
if command -v jq >/dev/null 2>&1; then
  ok "jq instalado ($(jq --version 2>/dev/null))"
else
  fail "jq não instalado" "Necessário para hooks. Instale: brew install jq"
fi
if command -v git >/dev/null 2>&1; then
  ok "git instalado ($(git --version | awk '{print $3}'))"
else
  fail "git não instalado" "Indispensável"
fi

sec "Repositório atual"
if git rev-parse --git-dir >/dev/null 2>&1; then
  ok "Diretório é um repositório git"
  AUTHOR=$(git config user.email 2>/dev/null || echo "")
  if [[ -n "$AUTHOR" ]]; then
    ok "git identity configurada ($AUTHOR)"
  else
    warn "git user.email não configurada" "Necessária para /mb-approve gravar autor"
  fi
else
  warn "Não é um repositório git" "Bootstrap precisa de git inicializado"
fi

if [[ -f .gitignore ]]; then
  if grep -q '^\.env$\|^\.env\b' .gitignore; then
    ok ".env no .gitignore"
  else
    warn ".env não está no .gitignore" "Adicione: echo '.env' >> .gitignore"
  fi
fi

if [[ -f .env ]]; then
  if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    fail ".env rastreado em git" "git rm --cached .env e adicione ao .gitignore"
  fi
fi

sec "Estrutura .mb/"
if [[ -d .mb ]]; then
  ok "Diretório .mb/ existe"
  for f in CLAUDE.md glossary.md; do
    if [[ -f .mb/$f ]]; then ok ".mb/$f presente"; else warn ".mb/$f ausente" "Rode /mb-bootstrap ou /mb-bootstrap-rescan"; fi
  done
  for d in audit runbooks skills hooks bootstrap; do
    if [[ -d .mb/$d ]]; then ok ".mb/$d/ presente"; else warn ".mb/$d/ ausente" "Será criado quando necessário"; fi
  done
  if [[ -f .mb/config.yaml ]]; then ok ".mb/config.yaml presente"; else warn ".mb/config.yaml ausente" "Configuração padrão será assumida"; fi
else
  warn "Diretório .mb/ ausente" "Squad ainda não bootstrapado — rode /mb-bootstrap"
fi

sec "Plugins MB"
PLUGIN_PARENT=$(dirname "$PLUGIN_ROOT")
EXPECTED=(mb-ai-core mb-bootstrap mb-sdd mb-review mb-observability mb-security mb-retro)
for p in "${EXPECTED[@]}"; do
  if [[ -d "$PLUGIN_PARENT/$p" && -f "$PLUGIN_PARENT/$p/.claude-plugin/plugin.json" ]]; then
    VER=$(jq -r '.version // "?"' "$PLUGIN_PARENT/$p/.claude-plugin/plugin.json" 2>/dev/null)
    ok "$p@$VER"
  else
    warn "$p não encontrado" "Verifique se está habilitado em ~/.claude/settings.json"
  fi
done

sec "Hooks executáveis"
HOOK_COUNT=0
HOOK_FAIL=0
while IFS= read -r script; do
  HOOK_COUNT=$((HOOK_COUNT+1))
  if [[ ! -x "$script" ]]; then
    fail "$(basename "$script") não executável" "chmod +x $script"
    HOOK_FAIL=$((HOOK_FAIL+1))
  else
    if ! bash -n "$script" 2>/dev/null; then
      fail "$(basename "$script") com erro de sintaxe" "Verifique com bash -n"
      HOOK_FAIL=$((HOOK_FAIL+1))
    fi
  fi
done < <(find "$PLUGIN_PARENT" \( -path '*/hooks/scripts/*.sh' -o -path '*/scripts/*.sh' -o -path '*/lib/*.sh' -o -path '*/achievements/*.sh' \) -print 2>/dev/null)
if [[ $HOOK_FAIL -eq 0 ]]; then ok "$HOOK_COUNT scripts shell verificados (sintaxe OK + executáveis)"; fi

sec "Manifestos JSON"
JSON_FAIL=0
while IFS= read -r json; do
  if ! jq empty "$json" >/dev/null 2>&1; then
    fail "JSON inválido: $json" "Verifique com jq empty $json"
    JSON_FAIL=$((JSON_FAIL+1))
  fi
done < <(find "$PLUGIN_PARENT" -name 'plugin.json' -o -name 'marketplace.json' -o -name 'hooks.json' -o -name 'mcp-allowlist.json' -o -name 'definitions.json' 2>/dev/null)
[[ $JSON_FAIL -eq 0 ]] && ok "Todos os manifestos JSON são válidos"

sec "Audit trail"
if [[ -d .mb/audit ]]; then
  for log in approvals.log exceptions.log hook-fires.log security-events.log commands.log; do
    if [[ -f .mb/audit/$log ]]; then
      LINES=$(wc -l < ".mb/audit/$log" | tr -d ' ')
      ok "$log ($LINES linha(s))"
    fi
  done
else
  warn ".mb/audit ausente" "Será criado no primeiro uso"
fi

sec "Conformidade rápida"
if [[ -d "$PLUGIN_ROOT/config" && -f "$PLUGIN_ROOT/config/mcp-allowlist.json" ]]; then
  COUNT=$(jq -r '.approved | length' "$PLUGIN_ROOT/config/mcp-allowlist.json" 2>/dev/null)
  ok "MCP allowlist carregada ($COUNT MCPs aprovados)"
fi

# Resumo final
printf "\n${C_PRIMARY:-}${C_BOLD:-}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET:-}\n"
printf "  ${C_SUCCESS:-}${G_OK:-✓} %d OK${C_RESET:-}    ${C_WARN:-}${G_WARN:-⚠} %d aviso(s)${C_RESET:-}    ${C_DANGER:-}${G_FAIL:-✗} %d erro(s)${C_RESET:-}\n\n" \
  "$PASS" "$WARN" "$FAIL"

if [[ $FAIL -gt 0 ]]; then
  printf "${C_DANGER:-}Diagnóstico encontrou problemas. Resolva os ${G_FAIL:-✗} antes de prosseguir.${C_RESET:-}\n\n"
  exit 1
elif [[ $WARN -gt 0 ]]; then
  printf "${C_WARN:-}Diagnóstico OK com avisos. Considere resolver os ${G_WARN:-⚠} para experiência completa.${C_RESET:-}\n\n"
  exit 0
else
  printf "${C_SUCCESS:-}Tudo perfeito. SDK pronto para uso.${C_RESET:-}\n\n"
  exit 0
fi
