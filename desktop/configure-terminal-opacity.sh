#!/usr/bin/env bash
set -Eeuo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/ui.sh"

# Uso: configure-terminal-opacity.sh [porcentagem]
OPACITY="${1:-10}"
TERM_SCHEMA="org.mate.terminal.profile:/org/mate/terminal/profiles/default/"

print_info "Ajustando transparência do terminal para $OPACITY%..."
if gsettings list-keys "$TERM_SCHEMA" | grep -q "background-transparency-percent"; then
    gsettings set "$TERM_SCHEMA" use-transparent-background true
    gsettings set "$TERM_SCHEMA" background-transparency-percent "$OPACITY"
    print_ok "Transparência aplicada."
else
    print_warn "Seu terminal não suporta transparência."
fi
