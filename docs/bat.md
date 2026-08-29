# bat

`bat/config` maps to `~/.config/bat/config`
([bat](https://github.com/sharkdp/bat) follows XDG directly). The config
format is a flat args file (one CLI flag per line, blank lines ignored) —
not TOML, despite the name of other tools' config files in this repo.

## What's configured

- `--theme="Catppuccin Mocha"` — bundled with bat itself since it ships the
  Catppuccin themes built in; no vendoring needed (unlike
  [atuin](./atuin.md) or [lazygit](./lazygit.md), which don't ship it).
- `--style=numbers,changes,header` — line numbers, git-modification
  markers, and a filename header; deliberately excludes `grid` and `snip`
  (bat's other default components) for a leaner look.
- `--italic-text=always` — renders comments etc. in italics where the
  theme uses them (off by default).

## Found and fixed while setting this up

The file was named `config.toml`. bat's real config file has **no file
extension at all** — `~/.config/bat/config` — so a `.toml`-suffixed file
would never have been found once symlinked. Renamed to `bat/config`.

The flag values themselves were already correct: verified `--style=header`
is still a valid component (not renamed/removed — bat 0.26.1's default is
`header-filename`, but plain `header` remains a supported alias), and
`--italic-text=always` and the theme name resolve as documented, tested
against the actual installed `bat` binary.

## Validation

No linter exists for bat's config format (checked). The closest useful
check — wired into `hk.pkl` as `bat-check` — pipes a throwaway line through
`bat` with `BAT_CONFIG_PATH` pointed at this file; bat fails loudly with a
clear error on any unknown or malformed flag (verified against a
deliberately broken config first, to confirm the check has teeth).

The `bat` binary itself is provided by the **global mise config**, not
installed by this config — see [mise.md](./mise.md).
