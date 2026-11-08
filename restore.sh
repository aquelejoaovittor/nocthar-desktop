#!/usr/bin/env bash
# NOCTHAR DESKTOP - Restaurador de Ambiente
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

readonly BACKUP_DIR="$HOME/.local/share/nocthar/backups"
readonly TEMP_RESTORE_DIR="/tmp/nocthar_restore_$$"

restore_backup() {
    ensure_dir "$BACKUP_DIR"
    
    # Lista backups disponíveis
    local backups=("$BACKUP_DIR"/nocthar_backup_*.tar.gz)
    
    if [[ ! -e "${backups[0]}" ]]; then
        print_warn "Nenhum backup encontrado em $BACKUP_DIR"
        return 1
    fi

    echo -e "\n${C_INFO}Backups disponíveis:${C_RESET}"
    for i in "${!backups[@]}"; do
        echo "  [$i] $(basename "${backups[$i]}" .tar.gz)"
    done

    local choice
    read -r -p "Escolha o número do backup para restaurar: " choice

    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -ge "${#backups[@]}" ]]; then
        print_err "Opção inválida."
        return 1
    fi

    local selected_backup="${backups[$choice]}"
    print_warn "Você está prestes a sobrescrever suas configurações atuais com o backup:"
    print_warn "$(basename "$selected_backup")"
    
    if ! confirm_action "Deseja continuar?"; then
        print_info "Restauração cancelada."
        return 0
    fi

    # Backup de segurança rápido antes de restaurar
    print_info "Criando backup de segurança do estado atual..."
    bash "$PROJECT_ROOT/backup.sh" >/dev/null

    # Extração
    print_info "Extraindo backup..."
    ensure_dir "$TEMP_RESTORE_DIR"
    tar -xzf "$selected_backup" -C "$TEMP_RESTORE_DIR"

    # Restaurando dconf
    if [[ -f "$TEMP_RESTORE_DIR/dconf_mate.ini" ]]; then
        print_info "Restaurando configurações do dconf..."
        dconf load /org/mate/ < "$TEMP_RESTORE_DIR/dconf_mate.ini"
    fi

    # Restaurando pastas
    if [[ -d "$TEMP_RESTORE_DIR/.themes" ]]; then
        rm -rf "$HOME/.themes" # Cuidado: pedimos confirmação acima
        cp -r "$TEMP_RESTORE_DIR/.themes" "$HOME/"
    fi
    if [[ -d "$TEMP_RESTORE_DIR/.icons" ]]; then
        rm -rf "$HOME/.icons"
        cp -r "$TEMP_RESTORE_DIR/.icons" "$HOME/"
    fi
    if [[ -d "$TEMP_RESTORE_DIR/mate-terminal" ]]; then
        rm -rf "$HOME/.config/mate-terminal"
        cp -r "$TEMP_RESTORE_DIR/mate-terminal" "$HOME/.config/"
    fi

    rm -rf "$TEMP_RESTORE_DIR"
    
    print_ok "Restauração concluída com sucesso!"
    print_info "Pode ser necessário reiniciar a sessão (logout/login) para que todas as mudanças visuais apareçam."
    log_event "INFO" "Backup restaurado: $(basename "$selected_backup")"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    restore_backup
fi
