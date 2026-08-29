# Core tools

Standalone TUI applications this setup is built around — the tools you
"live inside" for a while, as opposed to the small utilities invoked
briefly in [util_tools.md](./util_tools.md). All of them are installed via
the **global mise config**, not by their own config files — see
[mise.md](./mise.md). (git + delta, mise itself, and the repo's own lint
tooling have their own pages: [git.md](./git.md), [mise.md](./mise.md),
[linting.md](./linting.md).)

## k9s

`k9s/config.yaml` and `k9s/skins/catppuccin-mocha.yaml` map to
`~/.config/k9s/` **only if `$XDG_CONFIG_HOME` is set**. Checked directly
(`k9s info`): on macOS, absent that env var, [k9s](https://k9scli.io/)
defaults to `~/Library/Application Support/k9s/` instead — same
non-XDG-on-macOS behavior as Go's own env file (see
[langs.md#go](./langs.md#go); k9s is a Go binary too). Kept the repo
directory named `k9s/` regardless, matching the tool name, per this repo's
usual convention — the actual OS-dependent target is what varies, same
shape of exception as [starship](./util_tools.md#starship) and
[tmux](#tmux). **Resolved:** `shell/.zshrc` now exports
`XDG_CONFIG_HOME` globally (see [shell.md](./shell.md)), so on a machine
with that shell config in place, k9s does land at `~/.config/k9s/` after
all — this exception only still applies without it.

**Found and fixed while setting this up:** both files were named `.yml`.
k9s expects `.yaml` — verified this isn't cosmetic: with `.yml`, k9s
doesn't even create a default `config.yaml`, it just silently uses hardcoded
defaults and never touches the file at all (confirmed by running against
both extensions and diffing what k9s reports/creates). Renamed both files.

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

**Validation:** k9s always exits `0`, even on malformed config — no
exit-code check is possible (same situation as
[starship](./util_tools.md#starship)/[eza](./util_tools.md#eza)). Unlike
starship's semantic warnings, though, k9s's parse-failure message
(`ERROR ... Unable to unmarshal`) *is* reliably reproducible on repeat
identical-content runs — verified directly, no dedup/caching involved.
`k9s-check` in `hk.pkl` greps for it via the non-interactive `k9s info`
command (no real cluster needed). One important subtlety: `k9s info`
auto-writes missing default files (`aliases.yaml` etc.) into whatever
config directory it's pointed at — so the check runs against a disposable
`mktemp -d` copy of `k9s/`, never the real directory. (Found out the hard
way: an earlier manual test pointed straight at the real repo directory and
left a stray `aliases.yaml` behind, since cleaned up.)

## lazygit

`lazygit/config.yml` maps to `~/.config/lazygit/config.yml`
([lazygit](https://github.com/jesseduffield/lazygit) follows XDG directly —
no exception needed here, unlike [tmux](#tmux) below).

**What's configured:** `git.diffRenderers` renders diffs through
[delta](https://github.com/dandavison/delta) (`delta --dark
--paging=never`) instead of lazygit's own diff view — see
[git.md](./git.md). `gui.theme` is the official
[catppuccin/lazygit](https://github.com/catppuccin/lazygit) Mocha "blue"
variant, matching the blue accent used everywhere else in this repo —
inlined directly since lazygit's config has no "load an external theme
file" mechanism to vendor against, unlike [atuin](./util_tools.md#atuin).
`gui.authorColors: '*': '#b4befe'` gives every commit author the same
lavender color instead of lazygit's default random-per-author colors, also
from the official theme. `gui.nerdFontsVersion: "3"` enables Nerd Font
icons, consistent with the icon usage in [tmux](#tmux)'s statusline below.

**Found and fixed while setting this up:** the file was originally named
`config.toml` with YAML content inside — lazygit's config is YAML
(`config.yml`); renamed. The theme block had an `overlapBorderColor` key;
checked against lazygit's own published JSON schema
([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))
— it isn't a valid key and doesn't exist in the official theme either;
removed as dead config. `inactiveViewSelectedLineBgColor` and
`cherryPickedCommitBgColor` were hand-picked shades that diverged from the
official theme; aligned with it per AGENTS.md's "prefer the official
Catppuccin port over a hand-rolled palette" rule.

**Validation:** no YAML *linter* is wired in here — checked, and the one
static-binary Rust option (`ryl`) self-describes as still maturing, so it
was skipped rather than added half-heartedly (same call as skipping a tmux
linter below — see [linting.md](./linting.md)). `yamlfmt` (format-only,
Google-maintained, single static binary) is wired in for
`**/*.yml`/`**/*.yaml` generally; `.yamlfmt` at the repo root sets
`retain_line_breaks: true` so this file's blank-line section separators
survive formatting. The config itself was validated against the real,
installed lazygit binary (schema-checked theme keys, then loaded end-to-end
under a pty against a throwaway git repo — it reached full TUI
initialization with no parse errors).

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
moves between tmux panes. `prefix g` opens a [lazygit](#lazygit) popup in
the current pane's directory. Statusline hand-rolled in Catppuccin Mocha
(blue accent, matching [git.md](./git.md) and
[atuin](./util_tools.md#atuin)) — no plugin manager, no third-party
plugins, just tmux's own format strings, which also means there's nothing
here to vet for trust beyond tmux itself.

**Validation:** there's no established third-party linter for `tmux.conf`
(checked; nothing comparable to `taplo`/`rumdl` exists for tmux config
syntax). The closest useful substitute — wired into `hk.pkl` as
`tmux-check` — asks tmux itself to load the config on a throwaway, isolated
server and reports any syntax/unknown-option errors, then tears the server
down. See [linting.md](./linting.md).
