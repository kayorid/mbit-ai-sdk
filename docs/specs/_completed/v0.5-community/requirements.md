# v0.5 — Comunidade & Workshops

## WHY

v0.3.x estabeleceu a base técnica. v0.5 ativa o **uso humano**: comunidade formal de AI Champions, ritual de retrospectiva trimestral com newsletter automática, leaderboard saudável (foco em diversidade de uso, não competição tóxica), e refinamento dos plugins opt-in com base no que faz sentido como default a longo prazo.

## Stakeholders

- **AI Champions** — usuários avançados que viram referência por squad
- **Tech Leads** — recebem newsletter trimestral consolidada
- **Squads piloto** — fornecem feedback que orienta refinamento

## User stories

- **US-1** Como AI Champion, quero `/mb-leaderboard` que mostre adoção saudável (squads, comandos diversos usados, retros realizadas) sem ranquear pessoas individuais.
- **US-2** Como Tech Lead, quero `/mb-retro-quarterly` que consolide as retros do trimestre e gere uma newsletter pronta para distribuir em formato Markdown + HTML.
- **US-3** Como Chapter AI, quero documentação formal da **comunidade AI Champions** (charter, cadência mensal, RACI, critérios para virar Champion) commitada no repo.
- **US-4** Como mantenedor, quero documentação do **MB AI Lab** (workshop quinzenal hands-on) com 6 trilhas iniciais prontas.
- **US-5** Como squad piloto, quero plugins opt-in (`mb-evals`, `mb-cost`) com docs de uso explícitas e exemplos para decidir se vale ligar.

## Critérios de aceitação (EARS)

- **CA-1** Quando o usuário invocar `/mb-leaderboard`, o sistema **deve** exibir top 5 squads por diversidade de comandos (não por volume), top 5 squads por retros realizadas, e top 5 conquistas mais raras desbloqueadas. **Não deve** mostrar ranking individual de pessoas.
- **CA-2** Quando o usuário invocar `/mb-retro-quarterly`, o sistema **deve** ler todas as retros em `.mb/retros/` dos últimos 90 dias e gerar `docs/newsletter/YYYY-QN.md` + `docs/newsletter/YYYY-QN.html` com seções: highlights, decisões, blockers recorrentes, AI Champions do trimestre.
- **CA-3** Onde houver `docs/governance/ai-champions.md`, o sistema **deve** documentar: critérios de elegibilidade, processo de indicação, cadência de meetings, responsabilidades.
- **CA-4** Onde houver `docs/playbooks/ai-lab.md`, o sistema **deve** descrever 6 trilhas iniciais (mínimo: SDD, observability, security, cost, eval, retro).
- **CA-5** Onde houver `docs/plugins/opt-in-guide.md`, o sistema **deve** comparar `mb-evals` e `mb-cost`: o que ligam, custo de overhead, quando faz sentido.
- **CA-6** Quando `bash tests/smoke/run.sh` for executado, o sistema **deve** validar existência e estrutura mínima dos novos comandos, docs e newsletters geradas.

## Fora de escopo

- Slack bot real (v1.0).
- Integração Jira/Linear (v1.0).
- Bot de leaderboard automático em canal (v1.0).
- Programa de **certificação** AI Champion (v1.0 — diferente de comunidade aberta).

## Boundaries

- ✅ **Always:** leaderboard **agregado por squad**, nunca por pessoa; newsletter gerada offline sem chamadas externas.
- ⚠️ **Ask first:** mudanças em RACI da comunidade (afetam organização).
- 🚫 **Never:** expor PII em leaderboard ou newsletter; consumir dados fora de `.mb/`.

## Clarifications

- **Q:** Newsletter HTML — qual estilo?
  - **R:** HTML mínimo (template embedded), inline CSS, compatível com Gmail/Outlook. Sem JS.
- **Q:** Leaderboard puxa dados de onde?
  - **R:** Dos arquivos `.mb/retros/`, `.mb/achievements.json`, e do `git log` do próprio repo SDK (para contagem de squads via commits `[squad:*]`). Em produção MB seria de telemetria; aqui é mock local.
- **Q:** AI Lab quem facilita?
  - **R:** Charter prevê rotatividade entre Champions; doc inclui template de proposta de sessão.
