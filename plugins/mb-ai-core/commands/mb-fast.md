---
description: Modo expresso para tarefas triviais (< 1 dia) — destravado após maturidade do squad
argument-hint: <descrição-da-tarefa>
---

# /mb-fast

**Pré-requisito:** squad maduro (3+ ciclos completos, 0 exceções, 2+ learnings promovidos, 5+ achievements).

Verifica maturidade e ativa modo:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fast-mode.sh"
```

Se squad maduro, próximas tarefas pequenas podem usar este modo:
- Sem fase DISCUSS/SPEC formal.
- Commit direto referenciando contexto via `[fast:<descrição-curta>]`.
- Hooks bloqueantes continuam ativos (segurança/compliance).
- Verification ainda obrigatória se feature toca ativo crítico.

**Não use para:** features novas, ativos críticos, hotfix em produção (use `/mb-hotfix`).
