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

# M-8: dois canais separados
# 1. Visual colorido vai para stderr (terminal vê)
echo -e "$OUT" >&2

# 2. Contexto plain (sem ANSI) vai para additionalContext do agente
#    Economiza ~150 tokens por sessão evitando códigos de cor no prompt do LLM.
PLAIN_CTX="MBit AI SDK ativo · Squad: ${SQUAD} · Bootstrap: ${BOOTSTRAPPED} · Specs ativas: ${ACTIVE_SPECS} · Fase atual: ${PHASE}

Constitution corporativa MB carregada via mb-ai-core. Hooks bloqueantes ativos. Use /mb-help para visão geral, /mb-status para diagnóstico, /mb-doctor para health check.${NEW_ACHS:+

Achievement(s) recentemente desbloqueado(s): ${NEW_ACHS}}"

if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$PLAIN_CTX" '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $ctx
    }
  }'
fi
