---
description: Modo CI — roda eval, compara com threshold, exit 0/1
argument-hint: <feature-slug>
---

# /mb-evals-ci

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/ci-eval.sh" $ARGUMENTS
```

Use em GitHub Actions / GitLab CI para garantir que mudanças de prompt/modelo não regridem qualidade.

Comportamento:
- `passing` ou acima → exit 0
- entre `failing` e `passing` → exit 0 com aviso
- abaixo de `failing` → exit 1 (bloqueia PR)
