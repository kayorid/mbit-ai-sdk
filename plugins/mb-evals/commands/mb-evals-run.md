---
description: Executa eval de uma feature
argument-hint: <feature-slug>
---

# /mb-evals-run

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/run-eval.sh" $ARGUMENTS
```

Roda o `runner.sh` da feature, salva resultados em `runs/<timestamp>-<modelo>.jsonl`.
