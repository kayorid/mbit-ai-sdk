#!/usr/bin/env bash
# mb-ai-core / Notification with MB tone
# Customiza a mensagem de notificação do Claude Code.

set -euo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"
MSG=$(echo "$INPUT" | jq -r '.message // "Atenção"' 2>/dev/null || echo "Atenção")

C_GOLD='\033[38;5;220m'
C_RESET='\033[0m'

echo -e "${C_GOLD}◆ MB AI SDK${C_RESET} · ${MSG}" >&2
exit 0
