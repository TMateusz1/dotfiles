# Preserve machine-local login setup, such as a package manager's shellenv.
if [[ -r "$HOME/.zprofile.local" ]]; then
  source "$HOME/.zprofile.local"
fi

# Official mise integration for GUI editors: resolve tools through shims.
# Interactive shells subsequently load full PATH activation from .zshrc.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
