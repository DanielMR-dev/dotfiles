# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Usar Starship como prompt (no usar tema de OMZ)
ZSH_THEME=""

# Plugins
plugins=(git 1password node nodenv npm nvm pip python sdk ssh themes vscode z zsh-interactive-cd zsh-navigation-tools zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# fzf key bindings
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# fzf autocompletado
if [ -f /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
elif [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# Cargar aliases de Omarchy (incluye eza, etc.)
source ~/.local/share/omarchy/default/bash/aliases
