#!/usr/bin/env bash
# NOCTHAR DESKTOP - Utilitários Base
set -Eeuo pipefail

# Gera timestamp dinâmico em formato ISO 8601 UTC
get_iso_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Verifica se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verifica se um arquivo/diretório existe e é legível
check_file_access() {
    local file="$1"
    if [[ ! -e "$file" ]]; then
        echo "Erro: Arquivo ou diretório não encontrado: $file" >&2
        return 1
    fi
    if [[ ! -r "$file" ]]; then
        echo "Erro: Sem permissão de leitura: $file" >&2
        return 1
    fi
    return 0
}

# Previne operações destrutivas em caminhos críticos
is_safe_path() {
    local path="$1"
    # Rejeita caminhos vazios, raiz, home ou variáveis não expandidas
    if [[ -z "$path" || "$path" == "/" || "$path" == "$HOME" || "$path" == "/*" || "$path" == "~/*" ]]; then
        echo "Erro Crítico: Caminho inseguro detectado: $path" >&2
        return 1
    fi
    return 0
}

# Calcula hash SHA256 de um arquivo (útil para manifestos)
get_sha256() {
    local file="$1"
    if [[ -f "$file" ]]; then
        sha256sum "$file" | awk '{print $1}'
    else
        echo ""
    fi
}

# Cria diretório se não existir
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}
