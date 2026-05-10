#!/usr/bin/env bash
# mb-cost / cost-capture
# Captura uso de tokens reportado em PostToolUse.
# Não-bloqueante. Append em .mb/audit/cost.log.

set -euo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"

# B-4: curto-circuito antes de qualquer jq/find — payload sem 'usage' sai imediato
echo "$INPUT" | grep -q '"usage"' || exit 0

# Tenta extrair tokens (campos variam por modelo/versão)
IN_TOK=$(echo "$INPUT" | jq -r '.usage.input_tokens // .usage.prompt_tokens // .tool_response.usage.input_tokens // empty' 2>/dev/null)
OUT_TOK=$(echo "$INPUT" | jq -r '.usage.output_tokens // .usage.completion_tokens // .tool_response.usage.output_tokens // empty' 2>/dev/null)

# Se não há dados de tokens, sai silencioso
[[ -z "$IN_TOK" && -z "$OUT_TOK" ]] && exit 0

# Snapshot de preço no momento da captura (M-5: auditoria contábil)
PRICE_IN="${MB_PRICE_IN:-3.00}"
PRICE_OUT="${MB_PRICE_OUT:-15.00}"
RATE="${MB_USD_BRL:-5.30}"

TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
MODEL=$(echo "$INPUT" | jq -r '.model.id // .model // "unknown"' 2>/dev/null)
ACTOR=$(git config user.email 2>/dev/null || echo "unknown")

# Detecta feature e fase ativa
FEATURE="unknown"
PHASE="unknown"
LATEST=$(find docs/specs/_active -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort | tail -1)
if [[ -n "$LATEST" ]]; then
  FEATURE=$(basename "$LATEST" | sed 's/^[0-9-]*//')
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

mkdir -p .mb/audit
# H-2: linha sanitizada (remove pipes e newlines de campos do user-controlled)
SAFE_TOOL=$(printf '%s' "$TOOL" | tr -d '\n|' | head -c 64)
SAFE_FEATURE=$(printf '%s' "$FEATURE" | tr -d '\n|' | head -c 64)
SAFE_MODEL=$(printf '%s' "$MODEL" | tr -d '\n|' | head -c 64)
SAFE_ACTOR=$(printf '%s' "$ACTOR" | tr -d '\n|' | head -c 64)

(
  flock -x 9 2>/dev/null || true
  echo "$(date -u +%FT%TZ) | feature=$SAFE_FEATURE | phase=$PHASE | tool=$SAFE_TOOL | in_tokens=${IN_TOK:-0} | out_tokens=${OUT_TOK:-0} | model=$SAFE_MODEL | actor=$SAFE_ACTOR | price_in=$PRICE_IN | price_out=$PRICE_OUT | rate=$RATE" >> .mb/audit/cost.log
) 9>>.mb/audit/.cost.lock 2>/dev/null

exit 0
