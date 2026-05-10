---
description: Visão geral do MB AI SDK — plugins ativos, comandos disponíveis, links para documentação
---

# /mb-help

Você é um agente do MB AI SDK. Quando este comando for invocado, produza uma visão geral concisa cobrindo:

## 1. Identidade do SDK

Apresente brevemente: "MB AI SDK — harness corporativo de desenvolvimento assistido por IA do Mercado Bitcoin. Padroniza processo, garante auditabilidade e segurança, mantém squads alinhados sem engessar especialização."

## 2. Plugins do SDK

Liste os 7 plugins do SDK e o que cada um entrega:

| Plugin | Propósito | Comandos principais |
|--------|-----------|---------------------|
| `mb-ai-core` | Constitution, hooks, MCPs aprovados | `/mb-help`, `/mb-status`, `/mb-approve`, `/mb-exception` |
| `mb-bootstrap` | Onboarding híbrido do squad | `/mb-bootstrap`, `/mb-enrich-*` |
| `mb-sdd` | Ciclo Spec-Driven rígido | `/mb-spec`, `/mb-hotfix`, `/mb-spike` |
| `mb-review` | Code/security/spec review | `/mb-review-pr`, `/mb-review-security`, `/mb-review-spec` |
| `mb-observability` | Design e revisão de observabilidade | `/mb-observability-design`, `/mb-observability-review` |
| `mb-security` | Threat modeling, compliance, cripto | `/mb-threat-model`, `/mb-compliance-check` |
| `mb-retro` | Retrospectivas e learnings | `/mb-retro`, `/mb-retro-promote` |

## 3. Por onde começar

- **Squad novo no SDK:** rode `/mb-bootstrap` (Tech Lead conduz, Chapter AI acompanha).
- **Squad já bootstrapado, nova feature:** rode `/mb-spec`.
- **Verificar estado da instalação:** rode `/mb-status`.
- **Algo travando o trabalho:** rode `/mb-exception`.

## 4. Documentação

Links relevantes:
- Documento de design completo: `docs/plans/2026-05-10-mb-ai-sdk-design.md`
- Guia de instalação por papel: `docs/playbooks/install-by-role.md`
- Governança e RACI: `docs/governance/`
- FAQ: `docs/faq.md`

## 5. Onde pedir ajuda

- Canal Slack: `#mb-ai-sdk`
- Chapter AI: `chapter-ai@mercadobitcoin.com.br`
- Issues: repo `mb-ai-sdk` no GitHub Enterprise

Mantenha a resposta em uma única tela, sem encher de detalhes desnecessários.
