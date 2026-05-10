---
name: mb-bootstrap
description: Use quando o squad está sendo onboardado ao MB AI SDK pela primeira vez, quando é necessário regenerar o contexto após refator significativo, ou quando o usuário pedir para "configurar o squad", "fazer onboarding", "preparar o repo para usar IA", "criar contexto do projeto" ou similar. Conduz fluxo híbrido de três passos (análise automática → entrevista guiada → plano de enriquecimento) e gera estrutura .mb/ completa do squad.
---

# MB Bootstrap

Esta skill conduz o onboarding completo de um squad ao MB AI SDK. Produz contexto rico e específico do squad em três passos sequenciais.

## Pré-requisitos

Antes de iniciar:
1. Verifique `mb-ai-core` está ativo.
2. Verifique que o diretório atual é um repositório git.
3. Se `.mb/` já existe e contém `CLAUDE.md`, pergunte se é re-bootstrap (use `mb-bootstrap-rescan` se for atualização) ou bootstrap inicial.

## Welcome banner

Antes de iniciar a entrevista, mostre o banner de boas-vindas:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/../mb-ai-core/lib/ascii.sh" welcome primary
```

## Passo 1 — Análise automática (5 min)

Execute `${CLAUDE_PLUGIN_ROOT}/skills/mb-bootstrap/scripts/repo-scan.sh` que produz `.mb/bootstrap/analysis.md`.

Se o script não conseguir detectar algo crítico, complemente lendo manualmente:
- `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`, `pom.xml`, `Gemfile`
- `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`
- `Dockerfile`, `docker-compose.yml`, `Makefile`
- Diretórios principais (`src/`, `apps/`, `services/`, `packages/`)

Apresente resumo da análise ao usuário antes de prosseguir.

## Passo 2 — Entrevista guiada (20-30 min)

Conduza as 10 perguntas, **uma por vez**, registrando respostas em `.mb/bootstrap/interview.md`. Use as perguntas exatamente como em `references/interview-questions.md`.

**Regras da entrevista:**
- Uma pergunta por mensagem.
- Após cada resposta, registre em `.mb/bootstrap/interview.md` antes da próxima.
- Se resposta for vaga, faça follow-up dirigido (sem fazer múltiplas perguntas).
- Não interprete demais — capture o que foi dito; interpretação fica para o passo 3.

## Passo 3 — Geração de artefatos

Use os templates em `assets/templates/` para gerar:

1. `.mb/CLAUDE.md` — síntese do contexto principal.
2. `.mb/glossary.md` — jargões da pergunta 9, organizados.
3. `.mb/runbooks/README.md` — esqueleto vazio com instruções.
4. `.mb/skills/README.md` — esqueleto + template para primeira skill.
5. `.mb/hooks/README.md` — esqueleto + template.
6. `.mb/bootstrap/enrichment-plan.md` — 3 missões para próximas 4 semanas baseadas em:
   - Semana 1: runbook do fluxo crítico mais sensível (resposta da pergunta 2).
   - Semana 2-3: aprofundamento de domínio nos conceitos com glossário ainda raso.
   - Semana 4: primeira skill custom para automatizar dor citada na pergunta 8.

7. `.mb/config.yaml` — configuração inicial:
   ```yaml
   version: 0.1.0
   bootstrapped_at: <iso-date>
   maturity_level: novice  # novice | learning | mature
   hooks:
     pre-commit-spec-reference: warn  # vira block após 4 semanas
     pre-pr-create-review-required: warn
   modes_unlocked: []  # /mb-fast etc destravam após maturidade
   ```

## Pós-bootstrap

1. **Mostre o banner celebrativo:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/../mb-ai-core/lib/ascii.sh" bootstrap-done success
   ```
2. Apresente resumo do que foi criado.
3. Sugira commit inicial:
   ```
   git add .mb docs
   git commit -m "[mb-bootstrap] onboarding inicial do squad ao MB AI SDK"
   ```
3. Oriente próxima ação: rodar `/mb-spec` na primeira feature.
4. Lembre da missão da semana 1 do plano de enriquecimento.

## Erros comuns a evitar

- Pular o passo 1 e ir direto à entrevista (perde-se especificidade).
- Fazer várias perguntas por vez (perde-se profundidade).
- Gerar `.mb/CLAUDE.md` genérico sem usar respostas reais da entrevista.
- Esquecer de criar `.mb/bootstrap/enrichment-plan.md` (sem ele, contexto não evolui).
