# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

# Aliases
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias lt='eza --tree --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -l --color=auto'
    alias la='ls -la --color=auto'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

alias grep='grep --color=auto'
alias vim='nvim'
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns $(pacman -Qqtd)'
alias ..='cd ..'
alias ...='cd ../..'

# Key bindings (emacs mode)
bindkey -e

# Path
export PATH="$HOME/.local/bin:$PATH"

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Yazi shell wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Starship
eval "$(starship init zsh)"

# Fastfetch on first open
if [[ -z "$TMUX" && -z "$ZELLIJ" ]]; then
    fastfetch
fi
