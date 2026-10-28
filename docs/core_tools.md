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
catch-all `**/*.toml` glob — but nothing
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
[starship](./util_tools.md#starship). In practice this
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
[lazygit](https://github.com/jesseduffield/lazygit) follows XDG directly.

**What's configured:** `git.diffRenderers` renders diffs through
[delta](https://github.com/dandavison/delta) (`delta --dark
--paging=never`) instead of lazygit's own diff view — see
[git.md](./git.md). `gui.theme` matches the official
[catppuccin/lazygit](https://github.com/catppuccin/lazygit) Mocha "blue"
variant key-for-key, including `inactiveViewSelectedLineBgColor` and
`cherryPickedCommitBgColor` — inlined directly since lazygit's config has no
"load an external theme file" mechanism to vendor against. Every color
comes from that official theme
rather than a hand-picked shade, per [AGENTS.md](../AGENTS.md)'s "prefer
the official Catppuccin port over a hand-rolled palette" rule.
`overlapBorderColor` isn't set here — it isn't a valid key in lazygit's own
published JSON schema
([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))
or in the official theme. `gui.authorColors: '*': '#b4befe'` gives every
commit author the same lavender color instead of lazygit's default
random-per-author colors, also from the official theme.
`gui.nerdFontsVersion: "3"` enables Nerd Font icons.

**Validation:** no YAML *linter* is wired in here — the one static-binary
Rust option (`ryl`) self-describes as still maturing, so it's skipped
per this repo's general policy — see [linting.md](./linting.md).
`yamlfmt` (format-only, Google-maintained, single static binary) is wired
in for `**/*.yml`/`**/*.yaml` generally; `.yamlfmt` at the repo root sets
`retain_line_breaks: true` so this file's blank-line section separators
survive formatting.

## Zellij

The global mise config pins `aqua:zellij-org/zellij` to `0.45.1`, with
downloads/checksums in `mise/mise.lock`. It uses `theme "catppuccin-mocha-blue"`
with the official theme from Zellij 0.45.1 copied into the config and small
overrides: unselected ribbons use Catppuccin Mocha Blue (`#89b4fa`) instead
of the pale Text background. Active ribbons retain Mocha Green (`#a6e3a1`).
Shortcut letters on both backgrounds use Mocha Mantle (`#181825`) instead
of red, matching the dark labels for better contrast.
This colors native Zellij UI components. The top bar uses the same
Mocha palette, configured separately below. The complete theme is included because
omitted components fall back to Zellij's defaults rather than inherit Catppuccin.
The custom name matters: Zellij 0.45.1 loads built-in themes after inline
definitions, replacing any inline theme with the same name.
**Ctrl+Arrow** focuses the pane in that direction in every mode except
Locked, staying within the current tab. **Ctrl+Shift+Left/Right** switches
to the previous/next tab, also in every mode except Locked. **`Ctrl+l`**
enters the personal bindings group: **`l`** sends Ctrl+l to the focused
application for clear/redraw, and **`g`** opens [lazygit](#lazygit) in a
centered floating pane, 80% wide and tall, using the focused pane's current
directory. Both actions return to Normal. Exit lazygit with `q` to close
the popup. Esc, Enter, Ctrl+c, or Ctrl+l cancels the group.
Zellij has fixed modes, so this group replaces tmux compatibility mode and
is labeled TMUX in the native bottom bar. Ctrl+b passes through in Normal;
Ctrl+o remains Session mode. In Locked mode, Ctrl+l passes through directly.

The default layout has a custom top bar using
[zjstatus](https://github.com/dj95/zjstatus), pinned to `0.25.0`, and the native
Zellij mode/shortcut bar at the bottom. The top follows the old tmux styling:
a Blue session ribbon and tabs on the left; directory, Peach Git branch,
and a Blue Warsaw clock on the right. Every segment has the same arrow
shape, including the Surface 0 directory ribbon. The active tab uses
Green, inactive tabs use Blue, and a clickable Blue `+` ribbon opens a new tab.
Built-in swap layouts remain
available. Git context follows the focused pane, refreshes every three seconds,
and hides outside repositories. Detached HEAD shows a short commit.
See the [bar setup and key reference](./zellij.md#top-bar-session-tabs-directory-branch-and-clock).

`zellij/config.kdl` maps to **`~/.config/zellij/config.kdl`** through native
mise `[dotfiles]` provisioning. Only the file is linked because Zellij's
configuration UI can write settings/backups. Other files under `zellij/`
stay ignored; plugin caches and session state stay machine-local.
Zellij downloads the pinned plugin URL on first use. No helper scripts,
extra layouts or additional bootstrap entries are needed.

Start with `zellij`, or use `za work` with this repo's Zsh config. Outside
Zellij it attaches/creates with `zellij attach --create work`; inside it
uses `zellij action switch-session work` to switch the current client.
Bare `za` inside a session opens the floating session manager.
To start at the session manager, use `zellij -l welcome` (`zs` in Zsh): the built-in
welcome screen lets you select a running session, resurrect an exited
session, or create a new one. Inside a session, use `Ctrl+o`, then `w`.
In Zellij 0.45.1, `Ctrl+r` in the manager renames the current session,
regardless of the highlighted row. In `zs`, that is the temporary welcome
session. To rename a project session, attach to it first, then open the
manager with `Ctrl+o`, `w`, press `Ctrl+r`, type the name and press Enter.
Alternatively, target a running session from another shell with
`zellij --session old-name action rename-session new-name`.
On another machine:

```sh
mise install --locked aqua:zellij-org/zellij
mise bootstrap dotfiles apply --yes '~/.config/zellij/config.kdl'
```

See [Zellij](https://zellij.dev/) and the
[official Catppuccin port](https://github.com/catppuccin/zellij).

**Validation:** Zellij 0.45.1 accepted the custom theme and personal Ctrl+l
group (`l` sends byte 12; `g` runs lazygit) with `setup --check`.
The custom top bar and native bottom hints were loaded in an isolated PTY
session, including alignment, Git context updates, the clock, new tabs, swap
layouts, and lazygit popup. See [validation details](./zellij.md#validation).
