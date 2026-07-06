# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR='code --wait'
export SUDO_EDITOR="$EDITOR"

[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

ZFUNCDIR=${ZFUNCDIR:-$ZDOTDIR/functions}
fpath=($ZFUNCDIR $fpath)
[[ -d $ZSH_COMPDUMP:h ]] || mkdir -p $ZSH_COMPDUMP:h
autoload -Uz compinit && compinit -i -d $ZSH_COMPDUMP

[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

source ${ZDOTDIR:-~}/.antidote/antidote.zsh

source <(antidote init)

antidote bundle belak/zsh-utils path:editor
antidote bundle belak/zsh-utils path:history
antidote bundle belak/zsh-utils path:utility
antidote bundle ohmyzsh/ohmyzsh path:plugins/git
antidote bundle unixorn/fzf-zsh-plugin
antidote bundle jeffreytse/zsh-vi-mode

eval "$(direnv hook zsh)"


  # if [[ -z "$ZELLIJ" ]]; then
  #     if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
  #         zellij attach -c
  #     else
  #         zellij
  #     fi

  #     if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
  #         exit
  #     fi
  # fi


if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

# if command -v zellij &> /dev/null; then
#     eval "$(zellij setup --generate-auto-start zsh)"
# fi

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# atuin must bind Ctrl-R after zsh-vi-mode resets keymaps
if command -v atuin &> /dev/null; then
  zvm_after_init_commands+=('eval "$(atuin init zsh --disable-up-arrow)"')
fi

# Dracula palette for fzf (appended to keep plugin bindings)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# fzf-tab: group headers + directory previews
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'

# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd='z'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias n='nvim'
alias g='git'
alias d='docker'
# Debian ships bat/fd as batcat/fdfind
command -v batcat &> /dev/null && alias bat='batcat'
command -v fdfind &> /dev/null && alias fd='fdfind'
alias lzg='lazygit'
alias lzd='lazydocker'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias cc='claude'
alias ad='agent-deck'

if command -v kubecolor &> /dev/null; then
  alias kubectl='kubecolor'
  compdef kubecolor=kubectl
fi

# yazi: cd into the directory it exits in
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

antidote bundle Aloxaf/fzf-tab
antidote bundle zsh-users/zsh-autosuggestions
antidote bundle zsh-users/zsh-completions
antidote bundle belak/zsh-utils path:completion
antidote bundle zsh-users/zsh-syntax-highlighting
antidote bundle romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/.local/bin:$PATH"
