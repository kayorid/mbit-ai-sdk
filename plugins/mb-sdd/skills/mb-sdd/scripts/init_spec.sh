#!/usr/bin/env bash
# init_spec.sh — bootstrap de uma nova spec
#
# Uso:
#   ./scripts/init_spec.sh <slug>            (cria em $PWD/docs/specs/_active/)
#   SPECS_ROOT=docs/specs ./scripts/init_spec.sh <slug>
#
# Cria a pasta YYYY-MM-DD-<slug>/ com cópias dos templates
# (requirements.md, design.md, tasks.md, status.md) já com placeholders.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "uso: $0 <slug>" >&2
  echo "exemplo: $0 csv-export-progress" >&2
  exit 1
fi

SLUG="$1"
DATE="$(date +%Y-%m-%d)"
SPECS_ROOT="${SPECS_ROOT:-docs/specs}"
TARGET_DIR="${SPECS_ROOT}/_active/${DATE}-${SLUG}"

# Resolve o caminho dos templates relativo ao próprio script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../assets/templates"

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "erro: templates não encontrados em $TEMPLATES_DIR" >&2
  echo "este script deve rodar dentro da skill spec-driven-development" >&2
  exit 1
fi

if [ -d "$TARGET_DIR" ]; then
  echo "erro: $TARGET_DIR já existe" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for tpl in requirements design tasks status; do
  src="${TEMPLATES_DIR}/${tpl}.md.tpl"
  dst="${TARGET_DIR}/${tpl}.md"
  if [ ! -f "$src" ]; then
    echo "aviso: template $src ausente — pulando" >&2
    continue
  fi
  # Substitui placeholders óbvios; deixa demais para o autor preencher
  sed \
    -e "s|<NOME DA FEATURE>|${SLUG}|g" \
    -e "s|<YYYY-MM-DD-slug-da-feature>|${DATE}-${SLUG}|g" \
    -e "s|<YYYY-MM-DD>|${DATE}|g" \
    -e "s|<YYYY-MM-DD HH:MM>|${DATE} $(date +%H:%M)|g" \
    "$src" > "$dst"
done

# Cria também a constituição global se ainda não existir
CONST_FILE="${SPECS_ROOT}/constitution.md"
if [ ! -f "$CONST_FILE" ]; then
  mkdir -p "$SPECS_ROOT"
  cp "${TEMPLATES_DIR}/constitution.md.tpl" "$CONST_FILE"
  echo "criado: $CONST_FILE (preencha antes de prosseguir)"
fi

INDEX_FILE="${SPECS_ROOT}/INDEX.md"
if [ ! -f "$INDEX_FILE" ]; then
  cp "${TEMPLATES_DIR}/INDEX.md.tpl" "$INDEX_FILE"
  echo "criado: $INDEX_FILE (rode update_index.py para popular)"
fi

echo ""
echo "✅ Spec inicializada em $TARGET_DIR"
echo ""
echo "Próximos passos:"
echo "  1) Editar $TARGET_DIR/requirements.md (fase Specify)"
echo "  2) Marcar ambiguidades com [CLARIFY] e seguir para fase Clarify"
echo "  3) Rodar scripts/validate_spec.py $TARGET_DIR antes de avançar de fase"
