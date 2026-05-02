# Status Tracking — INDEX, status.md e HISTORY

Documentação morre quando ninguém atualiza, e ninguém atualiza quando o esforço supera o valor. As práticas abaixo são o mínimo viável: o suficiente para responder "onde estamos?" sem virar burocracia.

## Três artefatos de tracking

| Arquivo | Escopo | Frequência | Quem mantém |
|---------|--------|------------|-------------|
| `INDEX.md` | Global (todas features) | A cada mudança de fase | Skill (script) |
| `status.md` | Por feature | Vivo durante implement | Agente + humano |
| `HISTORY.md` | Global (cronológico) | A cada feature concluída | Humano + agente |

## INDEX.md — visão de portfólio

Tabela única que responde **"o que está em andamento e em que fase?"**.

### Estrutura
```markdown
# Specs Index

Última atualização: 2026-05-01

## Em andamento

| Feature | Fase atual | Início | Próximo passo | Link |
|---------|------------|--------|---------------|------|
| Sistema de certificados | implement (5/12 tasks) | 2026-04-15 | Task #6 — geração PDF | [link](_active/2026-04-15-certificates/) |
| Notificações Slack | clarify | 2026-04-28 | Aguardando respostas do PM | [link](_active/2026-04-28-slack-notif/) |

## Recém concluídas (últimos 30 dias)

| Feature | Concluída em | Link retro |
|---------|--------------|------------|
| Journey Templates 2.0 | 2026-04-29 | [retro](_completed/2026-04-15-jt-2.0/retrospective.md) |

## Constitution
[link](constitution.md) — última revisão 2026-04-01
```

### Quem atualiza e quando
- Sempre que feature muda de fase → atualizar INDEX
- Sempre que feature é movida `_active → _completed` → atualizar INDEX
- Quando rodar `scripts/update_index.py`, ele regenera a partir do estado em disco — útil para corrigir desalinhamentos

### O que NÃO colocar
- Detalhes de tasks (vão em `tasks.md`)
- Decisões longas (vão em `status.md` ou ADR)
- Histórico antigo (vai em `HISTORY.md`)

## status.md — diário de feature

Vive dentro da pasta da feature. Snapshot do estado **agora** + decisões registradas.

### Estrutura mínima
```markdown
# Status — <nome da feature>

**Fase**: implement
**Última atualização**: 2026-05-01 14:30
**Próximo passo concreto**: terminar task #6 (geração de PDF)

## Decisões

| Data | Decisão | Razão | Link |
|------|---------|-------|------|
| 2026-04-20 | Usar pdfkit em vez de puppeteer | Latência menor, sem dep nativa | — |
| 2026-04-25 | Templates inline (não DB) na v1 | Migração futura quando houver demanda | task #4 |

## Perguntas em aberto

- [ ] White-label do PDF deve respeitar tema do tenant? (perguntar PM)

## Blockers

_(nenhum)_

## Validation log

_(preenchido na fase 7)_
```

### Cadência de atualização
- Início e fim de cada task (mínimo)
- Quando tomar decisão não trivial (sempre)
- Em mudança de fase (sempre)
- Em surgir bloqueador (sempre)

### Decisões: o que registrar
Toda decisão que **um humano novo na feature precisaria saber para entender o código**. Em particular:
- Trocas de tecnologia/abordagem em relação ao `design.md` original
- Workarounds para limitação de biblioteca/sistema
- Trade-offs aceitos (ex: "performance < legibilidade aqui")

Não registre micro-decisões mecânicas (nome de variável, formatação) — git diff já mostra.

## HISTORY.md — cronologia do projeto

Nível mais alto: log de marcos do projeto inteiro. **Não é changelog do código** (esse é git log) — é narrativa de produto/feature.

### Estrutura
```markdown
# Project History

## 2026

### Maio
- 2026-05-15 — Sistema de certificados em produção (PR #145, [retro](specs/_completed/2026-04-15-certificates/retrospective.md))
- 2026-05-02 — Notificações Slack: kickoff, fase clarify

### Abril
- 2026-04-29 — Journey Templates 2.0 — todas 5 fases entregues, 5 PRs ([retro](specs/_completed/2026-04-15-jt-2.0/retrospective.md))
- 2026-04-15 — Início Journey Templates 2.0
```

### Quem mantém
Atualizado **na fase 8 (retrospective)** de cada feature. Uma linha por marco. Links para retros e PRs.

### Granularidade
- ✅ Início e fim de feature
- ✅ Decisões estruturais (mudança de plano, mudança de stack)
- ✅ Marcos de negócio (lançamento, migração, fim de piloto)
- ❌ Cada commit (excessivo)
- ❌ Cada PR (use o link da retro)

## Como o tracking conversa com agentes

Esta camada é o que permite que agente novo (ou agente vindo de uma sessão limpa) consiga retomar trabalho **sem precisar reconstruir contexto na cabeça do humano**:

1. Lê `INDEX.md` → sabe o que está em andamento
2. Abre pasta da feature ativa → lê `status.md`
3. `status.md` aponta para próximo passo + decisões já tomadas → contexto recuperado
4. Lê `requirements.md` e `design.md` para profundidade

Sem essa cadeia, cada retomada é "me lembra o que estávamos fazendo?". Com ela, o agente pode dizer **"sigo de onde paramos"** em segundos.

## Pegadinhas de manutenção

### Tracking que mente
A pior coisa é INDEX/status que dizem "fase X" enquanto a feature está em "fase Y". Pior que ausência. Mitigação:
- `scripts/update_index.py` regenera INDEX a partir do disco — rodar quando suspeitar de drift
- `scripts/validate_spec.py` checa consistência mínima

### Status excessivamente detalhado
Se `status.md` virou `tasks.md` paralelo, cortou. Status é sobre **decisões e estado**, tasks é sobre **execução**. Não duplique.

### HISTORY que vira changelog
Se HISTORY tem "fix typo X" — está virando git log. Suba o nível. HISTORY é narrativa, não diário.

### INDEX desatualizado por meses
Se nenhum agente está atualizando INDEX, é sinal de que ele não está sendo lido. Soluções:
- Rodar `update_index.py` em hook pré-commit
- Pôr leitura de INDEX como passo 1 de qualquer skill que toque specs
- Aceitar que talvez um projeto pequeno não precise de INDEX e usar só listing de pasta

## Cadência sugerida (rotina semanal)

Para projetos com SDD ativo, uma cadência leve mantém o sistema vivo:

- **Diário**: agente atualiza `status.md` da feature em curso ao começar/terminar trabalho
- **Após fase**: humano (ou agente sob revisão) atualiza `INDEX.md`
- **Após feature**: humano escreve retro, atualiza `HISTORY.md`, move para `_completed/`
- **Mensal**: revisar `_completed/` — algo deve virar runbook ou ADR? Algo deve atualizar `constitution.md`?
