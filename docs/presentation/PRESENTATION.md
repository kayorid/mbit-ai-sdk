# Roteiro de Apresentação — MB AI SDK

> Roteiro slide-a-slide para apresentar o MB AI SDK à liderança de Engenharia, Tech Leads e squads piloto. Duração estimada: **30-40 min** (apresentação) + **15-20 min** (Q&A).

**Audiências previstas:**
- 🎯 **Liderança de Engenharia:** foco em risco, governança, ROI, regulatório.
- 🎯 **Tech Leads + AI Champions:** foco em mecânica, dia a dia, autonomia.
- 🎯 **Squads piloto:** foco em "como vai mudar meu trabalho".

Cada slide tem: **Conteúdo visual sugerido** + **Falas-chave** + **Tempo** + **Antecipação de perguntas**.

---

## Slide 1 — Capa (1 min)

**Visual:**
> # MB AI SDK
> ### Harness corporativo de desenvolvimento assistido por IA
> Mercado Bitcoin · Maio 2026 · v0.1.0
>
> *Chapter AI*

**Falas-chave:**
> "Boa tarde. Hoje vou apresentar o MB AI SDK — uma proposta para padronizar como o MB constrói software com IA, garantindo segurança, auditabilidade e velocidade. Em 30 minutos quero responder três perguntas: por que precisamos disso agora, o que é exatamente, e como começamos."

---

## Slide 2 — A janela é agora (3 min)

**Visual:**
- Gráfico/foto: adoção de Claude Code crescendo nos squads.
- 3 ícones grandes: ⚠ Risco, 📉 Inconsistência, 🕳 Aprendizado perdido.

**Falas-chave:**
> "O MB começou a usar IA generativa em desenvolvimento. Cada squad está experimentando do seu jeito. Isso é normal — e é exatamente por isso que precisamos agir agora."
>
> "Sem padrão corporativo, três coisas acontecem nos próximos 6 meses: (1) práticas inseguras se normalizam — alguém vai vazar segredo via prompt, alguém vai usar MCP que exfiltra dados; (2) cada squad reinventa o fluxo, perdemos consistência e auditabilidade; (3) aprendizado fica fragmentado — o time A descobre algo, o time B reinventa."
>
> "A janela atual é estratégica: os primeiros padrões viram cultura. Vamos definir o piso agora."

**Antecipação:**
- *"Não dá pra deixar cada squad escolher?"* → "Para `como` se trabalha com IA, precisamos do piso comum. Para `o quê` construir, autonomia segue."

---

## Slide 3 — As restrições reais do MB (3 min)

**Visual:**
- 4 caixas: Regulação (Bacen, CVM, LGPD), Cripto-específico, Stack heterogênea, Maturidade variável.

**Falas-chave:**
> "Não estamos partindo do zero abstrato. O MB tem restrições reais que tornam ferramentas genéricas insuficientes:"
>
> "**Regulação:** Bacen, CVM e Receita exigem rastreabilidade de mudanças em sistemas críticos. Decisões automatizadas precisam ser explicáveis e auditáveis."
>
> "**Cripto-específico:** custódia, KYC/AML, Travel Rule, integração com blockchains. Superfície de ataque única que ferramentas genéricas não cobrem."
>
> "**Stack heterogênea:** Go, Node, Python, Rust, Java, Next, RN, Swift. Um SDK que dite stack não seria adotado."
>
> "**Maturidade variável:** alguns devs já operam Claude diariamente; outros nunca usaram. Precisamos servir aos dois."

---

## Slide 4 — O que é o MB AI SDK (2 min)

**Visual:**
> ## Não é um framework de código.
> ## É um **framework de processo, governança e contexto**.
>
> Distribuído como plugins Claude Code via marketplace interno.

