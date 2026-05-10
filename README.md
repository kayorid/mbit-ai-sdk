# MB AI SDK

> **Harness corporativo de desenvolvimento assistido por IA para o Mercado Bitcoin.**
> Padroniza processo, garante auditabilidade e segurança, mantém squads alinhados sem engessar especialização técnica.

[![Versão](https://img.shields.io/badge/versão-0.1.0-blue)]() [![Status](https://img.shields.io/badge/status-piloto-orange)]() [![Licença](https://img.shields.io/badge/licença-Proprietária-red)]()

---

## O que é

O **MB AI SDK** é um conjunto de plugins Claude Code que estabelece o "como" do desenvolvimento assistido por IA no MB. Não é uma biblioteca de runtime nem um framework de código — é um **framework de processo, governança e contexto** distribuído como plugins instaláveis via marketplace interno.

### Princípios fundadores

1. **Processo > Stack** — opina sobre como se trabalha, não sobre tecnologia.
2. **Auditabilidade nativa** — toda decisão deixa trilha versionada (compliance Bacen/CVM/LGPD).
3. **Rigidez pedagógica** — força o ciclo SDD enquanto o time aprende; modos relaxados após maturidade.
4. **Segurança não-negociável** — hooks de segurança/compliance sempre bloqueiam.
5. **Contexto vivo** — `.mb/CLAUDE.md`, glossário e skills do squad evoluem continuamente.
6. **MCPs sob curadoria** — apenas allowlist aprovada pelo Chapter AI.
7. **Verificação antes de claim** — nada está "pronto" sem evidência observável.
8. **Reversibilidade preferida** — ações destrutivas exigem confirmação humana.
9. **Custo de IA é decisão de engenharia** — exposto explicitamente.
10. **Aprendizado coletivo** — learnings dos squads alimentam o core.

---

## Os sete plugins

| Plugin | Obrigatório? | Propósito |
|--------|:-----------:|-----------|
| [`mb-ai-core`](plugins/mb-ai-core/) | ✓ | Constitution, hooks bloqueantes, MCP allowlist, comandos base |
| [`mb-bootstrap`](plugins/mb-bootstrap/) | recomendado | Onboarding híbrido do squad (análise + entrevista + enriquecimento) |
| [`mb-sdd`](plugins/mb-sdd/) | recomendado | Ciclo Spec-Driven rígido com checkpoints |
| [`mb-review`](plugins/mb-review/) | opt-in | Code, security e spec review como agentes formais |
| [`mb-observability`](plugins/mb-observability/) | opt-in | Design e revisão de observabilidade (stack-agnostic) |
| [`mb-security`](plugins/mb-security/) | opt-in (obrigatório se ativo crítico) | Threat modeling, compliance, padrões cripto |
| [`mb-retro`](plugins/mb-retro/) | opt-in | Retrospectivas e memória organizacional |

---

## Início rápido

### Para um Tech Lead onboardando seu squad

1. **Instale o marketplace** (em `~/.claude/settings.json`):

```json
{
  "extraKnownMarketplaces": {
    "mb": {
      "source": {
        "source": "github",
        "repo": "mercadobitcoin/mb-ai-sdk"
      }
    }
  },
  "enabledPlugins": {
    "mb-ai-core@mb": true,
    "mb-bootstrap@mb": true,
    "mb-sdd@mb": true,
    "mb-review@mb": true,
    "mb-observability@mb": true,
    "mb-security@mb": true,
    "mb-retro@mb": true
  }
}
```

2. **Reinicie o Claude Code** e verifique:
```
/mb-status
```

3. **Bootstrap do squad** (com squad presente, Chapter AI acompanhando):
```
/mb-bootstrap
```

4. **Primeira feature pelo ciclo completo:**
```
/mb-spec <slug-da-feature>
```

5. **Cumpra a missão da semana 1** do plano de enriquecimento gerado.

### Para um Dev novo no squad

1. Garanta que o marketplace MB e os plugins ativados estão no seu `~/.claude/settings.json` (peça ao TL ou ao AI Champion).
2. Rode `/mb-help` para visão geral.
3. Leia `.mb/CLAUDE.md` do repositório.
4. Para features, sempre use `/mb-spec`.

---

## Documentação

- 📋 [**Documento de Design Completo**](docs/plans/2026-05-10-mb-ai-sdk-design.md) — proposta executiva + arquitetura + roadmap
- 📚 [**Manual Técnico Detalhado**](docs/manual/MANUAL.md) — bases teóricas, arquitetura interna, fluxos
- 🎤 [**Roteiro de Apresentação**](docs/presentation/PRESENTATION.md) — slides comentados para liderança
- 🏛 [**Governança e RACI**](docs/governance/) — papéis, processos, proposta de mudança
- 📖 [**Playbooks por papel**](docs/playbooks/) — Chapter AI, Tech Lead, AI Champion, Dev
- ❓ [**FAQ**](docs/faq.md)

---

## Estrutura do repositório

```
mb-ai-sdk/
├── README.md                          ← você está aqui
├── CHANGELOG.md
├── LICENSE
├── .claude-plugin/
│   └── marketplace.json               ← lista os 7 plugins
├── docs/
│   ├── plans/                         ← propostas e designs
│   ├── manual/                        ← manual técnico completo
│   ├── presentation/                  ← roteiro de apresentação
│   ├── governance/                    ← papéis, processos, RACI
│   ├── playbooks/                     ← guias práticos por papel
│   └── faq.md
└── plugins/
    ├── mb-ai-core/
    ├── mb-bootstrap/
    ├── mb-sdd/
    ├── mb-review/
    ├── mb-observability/
    ├── mb-security/
    └── mb-retro/
```

---

## Suporte e contato

- **Canal Slack:** `#mb-ai-sdk`
- **Chapter AI:** `chapter-ai@mercadobitcoin.com.br`
- **Issues:** abrir no GitHub Enterprise (`mercadobitcoin/mb-ai-sdk`)
- **Comunidade de AI Champions:** encontro mensal — calendário interno

---

## Roadmap

| Versão | Janela | Marco |
|--------|--------|-------|
| v0.1 | Sem 1-3 | Foundation — core + bootstrap + sdd, 1 squad piloto |
| v0.5 | Sem 4-8 | Expansão — review, observability, security, retro, 3-5 squads |
| v1.0 | Sem 9-13 | Maturidade pedagógica — destravamento de modos relaxados, CI integrado |
| v1.5 | Sem 14-20 | Inteligência — análise agregada, sugestão automática de skills |
| v2.0 | Trim 2 | Plataforma corporativa — infra própria, SIEM, dashboard executivo |

Detalhes em [`docs/plans/2026-05-10-mb-ai-sdk-design.md`](docs/plans/2026-05-10-mb-ai-sdk-design.md).

---

**Feito pelo Chapter AI do Mercado Bitcoin · Maio 2026**
