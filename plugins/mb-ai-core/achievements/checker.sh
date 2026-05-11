#!/usr/bin/env bash
# mb-ai-core / achievements / checker.sh
# Avalia critérios e atualiza .mb/achievements.json com novos desbloqueios.
# Saída em stdout: lista IDs recém-desbloqueados (um por linha).

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
DEF_FILE="$PLUGIN_ROOT/achievements/definitions.json"
STATE_FILE=".mb/achievements.json"

[[ ! -f "$DEF_FILE" ]] && exit 0

# Inicializa state se não existir
if [[ ! -f "$STATE_FILE" ]]; then
  mkdir -p "$(dirname "$STATE_FILE")"
  echo '{"unlocked": [], "last_evaluated_at": "1970-01-01T00:00:00Z"}' > "$STATE_FILE"
fi

# M-7: cache — só re-avalia a cada 5 min para evitar custo em monorepos
if command -v jq >/dev/null 2>&1; then
  LAST_EVAL=$(jq -r '.last_evaluated_at // "1970-01-01T00:00:00Z"' "$STATE_FILE" 2>/dev/null || echo "1970-01-01T00:00:00Z")
  NOW_EPOCH=$(date +%s)
  LAST_EPOCH=0
  if last_eval_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_EVAL" +%s 2>/dev/null); then
    LAST_EPOCH=$last_eval_epoch
  elif last_eval_epoch=$(date -d "$LAST_EVAL" +%s 2>/dev/null); then
    LAST_EPOCH=$last_eval_epoch
  fi
  AGE=$((NOW_EPOCH - LAST_EPOCH))
  # Force re-eval se MB_FORCE_ACHIEVEMENT_CHECK setado (testes)
  if [[ $AGE -lt 300 && -z "${MB_FORCE_ACHIEVEMENT_CHECK:-}" ]]; then
    exit 0  # cache válido
  fi
  # Atualiza timestamp ao final (mesmo se nada mudou)
  TS_NOW=$(date -u +%FT%TZ)
  TMP=$(mktemp)
  jq --arg ts "$TS_NOW" '.last_evaluated_at = $ts' "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"
fi

# Coleta métricas do squad
metric() {
  local key="$1"
  case "$key" in
    has_claude_md)
      [[ -f .mb/CLAUDE.md ]] && echo 1 || echo 0
      ;;
    archived_specs)
      find docs/specs/_archive -mindepth 2 -maxdepth 3 -type d 2>/dev/null | wc -l | tr -d ' '
      ;;
    blocks_secrets)
      grep -c 'pre-tool-secret-scan.*BLOCKED\|pre-tool-private-key-scan.*BLOCKED\|pre-tool-pii-scan.*BLOCKED' .mb/audit/hook-fires.log .mb/audit/security-events.log 2>/dev/null | awk -F: '{s+=$2} END {print s+0}'
      ;;
    approvals)
      [[ -f .mb/audit/approvals.log ]] && wc -l < .mb/audit/approvals.log | tr -d ' ' || echo 0
      ;;
    exceptions)
      [[ -f .mb/audit/exceptions.log ]] && wc -l < .mb/audit/exceptions.log | tr -d ' ' || echo 0
      ;;
    promoted_learnings)
      # Heurística: PRs com label proposal originados pelo squad — sem API local, contamos retros que mencionam "promote"
      grep -lr 'mb-retro-promote\|promovido ao core\|promote to core' docs/specs/_archive 2>/dev/null | wc -l | tr -d ' '
      ;;
    custom_skills)
      [[ -d .mb/skills ]] && find .mb/skills -mindepth 2 -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ' || echo 0
      ;;
    runbooks)
      [[ -d .mb/runbooks ]] && find .mb/runbooks -name '*.md' -not -name 'README.md' 2>/dev/null | wc -l | tr -d ' ' || echo 0
      ;;
    threat_models)
      find docs/specs -name 'THREAT-MODEL.md' 2>/dev/null | wc -l | tr -d ' '
      ;;
    hotfixes_with_postmortem)
      find docs/specs -path '*hotfix*' -name 'post-mortem.md' 2>/dev/null | wc -l | tr -d ' '
      ;;
    no_blocks_for_days)
      if [[ -f .mb/audit/hook-fires.log ]]; then
        local last=$(grep BLOCKED .mb/audit/hook-fires.log 2>/dev/null | tail -1 | cut -d'|' -f1 | xargs)
        if [[ -z "$last" ]]; then
          echo 999
        else
          # Diff em dias entre hoje e last (best-effort POSIX/macOS)
          local last_epoch now_epoch
          if last_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last" +%s 2>/dev/null); then :
          elif last_epoch=$(date -d "$last" +%s 2>/dev/null); then :
          else last_epoch=0; fi
          now_epoch=$(date +%s)
          echo $(( (now_epoch - last_epoch) / 86400 ))
        fi
      else
        echo 999
      fi
      ;;
    spec_commits)
      git log --oneline 2>/dev/null | grep -c '\[spec:' || echo 0
      ;;
    evals_runs)
      find evals -path '*/runs/*.jsonl' 2>/dev/null | wc -l | tr -d ' '
      ;;
    fast_mode_unlocked)
      [[ -f .mb/config.yaml ]] && grep -q 'modes_unlocked.*fast' .mb/config.yaml 2>/dev/null && echo 1 || echo 0
      ;;
    custom_theme)
      [[ -f .mb/config.yaml ]] && grep -E '^theme:[[:space:]]*(festive|compact|accessible)' .mb/config.yaml 2>/dev/null | head -1 | grep -q . && echo 1 || echo 0
      ;;
    compliance_checks)
      find docs/specs -name 'COMPLIANCE.md' 2>/dev/null | wc -l | tr -d ' '
      ;;
    *)
      echo 0
      ;;
  esac
}

