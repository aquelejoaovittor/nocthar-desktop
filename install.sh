#!/usr/bin/env bash
# NOCTHAR DESKTOP - Instalador Oficial
set -Eeuo pipefail

echo "=== Instalando NOCTHAR DESKTOP ==="

# 1. Instalar dependências
echo "-> Instalando dependências do sistema (GTK, Python, jq)..."
sudo apt update
sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 jq wget unzip tar

# 2. Dar permissão de execução em todos os scripts
echo "-> Configurando permissões de execução..."
find . -type f -name "*.sh" -exec chmod +x {} \;

# 3. Criar pastas XDG
echo "-> Criando diretórios de usuário..."
mkdir -p ~/.config/nocthar/{settings,logs}
mkdir -p ~/.local/share/nocthar/{backups,profiles,cache,state}

# 4. Criar atalho no menu de aplicativos
echo "-> Criando atalho no menu..."
DESKTOP_FILE="$HOME/.local/share/applications/nocthar.desktop"
cat << DESKTOP > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=NOCTHAR DESKTOP
Comment=Central de Personalização Linux MATE
Exec=python3 $(pwd)/gui/main.py
Icon=$(pwd)/assets/icons/nocthar_icon.png
Terminal=false
Categories=Settings;DesktopSettings;
DESKTOP
chmod +x "$DESKTOP_FILE"

echo "=== Instalação concluída com sucesso! ==="
echo "Procure por 'NOCTHAR DESKTOP' no seu menu de aplicativos ou rode: ./launcher.sh"
