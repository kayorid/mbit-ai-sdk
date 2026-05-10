---
description: Diagnóstico de instalação do MB AI SDK no repositório atual — plugins, hooks, MCPs, presença de .mb/, conformidade
---

# /mb-status

Produza um diagnóstico estruturado do estado do MB AI SDK no repositório atual.

## Verificações a executar

### 1. Plugins MB ativos

Liste plugins MB instalados (consulte `~/.claude/settings.json` e plugins disponíveis no contexto). Para cada um indique versão.

### 2. Estrutura `.mb/` do squad

Verifique a presença e validade de:
- `.mb/CLAUDE.md` (existe? última atualização?)
- `.mb/glossary.md`
- `.mb/runbooks/`
- `.mb/skills/`
- `.mb/hooks/`
- `.mb/audit/` (logs presentes?)
- `.mb/bootstrap/` (squad foi bootstrapado?)

### 3. Specs ativas

Conte e liste specs em `docs/specs/_active/`. Para cada uma indique fase atual estimada (último artefato presente).

### 4. Conformidade com constitution

Sinalize divergências:
- `.env` rastreado em git? (deve usar `.env.example`)
- Hooks do `mb-ai-core` carregados?
- MCP allowlist sendo respeitada?

### 5. Audit-trail

- Quantas aprovações registradas em `.mb/audit/approvals.log` nos últimos 30 dias?
- Quantas exceções abertas em `.mb/audit/exceptions.log`?
- Quantos hook fires bloqueantes em `.mb/audit/hook-fires.log` nos últimos 7 dias?

## Formato da saída

```
MB AI SDK — Status do repositório

Plugins ativos:
  ✓ mb-ai-core@0.1.0
  ✓ mb-sdd@0.1.0
  ✗ mb-bootstrap não instalado
  ...

Bootstrap do squad: [✓ feito em 2026-04-20 | ✗ não realizado — rode /mb-bootstrap]

.mb/ presente: [✓ | ✗]
  ├─ CLAUDE.md ........... [✓ atualizado | ⚠ desatualizado >90d | ✗ ausente]
  ├─ glossary.md ......... ...
  ...

Specs ativas: 2
  • 2026-05-10-onboarding-v2 (fase: PLAN)
  • 2026-05-08-fee-engine-rewrite (fase: EXECUTE)

Conformidade:
  ✓ .env não rastreado
  ✓ Hooks de segurança carregados
  ⚠ MCP "exemplo" em uso, não está na allowlist

Audit-trail (últimos 30d):
  Aprovações: 14
  Exceções: 1
  Hook fires bloqueantes: 3

Próxima ação sugerida: <ação contextual>
```

Seja preciso e factual. Se algo não pode ser verificado, diga explicitamente.
