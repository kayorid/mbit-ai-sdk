#!/usr/bin/env bash
# mb-ai-core / SessionStart banner
# Mostra banner MB + frase do manifesto + status rápido.
# Saída vai para o contexto do agente via additionalContext.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")/..}"
BANNER_FILE="$PLUGIN_ROOT/assets/banner.txt"
MANIFESTO_FILE="$PLUGIN_ROOT/assets/manifesto.txt"

# Cores ANSI (suportadas pelo terminal Claude Code via additionalContext exibido)
C_RESET='\033[0m'
C_GOLD='\033[38;5;220m'
C_ORANGE='\033[38;5;208m'
C_DIM='\033[2m'
C_BOLD='\033[1m'
C_GREEN='\033[38;5;82m'
C_CYAN='\033[38;5;87m'

# Frase aleatória do manifesto
QUOTE=""
if [[ -f "$MANIFESTO_FILE" ]]; then
  TOTAL_LINES=$(grep -c . "$MANIFESTO_FILE" || echo 1)
  RAND_LINE=$(( (RANDOM % TOTAL_LINES) + 1 ))
  QUOTE=$(sed -n "${RAND_LINE}p" "$MANIFESTO_FILE")
fi

# Status rápido do repo
SQUAD="?"
PHASE="—"
ACTIVE_SPECS=0
HOOK_COUNT=0
BOOTSTRAPPED="✗"

if [[ -f .mb/CLAUDE.md ]]; then
  BOOTSTRAPPED="✓"
  SQUAD=$(grep -m1 '^# CLAUDE.md' .mb/CLAUDE.md 2>/dev/null | sed 's/^# CLAUDE.md — //' || echo "squad")
fi

if [[ -d docs/specs/_active ]]; then
  ACTIVE_SPECS=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
fi

# Detecta fase aproximada da spec mais recente
LATEST_SPEC=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
if [[ -n "$LATEST_SPEC" ]]; then
  if [[ -f "$LATEST_SPEC/retro.md" ]]; then PHASE="RETRO"
  elif [[ -f "$LATEST_SPEC/REVIEW.md" ]]; then PHASE="REVIEW"
  elif [[ -f "$LATEST_SPEC/verification.md" ]]; then PHASE="VERIFY"
  elif [[ -f "$LATEST_SPEC/execution.log" ]]; then PHASE="EXECUTE"
  elif [[ -f "$LATEST_SPEC/tasks.md" ]]; then PHASE="PLAN"
  elif [[ -f "$LATEST_SPEC/design.md" ]]; then PHASE="DESIGN"
  elif [[ -f "$LATEST_SPEC/requirements.md" ]]; then PHASE="SPEC"
  elif [[ -f "$LATEST_SPEC/discuss.md" ]]; then PHASE="DISCUSS"
  fi
fi

# Monta output
OUT=$(cat <<EOF
${C_GOLD}$(cat "$BANNER_FILE" 2>/dev/null)${C_RESET}

${C_ORANGE}❝${C_RESET} ${C_BOLD}${QUOTE}${C_RESET} ${C_ORANGE}❞${C_RESET}

${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}
  ${C_CYAN}Squad${C_RESET}: ${SQUAD}     ${C_CYAN}Bootstrap${C_RESET}: ${BOOTSTRAPPED}     ${C_CYAN}Specs ativas${C_RESET}: ${ACTIVE_SPECS}     ${C_CYAN}Fase atual${C_RESET}: ${PHASE}
${C_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}

${C_GREEN}▸${C_RESET} Comece com ${C_BOLD}/mb-help${C_RESET} para ver tudo que o SDK oferece.
${C_GREEN}▸${C_RESET} ${C_BOLD}/mb-status${C_RESET} para diagnóstico do repo.
$([[ "$BOOTSTRAPPED" == "✗" ]] && echo "${C_GREEN}▸${C_RESET} ${C_BOLD}/mb-bootstrap${C_RESET} para configurar o squad pela primeira vez.")
EOF
)

# SessionStart hook deve emitir JSON com additionalContext
# para que o conteúdo apareça no início da conversa.
jq -n --arg ctx "$OUT" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ctx
  }
}'
