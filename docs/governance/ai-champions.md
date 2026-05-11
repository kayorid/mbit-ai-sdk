# Comunidade MB AI Champions

> Charter formal da comunidade. Revisada semestralmente.

## 1. Propósito

Articular uma rede de praticantes avançados do MBit AI SDK que:
- Ajudam squads vizinhos a adotar e usar bem o SDK
- Propagam práticas com evidência de eficácia
- Filtram propostas de evolução do SDK antes que virem PRs
- Servem como ponte entre Chapter AI e squads

**Não é** um programa de prestígio individual. É uma rede de serviço.

## 2. Princípios

- ✅ **Squad sobre pessoa**: rankings, leaderboards e métricas são sempre agregados por squad.
- ✅ **Evidência sobre opinião**: propostas precisam de retro ou métrica que sustente.
- ✅ **Diversidade de squads**: representar backend, frontend, observability, security, dados.
- 🚫 **Nunca**: rankings individuais públicos, gamificação que penalize uso baixo, exposição de PII.

## 3. Elegibilidade

Qualquer pessoa de squad MB que tenha:

- (a) Completado pelo menos **3 ciclos SDD** completos no SDK (spec → impl → retro)
- (b) Contribuído com pelo menos **1 PR mergeado** ao mbit-ai-sdk OU **1 padrão promovido** via `/mb-retro-promote`
- (c) Indicação por colega de squad **ou** auto-indicação respaldada por output em (a)+(b)

Não há limite de quantos Champions por squad nem cota global. Não é vaga.

## 4. Processo de indicação

1. Candidato (ou colega) preenche template em `docs/governance/champion-application.md` (a criar via PR)
2. Comitê Champion (rotativo, 5 nomes ativos) revisa em até 15 dias
3. Decisão registrada como ADR em `docs/adrs/`
4. Sem rejeição definitiva: feedback construtivo + reaplicação após 90d

## 5. Cadência

| Cerimônia | Frequência | Duração | Quem |
|---|---|---|---|
| Reunião comunitária | Mensal | 60min | Todos Champions ativos |
| MB AI Lab (workshop) | Quinzenal | 90min | Champion facilita, qualquer dev assiste |
| Newsletter trimestral | 1x/trimestre | — | gerada via `/mb-newsletter` |
| Comitê (revisão de candidaturas) | Conforme demanda | 30min | 5 Champions rotativos |
| Revisão do charter | Semestral | 90min | Todos Champions ativos |

## 6. RACI

| Atividade | Champion | Comitê | Chapter AI | Tech Lead |
|---|---|---|---|---|
| Facilitar AI Lab | R | C | I | I |
| Aprovar PR ao SDK | C | I | A | I |
| Decidir nova candidatura | C | A,R | C | I |
| Propor mudança no charter | C | C | A | I |
| Onboarding de novo squad | R | I | C | A |

R=Responsável, A=Aprovador, C=Consultado, I=Informado.

## 7. Saída / rotatividade

Champion inativo por **6 meses consecutivos** (sem participação em cerimônias nem contribuição registrada) é movido para `alumni` automaticamente. Re-ingresso é trivial: 1 sessão de Lab facilitada.

## 8. Revisão

Este documento é revisitado a cada 6 meses. Última revisão: 2026-05-11 (v0.5.0).

## 9. Métricas saudáveis (não tóxicas)

Rastreadas via `/mb-leaderboard` apenas por squad:
- Diversidade de comandos usados
- Retros realizadas
- Conquistas raras desbloqueadas

Nunca rastreadas: ranking individual, velocity comparativa, número de commits por pessoa.
