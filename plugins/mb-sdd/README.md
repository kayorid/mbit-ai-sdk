# mb-sdd

Espinha dorsal do MB AI SDK. Ciclo Spec-Driven Development rígido com checkpoints humanos obrigatórios e audit-trail compatível com requisitos regulatórios.

## Comandos

| Comando | Fase do ciclo |
|---------|---------------|
| `/mb-spec` | Conduz o ciclo completo (discuss → spec → plan → execute → verify → review → ship → retro) |
| `/mb-spec-discuss` | Apenas DISCUSS (ambiguity scoring) |
| `/mb-spec-requirements` | Apenas SPEC (gera `requirements.md` em EARS) |
| `/mb-spec-design` | Apenas PLAN parte 1 (`design.md`) |
| `/mb-spec-plan` | Apenas PLAN parte 2 (`tasks.md`) |
| `/mb-spec-execute` | Executa tasks com commits atômicos |
| `/mb-spec-verify` | Verificação goal-backward |
| `/mb-spec-retro` | Retrospectiva da feature |
| `/mb-hotfix` | Modo expresso (pula DISCUSS/SPEC, post-mortem em 48h) |
| `/mb-spike` | Modo exploratório (branch descartável) |

## Ciclo

```
DISCUSS → SPEC → PLAN → EXECUTE → VERIFY → REVIEW → SHIP → RETRO
   ✓        ✓      ✓       commit     ✓       ✓       PR     ↻
   /mb-approve em cada fase
```

## Pré-requisitos

- `mb-ai-core` ativo.
- `mb-bootstrap` executado (`.mb/CLAUDE.md` existe).
- Recomendado: `mb-review`, `mb-security`, `mb-observability`, `mb-retro` para integração completa.

## Artefatos por feature

```
docs/specs/_active/<data>-<feature>/
├── discuss.md
├── requirements.md       # EARS notation
├── design.md
├── tasks.md
├── execution.log
├── verification.md
├── REVIEW.md             # via mb-review
├── THREAT-MODEL.md       # via mb-security (se aplicável)
├── OBSERVABILITY.md      # via mb-observability
├── approvals.log         # via /mb-approve
└── retro.md              # via mb-retro
```
