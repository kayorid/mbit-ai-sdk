# Phase Playbook — guia detalhado das oito fases

Este playbook complementa o SKILL.md. Use-o quando aplicar uma fase pela primeira vez ou em casos não óbvios. Cada fase tem: **propósito**, **entradas**, **passos**, **saída**, **critério de pronto** e **armadilhas comuns**.

## Fase 1 — Constitution

### Propósito
Estabelecer princípios não negociáveis que sobrevivem a qualquer feature ou mudança de equipe.

### Entradas
- Conhecimento sobre o projeto (stack, mercado, time, processos)
- Documentação existente relevante (CLAUDE.md, docs/architecture.md, README)

### Passos
1. Ler todo o material existente sobre o projeto
2. Identificar os princípios que **não** devem mudar (idioma, stack core, segurança, processos)
3. Escrever em formato de afirmações testáveis (não "valorizar X" — escrever "X é obrigatório em Y")
4. Validar com o time: se alguém objeta, é bom — discuta agora, não no meio da feature

### Saída
`<root>/constitution.md` (template em `assets/templates/constitution.md.tpl`).

### Pronto quando
- Time concorda
- Cobre minimamente: idioma, stack, segurança, processos de qualidade, princípios de produto
- Cabe em uma página de leitura (≤ 200 linhas)

### Armadilhas
- ❌ Lista de "boas práticas" genéricas (motherhood statements) — escreva o que é específico deste projeto
- ❌ Misturar princípio (durável) com decisão técnica (datada) — decisões viram ADRs
- ❌ Esperar perfeição antes de commitar — versão 1 imperfeita é melhor que ausente

## Fase 2 — Specify (WHAT/WHY)

### Propósito
Capturar **o que** precisa ser construído e **por quê**, sem mencionar como.

### Entradas
- Pedido do stakeholder (frase, conversa, ticket)
- Constitution (para alinhar com princípios)

### Passos
1. Criar pasta `_active/YYYY-MM-DD-<slug>/` (use `scripts/init_spec.sh`)
2. Copiar `requirements.md.tpl` para `requirements.md`
3. Preencher seções:
   - **Contexto e problema**: por que isto agora? Qual a dor?
   - **Objetivo de negócio**: métrica que vai mudar (DAU, churn, NPS, custo, prazo)
   - **Personas**: quem usa
   - **User stories**: "Como X, eu quero Y para Z"
   - **Critérios de aceitação em EARS**: comportamentos observáveis (ver `ears-notation.md`)
   - **Fora de escopo**: explícito; o que **não** vai ser feito
4. Marcar todas as ambiguidades com `[CLARIFY]` para a próxima fase

### Saída
`requirements.md` parcialmente preenchido com tags `[CLARIFY]`.

### Pronto quando
- Alguém de produto consegue ler e dizer "sim, é isso"
- Sem menção de tecnologia (Postgres, React, etc.)
- Critérios EARS estão observáveis

### Armadilhas
- ❌ Misturar HOW: "vamos usar Redis para..." → mover para design
- ❌ Métricas vagas ("melhorar UX") — quantifique ou aceite que é qualitativo
- ❌ Pular escopo negativo — "não vai" é tão importante quanto "vai"

## Fase 3 — Clarify

### Propósito
Resolver todos os `[CLARIFY]` e suposições implícitas. **Esta fase é a maior fonte de ROI em SDD** — o tempo gasto aqui economiza dias depois.

### Entradas
- `requirements.md` da fase 2 com tags `[CLARIFY]`

### Passos
1. Listar todas as ambiguidades e suposições — não só as marcadas
2. Para cada uma, formular pergunta concreta com 2-3 opções
3. Apresentar lista para o stakeholder em **um único batch** (não pingar perguntas avulsas)
4. Receber respostas
5. Atualizar `requirements.md` removendo `[CLARIFY]` e incorporando respostas
6. Adicionar seção "Clarifications" no fim do arquivo registrando data, pergunta, resposta

