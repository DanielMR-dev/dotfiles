# dotfiles — danielmr-dev

Personalizaciones sobre [OmarchyOS](https://omarchy.org) (Arch Linux + Hyprland).

## Requisitos

- OmarchyOS instalado
- `git` y `stow` (`sudo pacman -S stow`)

## Instalación

```bash
git clone https://github.com/danielmr-dev/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

## Estructura

```
dotfiles/
├── hypr/                     # Configuración de Hyprland
│   ├── hyprland.conf         # Config principal
│   ├── bindings.conf         # Atajos de teclado
│   ├── monitors.conf         # ⚠️ Ajustar por PC
│   ├── input.conf            # Teclado, ratón, touchpad
│   └── hypridle.conf         # Screensaver automático (5 min)
├── waybar/                   # Barra de estado
│   ├── config.jsonc
│   └── style.css
├── ghostty/                  # Terminal
│   └── config
├── nvim/                     # Neovim (LazyVim)
│   ├── init.lua
│   ├── lua/
│   └── plugin/
├── starship/                 # Prompt (Catppuccin Mocha)
│   └── starship.toml
├── omarchy/                  # Extensiones de OmarchyOS
│   ├── extensions/
│   │   └── menu.sh
│   ├── hooks/
│   └── themed/
├── install.sh
└── README.md
```

## Notas

### Monitores
`hypr/monitors.conf` tiene mi setup específico (DP-1 + HDMI-A-1).
Ajústalo antes de correr el script:
```bash
hyprctl monitors  # Ver monitores disponibles
```

### Actualizar
```bash
cd ~/.dotfiles && git pull && ./install.sh
```