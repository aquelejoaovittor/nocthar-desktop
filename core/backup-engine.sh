#!/usr/bin/env bash
# NOCTHAR DESKTOP - Motor de Backup e Rollback Transacional
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# Proteção contra source duplo
if [[ -z "${BACKUP_DIR:-}" ]]; then
    readonly BACKUP_DIR="$HOME/.local/share/nocthar/backups"
    readonly STATE_DIR="$HOME/.local/share/nocthar/state"
    readonly STATE_FILE="$STATE_DIR/current_transaction.json"
    readonly MANIFEST_FILE="$HOME/.local/share/nocthar/state/manifest.json"
fi

init_backup_engine() {
    ensure_dir "$BACKUP_DIR"
    ensure_dir "$STATE_DIR"
    init_logging
}

start_transaction() {
    local action_name="$1"
    local timestamp
    timestamp=$(get_iso_timestamp)
    
    jq -n \
       --arg action "$action_name" \
       --arg ts "$timestamp" \
       '{status: "running", action: $action, start_time: $ts, components: []}' > "$STATE_FILE"
       
    trap 'handle_rollback' INT TERM ERR
    log_event "INFO" "Transação iniciada: $action_name"
}

commit_transaction() {
    trap - INT TERM ERR
    jq '.status = "completed" | .end_time = $ts' --arg ts "$(get_iso_timestamp)" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
    rm -f "$STATE_FILE" 
    log_event "INFO" "Transação concluída com sucesso."
}

handle_rollback() {
    local exit_code=$?
    trap - INT TERM ERR 
    
    print_err "Falha detectada (Código $exit_code). Iniciando rollback transacional..."
    log_event "ERROR" "Falha detectada. Iniciando rollback."
    
    if [[ -f "$STATE_FILE" ]]; then
        local action
        action=$(jq -r '.action' "$STATE_FILE")
        print_info "Revertendo operação: $action"
    fi
    
    rm -f "$STATE_FILE"
    exit $exit_code
}

register_file_ownership() {
    local file_path="$1"
    local origin="$2"
    local hash
    hash=$(get_sha256 "$file_path")
    
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        echo '{"files": []}' > "$MANIFEST_FILE"
    fi
    
    jq --arg path "$file_path" \
       --arg hash "$hash" \
       --arg origin "$origin" \
       --arg ts "$(get_iso_timestamp)" \
       '.files += [{"path": $path, "hash": $hash, "origin": $origin, "installed_at": $ts}] | .files |= unique_by(.path)' \
       "$MANIFEST_FILE" > tmp_manifest.json && mv tmp_manifest.json "$MANIFEST_FILE"
}
