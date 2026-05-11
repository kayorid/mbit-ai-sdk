#!/usr/bin/env bash
# mb-ai-core / Statusline
# Linha de status sempre visível no Claude Code.
# Recebe payload JSON via stdin com info da sessão.

set -euo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Claude"' 2>/dev/null || echo "Claude")
CWD=$(echo "$INPUT" | jq -r '.workspace.current_dir // "."' 2>/dev/null || echo ".")

# Cores
C_GOLD='\033[38;5;220m'
C_ORANGE='\033[38;5;208m'
C_GREEN='\033[38;5;82m'
C_CYAN='\033[38;5;87m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# Detecta squad e fase
SQUAD="∅"
PHASE="—"
ACTIVE=0
BOOT="✗"

cd "$CWD" 2>/dev/null || true

if [[ -f .mb/CLAUDE.md ]]; then
  BOOT="✓"
  # M-4: trunca por chars (UTF-8 safe via cut em modo character) com fallback
  SQUAD_RAW=$(grep -m1 '^# CLAUDE.md' .mb/CLAUDE.md 2>/dev/null | sed 's/^# CLAUDE.md — //' || echo "squad")
  if command -v jq >/dev/null 2>&1; then
    SQUAD=$(printf '%s' "$SQUAD_RAW" | jq -Rr '.[0:20]')
  else
    SQUAD=$(printf '%s' "$SQUAD_RAW" | cut -c 1-20)
  fi
fi

if [[ -d docs/specs/_active ]]; then
  ACTIVE=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  LATEST=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
  if [[ -n "$LATEST" ]]; then
    if [[ -f "$LATEST/retro.md" ]]; then PHASE="RETRO"
    elif [[ -f "$LATEST/REVIEW.md" ]]; then PHASE="REVIEW"
    elif [[ -f "$LATEST/verification.md" ]]; then PHASE="VERIFY"
    elif [[ -f "$LATEST/execution.log" ]]; then PHASE="EXECUTE"
    elif [[ -f "$LATEST/tasks.md" ]]; then PHASE="PLAN"
    elif [[ -f "$LATEST/design.md" ]]; then PHASE="DESIGN"
    elif [[ -f "$LATEST/requirements.md" ]]; then PHASE="SPEC"
    elif [[ -f "$LATEST/discuss.md" ]]; then PHASE="DISCUSS"
    fi
  fi
fi

# Conta hooks defensivos do dia
BLOCKS=0
if [[ -f .mb/audit/hook-fires.log ]]; then
  TODAY=$(date -u +%Y-%m-%d)
  BLOCKS=$(grep -c "^${TODAY}.*BLOCKED" .mb/audit/hook-fires.log 2>/dev/null || echo 0)
fi

# M-2: detecta largura do terminal e usa formato compacto se < 100 cols
COLS=$(echo "$INPUT" | jq -r '.workspace.columns // .terminal.columns // 120' 2>/dev/null || echo 120)
[[ ! "$COLS" =~ ^[0-9]+$ ]] && COLS=120

if [[ $COLS -lt 80 ]]; then
  # Mínimo: só MB + fase + blocks
  printf "${C_GOLD}◆ MB${C_RESET} ${C_DIM}·${C_RESET} ${C_ORANGE}%s${C_RESET} ${C_DIM}·${C_RESET} ${C_DIM}🛡 %d${C_RESET}" "$PHASE" "$BLOCKS"
elif [[ $COLS -lt 100 ]]; then
  # Compacto: sem nome de model
  printf "${C_GOLD}◆ MB${C_RESET} ${C_DIM}·${C_RESET} ${C_CYAN}%s${C_RESET} ${C_DIM}·${C_RESET} %s ${C_DIM}·${C_RESET} %d ${C_DIM}·${C_RESET} ${C_ORANGE}%s${C_RESET} ${C_DIM}·${C_RESET} 🛡 %d" \
    "$SQUAD" "$BOOT" "$ACTIVE" "$PHASE" "$BLOCKS"
else
  # Formato completo
  printf "${C_GOLD}◆ MB${C_RESET} ${C_DIM}│${C_RESET} ${C_CYAN}%s${C_RESET} ${C_DIM}│${C_RESET} ${C_DIM}boot${C_RESET} %s ${C_DIM}│${C_RESET} ${C_DIM}specs${C_RESET} %d ${C_DIM}│${C_RESET} ${C_ORANGE}%s${C_RESET} ${C_DIM}│${C_RESET} ${C_DIM}🛡${C_RESET} %d ${C_DIM}│${C_RESET} ${C_DIM}%s${C_RESET}" \
    "$SQUAD" "$BOOT" "$ACTIVE" "$PHASE" "$BLOCKS" "$MODEL"
fi
