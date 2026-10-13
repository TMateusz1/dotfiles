# Core tools

Standalone TUI applications this setup is built around — the tools you
"live inside" for a while, as opposed to the small utilities invoked
briefly in [util_tools.md](./util_tools.md). All of them are installed via
the **global mise config**, not by their own config files — see
[mise.md](./mise.md). (git + delta, mise itself, and the repo's own lint
tooling have their own pages: [git.md](./git.md), [mise.md](./mise.md),
[linting.md](./linting.md).)

## bottom

`bottom/bottom.toml` maps to `~/.config/bottom/bottom.toml` **only if
`$XDG_CONFIG_HOME` is set** — same shape of exception as
[k9s](#k9s)/[starship](./util_tools.md#starship): confirmed directly (a
sandboxed `HOME`+`XDG_CONFIG_HOME` run of the real `btm` binary resolves to
`$XDG_CONFIG_HOME/bottom/bottom.toml`), and this repo's `shell/.zshrc`
exports that variable, so it lands at `~/.config/bottom/` in practice.

**Not btop.** [btop](https://github.com/aristocratos/btop) — the tool
originally considered — publishes Linux-only release binaries; there's no
macOS build via any mise-native backend (`aqua`, `ubi`/`github`), and the
only real macOS install path is Homebrew building it from source, which
this repo's tool list otherwise avoids requiring. [bottom](https://github.com/ClementTsang/bottom)
(`btm`) is the substitute: a Rust TUI system/process monitor with real
`aarch64-apple-darwin` release binaries, verified installable via
`aqua:ClementTsang/bottom` with no Homebrew involved.

**Theme:** based on the official
[catppuccin/bottom](https://github.com/catppuccin/bottom) Mocha theme —
its multi-color semantic assignments (per-core CPU colors, RAM/cache/swap,
network rx/tx, battery high/medium/low) are kept exactly as upstream, since
those colors carry real meaning rather than being decorative. Two
selection-highlight values deviate to this repo's blue accent (`#89b4fa`),
same call as [k9s](#k9s)'s deviation: `selected_border_color` (official:
pink `#f5c2e7`) and `selected_text.bg_color` (official: mauve `#cba6f7`).

**Validation:** TOML *syntax* is covered by `taplo` via `hk.pkl`'s
catch-all `**/*.toml` glob, same as [yazi](#yazi)'s theme — but nothing
validates bottom's *schema* (whether a key or colour field is one bottom
actually recognises), and per this repo's policy no custom step fills that
gap (see [linting.md](./linting.md)). Verified against the real `btm`
binary via its own `-C <path>` flag (never the default config location, to
avoid writing into a real config path during testing): a deliberately
broken file produces a clear TOML parse error with line/column; this file
loads cleanly into the TUI. Not checked automatically going forward.

## k9s

`k9s/config.yaml` and `k9s/skins/catppuccin-mocha.yaml` map to
`~/.config/k9s/` **only if `$XDG_CONFIG_HOME` is set**. On macOS, absent
that env var, [k9s](https://k9scli.io/) defaults to
`~/Library/Application Support/k9s/` instead — same non-XDG-on-macOS
behavior as Go's own env file (see [langs.md#go](./langs.md#go); k9s is a
Go binary too). The repo directory is still named `k9s/`, matching the
tool name, per this repo's usual convention — the actual OS-dependent
target is what varies, same shape of exception as
[starship](./util_tools.md#starship) and [tmux](#tmux). In practice this
doesn't come up on a machine with this repo's `shell/.zshrc` in place,
since it exports `XDG_CONFIG_HOME` globally (see [shell.md](./shell.md)),
landing k9s at `~/.config/k9s/` as expected — the exception only applies
without that shell config.

Both files use the `.yaml` extension, not `.yml` — k9s requires it: with
`.yml`, k9s doesn't create or read a config file at all, it silently falls
back to hardcoded defaults with no error.

**What's configured:** `config.yaml` sets `ui.skin: catppuccin-mocha`,
`ui.enableMouse: false`, `ui.noIcons: false` — all verified against k9s's
own published JSON schema
([schemas/k9s.json](https://github.com/derailed/k9s/blob/master/internal/config/json/schemas/k9s.json))
to confirm they're current, not stale/renamed keys.

**Theme:** the skin is based on the official
[catppuccin/k9s](https://github.com/catppuccin/k9s) Mocha theme — most
sections (help, frame.title/menu/crumbs/status, views.table/xray/charts/
yaml/logs) match it byte-for-byte, confirmed by diffing against
`dist/catppuccin-mocha.yaml`. Three sections deliberately diverge, all in
the same direction as personalization seen elsewhere in this repo:
`body.logoColor` and `frame.border.focusColor` use this repo's blue accent
(`#89b4fa`) instead of the official mauve/lavender; `frame.border.fgColor`
uses a muted overlay0 gray instead of mauve; and `dialog` stays consistent
with the rest of the dark UI (dark background, light text, blue focus
button) rather than the official theme's lighter, higher-contrast "pop-out"
dialog style (light-gray background, dark text, pink focus button). Left
as-is rather than reverted to official — reads as a coherent, deliberate
choice (blue accent + fully-dark UI) rather than arbitrary drift, unlike
the [lazygit](#lazygit) case that did get aligned to its official theme.
Worth revisiting if that read is wrong.

**Validation:** no established linter exists for k9s's config, and per this
repo's policy (see [linting.md](./linting.md)) no bespoke one fills the
gap. Not checked automatically going forward.

## lazygit

`lazygit/config.yml` maps to `~/.config/lazygit/config.yml` — YAML,
matching lazygit's config format (`.yml`, not `.toml`, despite some other
tools in this repo using TOML). No placement exception needed here:
[lazygit](https://github.com/jesseduffield/lazygit) follows XDG directly,
unlike [tmux](#tmux) below.

**What's configured:** `git.diffRenderers` renders diffs through
[delta](https://github.com/dandavison/delta) (`delta --dark
--paging=never`) instead of lazygit's own diff view — see
[git.md](./git.md). `gui.theme` matches the official
[catppuccin/lazygit](https://github.com/catppuccin/lazygit) Mocha "blue"
variant key-for-key, including `inactiveViewSelectedLineBgColor` and
`cherryPickedCommitBgColor` — inlined directly since lazygit's config has no
"load an external theme file" mechanism to vendor against, unlike
[atuin](./util_tools.md#atuin). Every color comes from that official theme
rather than a hand-picked shade, per [AGENTS.md](../AGENTS.md)'s "prefer
the official Catppuccin port over a hand-rolled palette" rule.
`overlapBorderColor` isn't set here — it isn't a valid key in lazygit's own
published JSON schema
([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))
or in the official theme. `gui.authorColors: '*': '#b4befe'` gives every
commit author the same lavender color instead of lazygit's default
random-per-author colors, also from the official theme.
`gui.nerdFontsVersion: "3"` enables Nerd Font icons, consistent with the
icon usage in [tmux](#tmux)'s statusline below.

**Validation:** no YAML *linter* is wired in here — the one static-binary
Rust option (`ryl`) self-describes as still maturing, so it's skipped
rather than added half-heartedly (same call as skipping a tmux linter
below, and this repo's general policy — see [linting.md](./linting.md)).
`yamlfmt` (format-only, Google-maintained, single static binary) is wired
in for `**/*.yml`/`**/*.yaml` generally; `.yamlfmt` at the repo root sets
`retain_line_breaks: true` so this file's blank-line section separators
survive formatting.

## tmux

`tmux/.tmux.conf` maps to **`~/.tmux.conf`** — not the XDG path
(`~/.config/tmux/tmux.conf`). This is a deliberate exception to the usual
directory/symlink convention (see [AGENTS.md](../AGENTS.md)): tmux checks
`~/.tmux.conf` *before* the XDG path, so if both exist, `~/.tmux.conf` wins
unconditionally. Targeting the XDG path here would silently do nothing on
any machine that still has a stray legacy `~/.tmux.conf` lying around.
Filename keeps the leading dot for the same reason — it's not a stylistic
choice, it's the literal filename tmux requires at that path. The status
metrics helper is linked separately to `~/.config/tmux/status-metrics.sh`.

**What's configured:** prefix is `C-b`, with `C-a` as a secondary prefix;
`prefix r` reloads the config. `tmux-256color` terminal type with truecolor overrides,
extended-keys passthrough (e.g. Shift-Enter), focus events (Neovim
autoread), application-title forwarding (`set-titles` with `#T`, so Neovim's
current buffer title reaches the Kitty tab/window), OSC52 clipboard
passthrough for remote copy/paste. Vi-style copy mode and vi-style editing in
tmux command prompts, mouse on, 100k-line scrollback, and `escape-time 100`, a
temporary mitigation for tmux 3.7c misparsing split OSC 52 replies as input
([upstream issue](https://github.com/tmux/tmux/issues/5388)), while still short
enough not to fight Neovim's `<Esc>`. Smart pane navigation (`C-h/j/k/l`) that forwards
to Neovim/fzf when one of those is running in the current pane, otherwise
moves between tmux panes. The same treatment covers the arrow-key
equivalents (`C-Left/Down/Up/Right`) and `C-\` (jump to the previously used
pane). At an outside edge the directional keys emit a tmux passthrough sequence
containing the narrowly scoped `tmux_kitty_navigate` Kitty user variable. The
local watcher described in
[desktop_tools.md](./desktop_tools.md#seamless-kitty-tmux-and-neovim-navigation)
moves to the adjacent Kitty split, including when tmux is reached over SSH;
there is no local control socket for the remote VM to access or forward. See
[nvim.md](./nvim.md#plugins) for the Neovim-side counterpart. `prefix g` opens a [lazygit](#lazygit) popup in
the current pane's directory. Statusline hand-rolled in Catppuccin Mocha
(blue accent, matching [git.md](./git.md) and
[atuin](./util_tools.md#atuin)), using tmux's own format strings.
The right side also shows host CPU,
used memory and combined disk read/write throughput in a separate Catppuccin
green block beside the clock. The values refresh every five seconds through
[`status-metrics.sh`](../tmux/status-metrics.sh); it uses macOS or Linux system
tools and reflects the machine running the tmux server.
Beside the current pane directory, the current Git branch appears with the
same `` symbol and Catppuccin peach color as Starship. The Git query uses the
pane directory with shell quoting, including for paths containing spaces.
The branch label is hidden outside repositories or when HEAD is detached.
On macOS, MEM uses `vm_stat` page counters and `sysctl hw.memsize`, excluding
file-backed and purgeable cache while including wired memory and the physical
compressor footprint. This follows the [Stats RAM reader](https://github.com/exelban/stats/blob/master/Modules/RAM/readers.swift)
and avoids the near-100% readings produced by `top`'s cache-inclusive PhysMem
summary. It measures memory usage; [memory pressure](https://support.apple.com/guide/activity-monitor/actmntr1004/mac)
is a separate indicator of how efficiently macOS is serving memory requests.
On Linux, CPU comes from `/proc/stat`, memory from `/proc/meminfo` and disk
throughput from whole leaf devices in `/sys/block/*/stat`, excluding partitions,
stacked storage layers and loop/RAM-backed devices. The CPU total excludes the
guest counters already included in user/nice time.

When adding the metrics helper to an existing installation, apply its new
symlink before reloading tmux; `prefix r` only reloads the config and does
not provision files:

```sh
mise bootstrap dotfiles apply --yes '~/.config/tmux/status-metrics.sh'
```

Then reload with `prefix r`. The helper prints one complete line per sample
and uses the C locale so parsing is independent of the shell's language.

Session and title shortcuts: `prefix C` prompts for a new session name and
starts it in the current pane's directory; `prefix S` renames the session,
`prefix W` renames the window, and `prefix T` renames the pane. These use
uppercase letters (`Shift+C/S/W/T`), distinct from Control-letter keys.
The built-in `prefix $` and `prefix ,` rename-session and rename-window
bindings remain available too.
With `status-keys vi`, these prompts use vi-style editing: `h`/`l` move the
cursor, `b`/`w` move by word, and `0`/`$` jump to the start/end of the input.

`prefix s` opens [SessionX](https://github.com/omerxx/tmux-sessionx), replacing
the native session picker with fuzzy search and a pane preview. Enter selects
a session or creates one from a new name; within the popup, `Ctrl+r` renames,
`Alt+Backspace` deletes, `Ctrl+w` lists windows, and Escape closes the picker.
It uses the existing mise-managed fzf and bat, fzf's built-in tmux popup mode,
and the shared Catppuccin colors. The current session remains in the list.
Plain `tc` opens the complete SessionX plugin in every context. Outside tmux,
it attaches to an existing session and immediately opens SessionX, including
the attached session in the list. With the server stopped, it starts tmux,
lets Continuum restore the saved environment, then attaches and opens the
same picker. With no saved sessions, it creates `core` in the home directory
as the plugin's host. Escape closes the picker and leaves you attached.
`tc name` skips the picker and creates, attaches to, or switches to that exact
session name.
See [shell helpers](./shell.md#tmux-session-picker) for startup use.

[Resurrect](https://github.com/tmux-plugins/tmux-resurrect) and
[Continuum](https://github.com/tmux-plugins/tmux-continuum) save the environment
automatically every 15 minutes and restore the latest snapshot when the tmux
server starts. Saves live in `~/.local/share/tmux/resurrect/`, outside this
public repository. `prefix Ctrl+s` saves immediately; `prefix Ctrl+r` restores
manually. These are Control-letter keys, distinct from `prefix S` for renaming.
Snapshots restore sessions, windows, pane layouts and working directories;
supported programs can be restarted, but process memory is not preserved.
Pane-content capture remains disabled by default.

All three plugin checkouts live under `~/.local/share/tmux/plugins/` and are
pinned to exact upstream revisions in `mise.toml`'s `[bootstrap.repos]`.
`mise run bootstrap:plugins` provisions them; no TPM is needed. Provision the
plugins before the first config reload. Continuum loads after Resurrect and
the statusline, so its invisible autosave job survives config reloads.
Its upstream debug trace goes to `~/.local/share/tmux/plugins/tmux-continuum.log`
instead of appearing in a pane when the config loads.
Autosave needs an attached client refreshing the statusline; it does not run
on a timer while every client is detached. Continuum also suppresses automatic
save/restore when it detects another tmux server, to avoid mixing snapshots.

`prefix [` / `prefix ]` select the previous/next window and can be repeated
for one second after a single prefix. Ctrl-bracket variants work too; in legacy
terminals `Ctrl+[` is Escape, so `prefix Escape` also selects the previous
window with the same repeat timeout. These replace the stock bracket shortcuts: use
`prefix PageUp` for scrollback and `prefix P` to paste the tmux buffer.

`prefix w` captures the current session ID before filtering windows, including
when several sessions are attached. `run-shell -C` executes a native tmux command
and `##` delays the per-item format expansion; no shell command is needed.
Terminal overrides and features use fixed array
slots 10–12, preserving tmux's built-in entries and keeping repeated config
reloads from appending duplicate capabilities. The status blocks use square
edges and the same Mocha colors with fewer redundant style changes.

**Validation:** there's no established third-party linter for `tmux.conf`
(nothing comparable to `taplo`/`rumdl` exists for tmux config syntax), and
per this repo's policy no custom step fills the gap — see
[linting.md](./linting.md). Not checked automatically going forward.

The 2026-09-30 review loaded the original and revised configs in separate
temporary tmux 3.7c servers. Three reloads left every revised option and binding
identical. Terminal capability values matched the original config; other options
and bindings matched apart from the intended window-picker filter, shorter
status formats and unused palette variables. With two attached test clients,
the actual `prefix w` picker showed only its client's current session.
The 2026-10-08 navigation change was reviewed against tmux 3.7c's
`command-alias`, `pane_at_*` and passthrough syntax. The sandbox used for the
change prohibited creating a tmux server socket, so config loading and the real
desktop/SSH navigation round trip still need an attached client check.

The 2026-10-11 metrics fix applied the helper's missing symlink through mise,
ran the helper on macOS and obtained numeric CPU, RAM and disk throughput
readings, then reloaded the live tmux server. tmux's job diagnostics confirmed
the attached client was running the helper. The script passed ShellCheck.

The bracket navigation fix was tested in a temporary tmux server with an
attached PTY client: a single `C-a` followed by repeated `[` or `]` switched
windows on every keypress. Repeated legacy `Ctrl+[` (Escape) also worked.
The tested config was then reloaded in the live server. Linux metric counters
were reviewed against the kernel documentation; Linux runtime verification
remains outstanding because no running Linux environment was available.

The 2026-10-12 macOS memory correction was checked against live `vm_stat`
counters and the installed RAM size: the helper reported about 60% usage,
excluding reclaimable cache, where the earlier PhysMem-based reading was
near full. The revised script passed ShellCheck and requires no tmux reload:
the status command reads it again on each refresh.

The Git branch status command was checked in a temporary tmux server for a
repository, its subdirectory, a non-Git directory, and a path containing spaces
and quotes. The label matched the branch or was hidden as appropriate. The
updated status format was applied to the live server.

The 2026-10-12 session plugins were checked on an isolated tmux 3.7c server
with an attached PTY client: both prefixes opened SessionX and selected the
requested session. Continuum saved when its interval was due; after killing
that test server, Resurrect recovered two sessions, three windows, four panes
and their directories. The live server was reloaded twice, with one autosave
status job retained, and that job created the first machine-local snapshot.
Automatic startup restoration is enabled; the kill/restore test exercised
Resurrect manually because Continuum suppresses automatic restoration while
the user's separate live server exists. TOML and Markdown checks passed.

## yazi

`yazi/` maps to `~/.config/yazi/` **only if `$XDG_CONFIG_HOME` is set** —
same shape of exception as [k9s](#k9s)/[bottom](#bottom): on macOS without
it, [yazi](https://yazi-rs.github.io/) defaults to
`~/Library/Application Support/yazi/` instead. Confirmed directly via
`ya env` (yazi's own diagnostic subcommand) in a sandboxed environment.
This repo's `shell/.zshrc` exports `XDG_CONFIG_HOME`, so it lands at
`~/.config/yazi/` in practice.

**Contents:**

- `theme.toml` — the official
  [catppuccin/yazi](https://github.com/catppuccin/yazi) Mocha "blue"
  variant (yazi's own README instructs renaming whichever flavor/accent file
  you pick to `theme.toml`). Vendored as-is apart from **one deliberate
  edit**, the status-bar separators — see below.
- `Catppuccin-mocha.tmTheme` — vendored from
  [catppuccin/bat](https://github.com/catppuccin/bat)'s `themes/`
  directory, per catppuccin/yazi's own setup instructions: `theme.toml`'s
  `syntect_theme` key points at this file for Catppuccin-consistent syntax
  highlighting in yazi's file preview pane. The path in `theme.toml` is
  already correct for this repo's deployment model (`~/.config/yazi/...`),
  since the two files land in the same symlinked directory.

No `yazi.toml`/`keymap.toml` — yazi's built-in defaults weren't worth
overriding, and per this repo's philosophy nothing is added just to have a
file present (same call as [fd](./util_tools.md#fd)/[jq](./util_tools.md#jq)
having no config here).

**Square status bar.** Upstream's `[status]` block draws the mode and
permission blocks with powerline half-circles — `sep_left`/`sep_right` set to
U+E0B6 (`` ) and U+E0B4 (`` ). Those are the only rounded edges in the
bottom-bar stack: tmux's status line draws no separators at all, just colour
fills, and Neovim's lualine is angular. Both separators are therefore set to
empty strings, which leaves yazi's blocks with hard square edges to match:

```toml
[status]
sep_left = { open = "", close = "" }
sep_right = { open = "", close = "" }
```

Yazi is used directly from the shell; Neovim uses
[Neo-tree](./nvim.md#file-explorers-oil-and-neo-tree) for its sidebar.

**Shell integration:** `shell/.zshrc` adds a `y()` function — the wrapper
from yazi's own quick-start docs. yazi runs as a child process, so it can't
change its parent shell's working directory itself; `y()` runs yazi with
`--cwd-file`, then `cd`s the shell to whatever directory yazi wrote there
on exit.

**Validation:** no established linter exists for yazi's TOML config beyond
generic syntax (already covered by `taplo`), and no custom step fills that
gap either. Verified against the real `ya env`/`yazi` binaries directly: a
deliberately broken `theme.toml` produces a clear TOML parse error with
line/column from `ya env` (`ya env` needs a TTY, so this runs under `script`);
the vendored file loads without one — `ya env` exits 0 and reports
`Theme: .../theme.toml (41483 chars)` after the separator edit above.

That the edit reaches the right keys was confirmed against the binary rather
than assumed: yazi 26.9.1 embeds the Lua that renders the bar, and it reads
`th.status.sep_left.open` / `.close` through `ui.Span(...)`, so those key names
are current and an empty string is a valid span that draws nothing. Note the
rendered bar itself could not be captured here — yazi needs real terminal
dimensions, and a `script` pty in this environment only ever flushed a partial
first frame, so the visual result is unverified even though the config is. Not
checked automatically going forward.
