# CLI tools

General-purpose CLI/TUI tools configured in this repo. All of them are
installed via the **global mise config**, not by their own config files —
see [mise.md](./mise.md). (git + delta, mise itself, and the repo's own
lint tooling have their own pages: [git.md](./git.md), [mise.md](./mise.md),
[linting.md](./linting.md).)

## atuin

`atuin/` maps to `~/.config/atuin/` ([atuin](https://atuin.sh) follows XDG
directly). Contents:

- `atuin/config.toml`
  - `auto_sync = false` — no history is synced to any server by default;
    sync requires an explicit `atuin login`/opt-in on a given machine. This
    is a public dotfiles repo, so nothing here should assume a signed-in
    sync account.
  - `sync_frequency = "5m"` — takes effect only once sync is enabled.
  - `search_mode = "fuzzy"`, `filter_mode = "global"`, `style = "compact"`,
    `enter_accept = true` — search/UI behavior preferences.
  - `[theme] name = "catppuccin-mocha-blue"` — Catppuccin Mocha, blue accent
    (`#89b4fa`), matching the accent used in [git.md](./git.md)'s delta
    theme for cross-tool consistency.
- `atuin/themes/catppuccin-mocha-blue.toml` — vendored from
  [catppuccin/atuin](https://github.com/catppuccin/atuin) (mocha/blue
  variant), since atuin loads named themes from `themes/` next to
  `config.toml` rather than shipping them built in.

## bat

`bat/config` maps to `~/.config/bat/config`
([bat](https://github.com/sharkdp/bat) follows XDG directly). The config
format is a flat args file (one CLI flag per line, blank lines ignored) —
not TOML, despite the name of other tools' config files in this repo.

**What's configured:** `--theme="Catppuccin Mocha"` (bundled with bat
itself — no vendoring needed, unlike atuin or lazygit below);
`--style=numbers,changes,header` (line numbers, git-modification markers,
filename header; deliberately excludes bat's other defaults, `grid` and
`snip`, for a leaner look); `--italic-text=always` (comments etc. render
italic where the theme uses it, off by default).

**Found and fixed while setting this up:** the file was named
`config.toml`. bat's real config file has **no file extension at all** —
so a `.toml`-suffixed file would never have been found once symlinked;
renamed to `bat/config`. The flag values themselves were already correct —
verified `--style=header` is still a valid component in 0.26.1 (default is
now `header-filename`, but plain `header` remains a supported alias), and
`--italic-text=always` plus the theme name resolve as documented, tested
against the actual installed binary.

**Validation:** no linter exists for bat's config format (checked). The
closest useful check — wired into `hk.pkl` as `bat-check` — pipes a
throwaway line through `bat` with `BAT_CONFIG_PATH` pointed at this file;
bat fails loudly with a clear error on any unknown or malformed flag
(verified against a deliberately broken config first, to confirm the check
has teeth).

## eza

`eza/theme.yml` maps to `~/.config/eza/theme.yml`
([eza](https://github.com/eza-community/eza) follows XDG directly, and
looks specifically for a file named `theme.yml`, wherever
`EZA_CONFIG_DIR`/`$XDG_CONFIG_HOME/eza` points).

**What's configured:** vendored verbatim from the official
[catppuccin/eza](https://github.com/catppuccin/eza) Mocha "blue" theme,
matching the blue accent used everywhere else in this repo. Sets
per-filetype colors (directories, symlinks, executables, ...), permission
bit colors, and size/date colors.

**Important — `LS_COLORS`/`EZA_COLORS` silently override this theme:**
verified directly: with `LS_COLORS` set in the environment (common —
macOS/most shells set a default), eza's file-kind colors (directories,
executables, etc.) come from `LS_COLORS` instead of `theme.yml`, with no
warning. Other elements (permissions, size, user, timestamps) aren't
affected. Confirmed by testing the same command with and without
`LS_COLORS` set. **Follow-up for whenever shell integration is set up**
(see zoxide below for the same "not yet" caveat): the shell startup file
should not export a conflicting `LS_COLORS`/`EZA_COLORS`, or this theme
will only partially apply.

**Installing eza on macOS required adding a Rust toolchain:** eza publishes
GitHub release binaries for Linux and Windows only — checked its releases
directly, and confirmed at the source that aqua's own registry definition
(`aqua-registry/pkgs/eza-community/eza`) unconditionally routes `darwin` to
`type: cargo` across every version. So on macOS, `aqua:eza-community/eza`
and `cargo:eza` are the same thing, and cargo has no standalone install —
it ships with the rest of the Rust toolchain. See
[langs.md](./langs.md#rust) for that toolchain; it's a meaningfully heavier
dependency than anything else here (compiles from source, ~35s vs. an
instant binary download), a deliberate tradeoff the user chose over
`vfox:eza` (would contradict this repo's `disable_backends = ["asdf",
"vfox"]` rule) or skipping eza. The `cargo:eza` lock entry in
`mise/mise.lock` has no per-platform checksums, unlike the aqua-backed
tools here — expected, not a gap: cargo-managed installs don't work that
way; reproducibility comes from the pinned crate version (`--locked`) and
crates.io's immutability instead.

**Validation:** no linter exists for eza's theme format beyond generic YAML
syntax (`yamlfmt`, already applied via `hk.pkl`'s catch-all `**/*.yml`
glob — no bespoke step needed). A load-test step (mirroring bat's or
tmux's above/below) was deliberately **not** added: verified that eza
silently falls back to defaults on a malformed `theme.yml` (exit 0, no
error) rather than failing, so such a check would never actually catch a
broken theme — it would just be for show.

## fd

No config file lives here. [fd](https://github.com/sharkdp/fd) has a real,
XDG-mapped global ignore file — `$XDG_CONFIG_HOME/fd/ignore` (verified in
its docs) — but no default patterns are added; there's nothing to exclude
by default beyond what fd already respects (`.gitignore`, `.ignore`,
`.fdignore`). Revisit if a real need for global excludes shows up.

## fzf

`fzf/config` is a flat options file (one flag per line, same format as
bat's above), vendored verbatim from the official
[catppuccin/fzf](https://github.com/catppuccin/fzf) Mocha theme (the `.rc`
variant — a plain options file, as opposed to the `.sh` variant which wraps
the same content in a shell `export`).

Unlike the other tools' Catppuccin themes in this repo, catppuccin/fzf
ships one fixed Mocha palette rather than per-accent variants, so this
doesn't use the blue accent used elsewhere (delta, atuin, tmux, lazygit,
eza) — using the official theme as-is took priority over hand-editing it
for consistency.

**Deferred: activating it.** [fzf](https://github.com/junegunn/fzf) has no
auto-discovered config path. Loading this file requires
`export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"` (or the
resolved absolute path) in a shell startup file, which doesn't exist in
this repo yet — same gap as zoxide's shell hook below.

**Validation:** no linter exists for fzf's options-file format. `fzf-check`
in `hk.pkl` loads this file via `FZF_DEFAULT_OPTS_FILE` and runs a
throwaway filter; fzf exits `2` specifically on a bad flag (vs. `0`/`1` for
a normal found/not-found result), so the check distinguishes a real config
error from an expected non-match. Verified both directions: passes against
this file, fails against a deliberately broken one.

## jq

No config file here. [jq](https://github.com/jqlang/jq) doesn't have an
application-settings file — its only file-based mechanism is `~/.jq`, a
personal library of custom jq function definitions automatically included
in every invocation. That's fundamentally different from the theme/behavior
config every other tool here has (it's arbitrary user-authored jq code, not
settings), so nothing generic belongs there; skipped rather than inventing
filler content.

## k9s

`k9s/config.yaml` and `k9s/skins/catppuccin-mocha.yaml` map to
`~/.config/k9s/` **only if `$XDG_CONFIG_HOME` is set**. Checked directly
(`k9s info`): on macOS, absent that env var, [k9s](https://k9scli.io/)
defaults to `~/Library/Application Support/k9s/` instead — same
non-XDG-on-macOS behavior as Go's own env file (see
[langs.md#go](./langs.md#go); k9s is a Go binary too). Kept the repo
directory named `k9s/` regardless, matching the tool name, per this repo's
usual convention — the actual OS-dependent target is what varies, same
shape of exception as [starship](#starship) and [tmux](#tmux) above. If
the eventual shell setup ends up exporting `$XDG_CONFIG_HOME` globally (a
few tools in this repo now have a reason to want that), this placement
concern disappears on its own.

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
the lazygit case that did get aligned to its official theme. Worth
revisiting if that read is wrong.

**Validation:** k9s always exits `0`, even on malformed config — no
exit-code check is possible (same situation as
[starship](#starship)/[eza](#eza)). Unlike starship's semantic warnings,
though, k9s's parse-failure message (`ERROR ... Unable to unmarshal`) *is*
reliably reproducible on repeat identical-content runs — verified directly,
no dedup/caching involved. `k9s-check` in `hk.pkl` greps for it via the
non-interactive `k9s info` command (no real cluster needed). One important
subtlety: `k9s info` auto-writes missing default files (`aliases.yaml`
etc.) into whatever config directory it's pointed at — so the check runs
against a disposable `mktemp -d` copy of `k9s/`, never the real directory.
(Found out the hard way: an earlier manual test pointed straight at the
real repo directory and left a stray `aliases.yaml` behind, since cleaned
up.)

## lazygit

`lazygit/config.yml` maps to `~/.config/lazygit/config.yml`
([lazygit](https://github.com/jesseduffield/lazygit) follows XDG directly —
no exception needed here, unlike tmux below).

**What's configured:** `git.diffRenderers` renders diffs through
[delta](https://github.com/dandavison/delta) (`delta --dark
--paging=never`) instead of lazygit's own diff view — see
[git.md](./git.md). `gui.theme` is the official
[catppuccin/lazygit](https://github.com/catppuccin/lazygit) Mocha "blue"
variant, matching the blue accent used everywhere else in this repo —
inlined directly since lazygit's config has no "load an external theme
file" mechanism to vendor against, unlike atuin above.
`gui.authorColors: '*': '#b4befe'` gives every commit author the same
lavender color instead of lazygit's default random-per-author colors, also
from the official theme. `gui.nerdFontsVersion: "3"` enables Nerd Font
icons, consistent with the icon usage in tmux's statusline below.

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

## ripgrep

`ripgrep/config` is a flat options file (one flag per line — verified in
[ripgrep](https://github.com/BurntSushi/ripgrep)'s man page). No official
Catppuccin theme exists for ripgrep (its theming surface is narrow — just a
handful of `--colors type:attr:value` settings, not a full palette), so
this is hand-authored rather than vendored, using this repo's established
blue accent (`#89b4fa`, RGB `137,180,250`) for matches and paths, and a
muted subtext tone (`#a6adc8`, RGB `166,173,200`) for line numbers:

```text
--smart-case
--colors=match:fg:137,180,250
--colors=path:fg:137,180,250
--colors=line:fg:166,173,200
```

**Deferred: activating it.** ripgrep has no auto-discovered config path —
only `RIPGREP_CONFIG_PATH`, an environment variable that must point at this
file. That has to be set in a shell startup file, which doesn't exist in
this repo yet — same gap as zoxide and fzf above.

**Validation:** no linter exists for ripgrep's options-file format.
`ripgrep-check` in `hk.pkl` loads this file via `RIPGREP_CONFIG_PATH` and
runs a throwaway search; ripgrep exits `2` specifically on a bad flag (vs.
`0`/`1` for a normal found/not-found result), so the check distinguishes a
real config error from an expected non-match — same pattern as fzf-check
above. Verified both directions.

## starship

`starship/starship.toml` maps to **`~/.config/starship.toml`** — a flat
file directly in `~/.config/`, *not* `~/.config/starship/starship.toml`.
Checked directly: `starship` has no notion of a `starship/` config
subdirectory at all; the directory here exists only to keep this repo's
one-directory-per-tool convention, matching how [tmux](#tmux) below keeps
its own directory despite also mapping outside the usual
`~/.config/<tool>/` pattern.

**What's configured:** module order (`directory`, `git_branch`,
`git_status`, `git_state`, `golang`, `python`, `nodejs`, `helm`, then
`jobs`/`character`), with `$cmd_duration` on the right edge to keep the
left prompt short. Comments in the file note *why* `golang`/`python`/
`nodejs` render `$version` (~20-80ms, measured, cheap enough per prompt)
while `helm` stays symbol-only (~700ms measured — rendering its version
would exec `helm version` on every prompt in a chart directory).

**Theme:** the `[palettes.catppuccin_mocha]` table is a byte-for-byte match
of the official [catppuccin/starship](https://github.com/catppuccin/starship)
Mocha palette (`themes/mocha.toml`), verified by diffing all 26 values.
One deliberate addition beyond the official palette: a `cyan` key
duplicating `sky`'s value — starship recognizes bare `cyan` as a built-in
color name, so without this alias any style that used it would fall back
to the terminal's own cyan instead of a theme-consistent color. Not a
mistake; a completeness fix.

**Validation:** starship does **not** fail loudly on a bad config — a
malformed file still exits `0`, only logging to stderr, so no exit-code
check (like `bat-check`/`fzf-check`) is possible. Investigated the stderr
signal directly and found it's not reliable enough to gate on:

- Genuine TOML syntax errors *do* print a reliable, repeatable `ERROR` line
  to stderr — but syntax validity is already covered by the generic
  `taplo` lint step (`**/*.toml`), so a bespoke check here would be pure
  redundancy.
- Semantic errors (e.g. an unknown key) print a `WARN` line — but only
  the *first* time that exact config content is checked. Verified directly:
  re-running `starship print-config` against byte-identical broken content
  produces the warning once, then silently nothing on the next run,
  meaning a persistent typo could go undetected depending on whatever
  ran first. Not something to build a gate on.

No `starship-check` step was added, given neither signal holds up on its
own merits — not an oversight.

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
moves between tmux panes. `prefix g` opens a lazygit popup in the current
pane's directory. Statusline hand-rolled in Catppuccin Mocha (blue accent,
matching [git.md](./git.md) and atuin above) — no plugin manager, no
third-party plugins, just tmux's own format strings, which also means
there's nothing here to vet for trust beyond tmux itself.

**Validation:** there's no established third-party linter for `tmux.conf`
(checked; nothing comparable to `taplo`/`rumdl` exists for tmux config
syntax). The closest useful substitute — wired into `hk.pkl` as
`tmux-check` — asks tmux itself to load the config on a throwaway, isolated
server and reports any syntax/unknown-option errors, then tears the server
down. See [linting.md](./linting.md).

## yq

No config file here — checked directly (`yq --help`, docs): the
[mikefarah/yq](https://github.com/mikefarah/yq) build (the Go one, as
opposed to the Python jq-wrapper of the same name) has no config-file
mechanism at all, only CLI flags and expressions. Nothing to add.

## zoxide

No config file exists here (or anywhere) for
[zoxide](https://github.com/ajeetdsouza/zoxide) — checked its `--help`
output directly: it's driven entirely by environment variables and a shell
hook (`eval "$(zoxide init <shell>)"`), with no `~/.config/zoxide/*` file it
reads.

**Environment variables (not yet set anywhere):** zoxide reads these if
present; none are set by this repo yet: `_ZO_DATA_DIR` (where the
ranked-directory database lives), `_ZO_ECHO` (print the matched directory
before jumping), `_ZO_EXCLUDE_DIRS` (globs to exclude from ranking),
`_ZO_FZF_OPTS` (flags passed to `fzf` for interactive selection),
`_ZO_MAXAGE` (prune entries once total "age" exceeds this),
`_ZO_RESOLVE_SYMLINKS` (resolve symlinks before storing a path).

**Deferred: shell integration.** The `eval "$(zoxide init zsh)"` line has
to live in a shell startup file (`.zshrc` or similar), which doesn't exist
in this repo yet. Nothing to configure here until that lands — tracked as
a gap, not forgotten.
