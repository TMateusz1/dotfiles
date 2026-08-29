# Shell (`shell/.zshrc`)

`shell/.zshrc` maps to **`~/.zshrc`** — a flat file directly in `$HOME`,
*not* an XDG path. zsh only looks elsewhere (e.g. under
`$XDG_CONFIG_HOME/zsh/`) if `$ZDOTDIR` is set before zsh starts, normally
from `/etc/zshenv` or `~/.zshenv` — neither exists in this repo, so the
real, current target is `~/.zshrc`. Same shape of exception as
[tmux](./core_tools.md#tmux)/[starship](./util_tools.md#starship).

This is the file that activates the "shell integration" pieces documented
across [util_tools.md](./util_tools.md) and [core_tools.md](./core_tools.md)
for individual tools. Getting this file (and oh-my-zsh plus its custom
plugins) actually onto a machine is [bootstrap.md](./bootstrap.md)'s job,
not this file's — this doc only covers what's *in* `.zshrc`.

## What's configured

- `export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"` near the
  top. This isn't cosmetic — several things in this repo depend on it:
  [fzf](./util_tools.md#fzf) and [ripgrep](./util_tools.md#ripgrep) only
  auto-discover their config files via `$XDG_CONFIG_HOME`-based env vars
  (below); and it's what resolves the exceptions documented for
  [k9s](./core_tools.md#k9s) and [Go's own env file](./langs.md#go), both of
  which default to `~/Library/Application Support/...` on macOS specifically
  when this variable isn't set.
- `path+=(...)` for `~/.local/bin`, `~/bin`, `~/go/bin` (only if the
  directory exists), deduped via `typeset -U path PATH`.
- `TERM` fallback to `xterm-256color` if the current `$TERM` has no
  terminfo entry available (e.g. SSH'ing somewhere that doesn't know
  `tmux-256color`/`xterm-ghostty`) — same class of concern as
  [tmux.conf's own comment](./core_tools.md#tmux) about not hardcoding a
  terminal-specific `TERM`.
- `mise activate zsh`, then oh-my-zsh (`$ZSH_THEME` empty — starship owns
  the prompt instead, avoiding a double-prompt conflict), then starship,
  atuin, zoxide, eza aliases, fzf, a `tc()` tmux session helper, and
  finally `.zshrc.local` for machine-local overrides — all individually
  guarded by `command -v`/`[[ -r ... ]]` checks, so this degrades cleanly
  on a machine missing some of these tools.
- `zsh-syntax-highlighting` is sourced last, after `.zshrc.local` — required
  by its own upstream docs to load after every other widget/hook is
  registered.
- In the eza block: `unset LS_COLORS`. eza prefers `LS_COLORS`/`EZA_COLORS`
  over its own `theme.yml` for file-kind colors, with no warning, if either
  is set — see [util_tools.md#eza](./util_tools.md#eza). Unsetting it here
  keeps eza's Catppuccin theme in effect regardless of what the wider
  environment sets.
- `export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"`, guarded as
  `[[ -r "$XDG_CONFIG_HOME/fzf/config" ]] && export ...` — fzf hard-fails
  (exit `2`) if this points to a file that doesn't exist, unlike ripgrep
  below, so the export only fires when the file is actually readable.
- `export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"`, unguarded
  — ripgrep degrades gracefully on a missing file (a stderr warning, still
  exits `0`), so no existence check is needed.
- `export FZF_CTRL_R_COMMAND=''` — fzf's documented mechanism for opting
  its own `Ctrl-R` history binding out entirely. atuin binds `Ctrl-R` first
  for its own search; fzf's init (`source <(fzf --zsh)`) runs after and
  would otherwise also claim it. With this set, `Ctrl-R` stays on
  `atuin-search` and the separately-bound `Ctrl-F` stays on
  `fzf-history-widget`. Exported (not just assigned) because it's read by
  the dynamically-sourced fzf script, not by this file directly.

## Validation

`shellcheck --shell=bash` runs against this file (`zshrc-check` in
`hk.pkl`) — shellcheck has no zsh dialect, but `bash` mode produces zero
false positives against this file's zsh-specific syntax (`path+=`,
`typeset -U`, etc.) while still catching real issues, such as a plain
(non-exported) variable assignment that's only read by a dynamically
sourced script. `SC1090`/`SC1091` ("can't follow this source") are excluded
in `zshrc-check` — unavoidable noise for an rc file that legitimately
sources dynamic/generated content (oh-my-zsh, `.zshrc.local`, fzf's own
init).

`shellcheck` is a repo-local tool (`mise.toml`, not the global config) —
it's for linting this repo's own shell script, not something the user runs
directly day to day.
