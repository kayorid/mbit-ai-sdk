# Tasks — Exportação de progresso em CSV

**Linkado a**: [design.md](./design.md)
**Última atualização**: 2026-05-15

---

## Setup

- [x] **T1** — Criar branch `feat/csv-export-progress` a partir de main
  - Critério de pronto: branch criada, build local passa

## Banco de dados

- [x] **T2** — Adicionar modelo `Export` em schema.prisma (`backend/prisma/schema.prisma`) → R1
  - Critério de pronto: `prisma migrate dev` passa, modelo aparece em `npx prisma studio`

## Backend — Worker

- [x] **T3** [P] — Implementar `ProgressExportProcessor` (`backend/src/workers/progress-export.processor.ts`) → R1, R4, R7
  - Critério de pronto: 5 testes unitários verdes (caso feliz, plano Free com limite, plano Pro sem limite, erro de query, timeout)
- [x] **T4** [P] — Adicionar BOM + UTF-8 ao CSV writer (`backend/src/utils/csv.ts`) → R1
  - Critério de pronto: arquivo gerado abre corretamente em Excel pt-BR (teste manual + snapshot do início do arquivo)

## Backend — API

- [x] **T5** — Endpoint `POST /api/v1/exports/progress` (`backend/src/routes/exports.routes.ts`) → R2, R5, R6
  - Critério de pronto: 4 testes de integração — sucesso, 403 sem role, 409 quando há job em andamento, 400 com filtros inválidos
- [x] **T6** [P] — Endpoint `GET /api/v1/exports/:jobId` (`backend/src/routes/exports.routes.ts`)
  - Critério de pronto: retorna status correto + 404 quando jobId não existe ou pertence a outro tenant
- [x] **T7** [P] — Endpoint `GET /api/v1/exports/:jobId/download` → R8
  - Critério de pronto: 302 para presigned URL quando válido, 410 quando expirado

## Backend — Notificações

- [x] **T8** — Integrar `NotificationService` para emitir `export_ready` e `export_failed` (`backend/src/services/notification.service.ts`) → R3, R7
  - Critério de pronto: notificações aparecem no painel do HR Admin com link/mensagem corretos

## Frontend

- [x] **T9** [P] — Componente `<ExportProgressButton />` (`frontend/src/features/hr-admin/exports/ExportProgressButton.tsx`) → R2, R5
  - Critério de pronto: Storybook story renderiza estados (idle, loading, disabled, error)
- [x] **T10** [P] — Hook `useProgressExport` (`frontend/src/features/hr-admin/exports/useProgressExport.ts`)
  - Critério de pronto: 3 testes unitários (start success, status polling, error handling)
- [x] **T11** — Integração download no painel notificações (`frontend/src/features/notifications/NotificationItem.tsx`)
  - Critério de pronto: clicar na notificação dispara `api.fetchAuthed` e o arquivo baixa

## Validação cruzada

- [x] **T12** [CHECKPOINT] — Revisar contratos com PM (Bruno) antes de E2E
  - Critério de pronto: PM confirmou via comentário no PR

## E2E e validation

- [x] **T13** — E2E spec cobrindo R2, R3, R5 (`e2e/personas/hr-admin-export.spec.ts`)
  - Critério de pronto: spec verde local + CI
- [x] **T14** — Validation report no `status.md` (todos critérios EARS R1-R8)
  - Critério de pronto: tabela preenchida com evidência por critério

## Documentação e fechamento

- [x] **T15** — Atualizar runbook HR Admin (`docs/runbooks/hr-admin.md` — seção "Exportações")
- [x] **T16** — Criar ADR 008 (padrão de export assíncrono — pode reaproveitar para futuras exports)
- [x] **T17** [CHECKPOINT] — Code review aprovado
- [x] **T18** — Retrospectiva e arquivamento (mover para `_completed/`)

---

## Notas de execução

- T3 e T4 paralelos — arquivos diferentes, mesmo PR ok.
- T6 e T7 paralelos com T5 — embora mesmo arquivo de rota, T5 cria o arquivo; T6/T7 adicionam handlers independentes.
- T9 e T10 paralelos — feature isolada do front.
- Em T12, **parar** e confirmar contratos antes de E2E (mudar contrato depois é caro).
