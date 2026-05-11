#!/usr/bin/env bash
# mb-ai-core / pre-tool MCP allowlist
# Bloqueia uso de MCP fora da allowlist.
# Categoria: COMPLIANCE (sempre bloqueante).

set -euo pipefail

INPUT="$(cat)"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [[ -z "$TOOL" || "$TOOL" != mcp__* ]]; then
  exit 0
fi

# Extrai server do nome (mcp__<server>__<tool>)
SERVER=$(echo "$TOOL" | sed -E 's/^mcp__([^_]+(_[^_]+)*)__.*/\1/')

ALLOWLIST_FILE="${CLAUDE_PLUGIN_ROOT}/config/mcp-allowlist.json"
if [[ ! -f "$ALLOWLIST_FILE" ]]; then
  echo "[mb-ai-core] WARN — allowlist não encontrada em $ALLOWLIST_FILE; bloqueando por padrão" >&2
  exit 2
fi

# M-3: validate JSON before parsing
if ! jq empty "$ALLOWLIST_FILE" 2>/dev/null; then
  echo "[mb-ai-core] WARN — allowlist file corrompido ($ALLOWLIST_FILE). Bloqueando MCP preventivamente. Notifique o Chapter AI." >&2
  exit 2
fi

APPROVED=$(jq -r '.approved[].name' "$ALLOWLIST_FILE" 2>/dev/null || true)

if echo "$APPROVED" | grep -qx "$SERVER"; then
  exit 0
fi

# Permite MCPs do próprio MB (prefixos conhecidos) — ajuste conforme política
if [[ "$SERVER" == mb_* || "$SERVER" == mercadobitcoin_* ]]; then
  exit 0
fi

AUDIT_DIR=".mb/audit"
mkdir -p "$AUDIT_DIR"
echo "$(date -u +%FT%TZ) | hook=pre-tool-mcp-allowlist | tool=$TOOL | server=$SERVER | status=BLOCKED" >> "$AUDIT_DIR/hook-fires.log"

cat <<EOF >&2
[mb-ai-core] BLOCKED — MCP fora da allowlist
  MCP server: $SERVER
  Allowlist:  $(echo "$APPROVED" | tr '\n' ' ')
  Para incluir, abra PR ao mb-ai-sdk adicionando entrada em config/mcp-allowlist.json (under_review).
  Para uso urgente justificado: /mb-exception
EOF
exit 2
