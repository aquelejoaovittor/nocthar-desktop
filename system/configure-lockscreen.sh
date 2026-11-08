#!/usr/bin/env bash
# NOCTHAR DESKTOP - Configurador de Tela de Bloqueio
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

configure_lockscreen() {
    local target_wallpaper="${1:-}"
    
    print_info "Configurando a Tela de Bloqueio (MATE Screensaver)..."
    local schema="org.mate.screensaver"
    
    # 1. Ativar bloqueio e exigir senha
    gsettings set "$schema" lock-enabled true
    gsettings set "$schema" lock-delay 0
    
    # 2. Definir o fundo da tela de bloqueio
    if [[ -n "$target_wallpaper" && -f "$target_wallpaper" ]]; then
        print_info "Aplicando wallpaper na tela de bloqueio: $(basename "$target_wallpaper")"
        gsettings set "$schema" picture-filename "$target_wallpaper"
    else
        # Se nenhum wallpaper for passado, pega o wallpaper atual do desktop
        local current_wallpaper
        current_wallpaper=$(gsettings get org.mate.background picture-filename | tr -d "'")
        if [[ -f "$current_wallpaper" ]]; then
            print_info "Copiando o wallpaper atual do desktop para a tela de bloqueio."
            gsettings set "$schema" picture-filename "$current_wallpaper"
        fi
    fi
    
    # 3. Definir o tema do protetor de tela (caso suporte)
    if gsettings list-keys "$schema" | grep -q "theme"; then
        gsettings set "$schema" theme "screensavers-personal-slideshow" 2>/dev/null || true
    fi
    
    print_ok "Tela de Bloqueio configurada com sucesso."
    log_event "INFO" "Tela de bloqueio configurada."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_lockscreen "$@"
fi
