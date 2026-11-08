#!/usr/bin/env bash
# NOCTHAR DESKTOP - Instalador de Cursores
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"
source "$PROJECT_ROOT/core/backup-engine.sh"

readonly ICONS_DIR="$HOME/.icons"
readonly TEMP_DIR="$HOME/.local/share/nocthar/cache"

install_bibata_cursor() {
    local target_theme="Bibata-Modern-Ice"
    local install_path="$ICONS_DIR/$target_theme"
    
    print_info "Verificando cursor: $target_theme"
    
    if [[ -d "$install_path" ]]; then
        print_ok "O cursor $target_theme já está instalado."
        return 0
    fi

    print_info "Baixando o cursor $target_theme..."
    ensure_dir "$TEMP_DIR"
    ensure_dir "$ICONS_DIR"
    
    # Link oficial do repositório do Bibata
    local download_url="https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.6/Bibata-Modern-Ice.tar.xz"
    local tar_file="$TEMP_DIR/bibata.tar.xz"
    
    if ! wget -q --show-progress -O "$tar_file" "$download_url"; then
        print_err "Falha ao baixar o cursor."
        return 1
    fi
    
    print_info "Extraindo cursor..."
    mkdir -p "$install_path"
    tar -xf "$tar_file" -C "$install_path"
    
    register_file_ownership "$install_path" "Bibata-Cursor"
    rm -f "$tar_file"
    
    print_ok "Cursor instalado com sucesso!"
    log_event "INFO" "Cursor Bibata instalado em $install_path"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_backup_engine
    install_bibata_cursor
fi
