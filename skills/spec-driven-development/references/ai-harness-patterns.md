# AI Harness Patterns — práticas anti-drift

Drift é o problema número um em desenvolvimento assistido por IA: a implementação se afasta progressivamente da intenção sem que ninguém perceba até ser tarde. Este documento descreve as práticas que mitigam drift quando você opera com Spec-Driven Development.

## O que é drift, exatamente

**Drift de intenção**: a spec diz uma coisa, o código faz outra. Pode ser:
- **Drift silencioso**: a IA implementou algo "parecido" mas não exatamente o spec — funciona, mas não é o que foi pedido
- **Drift de escopo**: a IA adicionou funcionalidades extra ("você gostaria também de..."), inflando o sistema
- **Drift de qualidade**: a IA tomou atalhos (sem testes, sem error handling em casos importantes) sem flag-ar
- **Drift de stack**: a IA escolheu biblioteca/padrão diferente do projeto sem perguntar

Awareness ≠ adherence: o agente pode **saber** o que a spec pede e mesmo assim divergir. A solução não é mais texto na spec — frequentemente é o oposto.

## Os três pilares anti-drift

### 1. Spec-anchored, não spec-once

A spec é viva. Toda vez que a realidade obriga a divergir do plano, **a spec é atualizada antes do código**. Isto é antitético ao modo "spec-once" (escreve a spec no kickoff, esquece, código vive vida própria).

**Operacionalmente:**
- Antes de mudar comportamento durante implementação → atualizar `requirements.md` ou `design.md`
- Mudança de rumo registrada em `status.md` na seção "Decisões"
- Se mudança grande, considerar ADR

**Sinal de drift começando**: você está prestes a editar código de uma forma que contradiz a spec. **Pare**. Atualize a spec, depois retome o código. Não inverta.

### 2. Boundaries de três níveis

Cada spec define explicitamente:

#### ✅ Always — comportamentos obrigatórios
Restrições positivas que o agente deve garantir. Exemplos:
- "Toda mutation que modifica estado de bloco deve invalidar `block-progress.*` e `collaborator.my-journey`."
- "Toda página exposta a colaborador deve verificar `tenantId` antes de retornar dados."
- "Todo arquivo `.tsx` ou `.ts` novo deve ter type checking limpo (`npm run typecheck`)."

#### ⚠️ Ask first — exige confirmação humana
Ações reversíveis mas significativas. O agente para e pergunta antes de executar.
- "Qualquer migration que altere coluna existente."
- "Qualquer mudança em prefixo de URL pública (afeta SEO/links externos)."
- "Qualquer adição de dependência runtime."

#### 🚫 Never — proibido
Hard stops. Sem exceção.
- "Nunca commitar segredos (.env, chaves)."
- "Nunca usar `--no-verify` ou `--dangerously-skip-permissions`."
- "Nunca rodar destrutivos (drop, truncate, force-push) sem autorização explícita do humano."

Na prática, esta seção fica em `design.md` da feature e/ou na `constitution.md` global. **Boundaries específicas da feature ficam na feature**; boundaries globais ficam na constitution.

### 3. Checkpoints humanos

Pontos onde o agente para e pede revisão. Não é falta de confiança no agente — é prevenção de gasto irrecuperável quando o trilho saiu da pista 30 turnos atrás.

**Checkpoints padrão**:
- Após `clarify`, antes de `plan` — confirmar interpretação
- Após `plan`, antes de `tasks` — auditoria de over-engineering
- Antes de qualquer task `[CHECKPOINT]` (você define no `tasks.md`)
- Antes de operações destrutivas

**Como sinalizar checkpoint** em `tasks.md`:
```markdown
- [ ] [CHECKPOINT] Revisar contratos de API antes de mudanças no frontend
- [ ] [CHECKPOINT] Confirmar migração com humano antes de aplicar em prod
```

**Mesmo quando o usuário diz "siga até o fim"**: a estrutura interna ainda separa fases. Você pode executar várias fases consecutivas em um turno, mas no `status.md` cada fase tem entrada própria — permite auditoria depois.

## Curse of instructions: por que mais texto piora

