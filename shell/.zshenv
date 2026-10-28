# Every Zsh reads this, including non-interactive SSH commands used by Zed.
# Keep it quiet and cheap; interactive setup belongs in .zshrc.
typeset -U path PATH
if [[ -d "$HOME/.local/bin" ]]; then
  path+=("$HOME/.local/bin")
fi
export PATH
