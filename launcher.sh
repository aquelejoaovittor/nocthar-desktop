#!/usr/bin/env bash
# NOCTHAR DESKTOP - Menu CLI
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/lib/ui.sh"

show_menu() {
    clear
    echo -e "${C_INFO}=========================================${C_RESET}"
    echo -e "${C_INFO}       NOCTHAR DESKTOP - CENTRAL         ${C_RESET}"
    echo -e "${C_INFO}=========================================${C_RESET}"
    echo "1) Aplicar Perfil CORE (Minimalista)"
    echo "2) Aplicar Perfil ABYSS (Gothic)"
    echo "3) Aplicar Perfil NEXUS (Cyberpunk)"
    echo "4) Fazer Backup do Sistema Atual"
    echo "5) Restaurar Backup"
    echo "0) Sair"
    echo -e "${C_INFO}=========================================${C_RESET}"
}

while true; do
    show_menu
    read -r -p "Escolha uma opção: " opt
    case $opt in
        1) bash "$PROJECT_ROOT/core/profiles.sh" --apply "$PROJECT_ROOT/config/core.json" ;;
        2) bash "$PROJECT_ROOT/core/profiles.sh" --apply "$PROJECT_ROOT/config/abyss.json" ;;
        3) bash "$PROJECT_ROOT/core/profiles.sh" --apply "$PROJECT_ROOT/config/nexus.json" ;;
        4) bash "$PROJECT_ROOT/backup.sh" ;;
        5) bash "$PROJECT_ROOT/restore.sh" ;;
        0) echo "Saindo do NOCTHAR..."; exit 0 ;;
        *) print_err "Opção inválida!" ;;
    esac
    echo -e "\nPressione ENTER para voltar ao menu..."
    read -r
done
