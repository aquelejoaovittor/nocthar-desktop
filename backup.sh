#!/usr/bin/env bash
# NOCTHAR DESKTOP - Criador de Backup do Ambiente
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

readonly BACKUP_DIR="$HOME/.local/share/nocthar/backups"
readonly TEMP_BACKUP_DIR="/tmp/nocthar_backup_$$"

create_backup() {
    print_info "Iniciando backup do ambiente MATE..."
    ensure_dir "$BACKUP_DIR"
    ensure_dir "$TEMP_BACKUP_DIR"

    local timestamp
    timestamp=$(date -u +"%Y%m%d_%H%M%S")
    local backup_name="nocthar_backup_${timestamp}"
    local final_tar="$BACKUP_DIR/${backup_name}.tar.gz"

    # 1. Exportar configurações do dconf (MATE, Caja, Marco, Terminal)
    print_info "Exportando configurações do dconf..."
    dconf dump /org/mate/ > "$TEMP_BACKUP_DIR/dconf_mate.ini"
    dconf dump /org/gtk/ > "$TEMP_BACKUP_DIR/dconf_gtk.ini" 2>/dev/null || true

    # 2. Copiar temas e ícones locais (se existirem)
    print_info "Copiando temas e ícones locais..."
    [[ -d "$HOME/.themes" ]] && cp -r "$HOME/.themes" "$TEMP_BACKUP_DIR/" || true
    [[ -d "$HOME/.icons" ]] && cp -r "$HOME/.icons" "$TEMP_BACKUP_DIR/" || true
    
    # 3. Copiar configurações do Terminal
    [[ -d "$HOME/.config/mate-terminal" ]] && cp -r "$HOME/.config/mate-terminal" "$TEMP_BACKUP_DIR/" || true

    # 4. Criar manifesto do backup
    local iso_ts
    iso_ts=$(get_iso_timestamp)
    cat << MANIFEST > "$TEMP_BACKUP_DIR/manifest.json"
{
  "backup_name": "${backup_name}",
  "timestamp": "${iso_ts}",
  "hostname": "$(hostname)",
  "user": "${USER}",
  "components": ["dconf", "themes", "icons", "terminal"]
}
MANIFEST

    # 5. Compactar tudo
    print_info "Compactando backup..."
    tar -czf "$final_tar" -C "$TEMP_BACKUP_DIR" .
    
    # Limpeza
    rm -rf "$TEMP_BACKUP_DIR"
    
    # Calcula o hash para o manifesto global (opcional, mas útil)
    local hash
    hash=$(get_sha256 "$final_tar")
    
    print_ok "Backup criado com sucesso: $final_tar"
    print_info "Hash SHA256: $hash"
    log_event "INFO" "Backup criado: $backup_name (Hash: $hash)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_backup
fi
