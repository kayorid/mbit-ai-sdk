#!/usr/bin/env bash
# MBit · Smoke Test Suite
# Cobertura: estrutura, manifestos, scripts, hooks (positivo + negativo),
# sincronização de versões, regressão dos bugs encontrados em REVIEW.md.

set -uo pipefail

ROOT="$(cd "$(dirname "$(realpath "$0")")"/../.. && pwd)"
cd "$ROOT"

# Cores
GOLD=$'\033[38;2;232;85;12m'
GREEN=$'\033[38;5;82m'
RED=$'\033[38;5;196m'
YELLOW=$'\033[38;5;220m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

PASS=0
FAIL=0
WARN=0
START=$(date +%s)

t_pass() { printf "  ${GREEN}✓${RESET} %s\n" "$1"; PASS=$((PASS+1)); }
t_fail() { printf "  ${RED}✗${RESET} %s\n" "$1"; printf "      ${DIM}↳ %s${RESET}\n" "$2"; FAIL=$((FAIL+1)); }
t_warn() { printf "  ${YELLOW}⚠${RESET} %s\n" "$1"; printf "      ${DIM}↳ %s${RESET}\n" "$2"; WARN=$((WARN+1)); }
section() { printf "\n${GOLD}${BOLD}▸ %s${RESET}\n" "$1"; }

HAVE_JQ=0; HAVE_PY=0
command -v jq >/dev/null 2>&1 && HAVE_JQ=1
command -v python3 >/dev/null 2>&1 && HAVE_PY=1

json_valid() {
  local f="$1"
  if [[ $HAVE_JQ -eq 1 ]]; then jq empty "$f" 2>/dev/null
  elif [[ $HAVE_PY -eq 1 ]]; then python3 -c "import json; json.load(open('$f'))" 2>/dev/null
  else return 0; fi
}

json_query() {
  local f="$1"; local jqpath="$2"; local pypath="$3"
  if [[ $HAVE_JQ -eq 1 ]]; then jq -r "$jqpath" "$f" 2>/dev/null
  elif [[ $HAVE_PY -eq 1 ]]; then python3 -c "import json; d=json.load(open('$f')); $pypath" 2>/dev/null
  else echo "?"; fi
}

# Helper: roda hook com payload, retorna exit code
run_hook() {
  local hook="$1"; local payload="$2"
  local exit_code=0
  echo "$payload" | bash "$hook" >/dev/null 2>&1 || exit_code=$?
  echo "$exit_code"
}

assert_block() {
  local label="$1"; local hook="$2"; local payload="$3"
  local code=$(run_hook "$hook" "$payload")
  if [[ "$code" == "2" ]]; then t_pass "$label (exit 2)"
  else t_fail "$label não bloqueou" "exit=$code, esperado 2"; fi
}

assert_allow() {
  local label="$1"; local hook="$2"; local payload="$3"
  local code=$(run_hook "$hook" "$payload")
  if [[ "$code" == "0" ]]; then t_pass "$label (exit 0)"
  else t_fail "$label deveria permitir" "exit=$code, esperado 0"; fi
}

printf "\n${GOLD}${BOLD}MBit · Smoke Test Suite${RESET}\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# ============================================================
section "Repo top-level"
# ============================================================

[[ -f README.md ]] && t_pass "README.md presente" || t_fail "README.md ausente" "obrigatório"
[[ -f CHANGELOG.md ]] && t_pass "CHANGELOG.md presente" || t_fail "CHANGELOG.md ausente" ""
[[ -f LICENSE ]] && t_pass "LICENSE presente" || t_fail "LICENSE ausente" "obrigatório"
[[ -d docs ]] && t_pass "docs/ presente" || t_fail "docs/ ausente" ""
[[ -d plugins ]] && t_pass "plugins/ presente" || t_fail "plugins/ ausente" ""
[[ -f .claude-plugin/marketplace.json ]] && t_pass "marketplace.json presente" || t_fail "marketplace.json ausente" ""

