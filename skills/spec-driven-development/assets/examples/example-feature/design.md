# Design — Exportação de progresso em CSV

**Linkado a**: [requirements.md](./requirements.md)
**Última atualização**: 2026-05-12

---

## 1. Visão geral da solução

Exportação assíncrona via fila de jobs (BullMQ + Redis). HR Admin dispara via endpoint `POST /api/v1/exports/progress`, recebe `jobId` imediato. Worker processa em background gerando CSV, salva no storage S3 abstraction com chave única, marca job como concluído. Notificação in-app sinaliza disponibilidade com link assinado de 24h. Download segue padrão `api.fetchAuthed` para arquivos binários autenticados.

A escolha de fila (em vez de stream HTTP direto) é justificada pela necessidade de tolerar tenants grandes (5000+ colaboradores) sem manter conexão HTTP aberta — request síncrono não escala para cenário Enterprise.

CSV é montado em memória durante a geração; para tenants > 1000 colaboradores, usamos streaming de chunks para evitar pico de RAM. Limite operacional inicial: 50 MB por arquivo (cobre tenants até ~500k linhas).

## 2. Arquitetura

### Componentes envolvidos

```
HR Admin Dashboard
  └─→ POST /api/v1/exports/progress  (returns jobId)
        └─→ ExportService.enqueueProgressExport
              └─→ BullMQ queue 'exports'

Worker (separate process)
  └─→ ProgressExportProcessor
        ├─→ Prisma → fetch journeys + progress (paginated)
        ├─→ csv-stringify (streaming)
        ├─→ Storage S3 abstraction → upload
        └─→ NotificationService.notify(userId, type='export_ready', actionUrl)

HR Admin Dashboard
  └─→ GET /api/v1/exports/:jobId
        └─→ ExportService.getStatus → 'pending' | 'ready' | 'failed'
  └─→ GET /api/v1/exports/:jobId/download (uses api.fetchAuthed)
        └─→ Storage S3 abstraction → presigned URL → 302 redirect
```

### Mudanças por camada

- **Frontend**: novo botão no dashboard HR + hook `useProgressExport` + entrada em painel de notificações
- **Backend (API)**: 3 rotas novas (`POST /exports/progress`, `GET /exports/:jobId`, `GET /exports/:jobId/download`)
- **Backend (Worker)**: novo processor `ProgressExportProcessor`
- **Banco de dados**: nova tabela `Export` (job tracking)
- **Infra**: nenhuma — BullMQ + Redis + S3 abstraction já em produção

## 3. Modelo de dados

### Mudanças no schema

```prisma
model Export {
  id          String      @id @default(cuid())
  tenantId    String
  userId      String
  type        ExportType
  status      ExportStatus @default(PENDING)
  filterJson  Json
  storageKey  String?
  expiresAt   DateTime?
  errorMessage String?
  createdAt   DateTime    @default(now())
  completedAt DateTime?

  @@index([tenantId, userId, createdAt(sort: Desc)])
}

enum ExportType { PROGRESS_CSV }
enum ExportStatus { PENDING, PROCESSING, READY, FAILED, EXPIRED }
```

### Migrations necessárias

- `2026-05-12-add-exports-table.sql` — pura adição, sem backfill, sem alteração de tabelas existentes (online safe)

## 4. Contratos de API

| Método | Endpoint | Descrição | Auth |
|--------|----------|-----------|------|
| POST | `/api/v1/exports/progress` | Inicia exportação assíncrona | JWT + role HR_ADMIN + tenant |
| GET | `/api/v1/exports/:jobId` | Consulta status do job | JWT + tenant + dono |
| GET | `/api/v1/exports/:jobId/download` | Faz download (302 → presigned) | JWT + tenant + dono |

### Schemas (Zod)

```typescript
const ProgressExportRequest = z.object({
  filters: z.object({
    journeyTemplateId: z.string().cuid().optional(),
    periodStart: z.string().datetime().optional(),
    periodEnd: z.string().datetime().optional(),
  }).default({}),
});

const ProgressExportResponse = z.object({
  jobId: z.string().cuid(),
  status: z.enum(['PENDING', 'PROCESSING', 'READY', 'FAILED']),
  estimatedSeconds: z.number().int().nullable(),
});
```

