# Spec-Driven Development — Claude Code Plugin

Plugin de Spec-Driven Development (SDD) para Claude Code. Introduz um fluxo estruturado de especificação antes da implementação: requisitos EARS → design → tasks faseadas → checkpoints → retrospectiva.

## O que é SDD

Spec-Driven Development é a prática de escrever uma especificação completa (requisitos, design, tasks) antes de tocar no código. O Claude atua como parceiro de spec: faz perguntas, resolve ambiguidades, gera os artefatos e guia a implementação fase a fase.

## Skill incluída

| Skill | Quando usar |
|-------|-------------|
| `spec-driven-development:spec-driven-development` | Planejando uma nova feature, iniciando uma fase do projeto, ou precisando de clareza antes de implementar |

## Instalação

### Via settings.json global (`~/.claude/settings.json`)

```json
{
  "enabledPlugins": {
    "spec-driven-development@kayorid": true
  },
  "extraKnownMarketplaces": {
    "kayorid": {
      "source": {
        "source": "github",
        "repo": "kayorid/spec-driven-development"
      }
    }
  }
}
```

## Artefatos gerados

```
docs/specs/_active/<data>-<feature>/
├── requirements.md   # Requisitos em EARS (16 critérios estruturados)
├── design.md         # Decisões de arquitetura e design
├── tasks.md          # Tasks faseadas com checkpoints e paralelização
└── status.md         # Estado atual, decisões, descobertas
```

## Scripts incluídos

| Script | O que faz |
|--------|-----------|
| `scripts/init_spec.sh` | Inicializa pasta de spec com todos os artefatos |
| `scripts/update_index.py` | Regenera `docs/specs/INDEX.md` |
| `scripts/validate_spec.py` | Valida estrutura e completude da spec |

## Versioning

`MAJOR.MINOR.PATCH` — patch para correções, minor para novos templates/referências, major para mudanças estruturais na metodologia.
