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

**What's configured:** `--theme="Catppuccin Mocha"` (bundled with bat
itself — no vendoring needed, unlike [atuin](#atuin) or
[lazygit](./core_tools.md#lazygit)); `--style=numbers,changes,header` (line
numbers, git-modification markers, filename header; deliberately excludes
bat's other defaults, `grid` and `snip`, for a leaner look);
`--italic-text=always` (comments etc. render italic where the theme uses
it, off by default).

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
(see [zoxide](#zoxide) for the same "not yet" caveat): the shell startup
file should not export a conflicting `LS_COLORS`/`EZA_COLORS`, or this
theme will only partially apply.

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
[bat](#bat)'s), vendored verbatim from the official
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
this repo yet — same gap as [zoxide](#zoxide)'s shell hook.

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
this repo yet — same gap as [zoxide](#zoxide) and [fzf](#fzf).

**Validation:** no linter exists for ripgrep's options-file format.
`ripgrep-check` in `hk.pkl` loads this file via `RIPGREP_CONFIG_PATH` and
runs a throwaway search; ripgrep exits `2` specifically on a bad flag (vs.
`0`/`1` for a normal found/not-found result), so the check distinguishes a
real config error from an expected non-match — same pattern as
[fzf-check](#fzf). Verified both directions.

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
malformed file still exits `0`, only logging to stderr, so no exit-code
check (like [bat-check](#bat)/[fzf-check](#fzf)) is possible. Investigated
the stderr signal directly and found it's not reliable enough to gate on:

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

**Deferred: shell integration.** The `eval "$(zoxide init zsh)"` line has
to live in a shell startup file (`.zshrc` or similar), which doesn't exist
in this repo yet. Nothing to configure here until that lands — tracked as
a gap, not forgotten.
