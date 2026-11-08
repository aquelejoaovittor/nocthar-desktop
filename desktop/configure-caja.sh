#!/usr/bin/env bash
set -Eeuo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/ui.sh"

# Uso: configure-caja.sh [mostrar_ocultos: true/false] [visualizacao: list-view/icon-view]
SHOW_HIDDEN="${1:-false}"
VIEW_MODE="${2:-icon-view}"

print_info "Configurando o Caja..."
gsettings set org.mate.caja.preferences show-hidden-files "$SHOW_HIDDEN"
gsettings set org.mate.caja.preferences default-folder-viewer "$VIEW_MODE"

# Força o Caja a recarregar as configurações abertas (se estiver rodando)
if command -v caja >/dev/null; then
    caja -q >/dev/null 2>&1 || true
fi

print_ok "Caja configurado com sucesso (Ocultos: $SHOW_HIDDEN | Modo: $VIEW_MODE)."
