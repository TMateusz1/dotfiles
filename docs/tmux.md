# tmux

`tmux/.tmux.conf` maps to **`~/.tmux.conf`** — not the XDG path
(`~/.config/tmux/tmux.conf`). This is a deliberate exception to the usual
directory/symlink convention (see [AGENTS.md](../AGENTS.md)): tmux checks
`~/.tmux.conf` *before* the XDG path, so if both exist, `~/.tmux.conf` wins
unconditionally. Targeting the XDG path here would silently do nothing on
any machine that still has a stray legacy `~/.tmux.conf` lying around.
Filename keeps the leading dot for the same reason — it's not a stylistic
choice, it's the literal filename tmux requires at that path.

## What's configured

- Prefix remapped to `C-Space`; `prefix r` reloads the config.
- `tmux-256color` terminal type with truecolor overrides, extended-keys
  passthrough (e.g. Shift-Enter), focus events (Neovim autoread), OSC52
  clipboard passthrough for remote copy/paste.
- Vi-style copy mode, mouse on, 100k-line scrollback, `escape-time 10` (fast
  enough not to fight Neovim's `<Esc>`).
- Smart pane navigation (`C-h/j/k/l`) that forwards to Neovim/fzf when one
  of those is running in the current pane, otherwise moves between tmux
  panes.
- `prefix g` opens a lazygit popup in the current pane's directory.
- Statusline hand-rolled in Catppuccin Mocha (blue accent, matching
  [git.md](./git.md) and [atuin.md](./atuin.md)) — no plugin manager, no
  third-party plugins, just tmux's own format strings.

No plugin manager (e.g. TPM) is used — the whole config is native tmux
options and key bindings, which also means there's nothing here to vet for
trust beyond tmux itself.

## Validation

There's no established third-party linter for `tmux.conf` (checked; nothing
comparable to `taplo`/`rumdl` exists for tmux config syntax). The closest
useful substitute — wired into `hk.pkl` as `tmux-check` — asks tmux itself
to load the config on a throwaway, isolated server and reports any
syntax/unknown-option errors, then tears the server down. See
[linting.md](./linting.md).

The `tmux` binary itself is provided by the **global mise config**, not
installed by this config — see [mise.md](./mise.md).
