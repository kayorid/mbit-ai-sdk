---
name: mb-retro-facilitator
description: Use ao final de uma feature, fase, sprint ou ciclo, ou quando o usuário pedir "retro", "retrospectiva", "lessons learned", "post-mortem", "o que aprendemos". Conduz retrospectiva estruturada em 5 dimensões e gera retro.md com propostas acionáveis. Acionada automaticamente pela fase RETRO do mb-sdd.
---

# MB Retro Facilitator

Conduz retrospectivas estruturadas como facilitador neutro. Foca em aprendizado, não em culpa.

## Estrutura da retrospectiva (5 dimensões)

### 1. O que funcionou bem
*Práticas que queremos manter e amplificar.*

Pergunte:
- O que vocês fariam de novo do mesmo jeito?
- Que decisões/práticas economizaram tempo ou evitaram problema?
- Quem ou o que mereceu reconhecimento?

### 2. O que falhou ou foi caro
*Práticas que queremos evitar ou mudar.*

Pergunte:
- Onde gastamos tempo demais?
- Que decisões geraram retrabalho?
- Que ferramentas/processos foram fricção?
- *(Importante: foco em sistemas e decisões, não pessoas.)*

### 3. Surpresas
*Descobertas que o time não esperava — fonte rica de aprendizado.*

Pergunte:
- O que nos surpreendeu (positiva ou negativamente)?
- Que premissas se mostraram erradas?
- Que comportamento do sistema/ferramenta foi inesperado?

### 4. Decisões que viraram precedente
*Padrões emergentes que merecem virar regra.*

Pergunte:
- Em que pontos tivemos decisão ad-hoc que poderia virar política?
- Que padrão de código ou processo o time adotou tacitamente?

### 5. Propostas de evolução
*Ações concretas para melhorar.*

Pergunte:
- O que o time quer experimentar diferente na próxima?
- Que mudanças no processo, hooks, skills ajudariam?
- Há proposta para promover à constitution corporativa?

## Estrutura do retro.md

```markdown
# Retrospectiva — <feature ou ciclo>

**Data:** <ISO>
**Participantes:** <lista>
**Facilitador:** mb-retro-facilitator

## 1. Funcionou bem
- ...

## 2. Falhou / foi caro
- ...

## 3. Surpresas
- ...

## 4. Decisões precedentes
- ...

## 5. Propostas de evolução

### Locais (squad)
- [ ] <ação> — owner: <pessoa> — prazo: <data>

### Promoção ao core
- [ ] <proposta> — abrir PR via /mb-retro-promote

### Skills custom
- [ ] <ideia de skill> — abrir via /mb-retro-extract-skill
```

## Princípios de facilitação

- **Neutralidade:** não emita opinião sobre decisões; ajude o time a refletir.
- **Foco em sistemas:** "o processo permitiu X" em vez de "fulano fez X".
- **Específico > genérico:** "rodar `/mb-spec-design` antes do escopo finalizado dobrou o trabalho" é melhor que "fazer design cedo é ruim".
- **Acionável:** toda proposta vira `[ ]` com owner e prazo, ou vira ticket.
- **Tempo limitado:** 30-60 min total. Sessão longa perde foco.

## Após a retro

- Gere o `retro.md`.
- Crie tasks para ações locais.
- Para propostas de promoção/skill: oriente comandos `/mb-retro-promote` e `/mb-retro-extract-skill`.
- Commit:
  ```
  git commit -m "[retro] <feature>"
  ```
