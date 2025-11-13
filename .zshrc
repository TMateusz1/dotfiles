export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)

source $ZSH/oh-my-zsh.sh
export EDITOR='nvim'

## Starship
eval "$(starship init zsh)"

## SDK Man
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# Tmux essentials
alias tls="tmux ls"
alias tas="tmux new -As"
alias tk="tmux kill-session -t"
