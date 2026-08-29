# Util tools

Small, general-purpose CLI utilities — things invoked briefly as part of
normal shell use, as opposed to the standalone TUI apps in
[core_tools.md](./core_tools.md) (tmux, lazygit, k9s). All of them are
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

The file is named `bat/config` with **no extension** — bat's real config
file has none, unlike this repo's other `.toml`-named configs; a
`.toml`-suffixed file would never be found once symlinked.

**What's configured:** `--theme="Catppuccin Mocha"` (bundled with bat
itself — no vendoring needed, unlike [atuin](#atuin) or
[lazygit](./core_tools.md#lazygit)); `--style=numbers,changes,header` (line
numbers, git-modification markers, filename header; deliberately excludes
bat's other defaults, `grid` and `snip`, for a leaner look);
`--italic-text=always` (comments etc. render italic where the theme uses
it, off by default). `--style=header` (rather than the current default
`header-filename`) remains a supported alias in 0.26.1.

**Validation:** no linter exists for bat's config format, and per this
repo's policy no custom step fills that gap (see [linting.md](./linting.md)).
A deliberately broken config produces a clear error from the real bat
binary; this file doesn't, but that check isn't automated going forward.

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

**`LS_COLORS`/`EZA_COLORS` silently override this theme if either is set**
— eza prefers them over `theme.yml` for file-kind colors (directories,
executables, etc.) with no warning; other elements (permissions, size,
user, timestamps) aren't affected. `shell/.zshrc` unsets `LS_COLORS` in the
eza block for exactly this reason — see [shell.md](./shell.md).

**Installing eza on macOS requires a Rust toolchain.** eza publishes GitHub
release binaries for Linux and Windows only; aqua's own registry definition
(`aqua-registry/pkgs/eza-community/eza`) unconditionally routes `darwin` to
`type: cargo` across every version. So on macOS, `aqua:eza-community/eza`
and `cargo:eza` are the same thing, and cargo has no standalone install —
it ships with the rest of the Rust toolchain. See
[langs.md](./langs.md#rust) for that toolchain; it's a meaningfully heavier
dependency than anything else here (compiles from source, ~35s vs. an
instant binary download) — the tradeoff chosen over `vfox:eza` (would
contradict this repo's `disable_backends = ["asdf", "vfox"]` rule) or
skipping eza entirely. The `cargo:eza` lock entry in `mise/mise.lock` has no
per-platform checksums, unlike the aqua-backed tools here — expected, not a
gap: cargo-managed installs don't work that way; reproducibility comes from
the pinned crate version (`--locked`) and crates.io's immutability instead.

**Validation:** no linter exists for eza's theme format beyond generic YAML
syntax (`yamlfmt`, already applied via `hk.pkl`'s catch-all `**/*.yml`
glob — no bespoke step needed). A load-test step (mirroring
[bat](#bat)'s or [tmux](./core_tools.md#tmux)'s) was deliberately **not**
added: verified that eza silently falls back to defaults on a malformed
`theme.yml` (exit 0, no error) rather than failing, so such a check would
never actually catch a broken theme — it would just be for show.

## fd

No config file lives here. [fd](https://github.com/sharkdp/fd) has a real,
XDG-mapped global ignore file — `$XDG_CONFIG_HOME/fd/ignore` (verified in
its docs) — but no default patterns are added; there's nothing to exclude
by default beyond what fd already respects (`.gitignore`, `.ignore`,
`.fdignore`). Revisit if a real need for global excludes shows up.

## fzf

`fzf/config` is a flat options file (one flag per line, same format as
[bat](#bat)'s), using this repo's blue accent (`#89b4fa`) for matches,
pointer, prompt, and header — rather than the official
[catppuccin/fzf](https://github.com/catppuccin/fzf) Mocha theme (which
ships one fixed, non-blue palette), for consistency with the accent used
everywhere else in this repo.

**Activated.** `shell/.zshrc` sets
`FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"` (guarded — fzf
hard-fails if this points to a missing file, unlike ripgrep below — see
[shell.md](./shell.md)).

**Validation:** no linter exists for fzf's options-file format, and per
this repo's policy no custom step fills that gap (see
[linting.md](./linting.md)). fzf exits `2` on a bad flag, giving a clear
signal if this file ever breaks, but that check isn't automated going
forward.

## glow

`glow/` maps to `~/.config/glow/`
([glow](https://github.com/charmbracelet/glow) follows XDG directly). Its
primary use is `glow file.md` — render once and exit, like
[bat](#bat) — though a `--tui`/`-t` flag also opens an interactive
file-browsing mode if wanted; grouped here rather than in
[core_tools.md](./core_tools.md) since rendering a file is the documented,
default use.

**Theme:** `glamour.json` is the official
[catppuccin/glamour](https://github.com/catppuccin/glamour) Mocha style
(glow renders markdown through Charm's `glamour` library, also used by
`gh`/`glab`/`gitea`), vendored as-is — headings use a deliberate rainbow
scale by design (h1 red through h6 lavender), and links/images already
land on this repo's blue accent (`#89b4fa`) in the official style, so no
accent swap was needed here, unlike [bottom](./core_tools.md#bottom).

**No `glow.yml` is shipped, and the theme is wired through a shell alias,
not the config file.** glow's own config `style` field has no path
expansion at all — checked directly against the real binary: neither a
leading `~`, nor `$HOME`, nor `$XDG_CONFIG_HOME` inside `glow.yml`'s
`style:` value resolves, and there's no `GLOW_STYLE`/`GLAMOUR_STYLE`
environment variable either (also checked directly). It also fails
*silently* on a bad or unresolved path — it just renders unstyled, no
error — so a broken reference here wouldn't even be visible as an error.
An explicit `--style <path>` flag does work correctly, so `shell/.zshrc`
aliases `glow` to always pass one:

```sh
alias glow="glow --style \"\$XDG_CONFIG_HOME/glow/glamour.json\""
```

No other `glow.yml` settings were worth overriding beyond the theme, so no
file is shipped for it — same call as [fd](#fd)/[jq](#jq) having nothing to
add.

**Validation:** no linter exists for glamour's JSON style format beyond
generic JSON syntax, and this repo doesn't currently lint JSON at all (this
is its first JSON file) — not worth adding a step for one vendored file.
Verified against the real `glow` binary directly: a deliberately broken
JSON style produces a clear "unable to create renderer" error; the
vendored file renders correctly (confirmed the h1 color matches the
style's `#f38ba8`). Not checked automatically going forward.

## jq

No config file here. [jq](https://github.com/jqlang/jq) doesn't have an
application-settings file — its only file-based mechanism is `~/.jq`, a
personal library of custom jq function definitions automatically included
in every invocation. That's fundamentally different from the theme/behavior
config every other tool here has (it's arbitrary user-authored jq code, not
settings), so nothing generic belongs there; skipped rather than inventing
filler content.

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

**Activated.** ripgrep has no auto-discovered config path — only
`RIPGREP_CONFIG_PATH`, which `shell/.zshrc` now exports (see
[shell.md](./shell.md)). Unlike [fzf](#fzf), ripgrep degrades gracefully
if this points to a missing file (a stderr warning, still exits `0` —
verified directly), so no existence guard was needed there.

**Validation:** no linter exists for ripgrep's options-file format, and per
this repo's policy no custom step fills that gap (see
[linting.md](./linting.md)); not something checked automatically going
forward.

## starship

`starship/starship.toml` maps to **`~/.config/starship.toml`** — a flat
file directly in `~/.config/`, *not* `~/.config/starship/starship.toml`.
Checked directly: `starship` has no notion of a `starship/` config
subdirectory at all; the directory here exists only to keep this repo's
one-directory-per-tool convention, matching how [tmux](./core_tools.md#tmux)
keeps its own directory despite also mapping outside the usual
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
malformed file still exits `0`, only logging to stderr, so no simple
exit-code check is possible. Investigated the stderr signal directly and
found it's not reliable enough to gate on anyway, on top of this repo's
general policy against hand-rolling checks for formats with no real linter
(see [linting.md](./linting.md)):

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

**Activated.** `shell/.zshrc` has `eval "$(zoxide init zsh)"` plus
`alias cd="z"` — see [shell.md](./shell.md). None of the optional
`_ZO_*` env vars above are set; defaults are fine for now.
