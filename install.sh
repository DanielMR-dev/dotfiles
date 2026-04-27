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
  local deps=("git" "stow" "starship" "zsh" "fzf")
  local missing=()
  for dep in "${deps[@]}"; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
  done

  # zsh-autosuggestions es un paquete (no un binario), verificar por separado
  if ! pacman -Qi zsh-autosuggestions &>/dev/null; then
    missing+=("zsh-autosuggestions")
  fi

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
    "$HOME/.zshrc"
  )

  local needs_backup=false
  for f in "${files_to_backup[@]}"; do
    # Solo hacer backup de archivos reales, no de symlinks que ya apuntan a dotfiles
    [ -f "$f" ] && [ ! -L "$f" ] && needs_backup=true && break
  done

  if $needs_backup; then
    mkdir -p "$BACKUP_DIR"
    for f in "${files_to_backup[@]}"; do
      if [ -f "$f" ] && [ ! -L "$f" ]; then
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
  local config_dirs=("hypr" "waybar" "ghostty" "omarchy")
  for dir in "${config_dirs[@]}"; do
    if [ -d "$DOTFILES_DIR/$dir" ]; then
      stow --target="$CONFIG" --dir="$DOTFILES_DIR" "$dir" --restow 2>/dev/null && \
        info "Linked: ~/.config/$dir" || \
        warning "Conflicto en $dir — revisa manualmente"
    fi
  done

  # starship.toml va directo en ~/.config/
  if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG/starship.toml"
    info "Linked: ~/.config/starship.toml"
  fi

  # .zshrc va directo en ~/
  if [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    info "Linked: ~/.zshrc"
  fi
}

# =============================================================================
# CONFIGURAR ZSH
# =============================================================================

setup_zsh() {
  # Instalar Oh My Zsh si no está instalado
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    warning "Instalando Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    info "Oh My Zsh instalado"
  else
    info "Oh My Zsh ya está instalado"
  fi

  # Crear symlink del plugin zsh-autosuggestions en Oh My Zsh custom plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ -d "/usr/share/zsh/plugins/zsh-autosuggestions" ]; then
    if [ ! -e "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
      mkdir -p "$ZSH_CUSTOM/plugins"
      ln -sf /usr/share/zsh/plugins/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
      info "Plugin zsh-autosuggestions vinculado"
    else
      info "Plugin zsh-autosuggestions ya configurado"
    fi
  else
    warning "zsh-autosuggestions no encontrado en /usr/share/zsh/plugins/"
  fi

  # Cambiar shell por defecto a zsh
  if [ "$SHELL" != "$(which zsh)" ]; then
    warning "Cambiando shell por defecto a zsh..."
    chsh -s "$(which zsh)"
    info "Shell por defecto cambiada a zsh (aplica en el próximo login)"
  else
    info "zsh ya es la shell por defecto"
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
echo "Configurando Zsh..."
setup_zsh

echo ""
echo "Aplicando dotfiles..."
link_configs

echo ""
echo "Recargando..."
reload_services

echo ""
info "¡Dotfiles aplicados correctamente!"
echo ""
echo "  ⚠️  Recuerda ajustar ~/.config/hypr/monitors.conf con tus monitores."
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "  ⚠️  Cierra sesión y vuelve a entrar para usar zsh como shell por defecto."
fi
echo ""