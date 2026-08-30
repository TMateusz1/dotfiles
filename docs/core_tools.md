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
choice, it's the literal filename tmux requires at that path.

**What's configured:** prefix remapped to `C-Space`; `prefix r` reloads the
config. `tmux-256color` terminal type with truecolor overrides,
extended-keys passthrough (e.g. Shift-Enter), focus events (Neovim
autoread), OSC52 clipboard passthrough for remote copy/paste. Vi-style copy
mode, mouse on, 100k-line scrollback, `escape-time 10` (fast enough not to
fight Neovim's `<Esc>`). Smart pane navigation (`C-h/j/k/l`) that forwards
to Neovim/fzf when one of those is running in the current pane, otherwise
moves between tmux panes. The same treatment covers the arrow-key
equivalents (`C-Left/Down/Up/Right`) and `C-\` (jump to the previously used
pane), so all three spellings behave identically whether or not Neovim owns
the pane — see [nvim.md](./nvim.md#plugins) for the Neovim-side
counterpart, vim-tmux-navigator, which binds the matching keys inside
Neovim's own splits. `prefix g` opens a [lazygit](#lazygit) popup in
the current pane's directory. Statusline hand-rolled in Catppuccin Mocha
(blue accent, matching [git.md](./git.md) and
[atuin](./util_tools.md#atuin)) — no plugin manager, no third-party
plugins, just tmux's own format strings, which also means there's nothing
here to vet for trust beyond tmux itself.

**Validation:** there's no established third-party linter for `tmux.conf`
(nothing comparable to `taplo`/`rumdl` exists for tmux config syntax), and
per this repo's policy no custom step fills the gap — see
[linting.md](./linting.md). Not checked automatically going forward.

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
  variant, vendored as-is (yazi's own README instructs renaming whichever
  flavor/accent file you pick to `theme.toml`).
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

**Shell integration:** `shell/.zshrc` adds a `y()` function — the wrapper
from yazi's own quick-start docs. yazi runs as a child process, so it can't
change its parent shell's working directory itself; `y()` runs yazi with
`--cwd-file`, then `cd`s the shell to whatever directory yazi wrote there
on exit.

**Validation:** no established linter exists for yazi's TOML config beyond
generic syntax (already covered by `taplo`), and no custom step fills that
gap either. Verified against the real `ya env`/`yazi` binaries directly: a
deliberately broken `theme.toml` produces a clear TOML parse error with
line/column from `ya env`; the vendored file loads without one. Not
checked automatically going forward.
