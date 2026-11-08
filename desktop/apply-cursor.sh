#!/usr/bin/env bash
set -Eeuo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/ui.sh"

if [[ -z "${1:-}" ]]; then
    print_err "Nenhum cursor especificado."
    exit 1
fi

print_info "Aplicando cursor: $1"
gsettings set org.mate.peripherals-mouse cursor-theme "$1"
print_success() { echo -e "\033[1;32m[SUCESSO]\033[0m $*"; }
print_success "Cursor aplicado."
