#!/usr/bin/env bash
# MBit · Completeness check
# Loop de garantia: lista TUDO que deve existir e valida.
# Usado iterativamente até zero falhas.

set -uo pipefail

ROOT="$(cd "$(dirname "$(realpath "$0")")"/.. && pwd)"
cd "$ROOT"

GOLD=$'\033[38;2;232;85;12m'
GREEN=$'\033[38;5;82m'
RED=$'\033[38;5;196m'
YELLOW=$'\033[38;5;220m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

PASS=0
FAIL=0

t_pass() { printf "  ${GREEN}✓${RESET} %s\n" "$1"; PASS=$((PASS+1)); }
t_fail() { printf "  ${RED}✗${RESET} %s\n" "$1"; FAIL=$((FAIL+1)); }
section() { printf "\n${GOLD}${BOLD}▸ %s${RESET}\n" "$1"; }

printf "\n${GOLD}${BOLD}MBit · Completeness Check${RESET}\n"
printf "${DIM}Garantia: tudo que foi prometido está entregue${RESET}\n"

# ============================================================
section "Plugins esperados (9)"
# ============================================================
EXPECTED_PLUGINS=(mb-ai-core mb-bootstrap mb-sdd mb-review mb-observability mb-security mb-retro mb-cost mb-evals)
for p in "${EXPECTED_PLUGINS[@]}"; do
  if [[ -d "plugins/$p" && -f "plugins/$p/.claude-plugin/plugin.json" ]]; then
    t_pass "plugin: $p"
  else
    t_fail "plugin AUSENTE: $p"
  fi
done

# ============================================================
section "Comandos esperados v0.3.1 (lista canônica)"
# ============================================================
EXPECTED_CMDS=(
  # mb-ai-core
  "mb-ai-core/mb-help" "mb-ai-core/mb-status" "mb-ai-core/mb-approve" "mb-ai-core/mb-exception"
  "mb-ai-core/mb-init" "mb-ai-core/mb-doctor" "mb-ai-core/mb-snapshot" "mb-ai-core/mb-dashboard"
  "mb-ai-core/mb-tutorial" "mb-ai-core/mb-update" "mb-ai-core/mb-banner" "mb-ai-core/mb-ascii"
  "mb-ai-core/mb-achievements" "mb-ai-core/mb-fast" "mb-ai-core/mb-theme" "mb-ai-core/mb-search"
  "mb-ai-core/mb-new-skill" "mb-ai-core/mb-version" "mb-ai-core/mb-list-plugins"
  # mb-bootstrap
  "mb-bootstrap/mb-bootstrap" "mb-bootstrap/mb-bootstrap-rescan"
  "mb-bootstrap/mb-enrich-domain" "mb-bootstrap/mb-enrich-runbooks" "mb-bootstrap/mb-enrich-skills"
  # mb-sdd
  "mb-sdd/mb-spec" "mb-sdd/mb-spec-discuss" "mb-sdd/mb-spec-requirements"
  "mb-sdd/mb-spec-design" "mb-sdd/mb-spec-plan" "mb-sdd/mb-spec-execute"
  "mb-sdd/mb-spec-verify" "mb-sdd/mb-spec-retro" "mb-sdd/mb-hotfix" "mb-sdd/mb-spike"
  # mb-review
  "mb-review/mb-review-pr" "mb-review/mb-review-security"
  "mb-review/mb-review-spec" "mb-review/mb-review-fix"
  # mb-observability
  "mb-observability/mb-observability-design" "mb-observability/mb-observability-review"
  "mb-observability/mb-runbook-from-incident"
  # mb-security
  "mb-security/mb-threat-model" "mb-security/mb-security-checklist"
  "mb-security/mb-compliance-check" "mb-security/mb-secret-rotate"
  # mb-retro
  "mb-retro/mb-retro" "mb-retro/mb-retro-promote" "mb-retro/mb-retro-extract-skill"
  "mb-retro/mb-retro-quarterly" "mb-retro/mb-retro-digest"
  "mb-retro/mb-leaderboard" "mb-retro/mb-newsletter"
  "mb-retro/mb-adoption-report"
  "mb-sdd/mb-spec-from-ticket"
  # mb-cost
  "mb-cost/mb-cost" "mb-cost/mb-cost-feature" "mb-cost/mb-cost-budget" "mb-cost/mb-cost-alert"
  # mb-evals
  "mb-evals/mb-evals-init" "mb-evals/mb-evals-run" "mb-evals/mb-evals-compare" "mb-evals/mb-evals-ci"
)
for cmd in "${EXPECTED_CMDS[@]}"; do
  PLUGIN="${cmd%%/*}"
  CMDNAME="${cmd##*/}"
  if [[ -f "plugins/$PLUGIN/commands/$CMDNAME.md" ]]; then
    t_pass "$cmd.md"
  else
    t_fail "comando AUSENTE: $cmd.md"
  fi
