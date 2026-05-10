# FAQ — MB AI SDK

## Geral

**P: O que o MB AI SDK *é* exatamente?**
R: Um conjunto de plugins Claude Code que padroniza o processo de desenvolvimento assistido por IA no MB. Não é um framework de runtime, não dita stack — opina sobre **como** se trabalha.

**P: Por que precisamos disso? Não dá pra cada squad usar Claude Code do jeito que quiser?**
R: Dá. Mas sem padrão: práticas inseguras se normalizam (vazamento de segredo, MCPs não-auditados), aprendizado não se consolida (cada time aprende sozinho), auditabilidade fica frágil (problema regulatório), onboarding leva muito mais tempo. O SDK garante o piso.

**P: É obrigatório?**
R: `mb-ai-core` é obrigatório para qualquer squad usando IA em código MB. Os demais são opt-in, mas alguns são exigidos por contexto (ex: `mb-security` se a feature toca ativo crítico).

**P: Quem mantém?**
R: Chapter AI, time corporativo dedicado. Mudanças vêm via PR aberto a qualquer squad — review do Chapter + 2 Champions.

## Instalação e uso

**P: Como instalo?**
R: Veja [`docs/playbooks/install-by-role.md`](playbooks/install-by-role.md). Resumo: configurar marketplace `mb` no `~/.claude/settings.json` e ativar os plugins desejados.

**P: Sou dev solo num squad pequeno, preciso de tudo isso?**
R: Comece com `mb-ai-core` + `mb-sdd`. Adicione outros conforme necessidade.

**P: Posso usar o SDK em projeto pessoal/não-MB?**
R: O SDK é proprietário MB, não disponível externamente. Para uso em projetos pessoais, use o plugin SDD original (open-source) que serviu de base.

## Stack e processo

**P: Meu squad usa stack X (Go/Rust/Swift/etc), vocês não documentaram nada para X.**
R: Por design — o SDK é stack-agnostic. `/mb-bootstrap` gera contexto específico para sua stack. Skills custom do squad cobrem padrões locais.

**P: O ciclo SDD é muito rígido. Não consigo fazer hotfix.**
R: Use `/mb-hotfix` — pula DISCUSS/SPEC, exige post-mortem em 48h.

**P: Quero fazer um spike rápido sem todo o processo.**
R: Use `/mb-spike` — branch descartável, gera só `spike.md`.

**P: Quando o ciclo SDD vai relaxar para meu squad?**
R: Após maturidade demonstrada (3+ ciclos completos sem exceções, 2+ retros com promoção de learning, Champion ativo ≥8 semanas). Aí destrava `/mb-fast` para tarefas pequenas.

## Segurança e compliance

**P: Posso desabilitar um hook que está atrapalhando?**
R: Hooks de SEGURANÇA/COMPLIANCE não. Hooks de PROCESSO/QUALIDADE sim, via `.mb/config.yaml`. Mudança fica registrada e revisada trimestralmente pelo Chapter AI.

**P: O SDK envia dados para fora do MB?**
R: O SDK em si não envia nada. As ferramentas que ele orquestra (Claude Code, MCPs aprovados) seguem suas próprias políticas. MCPs externos passam por avaliação de exfiltração.

**P: Posso usar um MCP novo?**
R: Abra PR adicionando entrada em `under_review` no `mcp-allowlist.json`. Chapter AI avalia (segurança, custo, exfiltração) e decide.

**P: O hook bloqueou meu commit por falso-positivo. O que faço?**
R: Verifique se é falso-positivo mesmo. Se for, abra `/mb-exception` com justificativa — Chapter AI vai criar exceção temporária e considerar refinar o regex.

**P: Estou trabalhando com dados regulados (KYC/AML/PII). Como o SDK ajuda?**
R: Use `mb-security` ativo. `/mb-threat-model` antes do design, `/mb-compliance-check lgpd` (e outras) durante. Hooks de PII bloqueiam vazamento. Audit-log registra acessos sensíveis.

## Custos e performance

**P: Usar o SDK encarece o uso de IA?**
R: Marginalmente sim — mais leitura de constitution, hooks executando. Mas evita custo bem maior: bug em produção, retrabalho por spec mal feita, incidente de segurança. Comparativamente, um ciclo SDD bem rodado é mais barato que um ciclo ad-hoc com retrabalho.

**P: O bootstrap leva muito tempo (60-90min). Vale?**
R: Sim. Sem bootstrap, cada feature do squad gasta tempo redescobrindo contexto. Após bootstrap, contexto é carregado automaticamente.

## Aprendizado e evolução

**P: Tive uma ideia ótima para o SDK. Como contribuo?**
R: Para o squad: implemente como skill custom em `.mb/skills/`. Para o MB todo: `/mb-retro-promote` abre PR ao core.

**P: Quero ver o que outros squads aprenderam.**
R: Veja `.mb/learnings/quarterly-*.md` se publicados, e participe da comunidade mensal de AI Champions.

**P: Como reportar bug no SDK?**
R: Issue no repo `mercadobitcoin/mb-ai-sdk` com label `bug`. P1 (bloqueia trabalho) → também avise no Slack.

## Suporte

**P: Onde peço ajuda?**
R: Em ordem:
1. AI Champion do seu squad.
2. `#mb-ai-sdk` Slack.
3. Chapter AI por email.
4. Issue no repo.

**P: Tem treinamento?**
R: Sim — onboarding de 1h ao instalar, 4h para Tech Leads, 8h para AI Champions. Calendário interno tem datas.
