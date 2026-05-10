#!/usr/bin/env bash
# mb-security / pre-tool private key scan
# Bloqueia escrita de qualquer formato de chave privada.
# Categoria: SEGURANÇA (sempre bloqueante).

set -euo pipefail

INPUT="$(cat)"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ -z "$CONTENT" ]]; then exit 0; fi

# Padrões de chave privada — ERE puro (sem (?:) que é PCRE)
# Limita input em 100KB para mitigar ReDoS (M-10)
CONTENT="$(echo "$CONTENT" | head -c 102400)"

# Padrões. Quantificadores grandes ({107,108}) podem falhar em algumas
# implementações de regex — usamos limites mais permissivos que ainda
# capturam os formatos reais.
PATTERNS=(
  '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY-----'
  'xprv[a-zA-Z0-9]{80,}'                                               # BIP-32 extended private (real ~107 chars; permissivo)
  '0x[a-fA-F0-9]{64}'                                                  # Ethereum 256-bit hex
  '(secret|private|priv|key|seed)[[:space:]]*[=:][[:space:]]*"?[a-fA-F0-9]{64}'  # hex 64 atribuído
  'mnemonic[[:space:]]*[=:][[:space:]]*"?([a-z]+ ){11,23}[a-z]+'       # BIP-39 mnemonic atribuído
)

for PAT in "${PATTERNS[@]}"; do
  if printf '%s' "$CONTENT" | grep -Eiq -e "$PAT"; then
    AUDIT_DIR=".mb/audit"; mkdir -p "$AUDIT_DIR"
    echo "$(date -u +%FT%TZ) | hook=pre-tool-private-key-scan | tool=$TOOL | path=$FILE_PATH | status=BLOCKED" >> "$AUDIT_DIR/security-events.log"
    cat <<EOF >&2
[mb-security] BLOCKED — possível chave privada detectada
  Arquivo: $FILE_PATH
  Tipo:    $PAT
  Chaves privadas NUNCA podem ser commitadas, nem em arquivos de teste.
  Use HSM/KMS para gestão.
  Esta regra é não-negociável e não aceita exceção via /mb-exception.
EOF
    exit 2
  fi
done

exit 0
