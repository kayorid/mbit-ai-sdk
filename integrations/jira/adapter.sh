#!/usr/bin/env bash
# integrations/jira/adapter.sh
# Lê metadados de um ticket Jira e emite JSON normalizado.
# Modos:
#   MB_MOCK_JIRA=1 — lê de mock-fixtures/<KEY>.json
#   real          — usa JIRA_BASE_URL + JIRA_USER + JIRA_TOKEN
# Uso: adapter.sh JIRA-1234

set -uo pipefail

KEY="${1:-}"
if [[ -z "$KEY" ]]; then
  echo "uso: adapter.sh <JIRA-KEY>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${MB_MOCK_JIRA:-}" == "1" ]]; then
  FIX="$SCRIPT_DIR/mock-fixtures/${KEY}.json"
  if [[ ! -f "$FIX" ]]; then
    # Fallback para fixture genérica
    FIX="$SCRIPT_DIR/mock-fixtures/JIRA-DEMO.json"
  fi
  cat "$FIX"
  exit 0
fi

: "${JIRA_BASE_URL:?defina JIRA_BASE_URL}"
: "${JIRA_USER:?defina JIRA_USER}"
: "${JIRA_TOKEN:?defina JIRA_TOKEN}"

API_PATH="rest/api/3/issue/$KEY"
[[ "${JIRA_LEGACY:-0}" == "1" ]] && API_PATH="rest/api/2/issue/$KEY"

RAW=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" "$JIRA_BASE_URL/$API_PATH")

# Normaliza
echo "$RAW" | jq '{
  key: .key,
  title: .fields.summary,
  description: (.fields.description // "" | tostring),
  status: .fields.status.name,
  reporter: .fields.reporter.displayName,
  type: .fields.issuetype.name,
  labels: .fields.labels,
  url: ("'"$JIRA_BASE_URL"'/browse/" + .key)
}'
