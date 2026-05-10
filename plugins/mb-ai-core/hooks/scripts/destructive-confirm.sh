#!/usr/bin/env bash
# mb-ai-core / pre-bash destructive confirm
# Bloqueia comandos destrutivos sem confirmação registrada.
# Categoria: COMPLIANCE (sempre bloqueante; permite com flag de confirmação explícita).

set -euo pipefail

INPUT="$(cat)"
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$CMD" ]]; then
  exit 0
fi

# H-9: --force-with-lease é seguro e preferível a --force; permite explicitamente
if echo "$CMD" | grep -Eiq -e 'git[[:space:]]+push[[:space:]]+.*--force-with-lease'; then
  exit 0
fi

# Padrões destrutivos
DANGER=(
  'rm[[:space:]]+-rf?[[:space:]]+/'
  'rm[[:space:]]+-rf?[[:space:]]+\*'
  'git[[:space:]]+push[[:space:]]+.*--force([[:space:]]|$)'
  'git[[:space:]]+push[[:space:]]+.*-f([[:space:]]|$)'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+-[fxd]+'
  'git[[:space:]]+branch[[:space:]]+-D'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  'TRUNCATE[[:space:]]+TABLE'
  'kubectl[[:space:]]+delete'
  'terraform[[:space:]]+destroy'
  'aws[[:space:]]+s3[[:space:]]+rb'
  'aws[[:space:]]+rds[[:space:]]+delete'
  ':>[[:space:]]*[^[:space:]]+\.(go|ts|tsx|js|py|rb|java|rs)$'
  'mkfs\.'
  'dd[[:space:]]+if='
)

for PAT in "${DANGER[@]}"; do
  if echo "$CMD" | grep -Eiq -e "$PAT"; then
    # Aceitar flag de confirmação explícita do usuário
    if echo "$CMD" | grep -Eq '#[[:space:]]*MB_CONFIRMED'; then
      AUDIT_DIR=".mb/audit"
      mkdir -p "$AUDIT_DIR"
      echo "$(date -u +%FT%TZ) | hook=pre-bash-destructive-confirm | status=ALLOWED_WITH_CONFIRMATION | cmd=$(echo "$CMD" | head -c 200)" >> "$AUDIT_DIR/hook-fires.log"
      exit 0
    fi
    AUDIT_DIR=".mb/audit"
    mkdir -p "$AUDIT_DIR"
    echo "$(date -u +%FT%TZ) | hook=pre-bash-destructive-confirm | status=BLOCKED | cmd=$(echo "$CMD" | head -c 200)" >> "$AUDIT_DIR/hook-fires.log"
    cat <<EOF >&2
[mb-ai-core] BLOCKED — comando destrutivo detectado
  Comando: $(echo "$CMD" | head -c 200)
  Padrão:  $PAT
  Para confirmar intenção, anexe \`# MB_CONFIRMED\` ao final do comando, ou execute manualmente fora do agente.
  Recomendação: prefira alternativas reversíveis (git revert vs reset --hard, soft delete vs DROP).
EOF
    exit 2
  fi
done

exit 0
