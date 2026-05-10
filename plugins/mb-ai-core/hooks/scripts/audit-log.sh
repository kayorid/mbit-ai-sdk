#!/usr/bin/env bash
# mb-ai-core / post-bash audit log
# Registra execução de comandos relevantes ao trail de auditoria.
# Categoria: COMPLIANCE (não-bloqueante; apenas observação).

set -euo pipefail

INPUT="$(cat)"
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
EXIT=$(echo "$INPUT" | jq -r '.tool_response.exit_code // empty')

# Registra apenas comandos relevantes (git, kubectl, terraform, aws, gh)
if echo "$CMD" | grep -Eq '^(git|kubectl|terraform|aws|gh|psql|mysql)\b'; then
  AUDIT_DIR=".mb/audit"
  mkdir -p "$AUDIT_DIR"
  ACTOR=$(git config user.email 2>/dev/null || echo "unknown")
  echo "$(date -u +%FT%TZ) | actor=$ACTOR | exit=$EXIT | cmd=$(echo "$CMD" | head -c 300)" >> "$AUDIT_DIR/commands.log"
fi

exit 0
