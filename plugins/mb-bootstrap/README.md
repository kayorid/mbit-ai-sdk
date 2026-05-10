# mb-bootstrap

Onboarding híbrido de squad ao MB AI SDK. Combina análise automática do repositório, entrevista guiada e plano de enriquecimento contínuo para gerar contexto rico e específico do squad.

## Comandos

| Comando | Quando usar |
|---------|-------------|
| `/mb-bootstrap` | Primeira vez do squad com o SDK |
| `/mb-bootstrap-rescan` | Após refator grande, mudança de stack ou trimestralmente |
| `/mb-enrich-domain` | Aprofundar glossário e contexto de domínio |
| `/mb-enrich-runbooks` | Documentar runbooks operacionais |
| `/mb-enrich-skills` | Identificar e gerar skills custom do squad |

## Fluxo

1. **Análise automática (5 min, sem humano):** detecta stack, frameworks, estrutura, CI, testes, IaC, observabilidade.
2. **Entrevista guiada (20-30 min, com TL + squad + Chapter AI):** 10 perguntas estruturadas sobre domínio, fluxos críticos, dores, prioridades.
3. **Geração:** cria `.mb/CLAUDE.md`, `.mb/glossary.md`, `.mb/runbooks/`, `.mb/skills/`, `.mb/hooks/`, plano de enriquecimento.

## Pré-requisitos

- `mb-ai-core` instalado e ativo.
- Repositório git inicializado.
- Permissão de escrita no repositório.
- Tech Lead presente; Chapter AI acompanhando primeiras execuções.