**Falas-chave:**
> "Importante: o MB AI SDK **não é** uma biblioteca de runtime. Não é um framework no estilo NestJS ou FastAPI. É um harness — define **como** trabalhamos com IA."
>
> "Tecnicamente: 7 plugins do Claude Code, um marketplace interno, e um padrão de pasta `.mb/` no repositório do squad."
>
> "Cada squad consome o que faz sentido para sua realidade. O processo é padronizado; a stack permanece autônoma."

---

## Slide 5 — Os 10 princípios fundadores (3 min)

**Visual:** lista numerada com ícones.

1. Processo > Stack
2. Auditabilidade nativa
3. Rigidez pedagógica
4. Segurança não-negociável
5. Contexto vivo
6. MCPs sob curadoria
7. Verificação antes de claim
8. Reversibilidade preferida
9. Custo de IA é decisão de engenharia
10. Aprendizado coletivo

**Falas-chave:**
> "Esses 10 princípios são a constituição operacional do SDK. Carregados em todo contexto. Inegociáveis."
>
> "Destaco três que costumam gerar conversa:"
>
> "**Rigidez pedagógica:** o ciclo SDD começa rígido. Forçamos disciplina enquanto o time aprende. Após maturidade demonstrada (com critérios objetivos), modos relaxados destravam."
>
> "**Segurança não-negociável:** hooks de segurança e compliance bloqueiam sempre. Sem flag, sem `--force`. Exceções existem, mas via processo formal auditável."
>
> "**Custo de IA é decisão de engenharia:** chamadas a modelos grandes têm custo. O SDK expõe esse custo para decisões conscientes — não escondemos a conta."

---

## Slide 6 — Arquitetura em camadas (3 min)

**Visual:** diagrama de 4 camadas (distribuição, core obrigatório, plugins opt-in, contexto do squad).

**Falas-chave:**
> "A arquitetura tem 4 camadas:"
>
> "**Distribuição:** repositório `mb-ai-sdk` no GitHub Enterprise, exposto como marketplace."
>
> "**Plugin obrigatório:** `mb-ai-core` carrega constitution, hooks bloqueantes de segurança, allowlist de MCPs. Todo squad usando IA carrega isso."
>
> "**Plugins opt-in:** `mb-bootstrap`, `mb-sdd`, `mb-review`, `mb-observability`, `mb-security`, `mb-retro`, `mb-cost`, `mb-evals`. Cada squad escolhe o que faz sentido. Alguns são exigidos por contexto — `mb-security` para qualquer feature tocando ativo crítico, `mb-evals` para features que usam IA em runtime."
>
> "**Contexto do squad:** uma pasta `.mb/` no repo, gerada pelo `mb-bootstrap`, com CLAUDE.md, glossário, runbooks, skills e hooks específicos do squad. Stack-specific — porque o SDK não é."

---

## Slide 7 — Os 9 plugins, em uma página (3 min)

**Visual:** tabela com nome, propósito, status (obrigatório/opt-in).

| Plugin | Propósito | Status |
|--------|-----------|--------|
| **mb-ai-core** | Constitution, hooks, MCPs, achievements, doctor, dashboard | Obrigatório |
| **mb-bootstrap** | Onboarding híbrido do squad | Recomendado |
| **mb-sdd** | Ciclo Spec-Driven rígido com checkpoints | Recomendado |
| **mb-review** | Code/security/spec review formais | Opt-in |
| **mb-observability** | Design e revisão de observabilidade | Opt-in |
| **mb-security** | Threat modeling, compliance, cripto | Obrigatório se ativo crítico |
| **mb-retro** | Retros estruturadas e memória organizacional | Opt-in |
| **mb-cost** | Captura de tokens, custo por fase/feature, alertas de budget | Recomendado |
| **mb-evals** | Eval framework para features que usam IA em runtime | Obrigatório se feature AI |

**Falas-chave:**
> "Nove plugins, cada um com responsabilidade clara. Todos compartilham convenções: prefixo `mb-`, pasta `.mb/`, comandos `/mb-*`, audit trail em `.mb/audit/`. Os dois últimos — mb-cost e mb-evals — endereçam dimensões cruciais: custo de IA é decisão de engenharia, e features que usam IA em runtime exigem framework de avaliação para evitar regressão silenciosa."

