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
│   ├── hyprland.conf         # Config principal (sources omarchy defaults)
│   ├── bindings.conf         # Atajos de teclado personalizados
│   ├── monitors.conf         # Configuración de monitores ⚠️ ajustar por PC
│   ├── input.conf            # Teclado, ratón, touchpad
│   └── hypridle.conf         # Screensaver automático (5 min)
├── waybar/                   # Barra de estado
│   ├── config.jsonc          # Módulos y layout
│   └── style.css             # Estilos
├── ghostty/                  # Terminal
│   └── config                # Font, padding, keybinds
├── nvim/                     # Neovim (LazyVim)
│   ├── init.lua
│   ├── lua/
│   └── plugin/
├── omarchy/                  # Extensiones de OmarchyOS
│   ├── extensions/
│   │   └── menu.sh           # Menú personalizado
│   ├── hooks/                # Hooks de eventos (battery-low, etc)
│   └── themed/               # Templates de temas
├── install.sh                # Script de instalación
└── README.md
```

## Notas importantes

### Monitores
`hypr/monitors.conf` está configurado para mi setup específico:
- `DP-1`: 1440x900@60
- `HDMI-A-1`: 2560x1440@100

**Ajusta este archivo** según tus monitores antes de aplicar:
```bash
hyprctl monitors  # Ver monitores disponibles
```

### Fix xdg-desktop-portal-hyprland
El `install.sh` detecta automáticamente si tienes la versión `1.3.11-4`
(que tiene un bug SIGSEGV que mata hyprlock) y la recompila desde git.

### Stow
Los dotfiles usan [GNU Stow](https://www.gnu.org/software/stow/) para
crear symlinks. Esto significa que editar los archivos en `~/.config/`
actualiza automáticamente el repo.

## Actualizar

```bash
cd ~/.dotfiles
git pull
./install.sh
```