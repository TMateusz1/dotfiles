# Desktop tools

GUI applications — a different category from
[util_tools.md](./util_tools.md) (small CLI utilities) and
[core_tools.md](./core_tools.md) (TUI apps you run *inside* a terminal):
these are the host application itself. Installed opt-in via
`mise/config.desktop.toml`/`bootstrap:all-desktop`, not the always-loaded
global mise config — see [bootstrap.md](./bootstrap.md).
Zed's configuration is managed here; its app is installed separately.

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

## Zed

`zed/` maps to the macOS `~/.config/zed/` through mise's `[dotfiles]`,
included in `bootstrap:dotfiles` and `bootstrap:all`. The whole directory
is symlinked so settings, keybindings and tasks share one location.

The root `.gitignore` allows only these files under `zed/`:

- `settings.json` — Vim mode, theme and extension preferences.
- [`keymap.json`](https://zed.dev/docs/key-bindings#user-keymaps) — custom
  keybindings; the filename is singular.
- [`tasks.json`](https://zed.dev/docs/tasks) — global tasks.

`keymap.json` contains the finder shortcuts below. No global tasks are
configured, so no empty `tasks.json` placeholder is added.

### AI disabled

`disable_ai = true` uses Zed's global AI opt-out. It disables all built-in
AI features, including the Threads Sidebar, Agent Panel, Inline Assistant
and Edit Prediction. See [Turn AI Off](https://zed.dev/docs/ai/quick-start#turn-ai-off).

### Theme and Vim-style finders

The editor uses `GeistMono Nerd Font Mono`, matching Kitty's `font_family`;
the integrated terminal inherits that family from the editor. Zed's existing
font sizes are kept; Kitty's font size
uses points, while Zed's uses pixels. The font is installed by the existing
opt-in desktop bootstrap (`font-geist-mono-nerd-font`).

Vim mode stays enabled, with the existing JetBrains base keymap for other
shortcuts. The official [Catppuccin extension](https://github.com/catppuccin/zed)
is declared in `auto_install_extensions`, so Zed installs it automatically
at startup on each machine. Restart an already running session after adding
the extension for the first time. The selected theme is Catppuccin Mocha in dark mode;
Catppuccin Latte is configured for light mode.

Zed's built-in pickers provide the fuzzy finder workflow. The Space-leader
shortcuts match this repo's Neovim finder keys where the features overlap:

| Shortcut            | Action                           |
| ------------------- | -------------------------------- |
| `Space f f`         | Find project files               |
| `Space f b`         | Find open tabs/buffers           |
| `Space f g`         | Search project text              |
| `Space f s`         | Find symbols in the current file |
| `Ctrl-j` / `Ctrl-k` | Next/previous result in a picker |

Leader bindings apply in Vim normal mode and empty panes. They do not
intercept spaces typed in insert mode. The picker navigation bindings
apply only inside picker inputs; Enter accepts and Escape dismisses using
Zed's existing bindings. The finders use Zed's native actions, with no
external fzf task or extra finder extension.

The file and project-text shortcuts run an `action::Sequence`: open the
picker, then `picker::SetPreviewRight`. This explicitly requests a preview
every time these shortcuts are used, even if it was previously hidden.
Zed 1.24.2 otherwise remembers the last layout separately for each picker
in local state; there is no `file_finder.show_preview` setting.
Inside a picker that supports previews, `Cmd-Alt-P` toggles the preview,
`Cmd-Alt-Right` places it on the right, and `Cmd-Alt-Down` places it below.
These preview panes are separate from Zed's reusable preview-tab settings.

### Explorer and terminal

The project explorer is docked on the left (`project_panel.dock = "left"`).

- `Cmd-1` — open/focus the project explorer.
- `Space e` — the same explorer action in Vim normal mode, empty panes,
  and the project panel when not editing a filename.
- `Cmd-2` — open/focus the integrated terminal.

The Command shortcuts apply throughout the workspace, including insert mode
and the terminal. These use Zed's native `ToggleFocus` actions, so pressing
the same shortcut from the focused panel returns focus to the editor.

### Code actions and refactoring

`Space c` groups code actions in Vim normal mode. Code actions, rename,
format and language-server restart use the same suffixes as this repo's
Neovim bindings.

| Shortcut    | Action                                       |
| ----------- | -------------------------------------------- |
| `Space c a` | Show code actions and available refactorings |
| `Space c r` | Rename the symbol under the cursor           |
| `Space c f` | Format the current buffer                    |
| `Space c o` | Organize imports                             |
| `Space c d` | Open project diagnostics                     |
| `Space c R` | Restart the current language server          |

In Vim visual mode, `Space c a` requests code actions for the selected
code and `Space c f` formats the selection. Range formatting requires a
formatter that supports it. Insert-mode text entry is unaffected.

Refactorings such as extracting a function or inlining are offered through
the code-actions menu when the active language server supports them.
Rename and import organization also depend on the language server's
capabilities; these shortcuts do not add language support or install any
extra extensions. See Zed's [action reference](https://zed.dev/docs/all-actions).

### Git actions

`Space g` groups the native Git actions in Vim normal mode and empty panes.
`Space g g` matches this repo's Neovim shortcut for opening the Git UI.

| Shortcut    | Action                   |
| ----------- | ------------------------ |
| `Space g g` | Open/focus the Git panel |
| `Space g b` | Find and switch branches |
| `Space g d` | Open the project diff    |
| `Space g h` | Show file history        |
| `Space g s` | Browse stashes and diffs |
| `Space g w` | Find or create worktrees |

The project diff uses Zed's configured `git.diff_base`. Branches, stashes
and worktrees use native pickers; changed files are available in the Git
panel. These actions are also available through the command palette.
See [Zed's Git documentation](https://zed.dev/docs/git) and
[action reference](https://zed.dev/docs/all-actions).

### Local data and bootstrap

All other files and directories are ignored, including the local `prompts/`
database. They will live physically under this repo once the directory is
linked, but remain untracked and are not shared between machines. Add an
explicit allowlist entry before tracking any additional custom config.
The Zed app is not installed by this repo's desktop bootstrap.

For an existing installation, preview the directory link with:

```sh
mise bootstrap dotfiles apply --dry-run --force ~/.config/zed
```

Before applying, move the existing `~/.config/zed` directory to a backup
outside this repo, keeping its prompt database and any other local data.
Copy any desired shareable config files into `zed/`, then apply only the
directory link with:

```sh
mise bootstrap dotfiles apply ~/.config/zed
```

The local `prompts/` directory can then be copied from the backup into the
linked directory if needed; Git will ignore it.

**Validation:** the directory bootstrap was checked with `--dry-run`, and
the Git allowlist was checked for all three config files and local state.
The finder actions and picker context were checked against Zed 1.24.2's
published macOS keymap and the official Vim keybinding documentation.
Both files parsed with Zed's installed JSONC parser. Opening the settings
in the installed app produced no settings or keymap errors in its new log
entries. The Catppuccin extension awaits the next app startup; visual theme
appearance and interactive shortcut behavior were not verified.
Preview actions, layout persistence and the action-sequence syntax were
checked against the installed version's picker implementation, macOS
keymap overrides and official documentation. The revised keymap was
parsed and checked for load errors in Zed's log; interactive preview
behavior was not verified.
Git action names were checked against the official action reference, and
the updated keymap passed parsing and repository checks. No Git operations
were executed while validating the bindings.
The `Space c` actions were checked against the official action reference;
the keymap parsed successfully and repository checks passed. Language-specific
refactorings and interactive normal/visual-mode behavior were not exercised.
