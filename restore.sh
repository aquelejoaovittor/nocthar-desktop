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
    local selected_backup=""
    
    # Se um argumento for passado (ex: nome do arquivo), usa ele. Senão, mostra o menu.
    if [[ -n "${1:-}" ]]; then
        selected_backup="$1"
        if [[ ! -f "$selected_backup" ]]; then
            print_err "Backup não encontrado: $selected_backup"
            return 1
        fi
    else
        ensure_dir "$BACKUP_DIR"
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
        selected_backup="${backups[$choice]}"
    fi

    print_warn "Restaurando: $(basename "$selected_backup")"
    
    # Backup de segurança rápido antes de restaurar
    print_info "Criando backup de segurança do estado atual..."
    bash "$PROJECT_ROOT/backup.sh" >/dev/null

    # Extração
    print_info "Extraindo backup..."
    ensure_dir "$TEMP_RESTORE_DIR"
    tar -xzf "$selected_backup" -C "$TEMP_RESTORE_DIR"

    if [[ -f "$TEMP_RESTORE_DIR/dconf_mate.ini" ]]; then
        print_info "Restaurando configurações do dconf..."
        dconf load /org/mate/ < "$TEMP_RESTORE_DIR/dconf_mate.ini"
    fi

    if [[ -d "$TEMP_RESTORE_DIR/.themes" ]]; then
        rm -rf "$HOME/.themes"
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
    log_event "INFO" "Backup restaurado: $(basename "$selected_backup")"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    restore_backup "$@"
fi