# Avalia critério (DSL minimalista)
check_criteria() {
  local crit="$1"
  case "$crit" in
    "exists:.mb/CLAUDE.md")
      [[ "$(metric has_claude_md)" -eq 1 ]] && return 0 || return 1
      ;;
    "archived_specs>=1")            [[ "$(metric archived_specs)" -ge 1 ]] ;;
    "blocks_secrets>=1")            [[ "$(metric blocks_secrets)" -ge 1 ]] ;;
    "approvals>=5 AND archived_specs>=5")
      [[ "$(metric approvals)" -ge 5 && "$(metric archived_specs)" -ge 5 ]]
      ;;
    "archived_specs>=3 AND exceptions==0 AND promoted_learnings>=2")
      [[ "$(metric archived_specs)" -ge 3 && "$(metric exceptions)" -eq 0 && "$(metric promoted_learnings)" -ge 2 ]]
      ;;
    "promoted_learnings>=1")        [[ "$(metric promoted_learnings)" -ge 1 ]] ;;
    "custom_skills>=1")             [[ "$(metric custom_skills)" -ge 1 ]] ;;
    "runbooks>=5")                  [[ "$(metric runbooks)" -ge 5 ]] ;;
    "threat_models>=3")             [[ "$(metric threat_models)" -ge 3 ]] ;;
    "hotfixes_with_postmortem>=1")  [[ "$(metric hotfixes_with_postmortem)" -ge 1 ]] ;;
    "no_blocks_for_days>=7")        [[ "$(metric no_blocks_for_days)" -ge 7 ]] ;;
    "spec_commits>=100")            [[ "$(metric spec_commits)" -ge 100 ]] ;;
    "evals_runs>=1")                [[ "$(metric evals_runs)" -ge 1 ]] ;;
    "fast_mode_unlocked")           [[ "$(metric fast_mode_unlocked)" -eq 1 ]] ;;
    "custom_theme")                 [[ "$(metric custom_theme)" -eq 1 ]] ;;
    "compliance_checks>=1")         [[ "$(metric compliance_checks)" -ge 1 ]] ;;
    *)
      return 1
      ;;
  esac
}

# Lê desbloqueios atuais
unlocked_now=()
if command -v jq >/dev/null 2>&1; then
  while IFS= read -r id; do unlocked_now+=("$id"); done < <(jq -r '.unlocked[].id // empty' "$STATE_FILE" 2>/dev/null)
fi

# Avalia cada achievement
new_unlocks=()
if command -v jq >/dev/null 2>&1; then
  count=$(jq -r '.achievements | length' "$DEF_FILE")
  for ((i=0; i<count; i++)); do
    id=$(jq -r ".achievements[$i].id" "$DEF_FILE")
    crit=$(jq -r ".achievements[$i].criteria" "$DEF_FILE")
    # já desbloqueado?
    skip=0
    for u in "${unlocked_now[@]}"; do
      [[ "$u" == "$id" ]] && skip=1 && break
    done
    [[ $skip -eq 1 ]] && continue
    # avalia
    if check_criteria "$crit"; then
      new_unlocks+=("$id")
      icon=$(jq -r ".achievements[$i].icon" "$DEF_FILE")
      name=$(jq -r ".achievements[$i].name" "$DEF_FILE")
      ts=$(date -u +%FT%TZ)
      tmp=$(mktemp)
      jq --arg id "$id" --arg ts "$ts" --arg name "$name" --arg icon "$icon" \
        '.unlocked += [{"id": $id, "name": $name, "icon": $icon, "unlocked_at": $ts}]' \
        "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
      echo "$id"
    fi
  done
fi

exit 0
