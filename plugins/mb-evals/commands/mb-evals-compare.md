---
description: A/B test entre duas versões/runs de eval
argument-hint: <feature-slug> <run-a> <run-b>
---

# /mb-evals-compare

Compara duas runs side-by-side (e.g. `prompt-v1` vs `prompt-v2`):

1. Lê `evals/<feature>/runs/<run-a>.jsonl` e `<run-b>.jsonl`.
2. Para cada `id`, mostra score A vs B + delta.
3. Resumo: regressões, melhorias, empate.
4. Sinaliza outliers (delta > 0.3).

Útil antes de mudar prompt em produção: roda eval da versão atual e da nova, compara.

```bash
F=$1; A=$2; B=$3
echo "Comparando $F: $A vs $B"
join -j 2 \
  <(jq -r '.id+" "+(.score|tostring)' "evals/$F/runs/$A.jsonl" | sort) \
  <(jq -r '.id+" "+(.score|tostring)' "evals/$F/runs/$B.jsonl" | sort) \
  | awk '{ d=$3-$2; printf "%-10s  %s  %s  Δ=%+.2f\n", $1, $2, $3, d }'
```
