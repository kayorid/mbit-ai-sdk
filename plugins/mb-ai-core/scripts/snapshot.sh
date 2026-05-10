#!/usr/bin/env bash
# mb-ai-core / scripts / snapshot.sh
# Snapshot reversível de .mb/ e docs/specs/_active/
# Subcomandos: create, list, restore.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(realpath "$0")")")}"
# shellcheck disable=SC1091
source "$PLUGIN_ROOT/lib/colors.sh" 2>/dev/null || true
mb_load_palette 2>/dev/null || true
mb_load_glyphs 2>/dev/null || true

SNAP_DIR=".mb/_snapshots"
mkdir -p "$SNAP_DIR"

SUB="${1:-help}"
shift || true

case "$SUB" in
  create)
    TAG="${1:-}"
    TS=$(date -u +%Y%m%dT%H%M%SZ)
    NAME="snapshot-${TS}${TAG:+-$TAG}.tar.gz"
    OUT="$SNAP_DIR/$NAME"

    TARGETS=()
    [[ -d .mb ]] && TARGETS+=(.mb)
    [[ -d docs/specs/_active ]] && TARGETS+=(docs/specs/_active)

    if [[ ${#TARGETS[@]} -eq 0 ]]; then
      printf "${C_WARN:-}${G_WARN:-⚠}${C_RESET:-} Nada a snapshotar (.mb e docs/specs/_active ausentes)\n"
      exit 0
    fi

    # exclui o próprio diretório de snapshots
    tar --exclude=".mb/_snapshots" -czf "$OUT" "${TARGETS[@]}" 2>/dev/null
    SIZE=$(du -h "$OUT" | cut -f1)
    printf "${C_SUCCESS:-}${G_OK:-✓}${C_RESET:-} Snapshot criado: ${C_BOLD:-}%s${C_RESET:-} (%s)\n" "$NAME" "$SIZE"
    ;;

  list)
    if [[ ! -d "$SNAP_DIR" ]] || [[ -z "$(ls -A "$SNAP_DIR" 2>/dev/null)" ]]; then
      printf "${C_DIM:-}Nenhum snapshot encontrado.${C_RESET:-}\n"
      exit 0
    fi
    printf "${C_PRIMARY:-}${C_BOLD:-}Snapshots disponíveis:${C_RESET:-}\n\n"
    while IFS= read -r f; do
      NAME=$(basename "$f")
      SIZE=$(du -h "$f" | cut -f1)
      DATE=$(echo "$NAME" | grep -Eo '[0-9]{8}T[0-9]{6}Z' | sed 's/T/ /;s/Z//')
      printf "  ${C_INFO:-}%s${C_RESET:-}  ${C_DIM:-}%-7s${C_RESET:-}  %s\n" "$NAME" "$SIZE" "$DATE"
    done < <(ls -1t "$SNAP_DIR" 2>/dev/null)
    ;;

  restore)
    NAME="${1:-}"
    if [[ -z "$NAME" ]]; then
      printf "${C_DANGER:-}${G_FAIL:-✗}${C_RESET:-} Uso: snapshot.sh restore <nome>\n"
      exit 1
    fi
    SRC="$SNAP_DIR/$NAME"
    if [[ ! -f "$SRC" ]]; then
      printf "${C_DANGER:-}${G_FAIL:-✗}${C_RESET:-} Snapshot não encontrado: %s\n" "$SRC"
      exit 1
    fi

    # snapshot do estado atual antes de restaurar (segurança)
    BACKUP_TS=$(date -u +%Y%m%dT%H%M%SZ)
    BACKUP="$SNAP_DIR/pre-restore-${BACKUP_TS}.tar.gz"
    TARGETS=()
    [[ -d .mb ]] && TARGETS+=(.mb)
    [[ -d docs/specs/_active ]] && TARGETS+=(docs/specs/_active)
    if [[ ${#TARGETS[@]} -gt 0 ]]; then
      tar --exclude=".mb/_snapshots" -czf "$BACKUP" "${TARGETS[@]}" 2>/dev/null
      printf "${C_DIM:-}Backup do estado atual em %s${C_RESET:-}\n" "$(basename "$BACKUP")"
    fi

    # restaura
    tar -xzf "$SRC"
    printf "${C_SUCCESS:-}${G_OK:-✓}${C_RESET:-} Restaurado de ${C_BOLD:-}%s${C_RESET:-}\n" "$NAME"
    printf "${C_DIM:-}Backup do estado anterior salvo. Para reverter, restore $(basename "$BACKUP")${C_RESET:-}\n"
    ;;

  help|*)
    cat <<EOF
MB Snapshot — backup reversível de .mb/ e specs ativas

Uso:
  /mb-snapshot create [tag]     Cria snapshot opcional com tag
  /mb-snapshot list             Lista snapshots disponíveis
  /mb-snapshot restore <nome>   Restaura snapshot (faz backup do atual antes)

Snapshots ficam em .mb/_snapshots/ (ignorado em git via .gitignore se desejado).
EOF
    ;;
esac
