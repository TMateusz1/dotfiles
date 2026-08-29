# atuin

`atuin/` maps to `~/.config/atuin/` ([atuin](https://atuin.sh) follows XDG
directly). Contents:

- `atuin/config.toml`
  - `auto_sync = false` — no history is synced to any server by default;
    sync requires an explicit `atuin login`/opt-in on a given machine. This
    is a public dotfiles repo, so nothing here should assume a signed-in
    sync account.
  - `sync_frequency = "5m"` — takes effect only once sync is enabled.
  - `search_mode = "fuzzy"`, `filter_mode = "global"`, `style = "compact"`,
    `enter_accept = true` — search/UI behavior preferences.
  - `[theme] name = "catppuccin-mocha-blue"` — Catppuccin Mocha, blue accent
    (`#89b4fa`), matching the accent used in [git.md](./git.md)'s delta
    theme for cross-tool consistency.
- `atuin/themes/catppuccin-mocha-blue.toml` — vendored from
  [catppuccin/atuin](https://github.com/catppuccin/atuin) (mocha/blue
  variant), since atuin loads named themes from `themes/` next to
  `config.toml` rather than shipping them built in.

The `atuin` binary itself is provided by the **global mise config**, not
installed by this config — see [mise.md](./mise.md).
