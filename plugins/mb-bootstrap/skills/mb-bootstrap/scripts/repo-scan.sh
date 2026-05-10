#!/usr/bin/env bash
# mb-bootstrap / repo-scan
# Análise automática do repositório — gera .mb/bootstrap/analysis.md
set -euo pipefail

OUT_DIR=".mb/bootstrap"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/analysis.md"

scan_languages() {
  local langs=()
  [[ -f go.mod || -n "$(find . -maxdepth 3 -name 'go.mod' -print -quit 2>/dev/null)" ]] && langs+=("Go")
  [[ -f package.json || -n "$(find . -maxdepth 3 -name 'package.json' -not -path '*/node_modules/*' -print -quit 2>/dev/null)" ]] && langs+=("Node.js/TypeScript")
  [[ -f pyproject.toml || -f setup.py || -f requirements.txt ]] && langs+=("Python")
  [[ -f Cargo.toml ]] && langs+=("Rust")
  [[ -f pom.xml || -f build.gradle || -f build.gradle.kts ]] && langs+=("Java/Kotlin")
  [[ -f Gemfile ]] && langs+=("Ruby")
  [[ -n "$(find . -maxdepth 3 -name '*.swift' -print -quit 2>/dev/null)" ]] && langs+=("Swift")
  [[ ${#langs[@]} -eq 0 ]] && echo "_(nenhuma linguagem dominante detectada)_" || printf -- "- %s\n" "${langs[@]}"
}

scan_frameworks() {
  local fw=()
  if [[ -f package.json ]]; then
    grep -q '"next"' package.json 2>/dev/null && fw+=("Next.js")
    grep -q '"react"' package.json 2>/dev/null && fw+=("React")
    grep -q '"react-native"' package.json 2>/dev/null && fw+=("React Native")
    grep -q '"express"' package.json 2>/dev/null && fw+=("Express")
    grep -q '"@nestjs/core"' package.json 2>/dev/null && fw+=("NestJS")
    grep -q '"fastify"' package.json 2>/dev/null && fw+=("Fastify")
  fi
  if [[ -f go.mod ]]; then
    grep -q 'gin-gonic/gin' go.mod 2>/dev/null && fw+=("Gin")
    grep -q 'gofiber/fiber' go.mod 2>/dev/null && fw+=("Fiber")
    grep -q 'labstack/echo' go.mod 2>/dev/null && fw+=("Echo")
  fi
  if [[ -f pyproject.toml || -f requirements.txt ]]; then
    grep -q 'fastapi' pyproject.toml requirements.txt 2>/dev/null && fw+=("FastAPI")
    grep -q 'django' pyproject.toml requirements.txt 2>/dev/null && fw+=("Django")
    grep -q 'flask' pyproject.toml requirements.txt 2>/dev/null && fw+=("Flask")
  fi
  [[ ${#fw[@]} -eq 0 ]] && echo "_(nenhum framework dominante detectado)_" || printf -- "- %s\n" "${fw[@]}"
}

scan_structure() {
  local notes=()
  [[ -d apps && -d packages ]] && notes+=("Monorepo (apps/ + packages/) — possivelmente Turborepo/Nx/pnpm workspaces")
  [[ -d services ]] && notes+=("Diretório services/ presente — provável arquitetura multi-serviço")
  [[ -f turbo.json ]] && notes+=("Turborepo detectado")
  [[ -f nx.json ]] && notes+=("Nx detectado")
  [[ -f pnpm-workspace.yaml ]] && notes+=("pnpm workspaces")
  [[ -f lerna.json ]] && notes+=("Lerna")
  [[ ${#notes[@]} -eq 0 ]] && echo "_(estrutura padrão de single-package)_" || printf -- "- %s\n" "${notes[@]}"
}

scan_ci() {
  local ci=()
  [[ -d .github/workflows ]] && ci+=("GitHub Actions ($(ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | wc -l | tr -d ' ') workflows)")
  [[ -f .gitlab-ci.yml ]] && ci+=("GitLab CI")
  [[ -f .circleci/config.yml ]] && ci+=("CircleCI")
  [[ -f Jenkinsfile ]] && ci+=("Jenkins")
  [[ ${#ci[@]} -eq 0 ]] && echo "_(nenhum CI detectado)_" || printf -- "- %s\n" "${ci[@]}"
}

scan_iac() {
  local iac=()
  [[ -n "$(find . -maxdepth 4 -name '*.tf' -print -quit 2>/dev/null)" ]] && iac+=("Terraform")
  [[ -n "$(find . -maxdepth 4 -name 'Pulumi.yaml' -print -quit 2>/dev/null)" ]] && iac+=("Pulumi")
  [[ -d helm || -n "$(find . -maxdepth 4 -name 'Chart.yaml' -print -quit 2>/dev/null)" ]] && iac+=("Helm")
  [[ -n "$(find . -maxdepth 4 -name 'kustomization.yaml' -print -quit 2>/dev/null)" ]] && iac+=("Kustomize")
  [[ -f Dockerfile ]] && iac+=("Docker")
  [[ -f docker-compose.yml || -f docker-compose.yaml ]] && iac+=("Docker Compose")
  [[ ${#iac[@]} -eq 0 ]] && echo "_(nenhum IaC detectado)_" || printf -- "- %s\n" "${iac[@]}"
}

scan_observability() {
  local obs=()
  grep -rqE '(opentelemetry|otel)' --include='*.json' --include='*.toml' --include='*.mod' . 2>/dev/null && obs+=("OpenTelemetry")
  grep -rq 'datadog' --include='*.json' --include='*.toml' --include='*.mod' . 2>/dev/null && obs+=("Datadog")
  grep -rq 'newrelic' --include='*.json' --include='*.toml' --include='*.mod' . 2>/dev/null && obs+=("New Relic")
  grep -rq 'sentry' --include='*.json' --include='*.toml' --include='*.mod' . 2>/dev/null && obs+=("Sentry")
  grep -rq 'prometheus' --include='*.json' --include='*.toml' --include='*.mod' . 2>/dev/null && obs+=("Prometheus")
  [[ ${#obs[@]} -eq 0 ]] && echo "_(nenhuma lib de observabilidade detectada)_" || printf -- "- %s\n" "${obs[@]}"
}

scan_security() {
  local sec=()
  [[ -f .gitleaks.toml || -f .gitleaks.yaml ]] && sec+=("gitleaks configurado")
  [[ -f .pre-commit-config.yaml ]] && sec+=("pre-commit hooks")
  [[ -f .github/dependabot.yml || -f .github/dependabot.yaml ]] && sec+=("Dependabot")
  [[ -f .snyk ]] && sec+=("Snyk")
  [[ ${#sec[@]} -eq 0 ]] && echo "_(nenhuma ferramenta de segurança detectada)_" || printf -- "- %s\n" "${sec[@]}"
}

scan_tests() {
  local tests=()
  [[ -f vitest.config.ts || -f vitest.config.js ]] && tests+=("Vitest")
  [[ -f jest.config.js || -f jest.config.ts ]] && tests+=("Jest")
  [[ -f pytest.ini || -f pyproject.toml ]] && grep -q '\[tool.pytest' pyproject.toml 2>/dev/null && tests+=("pytest")
  [[ -d cypress ]] && tests+=("Cypress")
  [[ -d playwright || -f playwright.config.ts ]] && tests+=("Playwright")
  [[ -n "$(find . -maxdepth 4 -name '*_test.go' -print -quit 2>/dev/null)" ]] && tests+=("go test")
  [[ ${#tests[@]} -eq 0 ]] && echo "_(nenhum framework de teste detectado)_" || printf -- "- %s\n" "${tests[@]}"
}

REPO_NAME=$(basename "$(pwd)")
COMMITS=$(git log --oneline 2>/dev/null | wc -l | tr -d ' ' || echo 0)
CONTRIBUTORS=$(git shortlog -sn 2>/dev/null | wc -l | tr -d ' ' || echo 0)
LAST_COMMIT=$(git log -1 --format='%cd' --date=short 2>/dev/null || echo "n/a")
DEFAULT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "n/a")

cat > "$OUT" <<EOF
# Análise automática do repositório

**Repositório:** \`$REPO_NAME\`
**Branch atual:** \`$DEFAULT_BRANCH\`
**Commits no histórico:** $COMMITS
**Contribuidores únicos:** $CONTRIBUTORS
**Último commit:** $LAST_COMMIT
**Análise gerada em:** $(date -u +%FT%TZ)

---

## Linguagens detectadas
$(scan_languages)

## Frameworks detectados
$(scan_frameworks)

## Estrutura do repositório
$(scan_structure)

## CI/CD
$(scan_ci)

## Infraestrutura como código
$(scan_iac)

## Observabilidade
$(scan_observability)

## Testes
$(scan_tests)

## Segurança
$(scan_security)

---

## Próximo passo

Esta análise é o ponto de partida. Conduza a entrevista guiada (10 perguntas) para capturar contexto que código não revela: domínio, dores, prioridades, stakeholders, jargão.

Após a entrevista, gere \`.mb/CLAUDE.md\` combinando esta análise com as respostas humanas.
EOF

echo "✓ Análise salva em $OUT"