---

## Slide 8 — O ciclo SDD que o SDK impõe (4 min)

**Visual:** diagrama do ciclo de 8 fases (DISCUSS → SPEC → PLAN → EXECUTE → VERIFY → REVIEW → SHIP → RETRO) com checkpoints `/mb-approve` em cada.

**Falas-chave:**
> "Toda feature não-trivial passa por 8 fases. Cada fase produz artefato versionado. Cada fase termina com checkpoint humano via `/mb-approve` — registrado no audit trail."
>
> "Por que rígido? Porque o time está aprendendo. Disciplina agora vira intuição depois. E porque cada checkpoint é um ponto de auditoria — em uma exchange, isso não é opcional."
>
> "Modos especiais existem mas continuam disciplinados: **`/mb-hotfix`** para urgências (pula DISCUSS/SPEC mas exige post-mortem em 48h). **`/mb-spike`** para exploração (branch descartável, gera só learning)."
>
> "Quando o squad demonstra maturidade — 3+ ciclos completos sem exceção, retros com promoção de learnings, Champion ativo — destrava `/mb-fast` para tarefas pequenas."

**Antecipação:**
- *"Vai matar minha velocidade?"* → "Curto prazo, freia 10-15%. Médio prazo, acelera por evitar retrabalho. Longo prazo, transforma onboarding (-30%)."

---

## Slide 9 — Bootstrap híbrido em 3 passos (3 min)

**Visual:** 3 caixas grandes com ícones (🤖 análise, 💬 entrevista, 🌱 enriquecimento).

**Falas-chave:**
> "Quando um squad começa a usar o SDK, roda `/mb-bootstrap`. Três passos:"
>
> "**Passo 1 — análise automática (5min, sem humano):** o plugin escaneia o repo. Detecta stack, frameworks, CI, observabilidade, segurança. Gera resumo."
>
> "**Passo 2 — entrevista guiada (20-30min, squad inteiro + Chapter AI):** 10 perguntas estruturadas. Domínio, fluxos críticos, dores, prioridades, jargão, regulação. Não substituível por código — captura o que código não revela."
>
> "**Passo 3 — geração:** combina análise + entrevista. Gera `.mb/CLAUDE.md`, glossário, esqueleto de runbooks, plano de enriquecimento das próximas 4 semanas."
>
> "Resultado: contexto rico do squad, em ~1 hora total."

---

## Slide 10 — Hooks bloqueantes (categorização) (3 min)

**Visual:** 4 categorias com cor (vermelho, laranja, amarelo, verde):
- 🔴 **SEGURANÇA** — bloqueia sempre, sem exceção
- 🟠 **COMPLIANCE** — bloqueia, exceção via processo formal
- 🟡 **PROCESSO** — warn → block após maturidade
- 🟢 **QUALIDADE** — warn-only

**Falas-chave:**
> "Hooks são scripts que rodam antes ou depois de o agente executar uma ação — antes de gravar arquivo, antes de rodar comando, antes de usar MCP."
>
> "Categorizamos em 4 níveis. Esta gradação evita 'fadiga de bloqueio'. Times que ficam bloqueados em tudo desabilitam tudo. Categorizar permite ser rígido onde importa, flexível onde aprende."
>
> "Exemplos: detecção de chave AWS num arquivo é vermelho (sempre bloqueia). Commit sem referência à spec começa amarelo (warn) e vira vermelho após 4 semanas. Sugestão de melhoria de observabilidade é verde (sempre warn)."
>
> "Hooks rodam local **e** em CI via GitHub Actions, garantindo que dev que desabilite localmente seja barrado no PR."

---

## Slide 11 — Audit trail e compliance (3 min)

