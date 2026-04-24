#!/usr/bin/env bash
# =============================================================================
# dotfiles/install.sh — danielmr-dev
# Aplica las personalizaciones sobre OmarchyOS
# Uso: ./install.sh
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo ""
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo ""
echo "  danielmr-dev — OmarchyOS dotfiles"
echo ""

# =============================================================================
# VERIFICACIONES PREVIAS
# =============================================================================

check_omarchy() {
  if [ ! -d "$HOME/.local/share/omarchy" ]; then
    error "OmarchyOS no está instalado. Instálalo primero desde https://omarchy.org"
  fi
  info "OmarchyOS detectado"
}

check_deps() {
  local deps=("git" "stow" "starship")
  local missing=()
  for dep in "${deps[@]}"; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
  done
  if [ ${#missing[@]} -gt 0 ]; then
    warning "Instalando dependencias faltantes: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi
  info "Dependencias verificadas"
}

# =============================================================================
# BACKUP
# =============================================================================

backup_existing() {
  local BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
  local files_to_backup=(
    "$CONFIG/hypr/hyprland.conf"
    "$CONFIG/hypr/bindings.conf"
    "$CONFIG/hypr/monitors.conf"
    "$CONFIG/hypr/input.conf"
    "$CONFIG/hypr/hypridle.conf"
    "$CONFIG/waybar/config.jsonc"
    "$CONFIG/waybar/style.css"
    "$CONFIG/ghostty/config"
    "$CONFIG/starship.toml"
  )

  local needs_backup=false
  for f in "${files_to_backup[@]}"; do
    [ -f "$f" ] && needs_backup=true && break
  done

  if $needs_backup; then
    mkdir -p "$BACKUP_DIR"
    for f in "${files_to_backup[@]}"; do
      if [ -f "$f" ]; then
        cp "$f" "$BACKUP_DIR/$(basename "$f")"
      fi
    done
    info "Backup guardado en $BACKUP_DIR"
  fi
}

# =============================================================================
# APLICAR DOTFILES (con symlinks via stow)
# =============================================================================

link_configs() {
  # Configs que van en ~/.config/
  local config_dirs=("hypr" "waybar" "ghostty" "nvim" "omarchy")
  for dir in "${config_dirs[@]}"; do
    if [ -d "$DOTFILES_DIR/$dir" ]; then
      stow --target="$CONFIG" --dir="$DOTFILES_DIR" "$dir" --restow 2>/dev/null && \
        info "Linked: ~/.config/$dir" || \
        warning "Conflicto en $dir — revisa manualmente"
    fi
  done

  # starship.toml va directo en ~/.config/ (no en subdirectorio)
  if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG/starship.toml"
    info "Linked: ~/.config/starship.toml"
  fi
}

# =============================================================================
# HYPRIDLE
# =============================================================================

setup_hypridle() {
  systemctl --user enable --now hypridle 2>/dev/null && \
    info "hypridle habilitado" || \
    warning "hypridle ya estaba habilitado o no disponible"
}

# =============================================================================
# xdg-desktop-portal-hyprland — compilar desde git si versión con bug
# =============================================================================

fix_portal() {
  local current_version
  current_version=$(pacman -Qi xdg-desktop-portal-hyprland 2>/dev/null | grep Version | awk '{print $3}')

  if [[ "$current_version" == "1.3.11-4" ]]; then
    warning "Versión con bug detectada ($current_version) — compilando desde git..."
    cd /tmp
    [ -d xdg-desktop-portal-hyprland ] && rm -rf xdg-desktop-portal-hyprland
    git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland
    cd xdg-desktop-portal-hyprland
    cmake -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build build -j"$(nproc)"
    sudo cmake --install build
    systemctl --user restart xdg-desktop-portal-hyprland
    info "xdg-desktop-portal-hyprland actualizado desde git"
  else
    info "xdg-desktop-portal-hyprland OK ($current_version)"
  fi
}

# =============================================================================
# RECARGAR
# =============================================================================

reload_services() {
  systemctl --user daemon-reload
  systemctl --user restart hypridle 2>/dev/null || true
  pkill waybar 2>/dev/null || true
  sleep 1
  waybar &
  info "Servicios recargados"
}

# =============================================================================
# MAIN
# =============================================================================

echo "Verificando requisitos..."
check_omarchy
check_deps

echo ""
echo "Haciendo backup de configs existentes..."
backup_existing

echo ""
echo "Aplicando dotfiles..."
link_configs

echo ""
echo "Configurando servicios..."
setup_hypridle
fix_portal

echo ""
echo "Recargando..."
reload_services

echo ""
info "¡Dotfiles aplicados correctamente!"
echo ""
echo "  ⚠️  Recuerda ajustar ~/.config/hypr/monitors.conf con tus monitores."
echo ""