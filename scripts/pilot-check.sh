#!/usr/bin/env bash
# scripts/pilot-check.sh
# Validação automatizada para piloto em máquina nova.
# Roda dependências + 4 suites + suites Node (se disponível).
# Saída: tabela colorida + exit code 0 (verde) ou 1 (algo falhou).

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_ROOT="$(pwd)"

if [[ -t 1 ]]; then
  GREEN='\033[38;5;82m'; RED='\033[38;5;196m'; YELLOW='\033[38;5;220m'
  DIM='\033[2m'; BOLD='\033[1m'; ORANGE='\033[38;2;232;85;12m'; RESET='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; DIM=''; BOLD=''; ORANGE=''; RESET=''
fi

PASS=0; FAIL=0; WARN=0

check() {
  local label="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %s\n" "$label"
    PASS=$((PASS+1))
  else
    printf "  ${RED}✗${RESET} %s ${DIM}— rode: %s${RESET}\n" "$label" "$cmd"
    FAIL=$((FAIL+1))
  fi
}

soft_check() {
  local label="$1" cmd="$2" hint="$3"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "  ${GREEN}✓${RESET} %s\n" "$label"
    PASS=$((PASS+1))
  else
    printf "  ${YELLOW}⚠${RESET} %s ${DIM}— %s${RESET}\n" "$label" "$hint"
    WARN=$((WARN+1))
  fi
}

section() { printf "\n${ORANGE}${BOLD}▸ %s${RESET}\n" "$1"; }

printf "${BOLD}MBit AI SDK · Pilot Check${RESET} ${DIM}— $(date -u +%FT%TZ)${RESET}\n"
printf "${DIM}Path: %s${RESET}\n" "$REPO_ROOT"

section "1/4 — Dependências do sistema"
check "bash disponível"          "command -v bash"
check "git disponível"           "command -v git"
check "jq disponível"            "command -v jq"
soft_check "node disponível (>=20)" \
  "command -v node && node -e 'process.exit(parseInt(process.versions.node.split(\".\")[0])>=20?0:1)'" \
  "necessário só para integrações Slack/PagerDuty"

section "2/4 — Permissões dos scripts"
NONEXEC=$(find . -name "*.sh" -not -path "*/node_modules/*" -not -path "*/.git/*" ! -executable 2>/dev/null | head -3)
if [[ -z "$NONEXEC" ]]; then
  printf "  ${GREEN}✓${RESET} todos os scripts .sh executáveis\n"
  PASS=$((PASS+1))
else
  printf "  ${YELLOW}⚠${RESET} alguns scripts sem +x ${DIM}— rode: find . -name \"*.sh\" -exec chmod +x {} \\;${RESET}\n"
  echo "$NONEXEC" | sed "s|^|       |"
  WARN=$((WARN+1))
fi

section "3/4 — Suites de teste do SDK"
check "version sync (9 plugins)"  "bash plugins/mb-ai-core/scripts/version.sh 2>&1 | grep -q 'sincronizado'"
check "completeness (166 itens)"  "bash tests/completeness-check.sh 2>&1 | grep -q 'TUDO ENTREGUE'"
check "smoke (120 OK)"            "bash tests/smoke/run.sh 2>&1 | grep -q 'SUITE PASSOU'"
check "e2e (11 OK)"               "bash tests/e2e/run.sh 2>&1 | grep -q 'E2E PASSOU'"

section "4/4 — Suites Node (integrações)"
if command -v node >/dev/null 2>&1; then
  soft_check "slack node:test (4/4)"     "node --test integrations/slack/test/"     "pode falhar se Node < 20"
  soft_check "pagerduty node:test (1/1)" "node --test integrations/pagerduty/test/" "pode falhar se Node < 20"
else
  printf "  ${YELLOW}⚠${RESET} node ausente — pulando suites JS\n"
  WARN=$((WARN+1))
fi

printf "\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${GREEN}✓ %d OK${RESET}    ${YELLOW}⚠ %d aviso(s)${RESET}    ${RED}✗ %d falha(s)${RESET}\n\n" "$PASS" "$WARN" "$FAIL"

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}${BOLD}PILOTO NÃO PRONTO.${RESET} Veja PILOT-SETUP.md fase 0-2 para resolver.\n\n"
  exit 1
fi

cat <<EOF
${GREEN}${BOLD}PILOTO PRONTO. ⬡${RESET}

Próximos passos (em ${BOLD}PILOT-SETUP.md${RESET}):
  ${ORANGE}▸${RESET} Fase 3 — Registrar marketplace local no Claude Code
       ${DIM}/plugin marketplace add $REPO_ROOT${RESET}
  ${ORANGE}▸${RESET} Fase 4 — Instalar os 7 plugins core + opt-ins desejados
  ${ORANGE}▸${RESET} Fase 5 — Criar projeto piloto e rodar /mb-init
  ${ORANGE}▸${RESET} Fase 6 — Smoke test ponta a ponta no piloto

EOF
exit 0
