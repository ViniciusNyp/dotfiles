# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR='code --wait'
export SUDO_EDITOR="$EDITOR"
export THEFUCK_REQUIRE_CONFIRMATION='false'

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
antidote bundle agkozak/zsh-z
antidote bundle unixorn/fzf-zsh-plugin
antidote bundle jeffreytse/zsh-vi-mode


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval $(thefuck --alias)


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

# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'batcat --style=numbers --color=always {}'"
alias fd='fdfind'
alias cd='z'
alias diff='diff-so-fancy'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias n='nvim'
alias g='git'
alias d='docker'
alias bat='batcat'
alias lzg='lazygit'
alias lzd='lazydocker'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

antidote bundle zsh-users/zsh-autosuggestions
antidote bundle zsh-users/zsh-completions
antidote bundle belak/zsh-utils path:completion
antidote bundle zsh-users/zsh-syntax-highlighting
antidote bundle romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(~/.local/bin/mise activate zsh)"
