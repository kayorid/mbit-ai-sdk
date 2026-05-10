# Status — Exportação de progresso em CSV

**Fase atual**: validate (concluída) → retrospective
**Última atualização**: 2026-05-22 17:30
**Próximo passo concreto**: escrever retrospective.md e arquivar feature

---

## Decisões registradas

| Data | Decisão | Razão | Referência |
|------|---------|-------|------------|
| 2026-05-12 | Adotar BullMQ em vez de cron próprio | Já em produção, contratos consolidados | design.md §1 |
| 2026-05-13 | TTL do link de download = 24h | Equilíbrio conveniência × custo storage | requirements.md §11 |
| 2026-05-15 | Chunks de 500 linhas no streaming | Tested OK até 50k linhas sem pico de RAM | T3 |
| 2026-05-18 | Adicionar coluna `deletado: sim/não` | Edge case identificado durante testes manuais | requirements.md §6 |

## Perguntas em aberto

(nenhuma — todas resolvidas)

## Blockers

(nenhum)

## Descobertas (fora de escopo planejado)

- HR Admins relataram que querem agendamento recorrente — registrado para v2 (já estava em §7 fora de escopo, confirmação reforça prioridade).
- Tenants Enterprise pediram XLSX — confirma backlog v2.
- Filtro por departamento mais pedido que esperávamos — promover P1 quando departamentos virarem entidade.

---

## Validation log

| Critério | Evidência | Status |
|----------|-----------|--------|
| R1 (CSV UTF-8 + BOM) | Snapshot test em `backend/tests/csv-format.test.ts`; teste manual em Excel pt-BR | ✅ ok |
| R2 (clique inicia geração) | E2E `hr-admin-export.spec.ts` linha 23-45 | ✅ ok |
| R3 (notificação ao terminar) | E2E linha 47-68; print do painel de notificações em PR #156 | ✅ ok |
| R4 (limite Free 100 colaboradores) | Teste integração `exports.test.ts:limites-plano-free` | ✅ ok |
| R5 (botão desabilitado durante geração) | Storybook story "ExportProgressButton/loading"; E2E linha 70-85 | ✅ ok |
| R6 (403 sem role HR_ADMIN) | Teste integração `exports.test.ts:auth-roles` | ✅ ok |
| R7 (notif de erro + Sentry) | Teste integração com mock de Sentry; print do dashboard Sentry | ✅ ok |
| R8 (410 após 24h) | Teste integração `exports.test.ts:link-expirado` | ✅ ok |

Validation report: **8/8 critérios atendidos**.

## Métricas pós-feature

| Métrica | Linha de base | Meta | Observado | Notas |
|---------|---------------|------|-----------|-------|
| Tempo HR para gerar relatório | 90 min | < 5 min | < 2 min em tenant piloto | Survey após 2 semanas de uso |
| Adoção (HRs ativos) | 0% | > 70% em 60 dias | aguardando janela | Próxima medição: 2026-07-22 |
| Falhas de geração | n/a | < 1% | 0% (24 exports gerados) | Sample inicial pequeno |

---

## Histórico de fase

| Data | Fase entrada | Quem | Notas |
|------|--------------|------|-------|
| 2026-05-10 09:00 | specify | Bruno + Carla | kickoff após QA com clientes piloto |
| 2026-05-11 14:00 | clarify | Carla | 4 perguntas batch para Bruno |
| 2026-05-12 10:00 | plan | Carla + agente | design.md gerado, validation gate ok |
| 2026-05-13 09:00 | tasks | Carla | tasks.md com 18 tasks, 6 paralelas |
| 2026-05-13 13:00 | implement | Carla + agentes paralelos | T3-T11 distribuídos |
| 2026-05-21 16:00 | validate | Carla | 8/8 critérios EARS validados |
| 2026-05-22 17:30 | retrospective | Carla | em curso |
