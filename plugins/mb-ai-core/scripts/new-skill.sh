#!/usr/bin/env bash
# mb-ai-core / scripts / new-skill.sh
# Scaffolder de skill custom em .mb/skills/

set -euo pipefail

NAME="${1:-}"
[[ -z "$NAME" ]] && { echo "Uso: new-skill.sh <slug>"; exit 1; }

# Validar slug
[[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]] && {
  echo "Slug inválido. Use kebab-case (ex: my-skill): $NAME"
  exit 1
}

DIR=".mb/skills/mb-${NAME}"
[[ -d "$DIR" ]] && { echo "Skill já existe: $DIR"; exit 1; }

mkdir -p "$DIR/references" "$DIR/scripts" "$DIR/assets/templates"

cat > "$DIR/SKILL.md" <<EOF
---
name: mb-${NAME}
description: <DESCRIÇÃO RICA — quando o agente deve invocar esta skill>. Acione quando o usuário disser "<termos-trigger>", ou em situações como <contextos>. Faz <o que faz>. Distingue de outras skills similares por <distinção>.
---

# MB ${NAME}

<Contexto introdutório de 1-2 parágrafos: o que esta skill resolve, quando aplicar.>

## Quando aplicar

- <Trigger 1>
- <Trigger 2>
- <Trigger 3>

## Como aplicar

### 1. <Primeiro passo>
<Descrição>

### 2. <Segundo passo>
<Descrição>

### 3. <Terceiro passo>
<Descrição>

## Princípios

- <Princípio 1>
- <Princípio 2>

## Limitações

- <O que esta skill NÃO faz>
EOF

cat > "$DIR/references/README.md" <<EOF
# References — mb-${NAME}

Documentação sob demanda da skill. Carregada apenas quando necessário (não inflar SKILL.md principal).

## Estrutura sugerida

- \`patterns.md\` — padrões consagrados do squad
- \`examples.md\` — exemplos reais
- \`troubleshooting.md\` — armadilhas comuns
EOF

cat > "$DIR/scripts/README.md" <<EOF
# Scripts auxiliares — mb-${NAME}

Bash/Python pequenos e idempotentes que a skill invoca.

Convenção:
- \`#!/usr/bin/env bash\`
- \`set -euo pipefail\`
- \`chmod +x\` ao criar
EOF

cat > "$DIR/assets/templates/example.md.tpl" <<EOF
# Template de exemplo

Substitua placeholders <ENTRE-COLCHETES-MAIÚSCULAS>.
EOF

# Atualiza index
INDEX=".mb/skills/README.md"
[[ ! -f "$INDEX" ]] && echo "# Skills custom do squad" > "$INDEX"
echo "" >> "$INDEX"
echo "- [mb-${NAME}](mb-${NAME}/SKILL.md) — <descrição curta>" >> "$INDEX"

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true

printf "\n${C_SUCCESS:-}✓${C_RESET:-} Skill ${C_BOLD:-}mb-${NAME}${C_RESET:-} criada em ${DIR}\n\n"
printf "${C_INFO:-}Próximos passos:${C_RESET:-}\n"
printf "  1. Edite ${C_BOLD:-}${DIR}/SKILL.md${C_RESET:-} — preencha description rica + triggers\n"
printf "  2. Adicione referências em ${DIR}/references/\n"
printf "  3. Crie scripts em ${DIR}/scripts/ se aplicável\n"
printf "  4. Atualize entrada em ${INDEX}\n"
printf "  5. Commit: ${C_BOLD:-}git commit -m \"[skills] cria skill custom mb-${NAME}\"${C_RESET:-}\n\n"
