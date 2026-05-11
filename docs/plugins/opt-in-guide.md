# Guia de plugins opt-in

O MBit AI SDK distribui **9 plugins**. Sete são **default** (todo squad MB instala). Dois são **opt-in** — ligados conscientemente por quem precisa.

## Default (sempre instalado)

`mb-ai-core`, `mb-bootstrap`, `mb-sdd`, `mb-review`, `mb-observability`, `mb-security`, `mb-retro`.

## Opt-in

### `mb-evals` — framework de avaliação para features de IA

**Quando ligar:** seu squad está construindo uma feature que **chama um modelo de IA em runtime** (resposta a usuário, classificação, sumarização). Sem eval estruturado, regressão de qualidade fica invisível.

**Quando NÃO ligar:** squad que apenas usa IA como ferramenta de dev (Claude Code, Cursor) sem expor IA ao usuário final.

**Overhead:**
- `/mb-evals-init` para configurar: ~5min
- `/mb-evals-run` em CI: depende do golden dataset (10 exemplos ≈ 30s)
- Custo: chamadas extras ao modelo durante eval (cobrir no orçamento de IA do squad)

**Saída:**
- `evals/<feature>/runs/*.jsonl` — histórico de scores
- `/mb-evals-compare` — diff entre runs

### `mb-cost` — captura de tokens & custo

**Quando ligar:** squad que quer rastrear custo de uso de IA (Claude Code, AI features em produção) para reportar a Tech Lead / Finance.

**Quando NÃO ligar:** squad que ainda está em fase exploratória sem KPI de custo.

**Overhead:**
- Hook `PostToolUse` adiciona ~10ms por chamada
- Arquivo `.mb/cost-events.jsonl` cresce ~1MB/semana em uso intensivo
- Privacy: nenhum conteúdo de prompt é gravado — só tokens + modelo + timestamp

**Saída:**
- `/mb-cost-report` — relatório de uso e custo no período
- Limitação conhecida: Claude Code raramente expõe `usage` em payloads de tool individuais; captura é parcial. Em v1.0+ mudará para `Stop`/`SessionEnd` lendo transcript.

## Como ativar

```bash
# Adicione ao seu ~/.claude/settings.json
{
  "plugins": {
    "mb-evals": { "enabled": true },
    "mb-cost":  { "enabled": true }
  }
}
```

Ou via comando:

```bash
/plugin install mb-evals@mbit-ai-sdk
/plugin install mb-cost@mbit-ai-sdk
```

## Critério de decisão rápida

| Você está... | Ligar? |
|---|---|
| Construindo chatbot ou feature AI exposta ao usuário | **mb-evals: sim** |
| Reportando custo de IA mensalmente | **mb-cost: sim** |
| Apenas explorando IA como ferramenta interna | **nenhum** |
| Squad com orçamento de IA estourando | **mb-cost: urgente** |
| Squad com cliente reclamando de qualidade AI | **mb-evals: urgente** |

## Roadmap

- v0.5: este guia.
- v1.0: dashboard cross-squad de adoção (`/mb-adoption-report`) usa dados destes 2 plugins quando ligados.
- v1.5: telemetria opt-in agregada (sem PII) cruzando uso × custo × qualidade.
