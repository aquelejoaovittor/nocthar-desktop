#!/usr/bin/env bash
# NOCTHAR DESKTOP - Gerador de Tema Autoral GTK3
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

readonly THEME_NAME="NOCTHAR-CORE"
readonly THEME_DIR="$HOME/.themes/$THEME_NAME/gtk-3.0"

generate_theme() {
    print_info "Gerando o tema autoral $THEME_NAME..."
    ensure_dir "$THEME_DIR"

    # Criar o arquivo de configuração principal do tema
    cat << CSS > "$THEME_DIR/gtk.css"
/* NOCTHAR CORE THEME - GTK3 CSS */
/* Herda a estrutura do Mint-Y-Dark para garantir compatibilidade */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");

/* Paleta de Cores NOCTHAR */
@define-color nocthar_bg #090B10;       /* Preto Mineral */
@define-color nocthar_surface #151B25;  /* Grafite */
@define-color nocthar_border #263344;   /* Azul Petróleo */
@define-color nocthar_primary #00D2FF;  /* Ciano Elétrico */
@define-color nocthar_text #C3CBD5;     /* Prata */
@define-color nocthar_danger #A82035;   /* Vermelho Escuro */

/* --- Substituições Globais --- */
window, .background {
    background-color: @nocthar_bg;
    color: @nocthar_text;
}

headerbar {
    background-color: @nocthar_surface;
    border-bottom: 2px solid @nocthar_border;
    color: @nocthar_primary;
}

button {
    background-color: @nocthar_surface;
    color: @nocthar_text;
    border: 1px solid @nocthar_border;
    border-radius: 4px;
}

button:hover {
    background-color: @nocthar_border;
    border-color: @nocthar_primary;
    color: @nocthar_primary;
}

button:active, button:checked {
    background-color: @nocthar_primary;
    color: @nocthar_bg;
}

entry {
    background-color: @nocthar_bg;
    color: @nocthar_text;
    border: 1px solid @nocthar_border;
}

entry:focus {
    border-color: @nocthar_primary;
}

menu, .menu, .context-menu {
    background-color: @nocthar_surface;
    border: 1px solid @nocthar_border;
}

menuitem:hover {
    background-color: @nocthar_primary;
    color: @nocthar_bg;
}

/* Barra de progresso */
progressbar trough {
    background-color: @nocthar_bg;
}
progressbar progress {
    background-color: @nocthar_primary;
}

/* Cores de seleção */
selection {
    background-color: @nocthar_primary;
    color: @nocthar_bg;
}
CSS

    print_ok "Tema $THEME_NAME gerado em $THEME_DIR"
    log_event "INFO" "Tema customizado $THEME_NAME gerado."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_theme
fi