done

# ============================================================
section "Skills esperadas (14)"
# ============================================================
EXPECTED_SKILLS=(
  "mb-ai-core/mb-constitution"
  "mb-bootstrap/mb-bootstrap"
  "mb-sdd/mb-sdd"
  "mb-review/mb-code-reviewer" "mb-review/mb-security-reviewer" "mb-review/mb-spec-reviewer"
  "mb-observability/mb-observability-designer" "mb-observability/mb-observability-reviewer"
  "mb-security/mb-threat-modeler" "mb-security/mb-compliance-advisor" "mb-security/mb-crypto-advisor"
  "mb-retro/mb-retro-facilitator" "mb-retro/mb-learning-extractor"
  "mb-evals/mb-evals"
)
for skill in "${EXPECTED_SKILLS[@]}"; do
  PLUGIN="${skill%%/*}"
  SKILL_NAME="${skill##*/}"
  if [[ -f "plugins/$PLUGIN/skills/$SKILL_NAME/SKILL.md" ]]; then
    t_pass "skill: $skill"
  else
    t_fail "skill AUSENTE: plugins/$PLUGIN/skills/$SKILL_NAME/SKILL.md"
  fi
done

# ============================================================
section "ASCII art (8)"
# ============================================================
EXPECTED_ASCII=(welcome bootstrap-done spec-start ship hotfix retro mature-squad hexagon-logo)
for art in "${EXPECTED_ASCII[@]}"; do
  if [[ -f "plugins/mb-ai-core/assets/ascii/${art}.txt" ]]; then
    t_pass "ascii: ${art}.txt"
  else
    t_fail "ascii AUSENTE: ${art}.txt"
  fi
done

# ============================================================
section "Hooks scripts (>=11)"
# ============================================================
EXPECTED_HOOKS=(
  "mb-ai-core/secret-scan.sh"
  "mb-ai-core/destructive-confirm.sh"
  "mb-ai-core/mcp-allowlist.sh"
  "mb-ai-core/audit-log.sh"
  "mb-ai-core/session-start-banner.sh"
  "mb-ai-core/stop-farewell.sh"
  "mb-ai-core/notify.sh"
  "mb-ai-core/statusline.sh"
  "mb-security/pii-scan.sh"
  "mb-security/private-key-scan.sh"
  "mb-cost/cost-capture.sh"
)
for hook in "${EXPECTED_HOOKS[@]}"; do
  PLUGIN="${hook%%/*}"
  SCRIPT="${hook##*/}"
  if [[ -f "plugins/$PLUGIN/hooks/scripts/$SCRIPT" && -x "plugins/$PLUGIN/hooks/scripts/$SCRIPT" ]]; then
    t_pass "hook: $hook"
  else
    t_fail "hook AUSENTE/não-executável: $hook"
  fi
done

# ============================================================
section "Scripts utilitários (>=15)"
# ============================================================
EXPECTED_SCRIPTS=(
  "mb-ai-core/scripts/doctor.sh"
  "mb-ai-core/scripts/snapshot.sh"
  "mb-ai-core/scripts/dashboard.sh"
  "mb-ai-core/scripts/update.sh"
  "mb-ai-core/scripts/tutorial-init.sh"
  "mb-ai-core/scripts/init-wizard.sh"
  "mb-ai-core/scripts/fast-mode.sh"
  "mb-ai-core/scripts/search-specs.sh"
  "mb-ai-core/scripts/new-skill.sh"
  "mb-ai-core/scripts/version.sh"
  "mb-ai-core/achievements/checker.sh"
  "mb-ai-core/achievements/notify.sh"
  "mb-ai-core/lib/colors.sh"
  "mb-ai-core/lib/spinner.sh"
  "mb-ai-core/lib/ascii.sh"
  "mb-bootstrap/skills/mb-bootstrap/scripts/repo-scan.sh"
  "mb-cost/scripts/cost-report.sh"
  "mb-evals/scripts/init-eval.sh"
  "mb-evals/scripts/run-eval.sh"
  "mb-evals/scripts/ci-eval.sh"
  "mb-evals/scripts/compare-eval.sh"
  "mb-retro/scripts/retro-digest.sh"
  "mb-retro/scripts/leaderboard.sh"
  "mb-retro/scripts/newsletter.sh"
  "mb-retro/scripts/adoption-report.sh"
  "mb-sdd/scripts/spec-from-ticket.sh"
)
for script in "${EXPECTED_SCRIPTS[@]}"; do
  if [[ -f "plugins/$script" && -x "plugins/$script" ]]; then
    t_pass "script: $script"
  else
    t_fail "script AUSENTE/não-executável: plugins/$script"
  fi
