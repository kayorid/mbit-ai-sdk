---
name: mb-learning-extractor
description: Use para agregar retros de múltiplas features (do squad ou do MB todo) e identificar padrões promovíveis a skills, hooks ou regras de constitution. Acione via /mb-retro-quarterly ou quando o Chapter AI pedir "ver tendências de aprendizado", "consolidar retros", "identificar padrões". Produz relatório executivo e propostas concretas.
---

# MB Learning Extractor

Analisa retros agregadas e extrai padrões para evolução do SDK.

## Como aplicar

### 1. Coletar fontes

- Squad: todos os `retro.md` em `docs/specs/_archive/<período>/*/retro.md`.
- MB-wide: solicitar export consolidado (futuro: dashboard).

### 2. Categorizar achados

Para cada retro, extraia:
- Itens de "funcionou bem" repetidos → padrões positivos.
- Itens de "falhou" repetidos → fragilidades sistêmicas.
- Surpresas convergentes → áreas de risco subestimado.
- Propostas similares → demanda real por mudança.

### 3. Identificar padrões promovíveis

Para cada padrão recorrente (≥3 ocorrências independentes):

- **Promoção a constitution:** se for princípio de comportamento universal.
- **Novo hook:** se for verificação automatizável.
- **Nova skill:** se for processo replicável.
- **Mudança em skill existente:** se for refinamento.

### 4. Produzir relatório

`.mb/learnings/quarterly-<YYYY-Qn>.md`:

```markdown
# Learnings consolidados — <YYYY Qn>

## Fontes
- N retros analisadas
- M squads representados

## Padrões positivos (funcionou bem ≥3x)
- ...

## Fragilidades sistêmicas (falhou ≥3x)
- ...

## Áreas de risco subestimado
- ...

## Propostas de evolução

### Para constitution corporativa
- [ ] <proposta> — abrir PR ao mb-ai-sdk
  - Justificativa: <padrão observado>
  - Squads que se beneficiariam: <lista>

### Para novos hooks
- ...

### Para novas skills
- ...

### Para refinamento de processo
- ...

## Métricas do trimestre
- Total de ciclos SDD completados: N
- Hotfixes: N
- Spikes: N
- Exceções abertas: N
- PRs ao core promovidos: N
- Skills custom criadas: N
```

### 5. Apresentar

- Sugerir abrir PRs concretos para as propostas mais maduras.
- Compartilhar com Chapter AI e AI Champions.
- Material para reunião trimestral de comunidade.

## Princípios

- Padrão precisa ter ≥3 ocorrências para virar proposta (evita reagir a evento isolado).
- Propostas precisam ser específicas e acionáveis.
- Manter rastreabilidade: cada proposta cita as retros de origem.
- Distinguir "problema do squad X" de "problema do MB" — promover só o segundo.
