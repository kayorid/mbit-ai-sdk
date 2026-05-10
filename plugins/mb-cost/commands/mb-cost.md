---
description: Mostra custo de IA agregado (dia/semana/mês)
argument-hint: [day|week|month]
---

# /mb-cost

Execute o relatório:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/cost-report.sh" ${ARGUMENTS:-week}
```

Mostra tokens consumidos por fase SDD, valor estimado em USD e BRL. Use para decisões conscientes sobre uso de modelos grandes vs pequenos.
