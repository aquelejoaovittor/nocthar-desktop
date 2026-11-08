#!/usr/bin/env bash
# NOCTHAR DESKTOP - Orquestrador de Perfis
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/validation.sh"
source "$PROJECT_ROOT/core/backup-engine.sh"
source "$PROJECT_ROOT/core/logging.sh"

apply_profile() {
    local profile_path="$1"
    
    if ! validate_profile "$profile_path"; then
        print_err "Perfil inválido. Abortando."
        return 1
    fi
    
    local profile_name
    profile_name=$(jq -r '.profile_name' "$profile_path")
    print_info "Iniciando aplicação do perfil: $profile_name"
    
    init_backup_engine
    start_transaction "apply_profile_$profile_name"
    
    # 1. Fontes
    local font_interface
    font_interface=$(jq -r '.components.fonts.interface // empty' "$profile_path")
    if [[ -n "$font_interface" ]]; then
        if ! fc-list : family | grep -qi "Inter"; then
            bash "$PROJECT_ROOT/desktop/configure-fonts.sh" || handle_rollback
        fi
        gsettings set org.mate.interface font-name "$font_interface" || handle_rollback
    fi

    # 2. Ícones
    local icon_theme
    icon_theme=$(jq -r '.components.icons.theme // empty' "$profile_path")
    if [[ -n "$icon_theme" ]]; then
        if [[ ! -d "$HOME/.icons/$icon_theme" && ! -d "/usr/share/icons/$icon_theme" ]]; then
            if [[ "$icon_theme" == "Papirus-Dark" ]]; then
                bash "$PROJECT_ROOT/themes/install-icons.sh" || handle_rollback
            fi
        fi
        gsettings set org.mate.interface icon-theme "$icon_theme" || handle_rollback
    fi
    
    # 3. Cursores
    local cursor_theme
    cursor_theme=$(jq -r '.components.cursors.theme // empty' "$profile_path")
    if [[ -n "$cursor_theme" ]]; then
        if [[ ! -d "$HOME/.icons/$cursor_theme" && ! -d "/usr/share/icons/$cursor_theme" ]]; then
            if [[ "$cursor_theme" == "Bibata-Modern-Ice" ]]; then
                bash "$PROJECT_ROOT/themes/install-cursors.sh" || handle_rollback
            fi
        fi
        gsettings set org.mate.peripherals-mouse cursor-theme "$cursor_theme" || handle_rollback
    fi

    # 4. Tema GTK
    local gtk_theme
    gtk_theme=$(jq -r '.components.gtk.theme // empty' "$profile_path")
    if [[ -n "$gtk_theme" ]]; then
        gsettings set org.mate.interface gtk-theme "$gtk_theme" || handle_rollback
    fi
    
    # 5. Terminal (Lendo as cores do JSON)
    if jq -e '.components.terminal' "$profile_path" >/dev/null; then
        local term_bg term_fg term_cursor
        term_bg=$(jq -r '.components.terminal.bg_color // "rgb(9,11,16)"' "$profile_path")
        term_fg=$(jq -r '.components.terminal.fg_color // "rgb(195,203,213)"' "$profile_path")
        term_cursor=$(jq -r '.components.terminal.cursor_color // "rgb(0,210,255)"' "$profile_path")
        bash "$PROJECT_ROOT/desktop/configure-terminal.sh" "$term_bg" "$term_fg" "$term_cursor" || handle_rollback
    fi

    # 6. Painéis
    if jq -e '.components.panel' "$profile_path" >/dev/null; then
        bash "$PROJECT_ROOT/desktop/configure-panels.sh" || handle_rollback
    fi
    
    commit_transaction
    print_ok "Perfil '$profile_name' aplicado com sucesso!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$1" == "--apply" && -n "$2" ]]; then
        apply_profile "$2"
    fi
fi
