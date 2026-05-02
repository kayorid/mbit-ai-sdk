# Requirements — <NOME DA FEATURE>

> WHAT e WHY desta feature. Sem mencionar tecnologia. Critérios em EARS notation.

**Slug**: `<YYYY-MM-DD-slug-da-feature>`
**Início**: <YYYY-MM-DD>
**Stakeholders**: <PM, Tech Lead, Designer, etc.>
**Status**: draft | clarifying | approved | implemented

---

## 1. Contexto e problema

<Por que isto agora? Qual a dor? Quais sinais (métricas, feedback, ticket) levaram a priorizar? Cite fontes quando possível.>

## 2. Objetivo de negócio

<Qual métrica vai mudar? Em quanto? Em que prazo?>

Exemplo: "Reduzir tempo médio de onboarding de 7 para 3 dias até final do trimestre."

## 3. Personas afetadas

| Persona | Como esta feature afeta |
|---------|------------------------|
| <ex: HR Admin> | <ex: passa a configurar templates sem dev> |
| <ex: Colaborador> | <ex: vê jornada na primeira sessão> |

## 4. User stories

- Como <persona>, eu quero <capacidade> para <benefício>.
- Como <persona>, eu quero <capacidade> para <benefício>.

## 5. Critérios de aceitação (EARS)

> Use os 5 padrões: Ubíquo, Estado (`Enquanto`), Evento (`Quando`), Opcional (`Onde`), Indesejado (`Se ... então`). Ver `references/ears-notation.md`.

### Comportamento principal

- **R1**: O <sistema> deve <resposta>.
- **R2**: Quando <gatilho>, o <sistema> deve <resposta>.
- **R3**: Enquanto <estado>, o <sistema> deve <resposta>.

### Comportamento condicional

- **R4**: Onde <feature/condição>, o <sistema> deve <resposta>.

### Comportamento de erro

- **R5**: Se <gatilho indesejado>, então o <sistema> deve <resposta>.
- **R6**: Se <gatilho indesejado>, então o <sistema> deve <resposta>.

## 6. Edge cases conhecidos

- <Caso 1: descrição + comportamento esperado>
- <Caso 2>

## 7. Fora de escopo (explícito)

> O que esta feature **não** vai fazer, mesmo que pareça óbvio incluir.

- <Item 1 + razão de não estar incluído>
- <Item 2>

## 8. Métricas de sucesso

| Métrica | Linha de base atual | Meta pós-feature | Como medir |
|---------|--------------------|--------------------|------------|
| <métrica> | <valor> | <valor> | <fonte/dashboard> |

## 9. Suposições e dependências

- <Dependência externa 1: serviço, equipe, decisão pendente>
- <Suposição que precisa ser confirmada na fase Clarify>

## 10. Tags pendentes de clarificação

> Use `[CLARIFY]` em qualquer trecho com ambiguidade. Resolva todos na fase Clarify antes do design.

Exemplo: "Quando o usuário recebe a notificação, o sistema deve [CLARIFY: enviar push? email? ambos?] dentro de 5 minutos."

---

## 11. Clarifications

> Preenchido na fase Clarify. Cada entrada: data, pergunta, opções consideradas, decisão.

| Data | Pergunta | Opções | Decisão | Razão |
|------|----------|--------|---------|-------|
| <YYYY-MM-DD> | <pergunta> | A, B, C | <decisão> | <razão curta> |

## 12. Links

- Plano macro: <docs/plans/...>
- ADRs relacionados: <docs/adrs/...>
- Tickets/Issues: <links>
- Design (Figma/etc.): <link>
