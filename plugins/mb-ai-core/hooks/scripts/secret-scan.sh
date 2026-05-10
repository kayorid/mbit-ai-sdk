#!/usr/bin/env bash
# mb-ai-core / pre-tool secret scan
# Bloqueia Write/Edit que introduza padrões de segredo conhecidos.
# Categoria: SEGURANÇA (sempre bloqueante).

set -euo pipefail

INPUT="$(cat)"
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
PATH_FIELD=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty')

if [[ -z "$CONTENT" ]]; then
  exit 0
fi

# Padrões de alto risco
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                                # AWS Access Key
  'AIza[0-9A-Za-z_-]{35}'                           # Google API Key
  'ya29\.[0-9A-Za-z_-]+'                            # Google OAuth token
  '-----BEGIN (RSA|EC|DSA|OPENSSH|PGP) PRIVATE KEY-----'
  'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'  # JWT
  'ghp_[A-Za-z0-9]{36}'                             # GitHub PAT
  'gho_[A-Za-z0-9]{36}'                             # GitHub OAuth
  'glpat-[A-Za-z0-9_-]{20}'                         # GitLab PAT
  'xox[baprs]-[A-Za-z0-9-]+'                        # Slack tokens
  'sk-[A-Za-z0-9]{32,}'                             # OpenAI/Anthropic-like
)

for PAT in "${PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -Eq -e "$PAT"; then
    AUDIT_DIR=".mb/audit"
    mkdir -p "$AUDIT_DIR"
    echo "$(date -u +%FT%TZ) | hook=pre-tool-secret-scan | tool=$TOOL | path=$PATH_FIELD | status=BLOCKED | pattern=$PAT" >> "$AUDIT_DIR/hook-fires.log"
    cat <<EOF >&2
[mb-ai-core] BLOCKED — segredo detectado
  Arquivo: $PATH_FIELD
  Padrão:  $PAT
  Ação:    remova o segredo ou use placeholder (<YOUR-KEY-HERE>).
  Se for falso-positivo, abra exceção formal: /mb-exception
EOF
    exit 2
  fi
done

# Detecção heurística de .env com valores reais
# Allowlist: variantes de exemplo/template/sample/local/development
ENV_ALLOW=0
case "$PATH_FIELD" in
  *.env.example|*.env.template|*.env.sample|*.env.local|*.env.development|*.env.test) ENV_ALLOW=1 ;;
esac

if [[ "$PATH_FIELD" == *.env && $ENV_ALLOW -eq 0 ]]; then
  # Ignora valores que parecem placeholders: <...>, ${...}, "changeme", "your-...-here"
  REAL_VALUES=$(echo "$CONTENT" | grep -E '^[A-Z_]+=' | grep -Ev '=[[:space:]]*($|<[^>]*>|\$\{[^}]+\}|"?(changeme|your[-_].*[-_]here|placeholder|todo|tbd|xxx+)"?[[:space:]]*$)')
  if [[ -n "$REAL_VALUES" ]]; then
    AUDIT_DIR=".mb/audit"
    mkdir -p "$AUDIT_DIR"
    echo "$(date -u +%FT%TZ) | hook=pre-tool-secret-scan | tool=$TOOL | path=$PATH_FIELD | status=BLOCKED | pattern=ENV_FILE" >> "$AUDIT_DIR/hook-fires.log"
    cat <<EOF >&2
[mb-ai-core] BLOCKED — arquivo .env com valores reais
  Arquivo: $PATH_FIELD
  Use .env.example/.env.template com placeholders, ou variantes de uso local
  (.env.local, .env.development, .env.test) com placeholders <...> ou \${VAR}.
EOF
    exit 2
  fi
fi

exit 0
