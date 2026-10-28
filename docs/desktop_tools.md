# Desktop tools

GUI applications — a different category from
[util_tools.md](./util_tools.md) (small CLI utilities) and
[core_tools.md](./core_tools.md) (TUI apps you run *inside* a terminal):
these are the host applications themselves. `mise/config.macos.toml`
provisions Kitty, Zed and fonts through mise's native `brew-cask:` provider. Its
`global:apps:install` task is included in `bootstrap:all` on macOS.
See [bootstrap.md](./bootstrap.md#macos-apps).

## kitty

`kitty/kitty.conf` (+ `kitty/catppuccin-mocha.conf`) map to
`~/.config/kitty/` — [kitty](https://sw.kovidgoyal.net/kitty/) is
genuinely XDG-compliant on macOS too (checked directly via `kitty
--help`'s documented search order), unlike [k9s](./core_tools.md#k9s) or
Go's own env file. No placement exception needed here.

**What's configured:** `env read_from_shell=PATH EDITOR VISUAL` — documented
kitty syntax: the special value `read_from_shell` tells kitty to read the
named variables from the login shell's own startup files, each name
treated as a glob. `editor .` follows `VISUAL`/`EDITOR` for config editing, using the
shell's Zed-or-vi selection. See [Kitty's editor setting](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.editor). Font
is `GeistMono Nerd Font Mono` at 16pt with a 105% cell-height stretch.
`background_opacity 1.0` is deliberate (commented in the file):
translucency made real text contrast drift over composited desktop content,
while TUI cells with explicit backgrounds stayed opaque and plain shell
output did not.
Also: `confirm_os_window_close 0` (no nag on close), `macos_option_as_alt
left`, a handful of `cmd+N` tab-switching binds, `F5`/`F6` horizontal/vertical
splits, and remapped `enter` combos (shift/alt/ctrl/ctrl+shift) sent as proper
CSI-u sequences for apps that distinguish them.

`Ctrl+Shift+Left/Right` are unmapped with `no_op` so Kitty passes them to
Zellij for previous/next tab navigation. Kitty's own tabs remain accessible
with `Cmd+1` through `Cmd+5`. Reload Kitty's config with `Ctrl+Shift+F5`
after changing these bindings. See
[Kitty's shortcut unmapping](https://sw.kovidgoyal.net/kitty/mapping/#unmapping-default-shortcuts).

`Ctrl+Backspace` sends an unmodified `Delete` when the focused terminal title
matches Zellij's `<session> | Session Manager`. This adds a Mac-friendly
delete-session shortcut alongside the plugin's original `Delete`, including
the welcome screen. The conditional mapping leaves `Ctrl+Backspace` unchanged
outside that manager. Zellij 0.45.1 hardcodes the plugin's delete binding;
it cannot be extended through its KDL keybindings. Reload Kitty with
`Ctrl+Shift+F5` after changing the mapping. See
[conditional mappings](https://sw.kovidgoyal.net/kitty/mapping/#conditional-mappings-depending-on-the-state-of-the-focused-window).

On macOS, left Option sends Alt shortcuts to terminal applications, including
Zellij; right Option retains native character input. This setting requires
a full Kitty restart rather than a config reload. See
[Kitty's Option setting](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_option_as_alt).

`clipboard_control` permits both writes and reads for the clipboard and primary
selection. Terminal applications, including those reached over SSH, can
write and read the Mac clipboard without a prompt. The read half is an
explicit convenience/security tradeoff: any program reached through this Kitty
terminal, including over SSH, can read the macOS clipboard. Replace
`read-clipboard`/`read-primary` with their `-ask` variants if per-read approval
is preferred.

### Pane navigation

Zellij owns terminal pane navigation. `Ctrl+Arrow` reaches Zellij directly;
`Ctrl+Shift+Left/Right` also passes through for tab switching. Kitty keeps
its native window navigation and the configured `F5`/`F6` split shortcuts.
No custom navigation kitten or watcher is installed.
See [Zellij keybindings](./zellij.md).

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
for a muted selection highlight. Not
present here (and not in conflict with anything, just omitted): the
official theme's `scrollbar_handle_color`/`scrollbar_track_color` and
`mark1`–`mark3` colors — minor, rarely-used features; addable later
without disturbing anything if wanted.

**Validation:** no third-party linter exists for kitty's config format, and
per this repo's policy no custom step fills that gap (see
[linting.md](./linting.md)). `kitty +runpy 'from kitty.config import
load_config; load_config(path)'` parses the config purely in-process, with
no window/GPU/display needed (unlike actually starting kitty). Kitty 0.48.2
accepted the left-Option setting through this loader. The resolved keyboard
map was also checked to confirm that `Ctrl+Shift+Left/Right` no longer
trigger Kitty's tab actions. The loader is a handy one-liner for a manual
spot-check — it's lenient on unknown keys but
raises a real error on an invalid value for a recognized option. Not wired
into an automated check, partly because kitty is a GUI application
(installed through native mise cask provisioning) and wouldn't reliably be on `PATH` during an ordinary
`hk check --all` anyway. After removing the navigation watcher, the real
loader confirmed `editor .`, no watchers, and no custom `Ctrl+Arrow` mappings.
The real Kitty loader resolved the conditional `Ctrl+Backspace` mapping to
`send_key delete`. Kitty's native window-query parser was used to check the
condition against the session-manager title captured from a temporary Zellij
0.45.1 session and ordinary shell titles. The expression uses `\s` rather than
literal spaces: Kitty parses spaces as separators in its match-query syntax.
Its native key dispatcher was also checked: Ctrl+Backspace produced the plain
Delete sequence (`ESC [ 3 ~`) for the manager title and passed through for a
shell title. These checks exercise parsing and key emission without a GUI;
they do not establish successful session deletion in the session-manager UI.
No global Ctrl+Backspace remapping is configured.

## Zed

`zed/` maps to the macOS `~/.config/zed/` through mise's `[dotfiles]`,
included in `bootstrap:dotfiles` and `bootstrap:all`. The whole directory
is symlinked so settings, keybindings and tasks share one location.

The root `.gitignore` allows only these files under `zed/`:

- `global_settings.json` — shared Vim mode, theme, language and extension preferences.
- [`keymap.json`](https://zed.dev/docs/key-bindings#user-keymaps) — custom
  keybindings; the filename is singular.
- [`tasks.json`](https://zed.dev/docs/tasks) — global tasks.
- `snippets/go.json` — shared Go snippets; other generated/local snippet
  files remain ignored until explicitly allowlisted.

`keymap.json` contains a small bridge between native JetBrains IDE commands
and native Vim editing. `tasks.json` contains Go/Rust test commands that save
all edited buffers before running and bind to the native runnable tags.

### Remote mise and hk environment

In an SSH project, Git and its hooks run on the remote machine. A hook error
`zsh: command not found: mise` means the remote process cannot find the mise
executable; it has not reached project tool/environment resolution yet.
The shared `shell/.zshenv` makes the standard `~/.local/bin` installation
visible to non-interactive Zsh; `shell/.zprofile` loads mise's official shims
integration for GUI editors. `.zshrc` retains full interactive activation.
These are shared shell/tool integrations, not Zed-specific hook wrappers.
Apply the startup files on the affected remote machine and restart/reconnect
the remote server. See
[deployment and PATH details](./shell.md#zed-remote-and-git-hooks).
Local Zed settings and local mise installation do not supply remote binaries.

### Keyboard model and backup

`base_keymap = "JetBrains"` supplies the macOS IDE shortcuts; `vim_mode = true`
adds modal editing, text objects, operators and Vim navigation. The user keymap
contains only deliberate overrides: our numbered panels, preview finders,
recent/open tabs, pane/dock navigation and completion/snippet behavior.
The current Vim leader shortcuts are `Space Space` for the tab switcher,
`Space f` for files and `Space g` for project text search, plus `Space r n`
for symbol rename, `Space q` to close the active tab and `Space Tab` for the
alternate tab. All leader shortcuts require Vim normal mode in a full
editor inside a central pane; they are inactive in docks, panel inputs,
pickers and empty panes. Zed's inherited Vim leader bindings outside editors
are explicitly disabled, preserving each panel's single-Space action.
`[f`/`]f` and `[F`/`]F` move between function boundaries.
Insert-mode spaces remain ordinary text.

`vim.toggle_relative_line_numbers = true` uses relative line numbers in Vim
normal mode and absolute numbers in insert mode. Native Which-key is enabled
with a 450 ms delay to show matching multi-key bindings.

Autosave is explicitly disabled (`autosave = "off"`). Use `Cmd-S` or `:w`
to save deliberately; `Cmd-Alt-L` formats without saving. Native tab closing
asks before discarding the last view of an unsaved buffer. Shared test tasks
still use `save = "all"`, awaiting saves of edited buffers before launch.

Before the rebuild, an exact copy of the previous keymap was saved under
`zed/backups/keymap-YYYYMMDD-HHMMSS.json`. Backups are ignored by the existing
Git allowlist and stay local. Copy the desired backup over `zed/keymap.json`
to restore the previous bindings; Zed reloads the file automatically.

The native JetBrains preset is the source of truth for commands not overridden
here; Zed implements the available equivalents rather than every IntelliJ
feature. Double Shift opens Zed's command palette, not IntelliJ's unified
Search Everywhere. See [Zed keybindings](https://zed.dev/docs/key-bindings)
and the [macOS JetBrains preset](https://github.com/zed-industries/zed/blob/v1.24.2/assets/keymaps/macos/jetbrains.json).

### AI disabled

`disable_ai = true` uses Zed's global AI opt-out. It disables all built-in
AI features, including the Threads Sidebar, Agent Panel, Inline Assistant
and Edit Prediction. See [Turn AI Off](https://zed.dev/docs/ai/quick-start#turn-ai-off).

### Theme and finders

The editor uses `GeistMono Nerd Font Mono`, matching Kitty's `font_family`;
the integrated terminal inherits that family from the editor. Zed's existing
font sizes are kept; Kitty's font size
uses points, while Zed's uses pixels. The font is installed by the existing
macOS app-install task (`font-geist-mono-nerd-font`).

Vim mode stays enabled, with the existing JetBrains base keymap for other
shortcuts. The selected theme is **Catppuccin Mocha**; Catppuccin Latte is
configured for light mode. The official
[Catppuccin extension](https://github.com/catppuccin/zed) and Zed Industries'
[Material Icon Theme](https://github.com/zed-extensions/material-icon-theme)
are declared in `auto_install_extensions` for future machines. Material icons
are used in both light and dark modes. The file finder shows these icons
and uses a `large` default width. Preview pickers keep Zed's larger native
layout and locally saved dimensions.

The IntelliJ influence is in the IDE shortcuts and file/folder icons;
the editor and UI retain this repo's Catppuccin palette.

Mocha-only overrides give picker frames and preview dividers an opaque blue
accent (`#89b4fa`) through `border.variant`. General borders use Surface 2,
elevated backgrounds use Mantle, and selection highlights/indent guides use
the matching Catppuccin colors. The picker container uses a one-pixel
`border.variant` border. These shared UI tokens also affect other panels
and popovers that use them.

On the current machine, Material Icon Theme 1.3.2 was installed from its
publisher's source revision registered in
`zed-industries/extensions` after the registry download endpoint returned
HTTP 403. Only theme/icon data, manifests and licenses were installed;
Zed's directory watcher loads them without restarting the editor. The shared
config retains the normal registry IDs for startup installation and updates.

Zed's built-in pickers provide fuzzy finding with IDE shortcuts:

| Shortcut                     | Action                             |
| ---------------------------- | ---------------------------------- |
| `Cmd-Shift-F`                | Find project files with a preview  |
| `Space f` (normal mode)      | Find project files with a preview  |
| `Cmd-E`                      | Find open/recent tabs              |
| `Space Space` (normal mode)  | Find open/recent tabs              |
| `Cmd-Shift-G`                | Search project text with a preview |
| `Space g` (normal mode)      | Search project text with a preview |
| `Cmd-F12`                    | Find symbols in the current file   |
| `Cmd-O`                      | Find symbols across the project    |
| `Cmd-Shift-A` / double Shift | Open the command palette           |
| `Ctrl-j` / `Ctrl-k`          | Next/previous result in a picker   |

The Command shortcuts also work in insert mode. `Space f` and `Space g`
provide equivalent leader shortcuts in Vim normal mode in central editors,
including the same always-requested right-hand preview.
File/project-text overrides match full editors, Pane/Workspace, the explorer
and project-search results so native JetBrains shortcuts do not shadow the
F-for-files/G-for-grep pair there. More specific search-field bindings retain
their own input contexts.
The `Cmd-E` override replaces the preset's file finder with Zed's searchable
global tab switcher (`tab_switcher::ToggleAll`), showing tabs across all splits.
`Space Space` opens that same switcher, providing the quick buffer-selection
workflow across the workspace. Zed shows a searchable list. Type part of a filename and press
Enter, or navigate the results with `Ctrl-j`/`Ctrl-k`. Selecting a tab focuses
its existing pane rather than duplicating the tab in the current split.
While navigating the list, the switcher previews each selected tab in its
editor behind the popup. Enter commits the selection; Escape restores the
previously active tabs. This live preview is built into Zed 1.24.2 and needs
no setting. That version's tab switcher does not support a separate preview
pane inside the popup like the file and text finders do.
Enter accepts and Escape dismisses pickers using native bindings.

For direct tab navigation within the current pane, native `[b`/`]b` move
to the previous/next tab. `gt`/`gT`
and the JetBrains `Cmd-Shift-[`/`Cmd-Shift-]` shortcuts are also available.
`Space Tab` switches to the alternate file (normally the previous tab);
repeating it toggles between the two most recently active files in that
pane. `Space Space`/`Cmd-E` remain the searchable switcher across all panes,
while native `Ctrl-Tab` cycles recent tabs in the current pane.

`Cmd-Shift-O` and `Cmd-Shift-N` remain file-finder aliases with the same preview.
`Cmd-P` retains JetBrains' manual signature help; automatic signature help
remains enabled, and Vim insert mode also retains `Ctrl-S` for manual help.

In both the file and text finders, `Cmd-Enter` opens the selected result in
a vertical split to the right. Plain Enter opens it in the current pane.
The binding matches the finder itself and its nested input/menu contexts,
overriding generic editor handling without changing other pickers or Enter
behavior in normal code editing. It uses the native `pane::SplitRight`
handlers registered by the two finders.

The file and project-text shortcuts run an `action::Sequence`: open the
picker, then `picker::SetPreviewRight`. This explicitly requests a preview
every time these shortcuts are used, even if it was previously hidden.
Zed 1.24.2 otherwise remembers the last layout separately for each picker
in local state; there is no `file_finder.show_preview` setting.
Inside a picker that supports previews, `Cmd-Alt-P` toggles the preview,
`Cmd-Alt-Right` places it on the right, and `Cmd-Alt-Down` places it below.
These preview panes are separate from Zed's reusable preview-tab settings.

### Explorer and terminal

`Cmd-W` closes tabs; `when_closing_with_no_tabs = "keep_window_open"`
keeps the workspace window open when no tabs remain.
`Space q` uses the same native close action in Vim normal mode. It presents
the native save/discard/cancel prompt when closing would discard unsaved
changes, and a Save As dialog when saving an untitled buffer. It does not
run from terminal inputs or dock panels.

The project explorer is docked on the left (`project_panel.dock = "left"`).
Its default width is 300 pixels, with Catppuccin file/folder icons, expansion
chevrons, bold folder labels and always-visible indent guides. A 16-pixel
indent keeps deeper trees compact; the active guide uses the blue accent.

`Cmd-Enter` on a selected explorer file opens it in a new vertical split
to the right, using `project_panel::OpenSplitVertical` (the default vertical
split direction is right). It also works for files already open in another
pane. For directories, the action expands/collapses the entry. The binding
only applies while browsing, leaving filename editing unchanged.

`Esc` while browsing the explorer focuses the central editor and leaves
the explorer open. During file creation/rename, the first `Esc` retains
native cancellation; a subsequent `Esc` returns to the editor. The mapping
uses `workspace::FocusCenterPane` directly, bypassing panel-toggle behavior.

- `Cmd-1` — open/focus the project explorer.
- `Cmd-2` — open/focus the integrated terminal.
- `Cmd-Shift-2` — create a new integrated terminal tab (`workspace::NewTerminal`).
- `Cmd-3` — open/focus the symbol outline; press it inside the outline to
  close that panel and return to the editor.
- `Cmd-4` — open/focus Git.
- `Cmd-5` — open/focus project diagnostics; press it within that view to
  close its tab and return to the previous item. Diagnostics is a central
  workspace view, not a dock panel.
- `Cmd-T` — open/close the task picker to select a test or other task.

The Command shortcuts apply throughout the workspace, including insert mode
and the terminal. `Cmd-1`, `Cmd-3` and `Cmd-4` use Zed's native `ToggleFocus`
actions with `close_panel_on_toggle = true`: open/focus the panel from
elsewhere, then close it and return to the editor when pressed within it.
`Cmd-2` uses `terminal_panel::Toggle`, the native terminal action used by
the JetBrains preset for `Alt-F12`. It opens/focuses the terminal panel and
hides it when pressed while the panel is focused, returning to the editor.
Existing terminal sessions remain running when hidden; `Cmd-Shift-2` is
the separate command for creating a new terminal. These panel actions and
the JetBrains bindings were checked against the installed Zed 1.25.3 source.
The overrides also match Pane, where JetBrains supplies its own number-key
bindings; GitPanel, whose native `Cmd-1/2` switch Changes/History; and
DebugPanel, whose native `Cmd-5` would otherwise close the debugger. Dock
input/menu contexts keep the same panel numbers while editing a filter or
commit message. Central modal dialogs retain their own more specific shortcuts.
The macOS keymap spells `Cmd-Shift-2` as `cmd-@` on the standard US/Polish
programmer layout. New terminal creation is separate from `Cmd-2` focus/toggle.

### Pane and dock navigation

`Ctrl-h/j/k/l` focus the visible pane or dock to the left/below/above/right.
They work in Vim normal and visual modes, empty panes, dock panels (including
their text fields) and the integrated terminal. Hidden docks remain closed;
use their `Cmd` shortcuts to open them. Main editor insert mode retains its
typing shortcuts. Finder inputs use `Ctrl-j`/`Ctrl-k` and `Ctrl-Down/Up`
for result navigation.

`Ctrl-Left/Down/Up/Right` provide the same directional pane/dock navigation.
They also work in editor insert mode, on the tab bar and in dock input fields.
Central picker/search-input bindings retain their own handling.
These shortcuts focus visible areas; use `Space Space` or `Cmd-E`
to select a tab within or across panes.

In the terminal both `Ctrl-h/j/k/l` and `Ctrl-Left/Down/Up/Right` are reserved
for Zed navigation, including when a terminal application is running; they
are not forwarded to the shell/TUI. Enter and Backspace retain their usual
functions. Zed's native `Cmd-K` clears the terminal, and `Cmd-Delete` sends
the shell's `Ctrl-K`.

`Ctrl-w h/j/k/l` and `Ctrl-w Left/Down/Up/Right` focus areas in Vim normal/
visual modes and non-terminal docks, including their input fields. Holding
Control for the second key works for both letter and arrow variants too.
The terminal retains `Ctrl-w` for shell word deletion; use direct
`Ctrl-h/j/k/l` or `Ctrl-Left/Down/Up/Right` to leave it.

`Ctrl-Shift-h/j/k/l` and `Ctrl-Shift-Left/Down/Up/Right` move the active
central tab to the pane in that direction and follow it. They work in
normal/visual/insert mode and central terminals. They do not operate from
dock panels, so editing a commit message cannot move an unrelated central
tab. If there is no adjacent pane, Zed creates one when the source contains
more than one tab; with one tab and no destination it does nothing. An empty
source pane disappears after a move.

`Ctrl-w Shift-H/J/K/L` and `Ctrl-w Shift-Left/Down/Up/Right` move the entire
pane. The shifted arrow chords deliberately override native pane swapping
to match their letter equivalents; `Ctrl-w x` retains native swapping.

### Code navigation

These Zed 1.24.2 Vim bindings use native actions. `g D` opens the definition
in a split instead of going to the declaration, and the custom `[f`/`]f`
aliases replace collaborator-following shortcuts with function motions.
Navigation requests depend on the active language server's capabilities.

| Shortcut            | Action                                   |
| ------------------- | ---------------------------------------- |
| `g d`               | Go to definition                         |
| `g D`               | Open definition in the pane to the right |
| `g y`               | Go to type definition                    |
| `g I` / `g r i`     | Go to implementation                     |
| `g r r`             | Find all references                      |
| `K` / `g h`         | Show documentation/hover                 |
| `Ctrl-o` / `Ctrl-i` | Back/forward through navigation history  |
| `Ctrl-w g d`        | Open definition in a split               |
| `Ctrl-w g D`        | Open type definition in a split          |
| `[f` / `]f`         | Previous/next function or method start   |
| `[F` / `]F`         | Previous/next function or method end     |

`g i` keeps Vim's insert-at-previous-position behavior; the implementation
shortcut uses uppercase `I` or the `g r i` sequence.
`g D` uses `editor::GoToDefinitionSplit`: it reuses the pane to the right,
or creates a vertical split there if needed. `g d` stays in the current pane.
See [Zed Vim mode](https://zed.dev/docs/vim).

Function motions use the same native actions as `[m`/`]m` and `[M`/`]M`.
They work in normal, visual and operator-pending modes and use the language's
Tree-sitter text-object queries rather than LSP. Supported languages also
provide native `vif`/`vaf` to select a function body/whole function and `dif`
or `cif` to delete/change its body. No standalone parser compiler is required.
See [Zed text objects](https://zed.dev/docs/extensions/languages#text-objects).

Panel toggling, directional navigation (including visible docks) and the
diagnostics context were checked against the installed version's published
workspace/diagnostics implementation. The code-navigation bindings were
checked against its native Vim keymap. The updated settings/keymap parsed
successfully and loaded without new keymap/context errors in Zed's log.
Interactive panel switching and the diagnostics toggle were not exercised.

### Symbol navigation

`Cmd-3` opens/focuses the native Outline Panel on the right and closes it
when pressed inside the panel, including its filter. `Cmd-F12` opens the compact
file-symbol picker; `Cmd-O` opens the project-symbol picker.

The outline panel follows the current editor and reveals the symbol near
the cursor using Zed's defaults. It also summarizes multibuffers, including
search results, references and diagnostics. Project symbols depend on the
active language server's workspace-symbol support. See
[Outline Panel](https://zed.dev/docs/outline-panel) and
[the native action reference](https://zed.dev/docs/all-actions).

The symbol actions and panel setting were checked against Zed's documented
actions and settings; the existing file-symbol picker is unchanged.

### Languages and formatting

The shared settings select one language server per language and enable
formatting on save for the languages below. `Cmd-S` saves the current file,
including the configured formatting and import actions. `Cmd-Alt-L` formats
the buffer, or the selection in Vim visual mode. Project settings in
`.zed/settings.json` can override formatting choices.

| Language                                    | Language server      | Formatter                     |
| ------------------------------------------- | -------------------- | ----------------------------- |
| Rust                                        | rust-analyzer        | rustfmt through rust-analyzer |
| Go                                          | gopls                | gofumpt inside gopls          |
| JavaScript (including JSX), TypeScript, TSX | vtsls                | Prettier                      |
| JSON, JSONC                                 | json-language-server | Prettier                      |
| YAML                                        | yaml-language-server | Prettier                      |
| TOML                                        | Tombi                | Tombi through LSP             |
| Markdown                                    | Marksman             | Prettier                      |

Rust, Go, JavaScript/TypeScript, JSON and YAML support is built into Zed.
The `toml` extension supplies TOML syntax support; the current version no
longer includes an LSP. The official [Tombi extension](https://github.com/tombi-toml/tombi/tree/main/editors/zed)
adds TOML completion, validation and formatting.
Markdown syntax support is built in; [Marksman](https://github.com/vitallium/zed-marksman)
adds navigation, link completion and diagnostics. These three extensions
are declared in `auto_install_extensions` and install at app startup.
Restart an already running Zed after adding them for the first time.

Zed and its extensions download missing language servers when needed;
existing supported installations on PATH may be used first. Zed's managed
Prettier integration uses a project installation when available and supplies
a fallback otherwise. No global npm formatter installation is required. Rust, Go and Node runtimes remain
managed by the global mise config; Rust's toolchain includes rustfmt.
Go explicitly runs `source.organizeImports` before formatting through gopls:
it adds missing imports, removes unused ones and sorts them. Gopls uses
its integrated gofumpt formatter and enables Staticcheck diagnostics; separate
`goimports`, `gofmt`, `gofumpt` or `staticcheck` processes are not required.

JavaScript, TypeScript and TSX run vtsls's `source.organizeImports` before
Prettier, combining/sorting imports and removing unused ones. Missing imports
remain available through completions and code actions. These actions run on
explicit save and on `Cmd-Alt-L`.
`Cmd-Alt-O` requests import organization separately.

Rust uses the active toolchain's rustfmt through rust-analyzer, preserving
the crate edition and project formatting rules. Stable rustfmt sorts imports
by default. Rust-analyzer runs Clippy on save for all targets, with build-script
and procedural-macro support. Its separate `target/rust-analyzer` build cache
reduces contention with terminal Cargo builds at the cost of extra disk space.
No `--all-features` override is imposed, so projects retain their selected features.

Rust-analyzer does not provide a generic `source.organizeImports` action.
Unused imports are diagnosed by Rust/Clippy and can be removed using
`Alt-Enter` (or the remove-unused-imports assist on a selection); they are
not removed automatically on save. `Cmd-Alt-O` therefore does not apply to Rust.
No broad quick-fix action runs on save. JSON, YAML, TOML and Markdown retain
their dedicated formatters; import organization is not configured for data
or prose formats.

Formatting follows project configuration such as `rustfmt.toml`,
`.prettierrc`, `.prettierignore` and `tombi.toml`. Per-language editor choices
can be overridden in `.zed/settings.json`. The repository's hk checks keep
using their independently pinned tools (including Taplo, yamlfmt and rumdl),
so editor formatting does not replace the required repository checks.
See [Zed's language configuration](https://zed.dev/docs/configuring-languages)
and [Prettier integration](https://zed.dev/docs/languages/typescript).

The language settings were checked against Zed 1.24.2's published defaults
and extension manifests and parsed with Zed's installed JSONC parser.
The installed rust-analyzer accepted the configured initialization options
and returned formatting edits on a temporary Rust crate; Clippy passed for
all targets. Zed's gopls accepted its options, added a missing import, removed
an unused import, returned formatted code and supplied function-call completions
with editable argument placeholders. The resulting Go sample passed `go test`.
First-start extension installation and formatting through the remaining
language servers have not been exercised.

#### Java and Kotlin imports

Java's JDTLS settings keep both regular and static imports explicit by setting
`java.sources.organizeImports.starThreshold` and `staticStarThreshold` to
`2147483647` (the maximum Java integer). These apply when using the
[Java extension](https://github.com/zed-extensions/java) and its `jdtls`
server, including import organization with `Cmd-Alt-O`. The extension is
installed separately. See [JDTLS import preferences](https://github.com/eclipse-jdtls/eclipse.jdt.ls/blob/main/org.eclipse.jdt.ls.core/src/org/eclipse/jdt/ls/core/internal/preferences/Preferences.java).

Kotlin uses the official JetBrains `kotlin-lsp` supplied by the
[Kotlin extension](https://zed.dev/docs/languages/kotlin). Its import code
style comes from the project's `.editorconfig`; there is no equivalent
global Zed import setting. Add this section to each Kotlin project's
`.editorconfig` at the project root (next to `settings.gradle.kts`,
`build.gradle.kts` or `pom.xml`), keeping any existing sections. This follows
[JetBrains' own import rules](https://github.com/JetBrains/intellij-community/blob/master/.editorconfig):

```ini
[{*.kt,*.kts}]
ij_kotlin_name_count_to_use_star_import = 2147483647
ij_kotlin_name_count_to_use_star_import_for_members = 2147483647
ij_kotlin_packages_to_use_import_on_demand =
```

The empty package list also disables the usual `java.util`, `kotlinx.android.synthetic`
and `io.ktor` wildcard exceptions. Run `Cmd-Alt-O` to organize existing imports
after the project has loaded; names must resolve for wildcard expansion to work.
Project `.editorconfig` rules and local/project Zed overrides can take precedence
over shared defaults.

**Validation:** the updated shared settings parsed with Zed's installed
JSONC parser and opened in Zed 1.25.3 with no new settings errors in its log.
The Java preference keys were checked against JDTLS sources; import edits
through JDTLS and a Kotlin project have not been exercised.

### Completion and Go snippets

Language servers and automatic completion menus are explicitly enabled,
with completion documentation and automatic signature help. Snippets appear
at the top of the completion menu. Gopls enables `usePlaceholders` and
`completeFunctionCalls` so accepting a function call supplies editable
arguments. AI remains disabled; these features use language servers and
local snippets.

`snippets/go.json` contains nine project-specific snippets for wrapped errors,
parallel table tests and controller-runtime helpers, plus these eight basic
Go constructs:

| Prefix  | Expansion                                       |
| ------- | ----------------------------------------------- |
| `func`  | Function declaration                            |
| `meth`  | Method with a pointer receiver                  |
| `forr`  | Range over a slice/map with index/key and value |
| `forc`  | Range over a channel until it closes            |
| `fori`  | Counted loop                                    |
| `iferr` | Return on error                                 |
| `main`  | Main function                                   |
| `test`  | Parallel test function                          |

The snippets are maintained directly in `zed/snippets/go.json`.

In Vim insert mode, type a prefix and choose its snippet in the completion
menu. Enter accepts it; Tab/Shift-Tab move through its placeholders, including
when another completion menu is open inside a placeholder. Tab does not
accept a completion in that menu. `Ctrl-n`/`Ctrl-p` use Zed's existing menu
navigation. `Ctrl-x Ctrl-o` explicitly opens completions in Vim insert mode;
`Ctrl-Space` is also available if macOS has not reserved it for input switching.
Structural snippets work without a running LSP; symbol suggestions,
auto-imports and call signatures require a healthy language server.
See [Zed snippets](https://zed.dev/docs/snippets) and
[code completions](https://zed.dev/docs/completions).

All 17 snippet bodies were expanded with their default placeholders and
accepted by the real Go toolchain's gofmt parser. Settings, keymap and snippet JSON
parsed successfully, repository checks passed, and opening the files in Zed
produced no new configuration errors. Interactive completion-menu selection
and placeholder navigation were not exercised.

### IDE code actions and refactoring

These IDE shortcuts remain available alongside Vim movements:

| Shortcut                             | Action                                             |
| ------------------------------------ | -------------------------------------------------- |
| `Alt-Enter`                          | Code actions and available refactorings            |
| `Shift-F6`                           | Rename symbol                                      |
| `Space r n` (normal mode)            | Rename symbol                                      |
| `Cmd-Alt-L`                          | Format buffer; format selection in Vim visual mode |
| `Cmd-Alt-O`                          | Organize imports                                   |
| `Cmd-B`                              | Go to definition                                   |
| `Cmd-Alt-B`                          | Go to implementation                               |
| `Cmd-Shift-B`                        | Go to type definition                              |
| `Alt-F7`                             | Find references/usages                             |
| `Cmd-J`                              | Show documentation/hover                           |
| `Cmd-P` / `Ctrl-S` (Vim insert mode) | Show signature help                                |
| `Cmd-[` / `Cmd-]`                    | Navigate backward/forward                          |
| `F2` / `Shift-F2`                    | Next/previous diagnostic                           |
| `Cmd-F` / `Cmd-R`                    | Find/replace in the current file                   |
| `Cmd-Shift-R`                        | Replace across the project                         |
| `Cmd-S` / `Cmd-W`                    | Save/close the active tab                          |

Vim's `gd`, `gy`, `grr`, `gri`, `K` and `Ctrl-o`/`Ctrl-i` remain native.
Splits use native `Ctrl-w v` (side by side), `Ctrl-w s` (stacked),
`Ctrl-w H/J/K/L` (move pane), `Ctrl-w =` (equal sizes) and
`Ctrl-w q` (close active tab; an empty split disappears).
Directional letter/arrow pairs are aligned as described above.

Refactorings such as extracting a function or inlining are offered through
`Alt-Enter` when the active language server supports them. Rename and import
organization also depend on server capabilities. In Vim visual mode,
`Cmd-Alt-L` requests selection formatting, which requires range support.
Use the command palette for less frequent actions such as restarting an LSP.

For Go's `Create variable err` quick fix, place the cursor inside `err` or
select only that identifier (`viw` in Vim normal mode), then press `Alt-Enter`.
This creates an undeclared variable; it is different from Extract variable.
With gopls 0.24.0, a selection starting at indentation or `if` can still offer
the quick fix but fail with `execute command: no identifier found`. This was
reproduced against Zed's installed gopls; the cursor/word cases succeeded.
Keep expression/block selections for Extract variable/function instead.

### Running tests

`Cmd-T` opens Zed's native task picker. Open a source/test file, type `test`
to filter the available tasks, select one and press Enter. Results appear
in the terminal dock; `Cmd-2` returns to them. Press `Cmd-T` again to dismiss
the picker. Explicit Terminal and DebugPanel contexts override native new
terminal/thread-picker handling, keeping the task shortcut consistent there.
Use `Cmd-Shift-2` to create a new terminal instead.

`Cmd-Shift-6` reruns the last task with its original captured context. This
keeps a chosen test/package selected when navigating to other files. It reruns
the most recent task of any kind, so launching a build replaces the previous
test as the rerun target. The macOS keymap spells this shortcut `cmd-^`
(`Shift-6` on the standard US/Polish programmer layout).

`Cmd-Alt-6` invokes `editor::SpawnNearestTask` in a full editor. Inside a
detected test it runs that test/subtest; elsewhere it can run a nearby
runnable, such as `main`, so it is not an unconditional test-only action.

Shared tasks prefixed `Test Go` and `Test Rust` in `zed/tasks.json` all use
`save = "all"`. Zed awaits the save operation before starting the command,
even with autosave disabled. Go tasks cover a test/example,
subtest, table case, testify suite method, package and module. Rust tasks
cover a test, doc test, module, package and Cargo workspace. Native runnable
tags connect those definitions to gutter buttons and the nearest-task
shortcut, with shared templates preceding language/LSP tasks. Project-local
tag overrides in `.zed/tasks.json` take priority and should also set
`save = "all"`. Other native/project tasks retain their own save policy.

Go provides native tasks for the current test/subtest, package and whole
module (`go test ./...`); availability depends on the cursor's context.
Rust supplies Cargo/rust-analyzer tasks for tests and test modules. Gutter
play buttons provide another way to run individual detected tests. JS/TS
projects should define their actual test command in `.zed/tasks.json`
(for example a project-owned npm test script); this config does not assume
Jest, Vitest or install a test framework globally. Set `"save": "all"` on
project-owned test tasks as well.

Zed 1.24.2 provides a task picker and terminal output rather than a dedicated
test tree with per-test pass/fail badges. See [Zed Tasks](https://zed.dev/docs/tasks)
and [Zed's test-running workflow](https://zed.dev/docs/migrate/rustrover#running-tests).
Bindings and task behavior were checked against the published 1.24.2 sources.
All 11 shared test commands passed against temporary dependency-free Go/Rust
projects, including individual-test/subtest selection and paths with spaces.
Interactive task selection and GUI shortcut behavior were
not exercised.

### Git actions

`Cmd-4` opens/focuses Git; press it within the focused panel to close it.
The native JetBrains aliases remain available: `Cmd-0` or `Cmd-K` opens
Git, `Cmd-~` opens the branch menu, and `Cmd-Shift-K` invokes Push.
History, diffs, stashes and worktrees are available through the Git UI and
command palette. No Git operation is executed when loading the keymap.
See [Zed Git](https://zed.dev/docs/git).

### Local data and bootstrap

Zed natively loads `global_settings.json` as defaults, then applies the
machine's `settings.json` on top. Shared changes belong in
`zed/global_settings.json`; settings changed through Zed's UI are written
to the ignored `zed/settings.json` and stay local. Local overrides take
precedence, so remove an override to inherit the shared value again.
Zed also writes `ssh_connections` into `settings.json`; keep that field and
all private connection details out of `global_settings.json`. No merge
script or additional settings loader is needed. See the
[settings loader in Zed 1.25.3](https://github.com/zed-industries/zed/blob/v1.25.3/crates/settings/src/settings_store.rs#L1377).

**Migrating another machine:** before updating this checkout, close Zed and
back up its existing `~/.config/zed/settings.json` outside the repository.
If local edits to that tracked file block the update, first verify the backup,
then run `git restore -- zed/settings.json` from the checkout and update again.
The update removes that formerly tracked file. Afterwards, restore only
`ssh_connections` and any intentional machine-specific overrides into a
new `~/.config/zed/settings.json`; do not restore the entire old config,
because its duplicate values would override future shared changes.
Verify that `git check-ignore zed/settings.json` reports the local file as
ignored before reopening Zed. Preserve the backup until the connections
and settings have been checked.

Files outside the allowlist are ignored, including the local `prompts/`
database. They will live physically under this repo once the directory is
linked, but remain untracked and are not shared between machines. Add an
explicit allowlist entry before tracking any additional custom config.
The Zed app is declared as `brew-cask:zed` in the macOS config.

For an existing installation, preview the directory link with:

```sh
mise bootstrap dotfiles apply --dry-run --force ~/.config/zed
```

Before applying, move the existing `~/.config/zed` directory to a backup
outside this repo, keeping its prompt database and any other local data.
Copy desired shared preferences into `zed/global_settings.json` and shared
keymaps/tasks into their respective files, then apply only the directory
link with:

```sh
mise bootstrap dotfiles apply ~/.config/zed
```

The local `prompts/` directory and a `settings.json` containing only private
connections and machine-specific overrides can then be copied from the
backup into the linked directory if needed; Git will ignore them.

**Validation:** bootstrap was checked with `--dry-run`; the Git allowlist
keeps global settings, keymap, tasks and the declared Go snippets shareable,
while local settings, backups and tool-written state remain ignored.
For the settings split, Zed 1.25.3's native loading/merge order was reviewed;
both JSONC files parsed, shared values matched the previous configuration,
and opening the shared file produced no new config errors in Zed's log.
Git confirmed that `settings.json` is ignored and absent from the index.
The rebuilt keymap was checked against
Zed 1.24.2's published macOS JetBrains/Vim presets and key-context precedence.
The settings and keymap parsed with Zed's installed JSONC parser. Repository
checks and app-log loading checks are recorded when the configuration changes;
interactive shortcut behavior has not been exercised.
