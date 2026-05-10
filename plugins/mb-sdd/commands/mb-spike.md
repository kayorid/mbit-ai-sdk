---
description: Modo spike — exploração de hipótese com branch descartável; produz aprendizado, não código de produção
argument-hint: <pergunta-a-responder>
---

# /mb-spike

Use quando há incerteza técnica que precisa ser resolvida via experimento antes de planejar a feature. Spikes geram **aprendizado**, não código de produção.

## Comportamento

1. **Validação:**
   - Pergunte: "Qual a pergunta que esse spike vai responder? Qual a hipótese?"
   - Se for "construir feature", redirecione para `/mb-spec`.
2. **Setup:**
   - Crie branch `spike/<slug>` (não pode ir para `main`).
   - Crie `docs/specs/_active/<YYYY-MM-DD>-spike-<slug>/spike.md`.
3. **Estrutura do `spike.md`:**
   - **Pergunta:** o que queremos saber?
   - **Hipótese inicial:** o que achamos que vai acontecer?
   - **Experimento:** o que vamos fazer (passos).
   - **Critério de pronto:** como saberemos que respondemos?
   - **Timebox:** máximo X dias.
   - **Resultado:** preenchido ao fim.
   - **Decisão:** o que fazer com o aprendizado (parar, virar feature `/mb-spec`, mudar abordagem).
4. **Execução:**
   - Implemente o experimento (pode ser código sujo, código que nunca rodaria em prod).
   - Capture observações em `spike.md` conforme avança.
5. **Conclusão:**
   - Preencha "Resultado" e "Decisão" no `spike.md`.
   - **Não merge a branch** — ela morre.
   - Se a decisão for "virar feature", abra `/mb-spec` referenciando o spike.
   - Arquive `spike.md` em `docs/specs/_archive/`.

## Regras

- Spike não pode mergear em `main`/`master`.
- Spike tem timebox obrigatório (max 5 dias).
- Resultado precisa ser registrado mesmo se for "não dá pra fazer assim".
- Hooks de segurança continuam ativos (não comprometer dados reais).
