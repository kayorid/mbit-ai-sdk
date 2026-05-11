---
description: Cria scaffolding de eval para uma feature AI
argument-hint: <feature-slug>
---

# /mb-evals-init

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-eval.sh" $ARGUMENTS
```

Cria `evals/<feature>/` com `dataset.jsonl`, `rubric.md`, `runner.sh`, `threshold.yaml` e estrutura `runs/`. Edite cada um conforme sua feature.
