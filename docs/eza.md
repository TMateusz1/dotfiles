# eza

`eza/theme.yml` maps to `~/.config/eza/theme.yml`
([eza](https://github.com/eza-community/eza) follows XDG directly, and
looks specifically for a file named `theme.yml`, wherever
`EZA_CONFIG_DIR`/`$XDG_CONFIG_HOME/eza` points).

## What's configured

The file is vendored verbatim from the official
[catppuccin/eza](https://github.com/catppuccin/eza) Mocha "blue" theme,
matching the blue accent used everywhere else in this repo. It sets
per-filetype colors (directories, symlinks, executables, ...), permission
bit colors, and size/date colors.

## Important: `LS_COLORS` / `EZA_COLORS` silently override this theme

Verified directly: with `LS_COLORS` set in the environment (common —
macOS/most shells set a default), eza's file-kind colors (directories,
executables, etc.) come from `LS_COLORS` instead of `theme.yml`, with no
warning. Other elements (permissions, size, user, timestamps) aren't
affected — only the parts `LS_COLORS` itself covers. Confirmed by testing
the same command with and without `LS_COLORS` set: the file-kind colors
only match the theme once `LS_COLORS` is unset.

**Follow-up for whenever shell integration is set up** (see
[zoxide.md](./zoxide.md) for the same "not yet" caveat): the shell startup
file should not export a conflicting `LS_COLORS`/`EZA_COLORS`, or this
theme will only partially apply.

## Installing eza on macOS required adding a Rust toolchain

eza publishes GitHub release binaries for Linux and Windows only — checked
its releases directly, and confirmed at the source that aqua's own registry
definition (`aqua-registry/pkgs/eza-community/eza`) unconditionally routes
`darwin` to `type: cargo` across every version. So on macOS,
`aqua:eza-community/eza` and `cargo:eza` are the same thing, and cargo has
no standalone install — it ships with the rest of the Rust toolchain.
`rust` was added to the global mise config to build this; it's also kept as
a general-purpose language toolchain in its own right (see
[mise.md](./mise.md)), not scoped only to `eza`. It's a meaningfully
heavier dependency than anything else here (compiles from source, ~35s vs.
an instant binary download), a deliberate tradeoff the user chose over
`vfox:eza` (would contradict this repo's `disable_backends
= ["asdf", "vfox"]` rule) or skipping eza.

The `cargo:eza` and `rust` lock entries in `mise/mise.lock` have no
per-platform checksums, unlike the aqua-backed tools elsewhere in this
repo — expected, not a gap: cargo/core-managed installs don't work that
way; reproducibility comes from the pinned crate version (`--locked`) and
crates.io's immutability instead.

## Validation

No linter exists for eza's theme format beyond generic YAML syntax
(`yamlfmt`, already applied via `hk.pkl`'s catch-all `**/*.yml` glob — no
bespoke step needed here). A load-test step (mirroring
[bat-check](./bat.md)/[tmux-check](./tmux.md)) was deliberately **not**
added: verified that eza silently falls back to defaults on a malformed
`theme.yml` (exit 0, no error) rather than failing, so such a check would
never actually catch a broken theme — it would just be for show.

The `eza` binary itself is provided by the **global mise config**, not
installed by this config — see [mise.md](./mise.md).
