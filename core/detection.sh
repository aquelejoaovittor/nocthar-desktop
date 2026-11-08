#!/usr/bin/env bash
# NOCTHAR DESKTOP - Detecção de Ambiente
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

detect_environment() {
    print_info "Iniciando detecção do sistema..."
    
    local os_name="Desconhecido"
    local os_version="Desconhecida"
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        os_name="$NAME"
        os_version="$VERSION"
    fi
    
    local session_type="${XDG_SESSION_TYPE:-x11}"
    local mate_version
    mate_version=$(mate-about --version | awk '{print $NF}' 2>/dev/null || echo "Não detectado")
    
    local de_name="${XDG_CURRENT_DESKTOP:-MATE}"
    
    # Verificação individual de componentes
    local has_gtk3="false"; [[ -d "$HOME/.config/gtk-3.0" ]] && has_gtk3="true"
    local has_gtk2="false"; [[ -d "$HOME/.config/gtk-2.0" ]] && has_gtk2="true"
    local has_caja="false"; command_exists caja && has_caja="true"
    local has_marco="false"; command_exists marco && has_marco="true"
    local has_dconf="false"; command_exists dconf && has_dconf="true"
    local has_gsettings="false"; command_exists gsettings && has_gsettings="true"
    
    cat << DETECT
--- Relatório do Sistema ---
SO: $os_name $os_version
Ambiente: $de_name (MATE: $mate_version)
Sessão Gráfica: $session_type
GTK3: $has_gtk3 | GTK2: $has_gtk2
Marco: $has_marco | Caja: $has_caja
dconf: $has_dconf | gsettings: $has_gsettings
DETECT
}