**Visual:** mapeamento entre regulações (Bacen, CVM, LGPD) → onde no audit MB.

**Falas-chave:**
> "Toda decisão deixa trilha versionada em git. Aprovações de fase, exceções abertas, hook fires, comandos sensíveis — tudo append-only."
>
> "Mapeamento direto para regulações:"
>
> "**Bacen 4.658** (segurança cibernética): rastreabilidade ✓ via git + audit logs. Gestão de incidentes ✓ via runbooks + retros."
>
> "**CVM 35** (custódia): segregação e aprovações ✓ via checkpoints SDD."
>
> "**LGPD**: prevenção de exposição de PII ✓ via hooks. Rastreio ✓ parcial (v2.0 integra SIEM corporativo)."
>
> "Para a próxima auditoria externa, em vez de reconstruir contexto a partir de Slack e memória das pessoas, abrimos a pasta `.mb/audit/` e o histórico do git."

---

## Slide 12 — Governança e papéis (2 min)

**Visual:** diagrama RACI simplificado.

| Papel | Compromisso de tempo |
|-------|----------------------|
| Chapter AI | ~20% FTE dedicado |
| Tech Lead | ~5% do tempo do TL |
| AI Champion | ~10% (1 por squad) |
| Dev | uso no dia a dia |

**Falas-chave:**
> "Quatro papéis. Chapter AI é o time corporativo dedicado. Mantém o SDK, treina champions, audita. Estimamos 20% de FTE dedicado para sustentar."
>
> "Cada squad tem **Tech Lead** (operador) e **AI Champion** (mantém contexto vivo, evangeliza, ponto de contato). Champion não precisa ser TL — pode ser dev sênior interessado."
>
> "**Comunidade mensal de Champions** com Chapter AI dissemina padrões e captura demanda."

---

## Slide 13 — Roadmap (3 min)

**Visual:** linha do tempo com 5 marcos.

| Versão | Janela | Marco |
|--------|--------|-------|
| **v0.1** | Sem 1-3 | Foundation: core + bootstrap + sdd, **1 squad piloto** |
| **v0.5** | Sem 4-8 | Expansão: review + observability + security + retro, **3-5 squads** |
| **v1.0** | Sem 9-13 | Maturidade: destrava modos relaxados, CI integrado |
| **v1.5** | Sem 14-20 | Inteligência: análise agregada, sugestão de skills |
| **v2.0** | Trim 2 | Plataforma corporativa: infra própria, SIEM, dashboard executivo |

**Falas-chave:**
> "Cinco marcos em ~6 meses. Começamos com **um squad piloto** — proposta: alguém com TL engajado, vontade de experimentar e que tenha feature não-trivial entrando."
>
> "v0.5 expande para 3-5 squads. v1.0 já temos maturidade pedagógica."
>
> "v2.0 considera infraestrutura própria — só faz sentido se o ROI estiver demonstrado."

---

## Slide 14 — Métricas de sucesso (2 min)

**Visual:** dashboard mock com 6 métricas-chave.

| Métrica | Meta v1.0 |
|---------|-----------|
| Squads ativos | ≥5 |
| Ciclos SDD por squad/trim | ≥3 |
| Vazamentos de segredo via Claude Code | 0 |
| Tempo de bootstrap | ≤1h |
| Onboarding novo dev | -30% vs baseline |
| Cobertura threat-model em ativo crítico | 100% |

**Falas-chave:**
> "Como sabemos se funciona? Seis métricas-chave. Algumas mensuram adoção, outras qualidade, outras impacto operacional."
>
> "Métrica anti-frágil: número de **bloqueios de segredo** em audit log. Decrescente após semana 4 do squad significa que o time aprendeu — não que o hook está fraco."
>
> "Métrica de impacto: tempo de **onboarding de dev novo**. Hoje: ~2-3 semanas até primeiro PR. Meta com SDK: -30% via `.mb/CLAUDE.md` rico e ciclo SDD que ensina o domínio enquanto entrega."

