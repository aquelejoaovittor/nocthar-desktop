#!/usr/bin/env bash
# NOCTHAR DESKTOP - Interface de Terminal (UI)
set -Eeuo pipefail

# Proteção contra source duplo (Include Guard)
if [[ -z "${C_RESET:-}" ]]; then
    readonly C_RESET="\033[0m"
    readonly C_INFO="\033[1;36m"   # Ciano Elétrico (#00D2FF)
    readonly C_OK="\033[1;32m"     # Verde
    readonly C_WARN="\033[1;33m"   # Amarelo
    readonly C_ERR="\033[1;31m"    # Vermelho Escuro (#A82035)
    readonly C_DIM="\033[2m"       # Prata Escuro
fi

print_info() { echo -e "${C_INFO}[NOCTHAR]${C_RESET} $*"; }
print_ok() { echo -e "${C_OK}[SUCESSO]${C_RESET} $*"; }
print_warn() { echo -e "${C_WARN}[AVISO]${C_RESET} $*"; }
print_err() { echo -e "${C_ERR}[ERRO]${C_RESET} $*" >&2; }

confirm_action() {
    local prompt="$1"
    local response
    read -r -p "$(echo -e "${C_WARN}[CONFIRMAÇÃO]${C_RESET} $prompt [s/N]: ")" response
    case "$response" in
        [sS][iI][mM]|[sS]) return 0 ;;
        *) return 1 ;;
    esac
}
