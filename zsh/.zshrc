# Path
export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/homebrew/opt/ruby/bin:$PATH
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/opt/homebrew/opt/llvm/bin

# Shell
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="kphoen"
plugins=(git)
source $ZSH/oh-my-zsh.sh
export TERM="xterm-256color"

bindkey '^H' backward-kill-word
bindkey '5~' kill-word

bindkey -e
bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word

# Editor
alias sudo="sudo "
alias vi="nvim"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nvim"
else
  export EDITOR="nvim"
fi

# Aliases
alias ll="ls -lhaF --color=auto"
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"