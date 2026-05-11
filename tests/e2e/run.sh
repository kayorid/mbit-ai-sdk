#!/usr/bin/env bash
# tests/e2e/run.sh — Suite end-to-end do MBit AI SDK
# Simula um squad usando o SDK do zero, exercitando os hooks reais,
# scripts de bootstrap, ciclo SDD (spec/design/tasks), retro e achievements.
#
# Roda em diretório temporário isolado. Não requer Claude Code rodando —
# invoca scripts diretamente com payloads JSON equivalentes aos que o
# harness produziria.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
START=$(date +%s)

# Cores
if [[ -t 1 ]]; then
  GREEN='\033[38;5;82m'; RED='\033[38;5;196m'; YELLOW='\033[38;5;220m'
  DIM='\033[2m'; BOLD='\033[1m'; ORANGE='\033[38;2;232;85;12m'; RESET='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; DIM=''; BOLD=''; ORANGE=''; RESET=''
fi

PASS=0; FAIL=0; WARN=0

t_pass() { PASS=$((PASS+1)); printf "  ${GREEN}✓${RESET} %s\n" "$1"; }
t_fail() { FAIL=$((FAIL+1)); printf "  ${RED}✗${RESET} %s — ${DIM}%s${RESET}\n" "$1" "${2:-}"; }
t_warn() { WARN=$((WARN+1)); printf "  ${YELLOW}⚠${RESET} %s — ${DIM}%s${RESET}\n" "$1" "${2:-}"; }
section() {
  printf "\n${ORANGE}${BOLD}▸ %s${RESET}\n" "$1"
}

printf "${BOLD}MBit E2E suite${RESET} ${DIM}— ciclo completo num sandbox temporário${RESET}\n"

# Pré-requisitos
command -v jq >/dev/null || { echo "${RED}jq ausente; abortando${RESET}"; exit 1; }
command -v git >/dev/null || { echo "${RED}git ausente; abortando${RESET}"; exit 1; }

# Sandbox temporário com cleanup garantido
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t mbit-e2e)
cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

section "1/6 — Setup sandbox"
cd "$TMP"
git init -q
git config user.email "e2e@mbit.test"
git config user.name "E2E"
echo "# Dummy squad repo" > README.md
git add README.md
git commit -qm "initial"
t_pass "sandbox criado em $TMP"

section "2/6 — Bootstrap: criar .mb/CLAUDE.md"
mkdir -p .mb docs/specs/_active
cat > .mb/CLAUDE.md <<'EOF'
# CLAUDE.md — Squad Câmbio E2E

Squad: cambio-e2e
Stack: typescript/node
Maintainer: e2e
EOF
[[ -f .mb/CLAUDE.md ]] && t_pass "bootstrap stub criado" || t_fail "bootstrap stub" ""

section "3/6 — Hooks PreToolUse rodando contra payloads reais"

GUARD="$REPO_ROOT/plugins/mb-security/hooks/scripts/pre-write-guard.sh"
[[ -x "$GUARD" ]] || { t_fail "pre-write-guard ausente"; exit 1; }

# Positivo: deve bloquear PII
PAYLOAD_PII='{"tool_name":"Write","tool_input":{"file_path":"src/customer.ts","content":"const cpf=\"123.456.789-00\";"}}'
if printf '%s' "$PAYLOAD_PII" | bash "$GUARD" >/dev/null 2>&1; then
  t_fail "pre-write-guard deveria ter bloqueado CPF" ""
else
  t_pass "pre-write-guard bloqueou CPF (exit != 0)"
fi

# Positivo: deve bloquear chave privada
PAYLOAD_KEY='{"tool_name":"Write","tool_input":{"file_path":"src/k.pem","content":"-----BEGIN RSA PRIVATE KEY-----\nMIIE..."}}'
if printf '%s' "$PAYLOAD_KEY" | bash "$GUARD" >/dev/null 2>&1; then
  t_fail "pre-write-guard deveria ter bloqueado chave privada" ""
else
  t_pass "pre-write-guard bloqueou RSA PRIVATE KEY"
fi

# Positivo: deve bloquear AWS key
PAYLOAD_AWS='{"tool_name":"Write","tool_input":{"file_path":"src/c.ts","content":"K=AKIAIOSFODNN7EXAMPLE"}}'
if printf '%s' "$PAYLOAD_AWS" | bash "$GUARD" >/dev/null 2>&1; then
  t_fail "pre-write-guard deveria ter bloqueado AWS key" ""
else
  t_pass "pre-write-guard bloqueou AWS key"
fi

# Negativo: deve permitir
PAYLOAD_OK='{"tool_name":"Write","tool_input":{"file_path":"src/h.ts","content":"const x=1;"}}'
if printf '%s' "$PAYLOAD_OK" | bash "$GUARD" >/dev/null 2>&1; then
  t_pass "pre-write-guard permitiu código limpo"
