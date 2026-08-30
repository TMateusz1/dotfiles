# Put machine-local overrides in ~/.zshrc.local.

# Several tools' configs in this dotfiles repo (fzf, ripgrep, and — on
# macOS specifically — k9s and Go's own env file) only resolve to
# ~/.config/<tool>/... when this is set; macOS doesn't export it by default.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

path_append_if_dir() {
  [[ -d "$1" ]] && path+=("$1")
}

path_append_if_dir "$HOME/.local/bin"
path_append_if_dir "$HOME/bin"
path_append_if_dir "$HOME/go/bin"
typeset -U path PATH

if [[ -n "${TERM:-}" ]] && ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

export EDITOR="nvim"
export VISUAL="$EDITOR"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
ZSH_THEME="${ZSH_THEME:-}"

zsh_plugin_exists() {
  local plugin="$1"

  [[ -d "$ZSH/plugins/$plugin" || -d "$ZSH_CUSTOM/plugins/$plugin" ]]
}

plugins=()
for plugin in git zsh-autosuggestions you-should-use; do
  zsh_plugin_exists "$plugin" && plugins+=("$plugin")
done

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

if command -v eza >/dev/null 2>&1; then
  # LS_COLORS (set elsewhere: a system default, oh-my-zsh, .zshrc.local...)
  # silently overrides eza's own theme.yml for file-kind colors with no
  # warning. Unset it so the Catppuccin theme actually applies.
  unset LS_COLORS
  alias ls="eza"
  alias ll="eza -al --icons=always --git -1"
  alias la="eza -al --icons=always --git"
  alias lt="eza --tree --level=2 --icons=always"
fi

if command -v fzf >/dev/null 2>&1; then
  # fzf hard-fails (rather than falling back) if this points to a file that
  # doesn't exist yet — e.g. before this repo is symlinked into place.
  [[ -r "$XDG_CONFIG_HOME/fzf/config" ]] && export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"
  # Empty (not unset) tells fzf's own init script to skip binding Ctrl-R
  # itself, leaving it to atuin above. Must be exported: read by the
  # dynamically-sourced script below, not by this file.
  export FZF_CTRL_R_COMMAND=''
  source <(fzf --zsh)
  bindkey '^F' fzf-history-widget
fi

if command -v rg >/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
fi

if command -v glow >/dev/null 2>&1; then
  # glow's own config file has no path-expansion for `style` (no `~`, no env
  # vars) — see docs/util_tools.md#glow. Wiring the theme through an alias
  # is the only reliable way to activate it.
  alias glow="glow --style \"\$XDG_CONFIG_HOME/glow/glamour.json\""
fi

# Markdown rendering for CLIs built on Charm's glamour library — gh documents
# this var (`gh help environment`); glab and other glamour tools read the same
# one, so this themes them together rather than being gh-specific. glow itself
# ignores it (see docs/util_tools.md#glow) and is handled by the alias above.
# Gated on the theme file, not on any one tool: a missing path here renders
# unstyled with no error, which would be invisible.
if [[ -r "$XDG_CONFIG_HOME/glow/glamour.json" ]]; then
  export GLAMOUR_STYLE="$XDG_CONFIG_HOME/glow/glamour.json"
fi

if command -v yazi >/dev/null 2>&1; then
  # Standard yazi wrapper (from its own quick-start docs): `cd`s the shell to
  # wherever yazi was left, since yazi itself is a child process and can't
  # change its parent shell's directory.
  y() {
    local tmp
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    local cwd
    cwd="$(command cat -- "$tmp")"
    rm -f -- "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && { cd -- "$cwd" || return; }
  }
fi

if command -v tmux >/dev/null 2>&1; then
  tc() {
    local session="${1:-core}"

    if [[ -n "$TMUX" ]] && tmux display-message -p '#S' >/dev/null 2>&1; then
      tmux has-session -t "$session" 2>/dev/null || tmux new-session -d -s "$session" -c "$HOME"
      tmux switch-client -t "$session"
    else
      tmux new-session -A -s "$session" -c "$HOME"
    fi
  }
fi

if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

unfunction path_append_if_dir zsh_plugin_exists 2>/dev/null

# This plugin must load after every other ZLE widget and hook.
if [[ -r "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
