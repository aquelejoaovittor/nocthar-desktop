#!/usr/bin/env bash
# NOCTHAR DESKTOP - Instalador de Ícones
set -Eeuo pipefail

# Resolve o caminho base do projeto independente de onde for chamado
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"
source "$PROJECT_ROOT/core/backup-engine.sh"

readonly ICONS_DIR="$HOME/.icons"
readonly TEMP_DIR="$HOME/.local/share/nocthar/cache"

install_papirus_icons() {
    local target_theme="Papirus-Dark"
    local install_path="$ICONS_DIR/Papirus"
    
    print_info "Verificando tema de ícones: $target_theme"
    
    # Se o tema já existe, não fazemos nada (Idempotência)
    if [[ -d "$install_path" ]]; then
        print_ok "O tema $target_theme já está instalado em $install_path"
        return 0
    fi

    print_info "Baixando o tema $target_theme..."
    ensure_dir "$TEMP_DIR"
    ensure_dir "$ICONS_DIR"
    
    local download_url="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/heads/master.tar.gz"
    local tar_file="$TEMP_DIR/papirus.tar.gz"
    
    if ! wget -q --show-progress -O "$tar_file" "$download_url"; then
        print_err "Falha ao baixar o tema de ícones."
        return 1
    fi
    
    # Verifica se o arquivo baixado é válido
    if ! tar -tzf "$tar_file" >/dev/null 2>&1; then
        print_err "O arquivo baixado está corrompido."
        rm -f "$tar_file"
        return 1
    fi
    
    print_info "Extraindo tema para $ICONS_DIR..."
    tar -xzf "$tar_file" -C "$TEMP_DIR"
    
    # Move a pasta extraída para o local correto
    mv "$TEMP_DIR/papirus-icon-theme-master" "$install_path"
    
    # Atualiza o cache de ícones do sistema
    print_info "Atualizando o cache de ícones..."
    gtk-update-icon-cache -f -t "$install_path" >/dev/null 2>&1 || true
    
    # Registra no manifesto do NOCTHAR
    register_file_ownership "$install_path" "Papirus-Icon-Theme"
    
    # Limpa o cache
    rm -f "$tar_file"
    
    print_ok "Tema de ícones instalado com sucesso!"
    log_event "INFO" "Tema de ícones Papirus instalado em $install_path"
}

# Ponto de entrada CLI
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_backup_engine
    install_papirus_icons
fi
