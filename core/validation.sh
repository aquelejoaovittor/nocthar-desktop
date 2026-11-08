#!/usr/bin/env bash
# NOCTHAR DESKTOP - Validação de Segurança e Esquemas
set -Eeuo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/utils.sh"

# Valida um perfil JSON usando jq
validate_profile() {
    local profile_file="$1"
    
    if ! check_file_access "$profile_file"; then return 1; fi
    if ! command_exists jq; then
        echo "Erro: 'jq' é necessário para validar perfis." >&2; return 1
    fi
    
    # Verifica se é um JSON válido
    if ! jq empty "$profile_file" 2>/dev/null; then
        echo "Erro: O arquivo não é um JSON válido." >&2; return 1
    fi
    
    # Validações de esquema estrito
    local schema_version
    schema_version=$(jq -r '.schema_version' "$profile_file")
    if [[ "$schema_version" != "1.0" ]]; then
        echo "Erro: Versão do schema incompatível ($schema_version). Esperado 1.0" >&2; return 1
    fi
    
    # Verifica campos obrigatórios na raiz
    if ! jq -e 'has("profile_name") and has("components")' "$profile_file" >/dev/null; then
        echo "Erro: Campos obrigatórios ausentes (profile_name, components)." >&2; return 1
    fi
    
    return 0
}

# Previne execução de caminhos perigosos (Path Traversal)
validate_safe_execution() {
    local target_path="$1"
    if ! is_safe_path "$target_path"; then
        return 1
    fi
    return 0
}