Há um ponto a partir do qual adicionar instrução **piora** o resultado: o agente ignora seletivamente partes do texto, e quanto mais houver, pior a aderência. Isto é especialmente verdade em modelos com janela longa — o sweet spot está em ~300-500 linhas de instrução de alto sinal, não 2000 de "mais é melhor".

**Sinais de que você passou do ponto:**
- O agente está repetindo o que você acabou de escrever em vez de aplicar
- Erros voltam mesmo após você adicionar nota explícita pedindo que não voltem
- O agente cita partes erradas da instrução para justificar decisões

**O que fazer:**
- Quebrar documentos longos em hierarquia (SKILL.md → references/ → assets/)
- Cortar tudo que é "boa prática genérica" sem traction (motherhood statements)
- Trocar MUSTs/NEVERs por explicações ("isso quebra X porque Y") — IA contemporânea responde melhor a razões que a comandos rígidos
- Promover regras a scripts: se algo é mecanicamente verificável, escrever script é mais robusto que repetir em prosa

## Modularidade: 500 linhas é o limite prático

Se um documento (spec, requirement, design) passa de ~500 linhas, **divida**. Padrões comuns:

- `requirements.md` muito longo → quebrar em `requirements.md` (overview + EARS) + `personas.md` + `non-functional.md`
- `design.md` muito longo → `design.md` (overview) + `data-model.md` + `api-contracts.md` + `integrations.md`
- `tasks.md` muito longo → quebrar feature em sub-features com pastas próprias

A primeira página/arquivo que o agente lê deve dar overview e ponteiros — não o conteúdo todo.

## Frequência de revisão da spec

Durante implementação, o agente deve **reler partes relevantes da spec** em três momentos:
1. **Início de cada nova task** — releia o critério de aceitação dela
2. **Antes de checkpoint** — releia a seção `requirements.md` correspondente
3. **Em sinal de divergência** — releia tudo, decida se é drift (corrigir código) ou descoberta legítima (atualizar spec)

Não confunda "lembrar" com "ler". Janela de contexto pode estar comprimida; releia do disco quando há dúvida.

## Patterns para subagentes

Quando dispara subagentes (especialmente em paralelo), o spec é o que evita explosão combinatória de inconsistências:

- **Brief cada subagente com seções específicas da spec**, não a spec inteira — atenção é cara
- **Cada subagente reporta de volta na linguagem da spec** (cita critérios EARS, não inventa termos)
- **Após paralelo, há merge gate**: reconcilia outputs contra spec antes de aplicar

Para mais sobre subagentes paralelos, veja `superpowers:dispatching-parallel-agents`.

## Quando suspender SDD

SDD tem custo. Há contextos onde o overhead destrói valor:

- **Spike/exploração**: você não sabe ainda o que quer construir. Vá em estilo "rascunho descartável" primeiro, depois transforme em spec quando o caminho for óbvio.
- **Bug pequeno e óbvio**: typo, off-by-one. Não envolva o aparato.
- **Refator interno sem mudança de comportamento**: testes existentes validam; spec atual já cobre.
- **Demo/protótipo descartável**: marque como tal e deixe documentado.

Em todos esses casos, registre uma linha em `status.md` ou `HISTORY.md` explicando que a feature foi feita em modo "fora de SDD" — mantém visibilidade.

## Checklist anti-drift (final de implementação)

Antes de fechar a fase implement, percorra:

- [ ] Cada critério EARS de `requirements.md` tem código que o satisfaz
- [ ] Cada decisão tomada durante implementação está em `status.md` (não só na cabeça)
- [ ] Boundaries Always foram respeitadas (greppe se preciso)
- [ ] Boundaries Ask first foram efetivamente perguntadas
- [ ] Boundaries Never não foram violadas
- [ ] Tudo que mudou de plano está refletido na spec
- [ ] Tasks marcadas batem com o que o código de fato faz
- [ ] Não há TODO órfão sem ticket/issue
- [ ] Validation report (fase 7) cobre 100% dos critérios EARS

Se algum item falhar, **volta a corrigir antes de declarar pronto**. Drift descoberto agora é barato; descoberto em 3 meses é caro.