### Saída
`requirements.md` sem `[CLARIFY]` + seção de Clarifications.

### Pronto quando
- Zero `[CLARIFY]` no arquivo
- Você consegue listar todas as suposições explicitamente
- Não resta "depende" sem resolução

### Armadilhas
- ❌ Pular a fase achando que "está claro" — esteve, mas o agente que vai implementar não vai ler sua mente
- ❌ Perguntas binárias sem opções concretas ("o que você acha?") — proponha 2-3 caminhos
- ❌ Aceitar resposta que ainda é ambígua — itere

## Fase 4 — Plan (HOW)

### Propósito
Desenhar a solução técnica que satisfaz `requirements.md`.

### Entradas
- `requirements.md` finalizado
- Constitution
- Conhecimento do código existente (subagentes podem ajudar a mapear)

### Passos
1. Copiar `design.md.tpl` para `design.md`
2. Preencher seções:
   - **Visão geral da solução**: 3-5 parágrafos do que será feito
   - **Arquitetura**: diagrama (texto/mermaid) de componentes
   - **Modelo de dados**: tabelas/entidades novas e alterações
   - **Contratos de API**: endpoints com métodos, payload, resposta
   - **Integrações externas**: serviços, bibliotecas, custos
   - **Alternativas consideradas**: opções rejeitadas + razão
   - **Riscos e mitigações**
   - **Boundaries (Always / Ask first / Never)** desta feature
3. **Validation gate**: depois de pronto, releia perguntando "isto é o mínimo necessário para os critérios EARS, ou estou projetando para o futuro?". Cortar over-engineering aqui é grátis; cortar depois custa retrabalho.

### Saída
`design.md` finalizado.

### Pronto quando
- Cada critério EARS pode ser mapeado para um componente do design
- Não há "como" não respondido para o agente implementar
- Alternativas rejeitadas têm razão registrada (futura referência)

### Armadilhas
- ❌ Escolher tecnologia sem checar versões/compat (`package.json` real do projeto)
- ❌ Plano muito abstrato — agente não vai conseguir transformar em tasks
- ❌ Pular alternativas — o "por que não X?" frequentemente vira pergunta meses depois
- ❌ Over-engineering: componentes "para o futuro" que ninguém pediu

## Fase 5 — Tasks

### Propósito
Quebrar o design em sequência ordenada de tarefas executáveis.

### Entradas
- `design.md` finalizado
- Conhecimento do código (para estimar dependências)

### Passos
1. Copiar `tasks.md.tpl` para `tasks.md`
2. Listar todas as tarefas necessárias para entregar o design
3. Para cada tarefa:
   - Frase imperativa concisa ("Adicionar coluna X em Y", não "Adição de X em Y")
   - Critério de pronto observável (idealmente um teste ou comportamento)
   - Arquivo(s) tocado(s) — se conhecido
   - Tag `[P]` se pode ser feita em paralelo (mesmo arquivo intocado, sem dependência)
   - Tag `[CHECKPOINT]` se exige revisão humana antes de prosseguir
4. Ordenar respeitando dependências (mais fundamental primeiro)
5. Estimar tamanho — cada task ≤ ~4h trabalho. Se passar, quebre em sub-tasks.

### Saída
`tasks.md` com checkboxes.

### Pronto quando
- Cada task tem critério de pronto observável
- Dependências estão visíveis (numeração, indentação, ou notas)
- Ninguém precisa adivinhar para começar

### Armadilhas
- ❌ Tasks vagas ("implementar feature X") — quebrar
- ❌ Critério de pronto = "feito" — circular, sem valor
- ❌ Dependências escondidas — bloqueios surpresa
- ❌ Não marcar paralelizáveis — perde-se tempo executando em série

## Fase 6 — Implement

### Propósito
Escrever código seguindo `tasks.md`, **mantendo a spec como verdade viva**.

