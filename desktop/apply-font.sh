#!/usr/bin/env bash
set -Eeuo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/ui.sh"

if [[ -z "${1:-}" ]]; then
    print_err "Nenhuma fonte especificada."
    exit 1
fi

print_info "Aplicando fonte: $1"
gsettings set org.mate.interface font-name "$1"
print_ok "Fonte aplicada com sucesso."
