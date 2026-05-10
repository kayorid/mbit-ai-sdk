---
description: Fase SPEC isolada — gera requirements.md em notação EARS sem mencionar stack
argument-hint: <slug-da-feature>
---

# /mb-spec-requirements

Conduza apenas a fase SPEC:

1. Verifique que DISCUSS está aprovada (procure entrada em `approvals.log`).
2. Leia `discuss.md` para entender escopo e premissas.
3. Gere `requirements.md` usando o template em `assets/templates/requirements.md.tpl`.
4. **Critérios em EARS** (ver `references/ears-notation.md`):
   - `Quando <evento>, o sistema deve <resposta>.`
   - `Onde <estado>, o sistema deve <resposta>.`
   - `Enquanto <condição contínua>, o sistema deve <resposta>.`
   - `Se <condição>, então o sistema deve <resposta>.`
5. Cubra: user stories, critérios EARS, edge cases conhecidos, fora de escopo, dependências externas.
6. **Não mencione stack/tecnologia.** Esta fase é WHAT/WHY, não HOW.
7. Peça `/mb-approve SPEC`.

Critério de pronto: produto consegue ler e dizer "é isso".
