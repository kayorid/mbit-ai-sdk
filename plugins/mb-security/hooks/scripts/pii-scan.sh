#!/usr/bin/env bash
# mb-security / pre-tool PII scan
# Bloqueia escrita de PII brasileira em arquivos não-marcados como teste.
# Categoria: SEGURANÇA (sempre bloqueante).

set -euo pipefail

INPUT="$(cat)"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ -z "$CONTENT" ]]; then exit 0; fi

# Caminhos permitidos (testes, fixtures, exemplos marcados)
if echo "$FILE_PATH" | grep -Eqi '(test|spec|fixture|mock|example|seed)' ; then
  exit 0
fi

# CPF: 000.000.000-00 ou 00000000000 (com validação heurística do dígito repetido)
if echo "$CONTENT" | grep -Eq '\b[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}\b'; then
  HIT=$(echo "$CONTENT" | grep -Eo '\b[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}\b' | head -1)
  # ignora valores claramente placeholder (000.000.000-00)
  if [[ "$HIT" != "000.000.000-00" && "$HIT" != "111.111.111-11" ]]; then
    AUDIT_DIR=".mb/audit"
    mkdir -p "$AUDIT_DIR"
    echo "$(date -u +%FT%TZ) | hook=pre-tool-pii-scan | tool=$TOOL | path=$FILE_PATH | status=BLOCKED | type=CPF" >> "$AUDIT_DIR/security-events.log"
    cat <<EOF >&2
[mb-security] BLOCKED — possível CPF detectado
  Arquivo: $FILE_PATH
  Padrão:  $HIT
  Para fixtures: marque o arquivo com sufixo _test, _fixture ou similar.
  Para necessidade legítima: /mb-exception
EOF
    exit 2
  fi
fi

# CNPJ
if echo "$CONTENT" | grep -Eq '\b[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}\b'; then
  HIT=$(echo "$CONTENT" | grep -Eo '\b[0-9]{2}\.[0-9]{3}\.[0-9]{3}/[0-9]{4}-[0-9]{2}\b' | head -1)
  AUDIT_DIR=".mb/audit"; mkdir -p "$AUDIT_DIR"
  echo "$(date -u +%FT%TZ) | hook=pre-tool-pii-scan | tool=$TOOL | path=$FILE_PATH | status=BLOCKED | type=CNPJ" >> "$AUDIT_DIR/security-events.log"
  echo "[mb-security] BLOCKED — CNPJ detectado em $FILE_PATH ($HIT). Use placeholder ou marque arquivo como fixture." >&2
  exit 2
fi

# Cartão de crédito (Visa, Mastercard, Amex, Discover) — ERE puro, sem (?:)
if echo "$CONTENT" | grep -Eq -e '\b(4[0-9]{12}([0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|6(011|5[0-9]{2})[0-9]{12})\b'; then
  AUDIT_DIR=".mb/audit"; mkdir -p "$AUDIT_DIR"
  echo "$(date -u +%FT%TZ) | hook=pre-tool-pii-scan | tool=$TOOL | path=$FILE_PATH | status=BLOCKED | type=CARD" >> "$AUDIT_DIR/security-events.log"
  echo "[mb-security] BLOCKED — número de cartão detectado em $FILE_PATH. Nunca commitar cartões reais." >&2
  exit 2
fi

# Conta bancária formato AAAA-D ou similar exposta junto a CPF/CNPJ
# (heurística simples — em produção, integrar com classificador específico)

exit 0