### Entradas
- `tasks.md` com checkboxes desmarcados
- `design.md` e `requirements.md` para consultar

### Passos
1. Pegar a próxima task não marcada (respeitando dependências)
2. Atualizar `status.md` (em curso, próximo passo, blockers)
3. Implementar — TDD se possível
4. Marcar task como completa quando o critério de pronto é satisfeito
5. Em `[CHECKPOINT]`, parar e pedir revisão antes de prosseguir
6. Em mudança de rumo (descoberta força ajuste): **atualizar a spec primeiro**, depois código
7. Em conclusão de cada bloco lógico, atualizar `status.md` e commitar

### Saída
- Código implementado
- `tasks.md` com checkboxes marcados
- `status.md` atualizado

### Pronto quando
- Todas as tasks marcadas
- Cada critério EARS tem código que o satisfaz
- Testes passam, build passa

### Armadilhas
- ❌ Implementar sem atualizar status — fica difícil retomar depois
- ❌ Mudar rumo sem atualizar spec — drift começou
- ❌ Pular `[CHECKPOINT]` "porque está fluindo" — checkpoints existem para os momentos onde a fluência leva pra fora do trilho
- ❌ Adicionar features fora de escopo — anote para próxima feature, não enxerte

## Fase 7 — Validate

### Propósito
Provar que o que foi construído satisfaz a spec — não apenas que "passa nos testes".

### Entradas
- Código implementado
- `requirements.md` (critérios EARS)

### Passos
1. Para cada critério EARS, identificar evidência:
   - Teste automatizado (ideal)
   - Screenshot/demo (para UX)
   - Log/output (para comportamento de sistema)
   - Métrica (para performance)
2. Adicionar seção "Validação" no `status.md` com tabela: critério → evidência → status
3. Para qualquer critério sem evidência: ou é gap real (criar task) ou é critério mal escrito (atualizar spec)
4. Rodar `scripts/validate_spec.py` para checagem mecânica
5. Se houver subagentes especializados disponíveis (security, perf, a11y), dispará-los contra os critérios relevantes

### Saída
Tabela de validação no `status.md`.

### Pronto quando
- Cada critério tem evidência
- Gaps identificados viraram tasks
- Validação automatizada passou

### Armadilhas
- ❌ Confundir "testes verdes" com "satisfaz spec" — testes podem testar a coisa errada
- ❌ Pular validação de critérios "óbvios" — frequentemente são onde o bug mora
- ❌ Achar que validação é "depois do code review" — é antes

## Fase 8 — Retrospective

### Propósito
Capturar lições, arquivar a feature, manter o sistema de specs limpo.

### Entradas
- Spec completa em `_active/`
- Memória da implementação (PRs, decisões, surpresas)

### Passos
1. Copiar `retrospective.md.tpl` para a pasta da feature
2. Preencher:
   - **O que funcionou bem**
   - **O que poderia ter sido melhor**
   - **Surpresas** (positivas e negativas)
   - **Decisões que viraram patterns** → propor mover para constitution ou ADR
   - **Métricas finais** (vs. as do `requirements.md`)
3. Adicionar entrada em `HISTORY.md` global
4. Mover pasta de `_active/` para `_completed/`
5. Atualizar `INDEX.md` (use `scripts/update_index.py`)
6. Identificar candidatos a runbook ou documentação permanente — criar tasks separadas para esses

### Saída
- `retrospective.md` na pasta
- Pasta movida para `_completed/`
- `INDEX.md` e `HISTORY.md` atualizados

### Pronto quando
- Feature está em `_completed/`
- INDEX reflete realidade
- Lições reutilizáveis foram propagadas (ADR, constitution, runbook)

### Armadilhas
- ❌ Pular retrospectiva por pressão de próxima feature — perde-se aprendizado
- ❌ Retro genérica ("foi bom") — sem valor; force especificidade
- ❌ Lições que ficam só na retro e não viram regra/runbook — somem em 6 meses
