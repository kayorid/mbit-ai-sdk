---
description: Verifica consumo do mês vs budget e alerta se passar do threshold
---

# /mb-cost-alert

Compara consumo dos últimos 30 dias com orçamento mensal definido.

Avisa em 3 níveis:
- ✓ Verde: <60% do budget
- ⚠ Amarelo: 60-85%
- ✗ Vermelho: >85% — sugere ações (modelo menor, menos paralelismo, revisar uso)

```bash
BUDGET=$(grep monthly_budget_brl .mb/cost-budget.yaml 2>/dev/null | awk '{print $2}')
[[ -z "$BUDGET" ]] && echo "Sem budget definido. Use /mb-cost-budget set <valor>" && exit 0

# Calcula consumo do mês via cost-report
SPENT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/cost-report.sh" month | awk '/TOTAL/ {gsub(/R\$/,"",$NF); print $NF}')
PCT=$(awk "BEGIN{printf \"%.0f\", ($SPENT/$BUDGET)*100}")

if [[ $PCT -gt 85 ]]; then
  echo "✗ ALERTA: $PCT% do budget consumido (R$$SPENT / R$$BUDGET)"
elif [[ $PCT -gt 60 ]]; then
  echo "⚠ ATENÇÃO: $PCT% do budget consumido"
else
  echo "✓ OK: $PCT% do budget consumido"
fi
```