---

## Slide 15 — Riscos principais e mitigações (3 min)

**Visual:** tabela de top 5 riscos.

| Risco | Mitigação |
|-------|-----------|
| Adoção baixa por overhead | Squad piloto engajado, retro semanal, evidência de tempo economizado |
| Hooks bloqueantes geram fricção | Categorização gradual; canal direto com Chapter AI |
| Vazamento de dados via prompt | MCP allowlist + hooks PII + treinamento |
| Manutenção vira gargalo no Chapter AI | Modelo de PR distribui carga; rotação de revisores |
| Compliance identifica lacuna | Engajar Compliance/Jurídico antes de v1.0 |

**Falas-chave:**
> "Top 5 riscos. Não escondemos."
>
> "O risco real número 1 é adoção. Mitigação: começar com squad engajado, demonstrar valor com evidência (ciclo concluído com qualidade), iterar com retro semanal nas primeiras 4 semanas."
>
> "Risco do hook fricção é real — por isso a categorização gradual. PROCESSO começa warn-only por 4 semanas; só depois vira block."
>
> "Risco de manutenção: distribuímos via PR aberto. Qualquer squad propõe mudança; Chapter AI + 2 Champions revisam. Não sobrecarrega ninguém."

---

## Slide 16 — Investimento e custo (2 min)

**Visual:** divisão de custos.

| Item | Custo aproximado |
|------|------------------|
| Chapter AI (20% FTE × N pessoas) | depende do dimensionamento |
| Treinamento Tech Leads (4h × N TLs) | esforço pontual |
| Treinamento AI Champions (8h × N Champions) | esforço pontual |
| Tokens IA adicionais (overhead do harness) | ~5-10% sobre uso atual |
| Infraestrutura | nenhuma na v0.1 (usa GitHub Enterprise) |

**Falas-chave:**
> "Custo direto: tempo do Chapter AI (20% FTE) + treinamento pontual + ~5-10% extra em tokens IA pelo overhead do harness (constitution, hooks, audit)."
>
> "Sem infra adicional na v0.1 — tudo via GitHub Enterprise existente."
>
> "Custo evitado: vazamento de segredo (~R$ 100k-1M+ por incidente), retrabalho em features mal-especificadas (~30% do tempo de squad sem SDD), incidente regulatório."

---

## Slide 17 — O que precisamos da liderança (2 min)

**Visual:**
> ## Pedidos
> 1. Aprovar começar com 1 squad piloto.
> 2. Indicar Chapter AI dedicado (ou reforçar o existente).
> 3. Endossar publicamente o SDK no próximo all-hands de Engenharia.
> 4. Endossar processo de proposta (PR + review Chapter + Champions).

**Falas-chave:**
> "Para começar precisamos de quatro sinais."
>
> "**Aprovação para piloto:** 1 squad, 4 semanas. Sugestão de critério: TL engajado + feature não-trivial entrando + disposição para retro semanal."
>
> "**Chapter AI dedicado:** 1-2 pessoas com 20% de tempo alocado para sustentar."
>
> "**Endosso público:** all-hands ou comunicado interno mostrando que isso é prioridade corporativa, não experimento de canto."
>
> "**Endosso ao processo:** mudanças via PR aberto a qualquer squad. Garante que o SDK evolui com o time, não imposto top-down."

---

## Slide 18 — Como começamos amanhã (2 min)

**Visual:** próximos 5 passos numerados.

1. Aprovar squad piloto (esta semana).
2. Onboarding do TL piloto (próxima semana).
3. `/mb-bootstrap` do squad (semana +2).
4. Primeira feature pelo ciclo completo (semanas +2-+4).
5. Retro com squad + Chapter AI + ajustes ao SDK (semana +4).

**Falas-chave:**
> "Cinco passos das próximas 4 semanas. Concretos, mensuráveis."
>
> "Em 4 semanas teremos: 1 squad operando, 1 feature concluída pelo ciclo completo, 1 retrospectiva real, e dados para decidir se expandimos para v0.5."