## 5. Mapeamento Requirements → Design

| Critério | Componente responsável | Notas |
|----------|------------------------|-------|
| R1 | `ProgressExportProcessor` | csv-stringify + BOM `﻿` |
| R2 | endpoint POST + status PENDING/PROCESSING | retorna jobId em < 200ms |
| R3 | `NotificationService.notify('export_ready')` | actionUrl = `/exports/:id/download` |
| R4 | `ProgressExportProcessor` precondição | checa tenant.plan + count(users) |
| R5 | endpoint POST | rejeita se há export PENDING/PROCESSING do mesmo userId |
| R6 | middleware `requireRole(['HR_ADMIN'])` + audit log | resposta 403 |
| R7 | try/catch no processor + Sentry capture | status FAILED + notification de erro |
| R8 | endpoint download | checa `expiresAt < now()` → 410 |

## 6. Integrações externas

| Serviço | Propósito | Custo | Limites |
|---------|-----------|-------|---------|
| Redis (BullMQ) | Fila de jobs | já no orçamento | rate atual ok |
| S3 abstraction | Storage temporário | ~$0.01/GB/mês | 50 MB por export |

## 7. Boundaries (harness anti-drift)

### ✅ Always
- Toda query Prisma deve filtrar por `tenantId` (multi-tenant isolation)
- Toda exportação deve registrar audit log de início e conclusão
- CSV deve usar `﻿` BOM + UTF-8

### ⚠️ Ask first
- Aumentar limite de 50 MB → impacto em custos S3 e timeout do worker
- Mudar TTL de 24h → impacto em conformidade de retenção de dados

### 🚫 Never
- Nunca incluir email/CPF/PII sensível no CSV sem mascaramento (LGPD)
- Nunca expor `storageKey` direto na resposta da API (sempre via presigned URL)
- Nunca rodar export síncrono — sempre fila

## 8. Alternativas consideradas

| Opção | Prós | Contras | Veredito |
|-------|------|---------|----------|
| Endpoint síncrono streaming HTTP | Simples; sem fila | Não escala > 1000 linhas; conexão idle | Rejeitado |
| Edge function gerando on-demand | Latência baixa | Custo alto p/ tenants grandes; complexo | Rejeitado |
| BullMQ + S3 (escolhido) | Reaproveita infra; escala | Mais peças móveis | **Escolhido** |
| XLSX nativo via SheetJS | UX melhor (cores) | Bundle pesado; complexidade alta para v1 | Adiar p/ v2 |

## 9. Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Worker trava em tenant grande | média | alto | Timeout de 5min no processor; chunks de 500 linhas |
| Storage cresce sem limpeza | média | médio | Cron diário deletando exports `expiresAt < now()` |
| BOM quebra parser não-Excel | baixa | médio | Documentar no runbook; oferecer opção sem-BOM em backlog |

## 10. Plano de rollout

- [ ] Feature flag: `csv_export_v1` (ativada por tenant)
- [ ] Rollout: 1 tenant piloto → 10 tenants → 100% (1 semana cada)
- [ ] Métricas a monitorar: taxa de sucesso, p95 de tempo de geração, tamanho médio de arquivo
- [ ] Plano de rollback: desligar feature flag (jobs em curso terminam; novos não são aceitos)

## 11. Validation gate (pós-design)

- [x] Cada critério EARS mapeado para componente
- [x] Componentes listados são todos necessários (nada para o futuro)
- [x] Dependências externas validadas (BullMQ, Redis, S3 — todas existentes)
- [x] Plano de rollback concreto (feature flag)
- [x] Boundaries cobrem cenários sensíveis (LGPD, isolamento tenant)

## 12. Links

- Requirements: [requirements.md](./requirements.md)
- ADR criado: `docs/adrs/008-async-export-pattern.md`
- Plano macro: `docs/plans/2026-04-26-issue-9-hr-admin-panel.md`
