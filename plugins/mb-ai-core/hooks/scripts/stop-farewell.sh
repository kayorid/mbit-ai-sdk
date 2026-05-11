#!/usr/bin/env bash
# mb-ai-core / Stop farewell
# Mensagem de despedida com resumo curto da sessão.
# Não bloqueia.

set -euo pipefail

# Conta atividades do dia no audit
APPROVALS_TODAY=0
BLOCKS_TODAY=0
TODAY=$(date -u +%Y-%m-%d)

if [[ -f .mb/audit/approvals.log ]]; then
  APPROVALS_TODAY=$(grep -c "^${TODAY}" .mb/audit/approvals.log 2>/dev/null || echo 0)
fi
if [[ -f .mb/audit/hook-fires.log ]]; then
  BLOCKS_TODAY=$(grep -c "^${TODAY}.*BLOCKED" .mb/audit/hook-fires.log 2>/dev/null || echo 0)
fi

C_GOLD='\033[38;5;220m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# Frases de despedida rotativas (uma é escolhida por hash do dia para variar)
FAREWELLS=(
  "Boa! Especificação clara, código limpo, retrospectiva honesta. Até logo."
  "Cada commit é uma promessa cumprida. Bom trabalho."
  "Cripto para todos. Código com confiança. Até a próxima."
  "Disciplina hoje, intuição amanhã. Bom descanso."
  "O próximo dev agradece. 🛡"
  "Quando a auditoria chegar, vamos estar prontos. Bom trabalho."
  "Stack é escolha. Processo é compromisso. Cumpriu hoje."
  "Construindo o MB de 2027, um spec por vez."
)
HASH=$(date +%j)
IDX=$(( HASH % ${#FAREWELLS[@]} ))
QUOTE="${FAREWELLS[$IDX]}"

cat <<EOF >&2

${C_GOLD}━━━ MBit ━━━${C_RESET}
${C_DIM}Sessão encerrada · ${APPROVALS_TODAY} aprovação(ões) hoje · ${BLOCKS_TODAY} bloqueio(s) defensivo(s)${C_RESET}
${C_GOLD}${QUOTE}${C_RESET}

EOF

# M-9: Stop hook stderr é capturado pelo Claude Code CLI mas pode ser
# filtrado em IDEs (Cursor, JetBrains). Para compatibilidade ampla,
# também emitimos via additionalContext quando jq disponível.
if command -v jq >/dev/null 2>&1; then
  PLAIN_FAREWELL="MBit · Sessão encerrada · ${APPROVALS_TODAY} aprovação(ões) hoje · ${BLOCKS_TODAY} bloqueio(s) defensivo(s) · ${QUOTE}"
  jq -n --arg ctx "$PLAIN_FAREWELL" '{
    "hookSpecificOutput": {
      "hookEventName": "Stop",
      "additionalContext": $ctx
    }
  }' 2>/dev/null || true
fi

exit 0
