#!/usr/bin/env bash
# NOCTHAR DESKTOP - Configurador do Terminal
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

# Uso: configure-terminal.sh [fundo_rgb] [texto_rgb] [cursor_rgb]
configure_mate_terminal() {
    local bg_color="${1:-rgb(9,11,16)}"      # Padrão: Preto Mineral
    local fg_color="${2:-rgb(195,203,213)}"  # Padrão: Prata
    local cursor_color="${3:-rgb(0,210,255)}" # Padrão: Ciano
    
    print_info "Configurando aparência do Terminal (mate-terminal)..."
    local term_schema="org.mate.terminal.profile:/org/mate/terminal/profiles/default/"
    
    if ! gsettings list-keys "$term_schema" >/dev/null 2>&1; then
        print_warn "Perfil padrão do mate-terminal não encontrado."
        return 0
    fi

    safe_gsettings() {
        local schema="$1" key="$2" value="$3"
        if gsettings list-keys "$schema" | grep -q "^$key$"; then
            gsettings set "$schema" "$key" "$value"
        fi
    }

    safe_gsettings "$term_schema" "use-theme-colors" false
    safe_gsettings "$term_schema" "background-color" "$bg_color"
    safe_gsettings "$term_schema" "foreground-color" "$fg_color"
    safe_gsettings "$term_schema" "bold-color" "$cursor_color"
    safe_gsettings "$term_schema" "use-system-font" false
    safe_gsettings "$term_schema" "font" "JetBrains Mono 11"
    safe_gsettings "$term_schema" "use-transparent-background" true
    safe_gsettings "$term_schema" "background-transparency-percent" 10
    
    print_ok "Terminal configurado."
    log_event "INFO" "Terminal configurado com cores: $bg_color / $fg_color"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_mate_terminal "$@"
fi