---

## Slide 19 — Q&A / contato (1 min)

**Visual:**
> ## Perguntas?
>
> 📧 chapter-ai@mercadobitcoin.com.br
> 💬 #mb-ai-sdk no Slack
> 📁 mercadobitcoin/mb-ai-sdk no GitHub Enterprise
>
> **Documentos:**
> - Design Completo (40+ páginas)
> - Manual Técnico Detalhado
> - Playbooks por papel
> - FAQ

**Falas-chave:**
> "Obrigado. Estamos abertos a perguntas. Documentação completa nos links — design proposal completo, manual técnico, playbooks por papel, FAQ. Tudo no repositório."

---

## Anexos para Q&A — perguntas mais prováveis e respostas

### "Por que não usamos uma ferramenta pronta de mercado (Cursor, Cody, Copilot Workspace)?"

> "Essas ferramentas são complementares, não substitutas. O SDK roda **em cima** do Claude Code. Mas o que estamos construindo não está no produto pronto: a constitution corporativa, os hooks de PII brasileira, o threat model cripto, o audit trail compatível com Bacen. Usar só ferramenta pronta deixa essas lacunas abertas."

### "E se o Claude Code mudar e quebrar nossos plugins?"

> "Risco real, mitigado por (1) versionamento independente do SDK, (2) smoke tests rodando contra cada release do Claude Code, (3) Chapter AI acompanhando releases. O SDK foi desenhado contra a API estável de plugins/hooks/MCP, não contra internas."

### "Vamos depender de uma única vendor (Anthropic)?"

> "Hoje sim, e essa é uma decisão consciente. O harness é portável conceitualmente — os princípios, os hooks bash, os artefatos versionados, as skills em markdown rodam em outros agentes com adaptação. Mas estamos otimizando para Claude Code agora porque é onde o time está."

### "Quem é dono do código IA gerado? E IP?"

> "O código gerado pelo agente operando dentro do SDK é do MB, mesma política aplicada a código escrito por dev. O SDK não envia código proprietário a sistemas externos não-aprovados — MCPs externos passam por avaliação de exfiltração."

### "Não vai virar burocracia?"

> "Risco real. Mitigamos por: (1) `mb-bootstrap` é única vez por squad; (2) ciclo SDD é proporcional — features triviais usam `/mb-fast` (após maturidade); (3) categorização de hooks evita bloqueio em qualidade; (4) retros mensais ajustam o que está atrapalhando. Burocracia que não se ajusta morre. Nosso compromisso é ajustar."

### "E se o squad piloto fracassar?"

> "Boa pergunta — fracasso ensina. Se o piloto identificar que algo não funciona, ajustamos o SDK antes de expandir. v0.5 só acontece se v0.1 mostrar valor. Estamos jogando iterativo, não big-bang."

### "Quanto tempo de Chapter AI realmente? 20% FTE × N pode crescer."

> "Modelagem: 1 pessoa 50% no Chapter AI cobre v0.1. Para v0.5 com 5 squads, 2 pessoas 50%. Para v1.0 com 10+ squads, 2-3 pessoas dedicadas + comunidade de Champions absorvendo demanda. O modelo de PR distribuído é o que escala."

### "Posso ver o código?"

> "Sim, repositório `mercadobitcoin/mb-ai-sdk` no GitHub Enterprise. Aberto a qualquer dev MB. Inspecionem, abram issue, proponham PR."

---

**Tempo total estimado:**
- Apresentação: 30-40 min (19 slides × ~2 min)
- Q&A: 15-20 min
- Backup para perguntas extras: 10 min

**Materiais a levar:**
- Documento de design completo impresso (3-5 cópias).
- Demo gravado (5min) do `/mb-bootstrap` rodando em repo de teste.
- Lista de TLs candidatos a piloto (para conversa pós-apresentação).
