---
description: Fase PLAN parte 1 — gera design.md com arquitetura, contratos e trade-offs
argument-hint: <slug-da-feature>
---

# /mb-spec-design

Conduza a primeira parte da fase PLAN:

1. Verifique SPEC aprovada.
2. Leia `requirements.md`, `.mb/CLAUDE.md`, glossário.
3. Verifique se a feature toca ativo crítico (regulação, fluxos críticos do squad). Se sim, **invoque `/mb-threat-model` antes de prosseguir** e referencie `THREAT-MODEL.md` no design.
4. Gere `design.md` usando template `assets/templates/design.md.tpl`. Cubra:
   - Arquitetura proposta (componentes, responsabilidades, integrações).
   - Modelo de dados (se aplicável).
   - Contratos de API/eventos (se aplicável).
   - Decisões técnicas relevantes (formato de mini-ADR inline).
   - Alternativas consideradas e por que rejeitadas.
   - Riscos técnicos.
   - Dependências (libs, serviços, MCPs).
5. **Validation gate (over-engineering):** depois de gerar, audite o próprio design — "o que aqui é necessário para a feature pedida vs. projetando para futuro hipotético?" Remova o segundo grupo.
6. Invoque `/mb-observability-design` para gerar `OBSERVABILITY.md` paralelo.
7. Peça `/mb-approve DESIGN`.
