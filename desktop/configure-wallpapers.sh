#!/usr/bin/env bash
# NOCTHAR DESKTOP - Gerenciador de Wallpapers
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/utils.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/core/logging.sh"

readonly WALLPAPER_DIR="$PROJECT_ROOT/assets/wallpapers"

generate_wallpapers() {
    ensure_dir "$WALLPAPER_DIR"
    
    # Gera um wallpaper CORE (Grafite/Preto)
    if [[ ! -f "$WALLPAPER_DIR/nocthar_core.svg" ]]; then
        cat << SVG > "$WALLPAPER_DIR/nocthar_core.svg"
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#090B10;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#151B25;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad1)" />
  <circle cx="960" cy="540" r="300" fill="none" stroke="#00D2FF" stroke-width="2" opacity="0.1" />
  <text x="960" y="560" font-family="sans-serif" font-size="40" fill="#C3CBD5" text-anchor="middle" opacity="0.3">NOCTHAR CORE</text>
</svg>
SVG
    fi

    # Gera um wallpaper ABYSS (Vermelho Escuro)
    if [[ ! -f "$WALLPAPER_DIR/nocthar_abyss.svg" ]]; then
        cat << SVG > "$WALLPAPER_DIR/nocthar_abyss.svg"
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad2" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#090B10;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#A82035;stop-opacity:0.4" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad2)" />
  <polygon points="960,200 1200,800 720,800" fill="none" stroke="#FF4D4D" stroke-width="2" opacity="0.1" />
  <text x="960" y="560" font-family="sans-serif" font-size="40" fill="#C3CBD5" text-anchor="middle" opacity="0.3">NOCTHAR ABYSS</text>
</svg>
SVG
    fi

    # Gera um wallpaper NEXUS (Ciano Elétrico)
    if [[ ! -f "$WALLPAPER_DIR/nocthar_nexus.svg" ]]; then
        cat << SVG > "$WALLPAPER_DIR/nocthar_nexus.svg"
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad3" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#090B10;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1B49A6;stop-opacity:0.4" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad3)" />
  <path d="M 0 540 Q 480 200 960 540 T 1920 540" fill="none" stroke="#00D2FF" stroke-width="3" opacity="0.2" />
  <text x="960" y="560" font-family="sans-serif" font-size="40" fill="#C3CBD5" text-anchor="middle" opacity="0.3">NOCTHAR NEXUS</text>
</svg>
SVG
    fi
}

apply_wallpaper() {
    local wallpaper_path="$1"
    
    if [[ ! -f "$wallpaper_path" ]]; then
        print_err "Wallpaper não encontrado: $wallpaper_path"
        return 1
    fi

    print_info "Aplicando wallpaper: $(basename "$wallpaper_path")"
    gsettings set org.mate.background picture-filename "$wallpaper_path"
    gsettings set org.mate.background picture-options 'zoom'
    
    print_ok "Wallpaper aplicado."
    log_event "INFO" "Wallpaper alterado para: $wallpaper_path"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    generate_wallpapers
    if [[ -n "${1:-}" ]]; then
        apply_wallpaper "$1"
    fi
fi
