#!/usr/bin/env bash
# NOCTHAR DESKTOP - Configurador de Painéis
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

configure_panels() {
    print_info "Ajustando os Painéis do MATE..."
    
    local panel_schema="org.mate.panel.toplevel:/org/mate/panel/toplevels/toplevel0/"
    
    # 1. Mover para baixo e ajustar tamanho (36px conforme o perfil)
    # Orientação: 'bottom'
    gsettings set "$panel_schema" orientation "bottom"
    gsettings set "$panel_schema" size 36
    
    # 2. Configurar Cor de Fundo do Painel
    # Fundo: #090B10 (Preto Mineral)
    # Cor Sólida (para evitar bugs visuais no Marco)
    if gsettings list-keys "$panel_schema" | grep -q "background-type"; then
        gsettings set "$panel_schema" background-type "solid"
        gsettings set "$panel_schema" background-color "rgb(9,11,16)"
    else
        # Em algumas versões do MATE, as chaves são ligeiramente diferentes
        dconf write /org/mate/panel/toplevels/toplevel0/background/type "'solid'"
        dconf write /org/mate/panel/toplevels/toplevel0/background/color "'#090B10'"
    fi
    
    print_ok "Painéis configurados (posição inferior, cor escura)."
    log_event "INFO" "Configurações de painel aplicadas."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    configure_panels
fi
