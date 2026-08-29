# Desktop tools

GUI applications — a different category from
[util_tools.md](./util_tools.md) (small CLI utilities) and
[core_tools.md](./core_tools.md) (TUI apps you run *inside* a terminal):
these are the host application itself. Installed opt-in via
`mise.desktop.toml`/`bootstrap:all-desktop`, not the always-loaded global
mise config — see [bootstrap.md](./bootstrap.md).

## kitty

`kitty/kitty.conf` (+ `kitty/catppuccin-mocha.conf`) map to
`~/.config/kitty/` — [kitty](https://sw.kovidgoyal.net/kitty/) is
genuinely XDG-compliant on macOS too (checked directly via `kitty
--help`'s documented search order), unlike [k9s](./core_tools.md#k9s) or
Go's own env file. No placement exception needed here.

**What's configured:** `env read_from_shell=PATH EDITOR VISUAL` — this
looked suspicious at first glance (not an obviously well-known directive),
but it's genuine, documented kitty syntax: the special value
`read_from_shell` tells kitty to read the named variables from the login
shell's own startup files, each name treated as a glob. Confirmed against
kitty's own config reference before concluding it wasn't a mistake.
`editor nvim` is separate — kitty's own setting for its internal
edit-in-kitty features, distinct from the `EDITOR` env var. Font is
`JetBrainsMono Nerd Font` at 16pt with a 115% cell-height stretch;
`background_opacity 1.0` is deliberate and commented in the file
(translucency was tried and rejected — composited desktop content behind
the window made real text contrast drift, while cells with their own
explicit background, like Neovim or the tmux status bar, stayed opaque
while plain shell output didn't, an inconsistent look). Also: `confirm_os_
window_close 0` (no nag on close), `macos_option_as_alt no`, a handful of
`cmd+N` tab-switching binds, and remapped `enter` combos
(shift/alt/ctrl/ctrl+shift) sent as proper CSI-u sequences for apps that
distinguish them.

**Found while verifying — not a config bug, a machine-state one:** loading
this config for real reported `The font JetBrainsMono Nerd Font was not
found, falling back to Menlo`, even though the font's `.ttf` files are
genuinely present (`~/Library/Fonts/JetBrainsMonoNerdFont-*.ttf`) and
Homebrew reports the cask "Installed (on request)". `font_family
JetBrainsMono Nerd Font` is the correct family name for nerd-fonts' base
(non-Mono, non-Propo) variant, matching those exact filenames — so this
reads as a macOS font-cache/registration lag (files on disk, not yet
indexed by CoreText) rather than anything wrong with the config. Worth
confirming once you actually launch kitty for real; if it persists, a
login-session restart or re-running the font cask install usually clears
it.

**Theme:** `catppuccin-mocha.conf` matches the official
[catppuccin/kitty](https://github.com/catppuccin/kitty) theme exactly on
`foreground`/`background`/`cursor`/`inactive_border_color`/
`bell_border_color`/inactive tab colors/all 16 ANSI colors — confirmed by
diffing every value. Three deliberate deviations, all this repo's
established blue accent (`#89b4fa`) replacing the official theme's
mauve/lavender/rosewater picks: `active_border_color`,
`active_tab_background`, `url_color`. `selection_foreground`/
`selection_background` diverge more substantially — a muted surface wash
(`#cdd6f4` on `#585b70`) instead of the official's bright rosewater block —
and the file's own comment explains why: matching tmux's copy-mode and
Neovim's Visual-mode look rather than inverting to a loud highlight. Not
present here (and not in conflict with anything, just omitted): the
official theme's `scrollbar_handle_color`/`scrollbar_track_color` and
`mark1`–`mark3` colors — minor, rarely-used features; addable later
without disturbing anything if wanted.

**Validation:** no third-party linter exists for kitty's config format,
but kitty itself can parse it **without spawning a window or touching the
GPU/display** — `kitty +runpy` runs Python using kitty's own bundled
interpreter, so `from kitty.config import load_config; load_config(path)`
validates purely in-process. This matters because the more obvious
approach (actually starting kitty, even with `--start-as=hidden`) still
creates a real OS-level window-server object and needs a display —
verified `+runpy` needs neither, making it safe for headless CI too.
Behavior is lenient for unknown keys (`Ignoring unknown config key: ...`,
still exits `0`) but raises a real Python exception (non-zero exit) for a
genuinely invalid *value* on a real option — verified both directly
(deliberately broken key vs. deliberately broken value). `kitty-check` in
`hk.pkl` treats either signal as failure.

**Also worth knowing:** kitty is deliberately *not* part of the always-on
toolset (it lives in `mise.desktop.toml`, opt-in only — see
[bootstrap.md](./bootstrap.md)), so it isn't guaranteed to be on `PATH`
during an ordinary `hk check --all`. `kitty-check` skips cleanly (exit `0`)
rather than failing when `kitty` isn't found, matching the same
graceful-degradation shape used throughout `shell/.zshrc`'s `command -v`
guards.
