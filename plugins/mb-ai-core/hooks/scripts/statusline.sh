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
  SQUAD=$(grep -m1 '^# CLAUDE.md' .mb/CLAUDE.md 2>/dev/null | sed 's/^# CLAUDE.md — //' | head -c 20 || echo "squad")
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

# Formato compacto
printf "${C_GOLD}◆ MB${C_RESET} ${C_DIM}│${C_RESET} ${C_CYAN}%s${C_RESET} ${C_DIM}│${C_RESET} ${C_DIM}boot${C_RESET} %s ${C_DIM}│${C_RESET} ${C_DIM}specs${C_RESET} %d ${C_DIM}│${C_RESET} ${C_ORANGE}%s${C_RESET} ${C_DIM}│${C_RESET} ${C_DIM}🛡${C_RESET} %d ${C_DIM}│${C_RESET} ${C_DIM}%s${C_RESET}" \
  "$SQUAD" "$BOOT" "$ACTIVE" "$PHASE" "$BLOCKS" "$MODEL"
