---
description: Define ou consulta o orçamento mensal de IA do squad
argument-hint: [set <valor> | show]
---

# /mb-cost-budget

Gerenciamento de orçamento em `.mb/cost-budget.yaml`.

**Set budget:**
```bash
echo "monthly_budget_brl: $2" > .mb/cost-budget.yaml
echo "✓ Orçamento mensal: R$$2"
```

**Show:**
```bash
cat .mb/cost-budget.yaml 2>/dev/null && echo "" && bash "${CLAUDE_PLUGIN_ROOT}/scripts/cost-report.sh" month
```

Use `/mb-cost-alert` para verificar consumo vs budget.
