---
description: Relatório de adoção corporativa do SDK por squad e período
argument-hint: [--period 30d|90d|365d] [--json]
---

# /mb-adoption-report

Relatório corporativo de adoção do MBit AI SDK. Consumível em terminal ou JSON para dashboards.

## Como rodar

```bash
bash plugins/mb-retro/scripts/adoption-report.sh                # default 90d
bash plugins/mb-retro/scripts/adoption-report.sh --period 30d
bash plugins/mb-retro/scripts/adoption-report.sh --period 365d --json
```

## O que mostra

- **Squads ativos** — número de squads únicos que commitaram no período (via `[squad:X]`)
- **Retros realizadas** — contagem total agregada
- **Top 10 categorias de commit** — `[spec]`, `[impl]`, `[fix]`, `[sec]`, etc.
- **Plugins/hooks com atividade** — quais bloqueios/eventos foram registrados em `.mb/audit/hook-fires.log`

## Output JSON

```json
{
  "period": "90d",
  "squads_active": 7,
  "retros_recent": 12,
  "top_commands": "...",
  "plugins_used": "..."
}
```

Consumido por dashboard interno da Plataforma MB (a configurar).

## Privacidade

Apenas dados agregados por squad. Não identifica pessoas.
