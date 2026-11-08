#!/usr/bin/env bash
# NOCTHAR DESKTOP - Sistema de Logging
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# Proteção contra source duplo
if [[ -z "${LOG_DIR:-}" ]]; then
    readonly LOG_DIR="$HOME/.config/nocthar/logs"
    readonly LOG_FILE="$LOG_DIR/nocthar_$(date -u +"%Y-%m-%d").log"
fi

init_logging() {
    ensure_dir "$LOG_DIR"
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "# NOCTHAR DESKTOP Log - Criado em $(get_iso_timestamp)" > "$LOG_FILE"
    fi
}

log_event() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(get_iso_timestamp)
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}
