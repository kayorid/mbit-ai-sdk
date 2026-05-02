# Constituição — <NOME DO PROJETO>

> Princípios não negociáveis deste projeto. Vivem mais que features individuais. Atualize apenas em mudança estrutural.

**Última revisão**: <YYYY-MM-DD>
**Aprovada por**: <nomes/papéis>

---

## 1. Idioma e ortografia

- Idioma de UI e documentação: <pt-BR | en-US | outro>
- Acentuação obrigatória em pt-BR — sem substituir caracteres acentuados por ASCII
- Termos técnicos consagrados (API, JWT, etc.) ficam no original

## 2. Stack core (não trocar sem ADR)

- Backend: <ex: Node 18 + TypeScript + Express + Prisma + PostgreSQL 15>
- Frontend: <ex: React 18 + Vite + Tailwind + Zustand + TanStack Query>
- Infra: <ex: Docker Compose dev, AWS prod>
- Testes: <ex: Jest backend, Vitest frontend, Playwright E2E>

## 3. Segurança

- Multi-tenant isolation por `tenantId` em toda query (se aplicável)
- Nunca commitar segredos (`.env`, chaves, tokens)
- Nunca usar `--no-verify` ou `--dangerously-skip-permissions`
- Migrações destrutivas exigem aprovação explícita
- Mutations sensíveis registram audit log

## 4. Qualidade

- Type checking limpo é gate de PR (`npm run typecheck`)
- Testes unitários para regras de negócio críticas
- Cobertura de E2E mínima por persona principal
- Lint sem warnings em código novo
- Build sem chunks acima de <X> KB

## 5. Processo

- Commits convencionais (`feat:`, `fix:`, `chore:`, etc.)
- PRs com descrição estruturada (Summary + Test plan)
- Code review obrigatório antes do merge
- Branches feature curtos; rebase preferível a merge commit
- Specs em `docs/specs/` antes de implementação não trivial

## 6. Performance e observabilidade

- p95 de endpoints autenticados abaixo de <X> ms
- Erros não tratados vão para Sentry (FE+BE) com contexto
- Logs estruturados (sem PII em logs)

## 7. UX e acessibilidade

- Padrões do design system internalizado (`docs/design-system.md`)
- Lighthouse a11y mínimo <X> em rotas chave
- Sem modal-sobre-modal; preferir step-based
- Toasts via componente único (sonner ou equivalente)

## 8. Decisões arquiteturais

ADRs vivem em `docs/adrs/NNN-titulo.md`. Toda decisão técnica não óbvia ou que feche caminho vira ADR.

## 9. Definição de pronto (DoD)

Uma feature está pronta apenas quando:

1. Requirements EARS implementados e validados
2. Testes automatizados cobrindo critérios de aceitação
3. Documentação operacional escrita (runbook se aplicável)
4. Code review aprovado
5. Deploy em ambiente de staging (se aplicável) sem regressão
6. Retrospectiva registrada em `_completed/<feature>/retrospective.md`

---

## Anexos vivos

- CLAUDE.md (instruções para agentes IA): <link>
- Architecture overview: <link para `docs/architecture.md`>
- API reference: <link>
- Design system: <link>
