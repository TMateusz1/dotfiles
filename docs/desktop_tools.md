# Desktop tools

GUI applications — a different category from
[util_tools.md](./util_tools.md) (small CLI utilities) and
[core_tools.md](./core_tools.md) (TUI apps you run *inside* a terminal):
these are the host application itself. Installed opt-in via
`mise/config.desktop.toml`/`bootstrap:all-desktop`, not the always-loaded
global mise config — see [bootstrap.md](./bootstrap.md).

## kitty

`kitty/kitty.conf` (+ `kitty/catppuccin-mocha.conf`) map to
`~/.config/kitty/` — [kitty](https://sw.kovidgoyal.net/kitty/) is
genuinely XDG-compliant on macOS too (checked directly via `kitty
--help`'s documented search order), unlike [k9s](./core_tools.md#k9s) or
Go's own env file. No placement exception needed here.

**What's configured:** `env read_from_shell=PATH EDITOR VISUAL` — documented
kitty syntax: the special value `read_from_shell` tells kitty to read the
named variables from the login shell's own startup files, each name
treated as a glob. `editor nvim` is separate — kitty's own setting for its
internal edit-in-kitty features, distinct from the `EDITOR` env var. Font
is `JetBrainsMono Nerd Font` at 16pt with a 115% cell-height stretch —
the correct family name for nerd-fonts' base (non-Mono, non-Propo) variant.
`background_opacity 1.0` is deliberate (commented in the file):
translucency made real text contrast drift over composited desktop content,
while cells with their own explicit background (Neovim, the tmux status
bar) stayed opaque and plain shell output didn't — an inconsistent look.
Also: `confirm_os_window_close 0` (no nag on close), `macos_option_as_alt
no`, a handful of `cmd+N` tab-switching binds, and remapped `enter` combos
(shift/alt/ctrl/ctrl+shift) sent as proper CSI-u sequences for apps that
distinguish them.

`clipboard_control` permits both writes and reads for the clipboard and primary
selection. Writes make remote Neovim yanks reach macOS; reads make ordinary
remote Neovim paste work through tmux without a prompt. The read half is an
explicit convenience/security tradeoff: any program reached through this Kitty
terminal, including over SSH, can read the macOS clipboard. Replace
`read-clipboard`/`read-primary` with their `-ask` variants if per-read approval
is preferred.

**Known issue: font registration lag.** Even with the
`font-jetbrains-mono-nerd-font` cask installed and its `.ttf` files present
on disk, kitty can report `The font JetBrainsMono Nerd Font was not found,
falling back to Menlo` right after install — a macOS font-cache/CoreText
indexing delay, not a config problem. A login-session restart or
re-running the font cask install usually clears it.

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

**Validation:** no third-party linter exists for kitty's config format, and
per this repo's policy no custom step fills that gap (see
[linting.md](./linting.md)). `kitty +runpy 'from kitty.config import
load_config; load_config(path)'` parses the config purely in-process, with
no window/GPU/display needed (unlike actually starting kitty), and is a
handy one-liner for a manual spot-check — it's lenient on unknown keys but
raises a real error on an invalid value for a recognized option. Not wired
into an automated check, partly because kitty is also opt-in
(`mise/config.desktop.toml`) and wouldn't reliably be on `PATH` during an ordinary
`hk check --all` anyway.