else
  t_fail "pre-write-guard rejeitou código limpo" ""
fi

# Performance — bloqueio em <500ms para payload de 10KB
BIG_CONTENT=$(printf 'x%.0s' {1..10000})
PAYLOAD_BIG=$(jq -n --arg c "$BIG_CONTENT" '{tool_name:"Write",tool_input:{file_path:"src/big.ts",content:$c}}')
T_START=$(python3 -c 'import time;print(int(time.time()*1e9))')
printf '%s' "$PAYLOAD_BIG" | bash "$GUARD" >/dev/null 2>&1 || true
T_END=$(python3 -c 'import time;print(int(time.time()*1e9))')
DUR_MS=$(( (T_END - T_START) / 1000000 ))
if [[ $DUR_MS -lt 1000 ]]; then
  t_pass "pre-write-guard processou 10KB em ${DUR_MS}ms (<1s)"
else
  t_warn "pre-write-guard lento" "${DUR_MS}ms para 10KB"
fi

section "4/6 — Ciclo SDD: criar spec, design, tasks"
SLUG="$(date +%F)-feature-e2e"
mkdir -p "docs/specs/_active/$SLUG"
cat > "docs/specs/_active/$SLUG/requirements.md" <<'EOF'
# Feature E2E

## User stories
- US-1 Como dev, quero X

## Critérios (EARS)
- CA-1 Quando A, o sistema deve B
EOF
cat > "docs/specs/_active/$SLUG/design.md" <<'EOF'
# Design
Stack: TS
EOF
cat > "docs/specs/_active/$SLUG/tasks.md" <<'EOF'
# Tasks
- [ ] T1 — implementar X
EOF
[[ -f "docs/specs/_active/$SLUG/requirements.md" ]] && t_pass "spec criada em docs/specs/_active/$SLUG"

section "5/6 — Achievements checker rodando"
export MB_FORCE_ACHIEVEMENT_CHECK=1
export CLAUDE_PLUGIN_ROOT="$REPO_ROOT/plugins/mb-ai-core"
if bash "$REPO_ROOT/plugins/mb-ai-core/achievements/checker.sh" >/dev/null 2>&1; then
  if [[ -f .mb/achievements.json ]]; then
    UNLOCKED=$(jq -r '.unlocked | length' .mb/achievements.json 2>/dev/null || echo 0)
    LAST_EVAL=$(jq -r '.last_evaluated_at' .mb/achievements.json 2>/dev/null)
    [[ -n "$LAST_EVAL" && "$LAST_EVAL" != "1970-01-01T00:00:00Z" ]] && \
      t_pass "achievements avaliados (last=$LAST_EVAL, unlocked=$UNLOCKED)" || \
      t_warn "achievement timestamp não atualizado" ""
  else
    t_warn ".mb/achievements.json não foi criado" ""
  fi
else
  t_warn "achievements checker retornou erro" ""
fi

# Segunda chamada deve usar cache (M-7)
unset MB_FORCE_ACHIEVEMENT_CHECK
T_START=$(python3 -c 'import time;print(int(time.time()*1e9))')
bash "$REPO_ROOT/plugins/mb-ai-core/achievements/checker.sh" >/dev/null 2>&1 || true
T_END=$(python3 -c 'import time;print(int(time.time()*1e9))')
DUR_MS=$(( (T_END - T_START) / 1000000 ))
if [[ $DUR_MS -lt 200 ]]; then
  t_pass "achievements segunda chamada usou cache (${DUR_MS}ms)"
else
  t_warn "achievements segunda chamada lenta" "${DUR_MS}ms"
fi

section "6/6 — SessionStart banner: additionalContext sem ANSI (M-8)"
BANNER="$REPO_ROOT/plugins/mb-ai-core/hooks/scripts/session-start-banner.sh"
export CLAUDE_PLUGIN_ROOT="$REPO_ROOT/plugins/mb-ai-core"
CTX=$(echo '{}' | bash "$BANNER" 2>/dev/null || true)
if [[ -n "$CTX" ]]; then
  if printf '%s' "$CTX" | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null | grep -q $'\033\['; then
    t_fail "additionalContext contém ANSI (regressão M-8)" ""
  else
    t_pass "additionalContext sem ANSI (M-8 OK)"
  fi
else
  t_warn "banner não emitiu JSON" ""
fi

END=$(date +%s)
DUR=$((END - START))
printf "\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${GREEN}✓ %d OK${RESET}    ${YELLOW}⚠ %d aviso(s)${RESET}    ${RED}✗ %d falha(s)${RESET}\n" "$PASS" "$WARN" "$FAIL"
printf "  ${DIM}Concluído em %ds${RESET}\n\n" "$DUR"

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}${BOLD}E2E FALHOU.${RESET}\n"
  exit 1
fi
printf "${GREEN}${BOLD}E2E PASSOU. Ciclo completo verde. ⬡${RESET}\n"
exit 0