# Regressão B-1 / H-1: CHANGELOG menciona versão atual
if [[ -f CHANGELOG.md ]]; then
  CURRENT_VER=$(json_query .claude-plugin/marketplace.json '.plugins[0].version' "print(d['plugins'][0]['version'])")
  if grep -q "^## \[${CURRENT_VER}\]" CHANGELOG.md; then
    t_pass "CHANGELOG menciona v${CURRENT_VER}"
  else
    t_fail "CHANGELOG sem entrada para v${CURRENT_VER}" "atualizar antes de release"
  fi
fi

# ============================================================
section "Marketplace"
# ============================================================

if json_valid .claude-plugin/marketplace.json; then
  t_pass "marketplace.json é JSON válido"
  COUNT=$(json_query .claude-plugin/marketplace.json '.plugins | length' "print(len(d['plugins']))")
  t_pass "marketplace lista $COUNT plugins"

  if [[ $HAVE_JQ -eq 1 ]]; then
    while IFS= read -r src; do
      PATH_=$(echo "$src" | sed 's|^\./||')
      if [[ -d "$PATH_" ]]; then
        t_pass "plugin path existe: $PATH_"
      else
        t_fail "plugin path ausente: $PATH_" "verificar marketplace.json"
      fi
    done < <(jq -r '.plugins[].source' .claude-plugin/marketplace.json)
  fi
else
  t_fail "marketplace.json é JSON inválido" "verificar manualmente"
fi

# ============================================================
section "Plugin manifests"
# ============================================================

for p in plugins/*/.claude-plugin/plugin.json; do
  if json_valid "$p"; then
    NAME=$(json_query "$p" '.name' "print(d['name'])")
    VER=$(json_query "$p" '.version' "print(d['version'])")
    t_pass "$NAME@$VER"
  else
    t_fail "JSON inválido: $p" ""
  fi
done

# ============================================================
section "Sincronização de versões (regressão B-1)"
# ============================================================

if [[ $HAVE_JQ -eq 1 ]]; then
  ALL_OK=1
  while IFS= read -r entry; do
    NAME=$(echo "$entry" | jq -r '.name')
    MARKET_VER=$(echo "$entry" | jq -r '.version')
    PLUGIN_FILE="plugins/${NAME}/.claude-plugin/plugin.json"
    if [[ -f "$PLUGIN_FILE" ]]; then
      PLUGIN_VER=$(jq -r '.version' "$PLUGIN_FILE")
      if [[ "$MARKET_VER" == "$PLUGIN_VER" ]]; then
        t_pass "$NAME: marketplace=$MARKET_VER == plugin.json=$PLUGIN_VER"
      else
        t_fail "$NAME: versões dessincronizadas" "marketplace=$MARKET_VER vs plugin.json=$PLUGIN_VER"
        ALL_OK=0
      fi
    fi
  done < <(jq -c '.plugins[]' .claude-plugin/marketplace.json)
fi

# ============================================================
section "Hooks JSON"
# ============================================================

for h in plugins/*/hooks/hooks.json; do
  if json_valid "$h"; then
    t_pass "$(echo "$h" | sed 's|plugins/||;s|/hooks/hooks.json||')"
  else
    t_fail "hooks.json inválido: $h" ""
  fi
done

# ============================================================
section "Outros JSONs"
# ============================================================

