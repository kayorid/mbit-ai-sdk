#!/usr/bin/env bash
# mb-evals / scripts / init-eval.sh
# Cria scaffolding de eval para uma feature.

set -euo pipefail

FEATURE="${1:-}"
[[ -z "$FEATURE" ]] && { echo "Uso: init-eval.sh <feature-slug>"; exit 1; }

DIR="evals/$FEATURE"
if [[ -d "$DIR" ]]; then
  echo "Eval já existe em $DIR. Use --force para sobrescrever (não implementado)."
  exit 1
fi

mkdir -p "$DIR/runs"

cat > "$DIR/README.md" <<EOF
# Eval — $FEATURE

Avaliação de qualidade da feature \`$FEATURE\`.

## Estrutura
- \`dataset.jsonl\` — golden examples
- \`rubric.md\` — critérios de avaliação
- \`runner.sh\` — executa eval
- \`threshold.yaml\` — passing score
- \`runs/\` — histórico de execuções

## Como rodar

\`/mb-evals-run $FEATURE\` ou diretamente:
\`\`\`bash
bash evals/$FEATURE/runner.sh
\`\`\`

## Como comparar versões

\`/mb-evals-compare $FEATURE prompt-v1 prompt-v2\`
EOF

cat > "$DIR/dataset.jsonl" <<'EOF'
{"id": "001", "input": {"query": "exemplo de input"}, "expected": {"label": "exemplo de output esperado"}, "tags": ["happy-path"]}
{"id": "002", "input": {"query": "edge case"}, "expected": {"label": "tratamento adequado"}, "tags": ["edge-case"]}
EOF

cat > "$DIR/rubric.md" <<EOF
# Rubrica — $FEATURE

## Critérios

### C-1: Correção (peso 50%)
- **Tipo:** determinística
- **Regra:** \`output.label == expected.label\`
- **Score:** 1.0 se igual, 0.0 caso contrário

### C-2: <outro critério> (peso 30%)
- **Tipo:** llm-as-judge
- **Prompt:** "Avalie de 1 a 5 se a saída X..."
- **Mapeamento:** 5→1.0, 4→0.8, 3→0.5, 2→0.2, 1→0.0

### C-3: <outro critério> (peso 20%)
- **Tipo:** custom
- **Script:** bash/python que retorna 0.0-1.0

## Score final
\`\`\`
score = 0.5*C1 + 0.3*C2 + 0.2*C3
\`\`\`
EOF

cat > "$DIR/threshold.yaml" <<EOF
# Threshold de aprovação
passing: 0.85    # acima disso, eval passa
warning: 0.70    # entre warning e passing: aceito mas com aviso
failing: 0.70    # abaixo: bloqueia em CI

# Acordado com produto em <data>
# Revisar trimestralmente
EOF

cat > "$DIR/runner.sh" <<'EOF'
#!/usr/bin/env bash
# Runner do eval — adapte para sua feature
set -euo pipefail

FEATURE_DIR="$(dirname "$(realpath "$0")")"
DATASET="$FEATURE_DIR/dataset.jsonl"
RUNS_DIR="$FEATURE_DIR/runs"
TS=$(date -u +%Y-%m-%dT%H%M)
MODEL="${MB_EVAL_MODEL:-claude-sonnet-4}"
OUT="$RUNS_DIR/${TS}-${MODEL}.jsonl"

mkdir -p "$RUNS_DIR"

echo "Rodando eval: $(wc -l < "$DATASET" | tr -d ' ') exemplos com $MODEL"

TOTAL=0; PASS=0
while IFS= read -r line; do
  TOTAL=$((TOTAL+1))
  ID=$(echo "$line" | jq -r '.id')

  # TODO: chame seu sistema sob teste aqui
  # Exemplo:
  # OUTPUT=$(curl -s "http://localhost:8000/predict" -d "$INPUT")
  # SCORE=$(echo "$OUTPUT" | jq -r '... rubrica ...')

  SCORE="0.0"  # placeholder

  echo "{\"id\":\"$ID\",\"score\":$SCORE,\"model\":\"$MODEL\",\"ts\":\"$TS\"}" >> "$OUT"

  awk "BEGIN { exit !($SCORE >= 0.85) }" && PASS=$((PASS+1))
done < "$DATASET"

PCT=$(awk "BEGIN { printf \"%.2f\", ($PASS/$TOTAL)*100 }")
echo "Pass rate: $PASS/$TOTAL ($PCT%)"
echo "Resultados: $OUT"
EOF
chmod +x "$DIR/runner.sh"

echo "✓ Eval scaffolding criado em $DIR"
echo ""
echo "Próximos passos:"
echo "  1. Edite $DIR/dataset.jsonl com exemplos reais"
echo "  2. Refine $DIR/rubric.md"
echo "  3. Implemente $DIR/runner.sh para chamar sua feature"
echo "  4. Rode: /mb-evals-run $FEATURE"
