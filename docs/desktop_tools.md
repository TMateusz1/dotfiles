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
is `GeistMono Nerd Font Mono` at 16pt with a 105% cell-height stretch.
`background_opacity 1.0` is deliberate (commented in the file):
translucency made real text contrast drift over composited desktop content,
while cells with their own explicit background (Neovim, the tmux status
bar) stayed opaque and plain shell output didn't — an inconsistent look.
Also: `confirm_os_window_close 0` (no nag on close), `macos_option_as_alt
no`, a handful of `cmd+N` tab-switching binds, `F5`/`F6` horizontal/vertical
splits, and remapped `enter` combos (shift/alt/ctrl/ctrl+shift) sent as proper
CSI-u sequences for apps that distinguish them.

`clipboard_control` permits both writes and reads for the clipboard and primary
selection. Writes make remote Neovim yanks reach macOS; reads make ordinary
remote Neovim paste work through tmux without a prompt. The read half is an
explicit convenience/security tradeoff: any program reached through this Kitty
terminal, including over SSH, can read the macOS clipboard. Replace
`read-clipboard`/`read-primary` with their `-ask` variants if per-read approval
is preferred.

### Seamless Kitty, tmux and Neovim navigation

Both `Ctrl-h/j/k/l` and `Ctrl-Left/Down/Up/Right` move in the requested
direction across all three split layers. `pane_navigation.py` is a no-UI Kitty
kitten and a global watcher:

- At an ordinary shell prompt, the kitten moves directly to the neighboring
  Kitty split.
- When a full-screen application owns Kitty's alternate screen, it passes the
  original key through. tmux therefore receives the key locally and over
  ordinary SSH without process-name or window-title guessing.
- At a tmux outer edge, `tmux/.tmux.conf` emits a Kitty `SetUserVar` escape
  sequence. The watcher accepts only the `tmux_kitty_navigate` variable and
  moves to that neighbor. This uses the terminal data path, so a tmux server on
  another VM needs no access to a local socket.
- At a Neovim edge, the vim-tmux-navigator configuration first tries another
  Neovim split, then another tmux pane, and emits the same narrow request only
  at the combined outer edge.

This deliberately does not enable Kitty's general remote-control listener or
forward a control socket to SSH hosts. A remote program can emit the named
escape sequence and request a focus move, but it cannot use this mechanism for
arbitrary Kitty commands. The handoff requires `allow-passthrough on` in the
tmux config, which is already enabled for clipboard support.

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
`hk check --all` anyway. The navigation kitten was also imported with Kitty's
embedded Python and its alternate-screen/pass-through, ordinary-shell/focus,
and watcher paths were exercised with stub windows.
