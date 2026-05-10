# Guia de instalação por papel

Como instalar e configurar o MB AI SDK conforme seu papel.

---

## 🛡 Chapter AI (responsável pelo SDK)

### O que você precisa fazer uma vez

1. **Manter o repositório `mercadobitcoin/mb-ai-sdk`** no GitHub Enterprise.
2. **Validar instalação local** completa:
   ```bash
   git clone git@github.enterprise.mb:mercadobitcoin/mb-ai-sdk.git
   cd mb-ai-sdk
   ```
3. **Em `~/.claude/settings.json`**:
   ```json
   {
     "extraKnownMarketplaces": {
       "mb": {
         "source": {
           "source": "github",
           "repo": "mercadobitcoin/mb-ai-sdk"
         }
       }
     },
     "enabledPlugins": {
       "mb-ai-core@mb": true,
       "mb-bootstrap@mb": true,
       "mb-sdd@mb": true,
       "mb-review@mb": true,
       "mb-observability@mb": true,
       "mb-security@mb": true,
       "mb-retro@mb": true
     }
   }
   ```
4. **Validar** com `/mb-status` em qualquer repositório de teste.
5. **Configurar permissões** no GitHub Enterprise para PRs ao SDK (label `proposal` requer review do Chapter).

### Suas responsabilidades operacionais

- Aprovar inclusão de novos MCPs (PRs ao `mcp-allowlist.json`).
- Aprovar mudanças à `constitution.md`.
- Conduzir/acompanhar primeiros 3 bootstraps de squads.
- Treinar AI Champions (programa de 8h).
- Manter comunidade mensal de Champions.
- Auditar exceções abertas (`mb-exception` issues).
- Releases do SDK: cadência, changelog, comunicação.

---

## 👨‍💻 Tech Lead (operador do SDK no squad)

### Antes do primeiro uso

1. **Confirme que o Chapter AI já validou o SDK** internamente (versão estável).
2. **Em `~/.claude/settings.json`**: copie o bloco do Chapter AI acima.
3. **Reinicie o Claude Code**.
4. Em qualquer repositório, rode `/mb-status` para confirmar plugins ativos.

### Conduzindo o bootstrap do squad

1. **Agende 60-90min** com squad inteiro + Chapter AI presente (primeira vez).
2. No repositório principal do squad, rode:
   ```
   /mb-bootstrap
   ```
3. Acompanhe a análise automática (5min) — leia o resumo com o squad.
4. Conduza a entrevista (10 perguntas, 20-30min). Squad inteiro contribui; você consolida.
5. Revise os artefatos gerados (`.mb/CLAUDE.md`, `glossary.md`, plano de enriquecimento).
6. Commit inicial (sugerido pelo plugin).

### No dia a dia

- Toda feature não-trivial passa por `/mb-spec`.
- Você é quem aprova fases via `/mb-approve <fase>` (ou delega ao AI Champion).
- Você decide quando abrir `/mb-exception`.
- Após cada feature: `/mb-spec-retro`.
- Trimestralmente: `/mb-retro-quarterly` para consolidar learnings.

### Quando escalar ao Chapter AI

- Hooks bloqueantes gerando fricção excessiva → discutir antes de abrir exceção.
- Necessidade de novo MCP → PR + revisão Chapter.
- Proposta de mudança à constitution → `/mb-retro-promote`.
- Dúvidas regulatórias → Compliance + Chapter AI.

---

## 🌟 AI Champion (referência local do squad)

### Suas responsabilidades

- Manter `.mb/CLAUDE.md` vivo (atualizar após mudanças significativas).
- Conduzir missões de enriquecimento mensais (`/mb-enrich-domain`, `/mb-enrich-runbooks`, `/mb-enrich-skills`).
- Ser ponto de contato para devs do squad em dúvidas sobre o SDK.
- Identificar candidatos a skill custom (`/mb-retro-extract-skill`).
- Promover learnings ao core (`/mb-retro-promote`).
- Participar da comunidade mensal de Champions com Chapter AI.

### Setup técnico

Mesmo do Tech Lead. Adicionalmente:
- Tenha acesso ao repositório `mercadobitcoin/mb-ai-sdk` para abrir PRs com propostas.
- Configure notificações Slack para canal `#mb-ai-sdk`.

### Programa de treinamento

- 8h iniciais (acompanhar Chapter AI em 1-2 bootstraps).
- Comunidade mensal (1h).
- Sessão de revisão semestral com Chapter AI sobre evolução do SDK.

---

## 👤 Dev (consumidor do SDK)

### Setup mínimo

1. Em `~/.claude/settings.json`, ative os plugins (peça o JSON ao Tech Lead/Champion):
   ```json
   {
     "enabledPlugins": {
       "mb-ai-core@mb": true,
       "mb-sdd@mb": true,
       "mb-review@mb": true
     }
   }
   ```
   *(Adicione os demais conforme o squad usa.)*
2. Reinicie o Claude Code.
3. Confirme com `/mb-help`.

### No dia a dia

- Para entender o squad: leia `.mb/CLAUDE.md`.
- Para nova feature: `/mb-spec <slug>`.
- Para review de PR: `/mb-review-pr`.
- Para hotfix: `/mb-hotfix`.
- Para dúvida sobre o SDK: `/mb-help` ou pergunte ao AI Champion.

### Boas práticas

- Sempre referencie spec ativa em mensagens de commit (`[spec:<slug>] <msg>`).
- Não tente desabilitar hooks bloqueantes — abra `/mb-exception` se necessário.
- Contribua para retros: o squad só melhora se vocês falarem.
- Sugira skills custom ao AI Champion quando perceber repetição.

---

## Verificação rápida pós-instalação

Em qualquer repositório, rode:

```
/mb-status
```

Saída esperada (mínimo):

```
MB AI SDK — Status do repositório

Plugins ativos:
  ✓ mb-ai-core@0.1.0
  ✓ mb-sdd@0.1.0
  ...

Bootstrap do squad: ✗ não realizado — rode /mb-bootstrap (apenas TL)

Conformidade:
  ✓ .env não rastreado
  ✓ Hooks de segurança carregados

Próxima ação sugerida: rodar /mb-bootstrap (TL) ou /mb-help (visão geral)
```

Se algo estiver vermelho, pergunte ao AI Champion ou ao Chapter AI.
