# Requirements — Exportação de progresso em CSV

> Exemplo didático. Feature simples (backend + frontend) usada para ilustrar todos os padrões EARS e a estrutura canônica.

**Slug**: `2026-05-10-csv-export-progress`
**Início**: 2026-05-10
**Stakeholders**: PM (Bruno), Tech Lead (Carla), HR Admin lead (Daniela)
**Status**: implemented

---

## 1. Contexto e problema

Hoje, HR Admins precisam compor relatórios de progresso de colaboradores manualmente, copiando dados da UI para planilhas. Levantamento com 3 clientes piloto mostrou tempo médio de 90 minutos por relatório mensal — sintoma de feature em falta, não de UX ruim.

Bruno (PM) identificou em sessão de QA que a primeira pergunta de qualquer HR é "como exporto isso?". Sem resposta hoje.

## 2. Objetivo de negócio

Reduzir tempo de geração de relatórios mensais de progresso de **90 minutos** para **menos de 5 minutos**, eliminando o gargalo de cópia manual e abrindo espaço para o HR focar em ações sobre os dados em vez de extração.

## 3. Personas afetadas

| Persona | Como esta feature afeta |
|---------|------------------------|
| HR Admin | Passa a baixar CSV em um clique a partir do dashboard |
| Manager | Não afetado (sem acesso à exportação na v1) |
| Colaborador | Não afetado |

## 4. User stories

- Como HR Admin, eu quero baixar um CSV com o progresso de todos os colaboradores ativos para fazer análises na minha planilha.
- Como HR Admin, eu quero filtrar a exportação por período e por jornada para gerar relatórios específicos.
- Como HR Admin, eu quero ver quando a exportação está disponível para download (em vez de ficar esperando cego).

## 5. Critérios de aceitação (EARS)

### Comportamento principal

- **R1**: O endpoint de exportação deve retornar arquivo no formato CSV (text/csv) com encoding UTF-8 e BOM inicial para compatibilidade com Excel pt-BR.
- **R2**: Quando o HR Admin clica "Exportar progresso" no dashboard, o sistema deve iniciar geração assíncrona e exibir status "preparando".
- **R3**: Quando a geração termina, o sistema deve notificar o HR Admin (toast + entrada em notificações) com link para download válido por 24 horas.

### Comportamento condicional

- **R4**: Onde o tenant está no plano Free, o sistema deve limitar a exportação a 100 colaboradores; planos pagos não têm limite.
- **R5**: Enquanto há uma exportação em andamento para o mesmo HR Admin, o botão "Exportar" deve ficar desabilitado com tooltip "exportação anterior em andamento".

### Comportamento de erro

- **R6**: Se um usuário sem papel HR Admin tenta acessar o endpoint de exportação, então o sistema deve responder 403 e registrar tentativa em audit log.
- **R7**: Se a geração falhar (erro de query, timeout), então o sistema deve notificar o HR Admin com mensagem genérica ("não foi possível gerar agora — tente novamente em alguns minutos") e registrar erro completo em Sentry.
- **R8**: Se o link de download for acessado após 24h, então o sistema deve responder 410 Gone com mensagem orientando a gerar nova exportação.

## 6. Edge cases conhecidos

- **Tenant com 5000+ colaboradores**: precisa rodar em fila, não pode bloquear request HTTP. Endpoint sempre retorna 202 + jobId.
- **Caracteres especiais em nomes** (acentos, emoji): UTF-8 + BOM resolve em Excel; testar com nomes reais.
- **Colaborador deletado durante geração**: incluir na exportação com flag `deletado: sim` em vez de pular silenciosamente.

## 7. Fora de escopo (explícito)

- ❌ Exportação para XLSX nativo (CSV é suficiente; XLSX em backlog).
- ❌ Agendamento recorrente da exportação (Pro feature em backlog).
- ❌ Filtro por departamento (será adicionado quando departamentos virarem entidade própria).
- ❌ Personalização de colunas pelo usuário (v1 tem set fixo).

## 8. Métricas de sucesso

| Métrica | Linha de base | Meta | Como medir |
|---------|---------------|------|------------|
| Tempo médio HR para gerar relatório mensal | 90 min | < 5 min | Survey trimestral com HRs piloto |
| Adoção (HRs que usaram em ≥ 1 mês) | 0% | > 70% em 60 dias | Audit log de exportações por tenant |
| Falhas de geração | n/a | < 1% | Métricas de fila + Sentry |

## 9. Suposições e dependências

- BullMQ já está instalado e workers ativados em produção (✅ confirmado com Tech Lead).
- Storage S3 abstraction comporta arquivos até 50 MB (✅ confirmado).
- Sistema de notificações in-app aceita "link externo de download" como tipo (⚠️ confirmar — virou pergunta na fase Clarify).

## 10. Tags pendentes de clarificação

> Resolvidas na fase Clarify abaixo.

(nenhuma — todas resolvidas)

---

## 11. Clarifications

| Data | Pergunta | Opções | Decisão | Razão |
|------|----------|--------|---------|-------|
| 2026-05-11 | Notificação in-app suporta link externo? | A) sim, já suporta; B) precisa estender o schema; C) usar email | A | Tech Lead confirmou que campo `actionUrl` já existe |
| 2026-05-11 | TTL do link de download | A) 1h; B) 24h; C) 7 dias | B (24h) | Equilibrio entre conveniência e custo de storage |
| 2026-05-12 | Limite Free é por exportação ou por mês? | A) por exportação; B) por mês | A | Simpler. Revisitar se virar problema |
| 2026-05-12 | Job ID exposto no front? | A) sim; B) não | A | Habilita "ver minhas exportações"; sem dado sensível |

## 12. Links

- Plano macro: `docs/plans/2026-04-26-issue-9-hr-admin-panel.md`
- ADR criado: `docs/adrs/008-async-export-pattern.md`
- Issue: #145