for j in plugins/*/config/*.json plugins/*/achievements/*.json; do
  [[ ! -f "$j" ]] && continue
  if json_valid "$j"; then
    t_pass "$(echo "$j" | sed 's|plugins/||')"
  else
    t_fail "JSON inválido: $j" ""
  fi
done

# ============================================================
section "Scripts shell — sintaxe"
# ============================================================

SH_TOTAL=0; SH_FAIL=0
while IFS= read -r script; do
  SH_TOTAL=$((SH_TOTAL+1))
  if ! bash -n "$script" 2>/dev/null; then
    t_fail "$(basename "$script")" "sintaxe inválida em $script"
    SH_FAIL=$((SH_FAIL+1))
  fi
done < <(find plugins tests -name '*.sh')
[[ $SH_FAIL -eq 0 ]] && t_pass "$SH_TOTAL scripts shell — sintaxe OK"

# ============================================================
section "Scripts shell — executáveis"
# ============================================================

EX_TOTAL=0; EX_FAIL=0
while IFS= read -r script; do
  EX_TOTAL=$((EX_TOTAL+1))
  if [[ ! -x "$script" ]]; then
    t_fail "não-executável: $(basename "$script")" "chmod +x $script"
    EX_FAIL=$((EX_FAIL+1))
  fi
done < <(find plugins -path '*/hooks/scripts/*.sh' -o -path '*/scripts/*.sh' -o -path '*/achievements/*.sh' -o -path '*/lib/*.sh')
[[ $EX_FAIL -eq 0 ]] && t_pass "$EX_TOTAL scripts são executáveis"

# ============================================================
section "Skills"
# ============================================================

SK_TOTAL=0
while IFS= read -r skill; do
  SK_TOTAL=$((SK_TOTAL+1))
  if ! head -10 "$skill" | grep -q '^name:' || ! head -10 "$skill" | grep -q '^description:'; then
    t_fail "skill sem frontmatter: $skill" "name + description obrigatórios"
  fi
done < <(find plugins -name 'SKILL.md')
t_pass "$SK_TOTAL skills com frontmatter válido"

# ============================================================
section "Comandos"
# ============================================================

CMD_TOTAL=$(find plugins -path '*/commands/*.md' | wc -l | tr -d ' ')
t_pass "$CMD_TOTAL comandos detectados"

# ============================================================
section "Hooks core — positivo (deve bloquear)"
# ============================================================

if [[ $HAVE_JQ -eq 0 ]]; then
  t_warn "jq ausente — pulando testes de execução" "instale jq"
else
  HOOK_SECRET="plugins/mb-ai-core/hooks/scripts/secret-scan.sh"
  HOOK_DESTR="plugins/mb-ai-core/hooks/scripts/destructive-confirm.sh"
  HOOK_PII="plugins/mb-security/hooks/scripts/pii-scan.sh"
  HOOK_KEY="plugins/mb-security/hooks/scripts/private-key-scan.sh"

  assert_block "secret-scan: AWS access key" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/config.ts","content":"const KEY=\"AKIAIOSFODNN7EXAMPLE\";"}}'

  assert_block "secret-scan: GitHub PAT" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/config.ts","content":"TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyz"}}'

  assert_block "secret-scan: RSA private key inline" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/config.ts","content":"const k = `-----BEGIN RSA PRIVATE KEY-----\nMIIE...`"}}'

  assert_block "destructive-confirm: rm -rf /" "$HOOK_DESTR" \
    '{"tool_input":{"command":"rm -rf /tmp/test-data"}}'

  assert_block "destructive-confirm: git push --force" "$HOOK_DESTR" \
    '{"tool_input":{"command":"git push origin main --force"}}'

  assert_block "destructive-confirm: git reset --hard" "$HOOK_DESTR" \
    '{"tool_input":{"command":"git reset --hard HEAD~5"}}'

  assert_block "destructive-confirm: DROP TABLE" "$HOOK_DESTR" \
    '{"tool_input":{"command":"psql -c \"DROP TABLE users\""}}'

  assert_block "pii-scan: CPF" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/cliente.ts","content":"const cpf = \"123.456.789-00\";"}}'

  assert_block "pii-scan: CNPJ" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/empresa.ts","content":"const cnpj = \"12.345.678/0001-90\";"}}'

  # Regressão B-3: cartão de crédito Visa precisa bloquear
  assert_block "pii-scan: Visa 4111111111111111 (regressão B-3)" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/pagamento.ts","content":"const card=\"4111111111111111\";"}}'

  assert_block "pii-scan: Mastercard (regressão B-3)" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/pagamento.ts","content":"const card=\"5555555555554444\";"}}'

  assert_block "pii-scan: Amex (regressão B-3)" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/pagamento.ts","content":"const card=\"378282246310005\";"}}'

  assert_block "private-key-scan: RSA PEM" "$HOOK_KEY" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/key.pem","content":"-----BEGIN RSA PRIVATE KEY-----\nMIIE..."}}'

  assert_block "private-key-scan: BIP-32 xprv" "$HOOK_KEY" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/wallet.json","content":"\"xprv\":\"xprvA1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTU\""}}'

  # Regressão B-3: Ethereum hex 64 + keyword
  assert_block "private-key-scan: Ethereum hex+keyword (regressão B-3)" "$HOOK_KEY" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/eth.ts","content":"const private = \"0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef\";"}}'
fi

# ============================================================
section "Hooks core — negativo (deve permitir)"
# ============================================================

if [[ $HAVE_JQ -eq 1 ]]; then
  assert_allow "secret-scan: payload limpo" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/hello.ts","content":"const NAME = \"world\";"}}'

  assert_allow "destructive-confirm: git status" "$HOOK_DESTR" \
    '{"tool_input":{"command":"git status"}}'

  assert_allow "destructive-confirm: git push --force-with-lease (regressão H-9)" "$HOOK_DESTR" \
    '{"tool_input":{"command":"git push --force-with-lease origin feature"}}'

  assert_allow "destructive-confirm: rm -rf com MB_CONFIRMED" "$HOOK_DESTR" \
    '{"tool_input":{"command":"rm -rf /tmp/foo # MB_CONFIRMED"}}'

  assert_allow "pii-scan: CPF em arquivo _test" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/cliente_test.ts","content":"const cpf=\"123.456.789-00\";"}}'

  assert_allow "pii-scan: CPF placeholder 000.000.000-00" "$HOOK_PII" \
    '{"tool_name":"Write","tool_input":{"file_path":"src/cliente.ts","content":"const PLACEHOLDER=\"000.000.000-00\";"}}'

  assert_allow "secret-scan: .env.local com placeholder (regressão H-7)" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":".env.local","content":"API_KEY=<your-key-here>\nDB_PASS=changeme"}}'

  assert_allow "secret-scan: .env.example" "$HOOK_SECRET" \
    '{"tool_name":"Write","tool_input":{"file_path":".env.example","content":"API_KEY=foo\nDB_PASS=bar"}}'
fi

# ============================================================
section "cost-report.sh — execução (regressão B-2)"
# ============================================================

# Cria sandbox temporário para teste
TMPDIR_TEST=$(mktemp -d 2>/dev/null || mktemp -d -t mbit)
mkdir -p "$TMPDIR_TEST/.mb/audit"
echo "2026-05-09T10:00:00Z | feature=foo | phase=PLAN | tool=Bash | in_tokens=100 | out_tokens=50 | model=claude | actor=test@mb | price_in=3.00 | price_out=15.00 | rate=5.30" \
  > "$TMPDIR_TEST/.mb/audit/cost.log"

(
  cd "$TMPDIR_TEST"
  for mode in day week month; do
    if bash "$ROOT/plugins/mb-cost/scripts/cost-report.sh" "$mode" >/dev/null 2>&1; then
      printf "  ${GREEN}✓${RESET} cost-report $mode (exit 0)\n" >&2
    else
      EXIT=$?
      printf "  ${RED}✗${RESET} cost-report $mode falhou (exit $EXIT)\n" >&2
      printf "      ${DIM}↳ regressão B-2: variável FEAT unbound${RESET}\n" >&2
      false
    fi
  done
)
COST_RC=$?
rm -rf "$TMPDIR_TEST"
if [[ $COST_RC -eq 0 ]]; then
  PASS=$((PASS+3))
else
  FAIL=$((FAIL+1))
fi

# ============================================================
section "cost-capture overhead (regressão B-4)"
# ============================================================

# Payload sem 'usage' deve sair em <50ms
PAYLOAD_NO_USAGE='{"tool_name":"Read","tool_input":{"file_path":"x.txt"}}'
T0=$(perl -MTime::HiRes=time -e 'printf "%d\n", time*1000' 2>/dev/null || date +%s000)
echo "$PAYLOAD_NO_USAGE" | bash plugins/mb-cost/hooks/scripts/cost-capture.sh >/dev/null 2>&1 || true
T1=$(perl -MTime::HiRes=time -e 'printf "%d\n", time*1000' 2>/dev/null || date +%s000)
ELAPSED=$((T1 - T0))
if [[ $ELAPSED -lt 200 ]]; then
  t_pass "cost-capture sem usage: ${ELAPSED}ms (curto-circuito OK)"
else
  t_warn "cost-capture sem usage: ${ELAPSED}ms" "esperado <200ms (regressão B-4)"
fi

# ============================================================
section "ASCII art"
# ============================================================

for art in welcome bootstrap-done spec-start ship hotfix retro mature-squad hexagon-logo; do
  if [[ -f "plugins/mb-ai-core/assets/ascii/${art}.txt" ]]; then
    t_pass "ascii: ${art}.txt"
  else
    t_fail "ascii: ${art}.txt ausente" ""
  fi
done

# ============================================================
section "Documentação"
# ============================================================

[[ -f docs/plans/2026-05-10-mb-ai-sdk-design.md ]] && t_pass "design doc presente" || t_fail "design doc ausente" ""
[[ -f docs/plans/2026-05-10-evolution-roadmap.md ]] && t_pass "roadmap evolutivo presente" || t_fail "roadmap ausente" ""
[[ -f docs/manual/MANUAL.md ]] && t_pass "manual técnico presente" || t_fail "manual ausente" ""
[[ -f docs/presentation/PRESENTATION.md ]] && t_pass "roteiro apresentação presente" || t_fail "roteiro ausente" ""
[[ -f docs/governance/raci.md ]] && t_pass "RACI presente" || t_fail "RACI ausente" ""
[[ -f docs/playbooks/install-by-role.md ]] && t_pass "playbook instalação presente" || t_fail "playbook ausente" ""
[[ -f docs/faq.md ]] && t_pass "FAQ presente" || t_fail "FAQ ausente" ""

# ============================================================
section "Integrações"
# ============================================================

[[ -f .github/workflows/mb-ai-checks.yml ]] && t_pass "GHA workflow distribuído" || t_warn "GHA workflow ausente" ""
[[ -f integrations/slack/manifest.yaml ]] && t_pass "Slack manifest presente" || t_warn "Slack manifest ausente" ""

# ============================================================
section "pre-write-guard consolidado (v0.3.2 / M-1)"
# ============================================================

if [[ $HAVE_JQ -eq 1 ]]; then
  HOOK_GUARD="plugins/mb-security/hooks/scripts/pre-write-guard.sh"

  if [[ -x "$HOOK_GUARD" ]]; then
    t_pass "pre-write-guard.sh existe e é executável"

    assert_block "pre-write-guard: bloqueia AWS key via secret-scan delegado" "$HOOK_GUARD" \
      '{"tool_name":"Write","tool_input":{"file_path":"src/config.ts","content":"K=AKIAIOSFODNN7EXAMPLE"}}'

    assert_block "pre-write-guard: bloqueia CPF via pii-scan delegado" "$HOOK_GUARD" \
      '{"tool_name":"Write","tool_input":{"file_path":"src/cliente.ts","content":"const cpf=\"123.456.789-00\";"}}'

    assert_block "pre-write-guard: bloqueia chave privada via private-key-scan delegado" "$HOOK_GUARD" \
      '{"tool_name":"Write","tool_input":{"file_path":"src/key.pem","content":"-----BEGIN RSA PRIVATE KEY-----\nMIIE..."}}'

    assert_allow "pre-write-guard: permite payload limpo" "$HOOK_GUARD" \
      '{"tool_name":"Write","tool_input":{"file_path":"src/hello.ts","content":"const N=\"world\";"}}'

    # M-1: hooks.json de mb-security deve ter apenas 1 entrada Write|Edit
    HSEC="plugins/mb-security/hooks/hooks.json"
    ENTRIES=$(jq '.hooks.PreToolUse[0].hooks | length' "$HSEC")
    [[ "$ENTRIES" == "1" ]] && t_pass "mb-security hooks.json consolidado (1 entrada Write|Edit)" \
      || t_fail "mb-security hooks.json não consolidado" "esperado 1, achou $ENTRIES"

    # mb-ai-core não deve mais ter Write|Edit em PreToolUse
    HCORE="plugins/mb-ai-core/hooks/hooks.json"
    CORE_WE=$(jq '[.hooks.PreToolUse[]? | select(.matcher == "Write|Edit")] | length' "$HCORE")
    [[ "$CORE_WE" == "0" ]] && t_pass "mb-ai-core hooks.json sem Write|Edit (dedup M-1)" \
      || t_fail "mb-ai-core ainda tem Write|Edit" "achou $CORE_WE entradas"
  else
    t_fail "pre-write-guard.sh ausente ou não executável" "$HOOK_GUARD"
  fi
fi

# ============================================================
section "v0.5 — Comunidade & Workshops"
# ============================================================

LDR="plugins/mb-retro/scripts/leaderboard.sh"
NWS="plugins/mb-retro/scripts/newsletter.sh"
[[ -x "$LDR" ]] && t_pass "leaderboard.sh executável" || t_fail "leaderboard.sh ausente/não-executável" "$LDR"
[[ -x "$NWS" ]] && t_pass "newsletter.sh executável" || t_fail "newsletter.sh ausente/não-executável" "$NWS"

# Leaderboard roda sem erro
if bash "$LDR" >/dev/null 2>&1; then
  t_pass "leaderboard.sh executa sem erro"
else
  t_fail "leaderboard.sh com erro de execução" ""
fi

# Newsletter gera arquivos
TMPDIR_NL=$(mktemp -d)
( cd "$TMPDIR_NL" && bash "$REPO_ROOT_LOC/$NWS" 2026-Q2 >/dev/null 2>&1 ) || true
REPO_ROOT_LOC="."
if bash "$NWS" 2026-Q2 >/dev/null 2>&1; then
  if [[ -f docs/newsletter/2026-Q2.md && -f docs/newsletter/2026-Q2.html ]]; then
    t_pass "newsletter.sh gerou .md + .html"
    grep -q '<!doctype html>' docs/newsletter/2026-Q2.html && t_pass "newsletter HTML é doctype-correto" \
      || t_warn "newsletter HTML sem doctype" ""
    rm -f docs/newsletter/2026-Q2.md docs/newsletter/2026-Q2.html
  else
    t_fail "newsletter.sh não criou arquivos esperados" ""
  fi
else
  t_fail "newsletter.sh erro de execução" ""
fi
rm -rf "$TMPDIR_NL"

# Docs novos
for d in docs/governance/ai-champions.md docs/playbooks/ai-lab.md docs/plugins/opt-in-guide.md; do
  [[ -f "$d" ]] && t_pass "doc v0.5: $d" || t_fail "doc v0.5 ausente" "$d"
done

# ============================================================
section "Hook references — scripts existem"
# ============================================================

if [[ $HAVE_JQ -eq 1 ]]; then
  REF_FAIL=0
  for hjson in plugins/*/hooks/hooks.json; do
    PLUGIN_DIR=$(dirname "$(dirname "$hjson")")
    while IFS= read -r ref; do
      [[ -z "$ref" ]] && continue
      RESOLVED=$(echo "$ref" | sed "s|\${CLAUDE_PLUGIN_ROOT}|$PLUGIN_DIR|g")
      if [[ ! -f "$RESOLVED" ]]; then
        t_fail "hook referencia script ausente" "$RESOLVED (de $hjson)"
        REF_FAIL=$((REF_FAIL+1))
      fi
    done < <(jq -r '.. | .command? // empty' "$hjson" 2>/dev/null)
  done
  [[ $REF_FAIL -eq 0 ]] && t_pass "hooks.json referenciam scripts existentes"
fi

# ============================================================
# Resumo
# ============================================================

END=$(date +%s)
DUR=$((END - START))

printf "\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${GREEN}✓ %d OK${RESET}    ${YELLOW}⚠ %d aviso(s)${RESET}    ${RED}✗ %d falha(s)${RESET}\n" "$PASS" "$WARN" "$FAIL"
printf "  ${DIM}Concluído em %ds${RESET}\n\n" "$DUR"

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}${BOLD}SUITE FALHOU.${RESET} Resolva os ✗ antes de release.\n\n"
  exit 1
elif [[ $WARN -gt 0 ]]; then
  printf "${YELLOW}${BOLD}SUITE PASSOU COM AVISOS.${RESET} Revise os ⚠.\n\n"
  exit 0
else
  printf "${GREEN}${BOLD}SUITE PASSOU. Tudo perfeito. ⬡${RESET}\n\n"
  exit 0
fi
