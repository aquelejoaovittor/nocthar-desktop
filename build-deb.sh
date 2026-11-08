#!/usr/bin/env bash
# NOCTHAR DESKTOP - Construtor de Pacote .deb
set -Eeuo pipefail

VERSION="1.0.0"
PKG_NAME="nocthar-desktop"
PKG_DIR="build_deb"
DEB_FILE="${PKG_NAME}_${VERSION}_all.deb"

echo "=== Construindo pacote .deb do NOCTHAR DESKTOP ==="

# 1. Limpar builds anteriores
rm -rf "$PKG_DIR"
rm -f "$DEB_FILE"

# 2. Criar a estrutura de diretórios do pacote Debian
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/nocthar"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/scalable/apps"

# 3. Copiar os arquivos do projeto para a pasta do sistema
echo "-> Copiando arquivos do projeto..."
cp -r core lib config desktop gui themes assets "$PKG_DIR/usr/share/nocthar/"

# 4. Criar o arquivo de controle (metadados e dependências)
echo "-> Gerando arquivo DEBIAN/control..."
cat << CONTROL > "$PKG_DIR/DEBIAN/control"
Package: $PKG_NAME
Version: $VERSION
Section: x11
Priority: optional
Architecture: all
Depends: python3, python3-gi, python3-gi-cairo, gir1.2-gtk-3.0, jq, wget, unzip, tar, dconf-cli
Maintainer: João Vitor <joaojsouzaxd@gmail.com>
Description: NOCTHAR DESKTOP - Customization Ecosystem for Linux Mint MATE
 A complete, modular, and safe customization ecosystem for Linux Mint MATE.
 It includes visual profiles (Core, Abyss, Nexus), a wallpaper engine,
 backup/restore functionality, and a GTK3 graphical interface.
CONTROL

# 5. Criar o script executável (/usr/bin/nocthar)
echo "-> Criando executável em /usr/bin/nocthar..."
cat << EXEC > "$PKG_DIR/usr/bin/nocthar"
#!/bin/bash
exec python3 /usr/share/nocthar/gui/main.py "\$@"
EXEC
chmod 755 "$PKG_DIR/usr/bin/nocthar"

# 6. Criar o atalho do menu (.desktop)
echo "-> Criando atalho no menu de aplicativos..."
cat << DESKTOP > "$PKG_DIR/usr/share/applications/nocthar.desktop"
[Desktop Entry]
Type=Application
Name=NOCTHAR DESKTOP
Comment=Central de Personalização Linux MATE
Exec=nocthar
Icon=/usr/share/icons/hicolor/scalable/apps/nocthar_icon.svg
Terminal=false
Categories=Settings;DesktopSettings;
DESKTOP

# 7. Copiar o ícone
cp assets/icons/nocthar_icon.svg "$PKG_DIR/usr/share/icons/hicolor/scalable/apps/"

# 8. Ajustar permissões
chmod -R 755 "$PKG_DIR/usr/share/nocthar"

# 9. Construir o pacote .deb
echo "-> Empacotando (.deb)..."
dpkg-deb --build "$PKG_DIR" "$DEB_FILE"

echo "=== Pacote criado com sucesso: $DEB_FILE ==="
echo "Para instalar, rode: sudo apt install ./$DEB_FILE"
