#!/usr/bin/env bash
# mb-ai-core / scripts / dashboard.sh
# Painel ASCII com métricas do squad.

set -uo pipefail
# dashboard tolera comandos faltantes; use || true onde apropriado.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

# Métricas
SQUAD="∅"
[[ -f .mb/CLAUDE.md ]] && SQUAD=$(grep -m1 '^# CLAUDE.md' .mb/CLAUDE.md 2>/dev/null | sed 's/^# CLAUDE.md — //' | head -c 30)

ACTIVE=$(find docs/specs/_active -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

# Trimestre atual
Q=$(( ($(date +%-m) - 1) / 3 + 1 ))
Y=$(date +%Y)
ARCH_THIS_Q=$(find "docs/specs/_archive/${Y}-Q${Q}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ' || echo 0)
ARCH_TOTAL=$(find docs/specs/_archive -mindepth 2 -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ' || echo 0)

HOTFIXES=$(find docs/specs -path '*hotfix*' -name 'hotfix-plan.md' 2>/dev/null | wc -l | tr -d ' ')
SPIKES=$(find docs/specs -path '*spike*' -name 'spike.md' 2>/dev/null | wc -l | tr -d ' ')

APPROVALS=$([ -f .mb/audit/approvals.log ] && wc -l < .mb/audit/approvals.log | tr -d ' ' || echo 0)
EXCEPTIONS=$([ -f .mb/audit/exceptions.log ] && wc -l < .mb/audit/exceptions.log | tr -d ' ' || echo 0)

BLOCKS_WEEK="n/d"
if [[ -f .mb/audit/hook-fires.log ]]; then
  WEEK_AGO=$(date -u -v-7d +%Y-%m-%d 2>/dev/null || date -u -d "7 days ago" +%Y-%m-%d 2>/dev/null || echo "")
  if [[ -n "$WEEK_AGO" ]]; then
    BLOCKS_WEEK=$(awk -v wa="$WEEK_AGO" -F'|' '$1>=wa && /BLOCKED/' .mb/audit/hook-fires.log 2>/dev/null | wc -l | tr -d ' ')
  fi
fi

# Achievements
ACH_TOTAL=16
ACH_UNLOCKED=0
if [[ -f .mb/achievements.json ]] && command -v jq >/dev/null 2>&1; then
  ACH_UNLOCKED=$(jq -r '.unlocked | length' .mb/achievements.json 2>/dev/null || echo 0)
fi

# mb-evals: contagem de evals + última run
EVALS_COUNT=$(find evals -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
EVALS_RUNS=$(find evals -path '*/runs/*.jsonl' 2>/dev/null | wc -l | tr -d ' ')

# mb-cost: custo do mês corrente (última linha summary se houver)
COST_MONTH="—"
if [[ -f .mb/audit/cost.log ]]; then
  COST_LINES=$(wc -l < .mb/audit/cost.log | tr -d ' ')
  COST_MONTH="${COST_LINES} eventos"
fi

# Modo /mb-fast
FAST="—"
[[ -f .mb/config.yaml ]] && grep -q 'modes_unlocked.*fast' .mb/config.yaml 2>/dev/null && FAST="✓ destravado"

# Maturidade — função de archived + promoted + champion-time (heurística simples)
MATURITY=0
[[ $ARCH_TOTAL -ge 1 ]] && MATURITY=$((MATURITY+15))
[[ $ARCH_TOTAL -ge 3 ]] && MATURITY=$((MATURITY+20))
[[ $EXCEPTIONS -eq 0 && $ARCH_TOTAL -ge 2 ]] && MATURITY=$((MATURITY+15))
[[ $ACH_UNLOCKED -ge 5 ]] && MATURITY=$((MATURITY+20))
[[ $APPROVALS -ge 10 ]] && MATURITY=$((MATURITY+15))
[[ -f .mb/skills/README.md ]] && MATURITY=$((MATURITY+15))

# Barra de maturidade
BAR_LEN=20
FILLED=$(( MATURITY * BAR_LEN / 100 ))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR="${BAR}█"; done
for ((i=FILLED; i<BAR_LEN; i++)); do BAR="${BAR}░"; done

# Sparkline simulado de ciclos por trimestre (pega últimos 8 trim do _archive)
SPARK=""
SPARK_CHARS="▁▂▃▄▅▆▇█"
for q_off in 7 6 5 4 3 2 1 0; do
  YEAR=$Y; QQ=$Q
  for ((i=0; i<q_off; i++)); do
    QQ=$((QQ-1)); if [[ $QQ -lt 1 ]]; then QQ=4; YEAR=$((YEAR-1)); fi
  done
  count=$(find "docs/specs/_archive/${YEAR}-Q${QQ}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  idx=$count
  [[ $idx -gt 7 ]] && idx=7
  SPARK="${SPARK}${SPARK_CHARS:$idx:1}"
done

# Próxima ação sugerida
NEXT="—"
if [[ ! -f .mb/CLAUDE.md ]]; then
  NEXT="/mb-bootstrap (squad ainda não bootstrapado)"
elif [[ $ACTIVE -eq 0 ]]; then
  NEXT="/mb-spec <slug> para iniciar próxima feature"
else
  LATEST=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
  if [[ -n "$LATEST" ]]; then
    SLUG=$(basename "$LATEST" | sed 's/^[0-9-]*//')
    if [[ ! -f "$LATEST/discuss.md" ]]; then NEXT="/mb-spec-discuss $SLUG"
    elif [[ ! -f "$LATEST/requirements.md" ]]; then NEXT="/mb-spec-requirements $SLUG"
    elif [[ ! -f "$LATEST/design.md" ]]; then NEXT="/mb-spec-design $SLUG"
    elif [[ ! -f "$LATEST/tasks.md" ]]; then NEXT="/mb-spec-plan $SLUG"
    elif [[ ! -f "$LATEST/verification.md" ]]; then NEXT="/mb-spec-execute $SLUG ou /mb-spec-verify $SLUG"
    elif [[ ! -f "$LATEST/REVIEW.md" ]]; then NEXT="/mb-review-pr para spec $SLUG"
    elif [[ ! -f "$LATEST/retro.md" ]]; then NEXT="/mb-spec-retro $SLUG"
    fi
  fi
fi

# Output
P="${C_PRIMARY:-}"; A="${C_ACCENT:-}"; D="${C_DIM:-}"; B="${C_BOLD:-}"; R="${C_RESET:-}"
S="${C_SUCCESS:-}"; W="${C_WARN:-}"; I="${C_INFO:-}"

cat <<EOF

${P}┌─ MB AI SDK · Squad ${B}${SQUAD}${R}${P} · ${Y}-Q${Q} ──────────────────────${R}
${P}│${R}
${P}│${R}  ${I}Specs ativas:${R}    ${B}${ACTIVE}${R}        ${I}Concluídas trim:${R}  ${B}${ARCH_THIS_Q}${R}
${P}│${R}  ${I}Hotfixes total:${R}  ${B}${HOTFIXES}${R}        ${I}Spikes total:${R}     ${B}${SPIKES}${R}
${P}│${R}
${P}│${R}  ${D}Ciclos completados (últ 8 trim)${R}
${P}│${R}    ${A}${SPARK}${R}
${P}│${R}
${P}│${R}  ${I}Hooks bloqueantes (sem):${R} ${B}${BLOCKS_WEEK}${R}
${P}│${R}  ${I}Aprovações registradas:${R}  ${B}${APPROVALS}${R}
${P}│${R}  ${I}Exceções abertas:${R}        ${B}${EXCEPTIONS}${R}
${P}│${R}
${P}│${R}  ${I}Maturidade:${R}    ${A}${BAR}${R}  ${B}${MATURITY}%${R}
${P}│${R}  ${I}Achievements:${R}  ${B}${ACH_UNLOCKED}/${ACH_TOTAL}${R}      ${I}Modo /mb-fast:${R} ${B}${FAST}${R}
${P}│${R}
${P}│${R}  ${I}Evals configurados:${R}    ${B}${EVALS_COUNT}${R}        ${I}Eval runs total:${R}     ${B}${EVALS_RUNS}${R}
${P}│${R}  ${I}Custo IA (eventos):${R}    ${B}${COST_MONTH}${R}
${P}│${R}
${P}│${R}  ${S}▸${R} ${B}Próxima ação:${R}  ${NEXT}
${P}└──────────────────────────────────────────────────────────${R}

EOF
