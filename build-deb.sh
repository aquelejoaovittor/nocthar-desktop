#!/usr/bin/env bash
# NOCTHAR DESKTOP - Construtor de Pacote .deb
set -Eeuo pipefail

VERSION="1.1.0"
PKG_NAME="nocthar-desktop"
PKG_DIR="build_deb"
DEB_FILE="${PKG_NAME}_${VERSION}_all.deb"

echo "=== Construindo pacote .deb do NOCTHAR DESKTOP v$VERSION ==="

rm -rf "$PKG_DIR"
rm -f "$DEB_FILE"

mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/nocthar"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/scalable/apps"

echo "-> Copiando arquivos do projeto..."
# Copia as pastas e os scripts principais para dentro do pacote
cp -r core lib config desktop gui themes assets system "$PKG_DIR/usr/share/nocthar/"
cp backup.sh restore.sh launcher.sh "$PKG_DIR/usr/share/nocthar/"

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
 It includes visual profiles, wallpaper engine, backup/restore, lock screen
 configuration, and a GTK3 graphical interface.
CONTROL

echo "-> Criando executável em /usr/bin/nocthar..."
cat << EXEC > "$PKG_DIR/usr/bin/nocthar"
#!/bin/bash
exec python3 /usr/share/nocthar/gui/main.py "\$@"
EXEC
chmod 755 "$PKG_DIR/usr/bin/nocthar"

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

cp assets/icons/nocthar_icon.svg "$PKG_DIR/usr/share/icons/hicolor/scalable/apps/"
chmod -R 755 "$PKG_DIR/usr/share/nocthar"

echo "-> Empacotando (.deb)..."
dpkg-deb --build "$PKG_DIR" "$DEB_FILE"

echo "=== Pacote criado com sucesso: $DEB_FILE ==="
echo "Para instalar, rode: sudo apt install ./$DEB_FILE"
