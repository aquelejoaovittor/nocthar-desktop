#!/usr/bin/env bash
# NOCTHAR DESKTOP - Instalador de Fontes
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

readonly FONTS_DIR="$HOME/.local/share/fonts"
readonly TEMP_DIR="$HOME/.local/share/nocthar/cache"

install_fonts() {
    print_info "Verificando e instalando fontes NOCTHAR..."
    ensure_dir "$FONTS_DIR"
    ensure_dir "$TEMP_DIR"

    # 1. Instalar Inter (Checagem via arquivo)
    if [ -z "$(find "$FONTS_DIR" -name 'Inter*' -print -quit 2>/dev/null)" ]; then
        print_info "Baixando fonte Inter..."
        wget -q --show-progress -O "$TEMP_DIR/inter.zip" "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip"
        unzip -q -o "$TEMP_DIR/inter.zip" -d "$TEMP_DIR/inter_extract"
        find "$TEMP_DIR/inter_extract" -name "*.ttf" -exec cp {} "$FONTS_DIR/" \;
        rm -rf "$TEMP_DIR/inter_extract" "$TEMP_DIR/inter.zip"
        print_ok "Fonte Inter instalada."
    else
        print_ok "Fonte Inter já está instalada."
    fi

    # 2. Instalar JetBrains Mono (Checagem via arquivo)
    if [ -z "$(find "$FONTS_DIR" -name 'JetBrainsMono*' -print -quit 2>/dev/null)" ]; then
        print_info "Baixando fonte JetBrains Mono..."
        wget -q --show-progress -O "$TEMP_DIR/jbmono.zip" "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
        unzip -q -o "$TEMP_DIR/jbmono.zip" -d "$TEMP_DIR/jbmono_extract"
        find "$TEMP_DIR/jbmono_extract/fonts/ttf" -name "*.ttf" -exec cp {} "$FONTS_DIR/" \;
        rm -rf "$TEMP_DIR/jbmono_extract" "$TEMP_DIR/jbmono.zip"
        print_ok "Fonte JetBrains Mono instalada."
    else
        print_ok "Fonte JetBrains Mono já está instalada."
    fi

    # 3. Atualizar o cache de fontes
    fc-cache -f "$FONTS_DIR" >/dev/null 2>&1
    log_event "INFO" "Fontes configuradas e cache atualizado."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts
fi