done

# ============================================================
section "Documentação (10)"
# ============================================================
EXPECTED_DOCS=(
  "README.md"
  "CHANGELOG.md"
  "RELEASE-NOTES.md"
  "CONTRIBUTING.md"
  "SECURITY.md"
  "REVIEW.md"
  "docs/plans/2026-05-10-mb-ai-sdk-design.md"
  "docs/plans/2026-05-10-evolution-roadmap.md"
  "docs/manual/MANUAL.md"
  "docs/presentation/PRESENTATION.md"
  "docs/governance/raci.md"
  "docs/playbooks/install-by-role.md"
  "docs/MIGRATION.md"
  "docs/PLUGIN-DEVELOPMENT.md"
  "docs/faq.md"
  "docs/governance/ai-champions.md"
  "docs/playbooks/ai-lab.md"
  "docs/plugins/opt-in-guide.md"
  "docs/governance/champion-certification.md"
  "PILOT-SETUP.md"
)
for doc in "${EXPECTED_DOCS[@]}"; do
  if [[ -f "$doc" ]]; then
    t_pass "doc: $doc"
  else
    t_fail "doc AUSENTE: $doc"
  fi
done

# ============================================================
section "Integrações & CI (5)"
# ============================================================
[[ -f .github/workflows/mb-ai-checks.yml ]] && t_pass "GHA distribuído (mb-ai-checks.yml)" || t_fail "AUSENTE: mb-ai-checks.yml"
[[ -f .github/workflows/sdk-ci.yml ]] && t_pass "GHA SDK próprio (sdk-ci.yml)" || t_fail "AUSENTE: sdk-ci.yml"
[[ -f .github/PULL_REQUEST_TEMPLATE.md ]] && t_pass "PR template" || t_fail "AUSENTE: PR template"
[[ -f .github/ISSUE_TEMPLATE/bug.md ]] && t_pass "Issue template: bug" || t_fail "AUSENTE: bug.md"
[[ -f .github/ISSUE_TEMPLATE/proposal.md ]] && t_pass "Issue template: proposal" || t_fail "AUSENTE: proposal.md"
[[ -f .github/ISSUE_TEMPLATE/security.md ]] && t_pass "Issue template: security" || t_fail "AUSENTE: security.md"
[[ -f integrations/slack/manifest.yaml ]] && t_pass "Slack manifest" || t_fail "AUSENTE: Slack manifest"

# ============================================================
section "Achievements catalog (16 conquistas v0.3)"
# ============================================================
if command -v jq >/dev/null 2>&1; then
  ACH_TOTAL=$(jq -r '.achievements | length' plugins/mb-ai-core/achievements/definitions.json 2>/dev/null)
  if [[ "$ACH_TOTAL" -ge 16 ]]; then
    t_pass "achievements: $ACH_TOTAL conquistas catalogadas"
  else
    t_fail "achievements: apenas $ACH_TOTAL (esperado >=16)"
  fi
fi

# ============================================================
section "Versões sincronizadas (9 plugins == marketplace)"
# ============================================================
if command -v jq >/dev/null 2>&1; then
  ALL_OK=1
  while IFS= read -r entry; do
    NAME=$(echo "$entry" | jq -r '.name')
    MARKET_VER=$(echo "$entry" | jq -r '.version')
    PLUGIN_FILE="plugins/${NAME}/.claude-plugin/plugin.json"
    if [[ -f "$PLUGIN_FILE" ]]; then
      PLUGIN_VER=$(jq -r '.version' "$PLUGIN_FILE")
      if [[ "$MARKET_VER" == "$PLUGIN_VER" ]]; then
        t_pass "$NAME @${MARKET_VER}"
      else
        t_fail "DESSINCRONIZADO: $NAME marketplace=$MARKET_VER vs plugin.json=$PLUGIN_VER"
        ALL_OK=0
      fi
    fi
  done < <(jq -c '.plugins[]' .claude-plugin/marketplace.json)
fi

# ============================================================
# Resumo
# ============================================================

printf "\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${GREEN}✓ %d completo${RESET}    ${RED}✗ %d faltando${RESET}\n\n" "$PASS" "$FAIL"

if [[ $FAIL -gt 0 ]]; then
  printf "${RED}${BOLD}INCOMPLETO. Resolva os ✗ antes de release.${RESET}\n\n"
  exit 1
else
  printf "${GREEN}${BOLD}TUDO ENTREGUE. ⬡${RESET}\n\n"
  exit 0
fi
