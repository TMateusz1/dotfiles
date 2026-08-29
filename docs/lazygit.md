# lazygit

`lazygit/config.yml` maps to `~/.config/lazygit/config.yml`
([lazygit](https://github.com/jesseduffield/lazygit) follows XDG directly —
no exception needed here, unlike [tmux](./tmux.md)).

## What's configured

- `git.diffRenderers` renders diffs through
  [delta](https://github.com/dandavison/delta) (`delta --dark
  --paging=never`) instead of lazygit's own diff view — see
  [git.md](./git.md).
- `gui.theme` is the official
  [catppuccin/lazygit](https://github.com/catppuccin/lazygit) Mocha "blue"
  variant, matching the blue accent used everywhere else in this repo
  (delta, atuin, tmux) — inlined directly since lazygit's config has no
  "load an external theme file" mechanism to vendor against, unlike atuin.
- `gui.authorColors: '*': '#b4befe'` gives every commit author the same
  lavender color instead of lazygit's default random-per-author colors —
  also from the official theme.
- `gui.nerdFontsVersion: "3"` enables Nerd Font icons, consistent with the
  icon usage already in [tmux.md](./tmux.md)'s statusline.

## Found and fixed while setting this up

- The file was originally named `config.toml` with YAML content inside —
  lazygit's config is YAML (`config.yml`); a `.toml`-named file would never
  have been found once symlinked. Renamed.
- The theme block had an `overlapBorderColor` key. Checked against
  lazygit's own published JSON schema
  ([schema/config.json](https://github.com/jesseduffield/lazygit/blob/master/schema/config.json))
  — it isn't a valid key and doesn't exist in the official theme either;
  removed as dead config.
- `inactiveViewSelectedLineBgColor` and `cherryPickedCommitBgColor` were
  hand-picked shades that diverged from the official theme; aligned with it
  per AGENTS.md's "prefer the official Catppuccin port over a hand-rolled
  palette" rule.

## Validation

No YAML *linter* is wired in here — checked, and the one static-binary Rust
option (`ryl`) self-describes as still maturing, so it was skipped rather
than added half-heartedly (same call as skipping a tmux linter — see
[linting.md](./linting.md)). `yamlfmt` (format-only, Google-maintained,
single static binary) is wired in for `**/*.yml`/`**/*.yaml` generally.
`.yamlfmt` at the repo root sets `retain_line_breaks: true` so this file's
blank-line section separators survive formatting.

The config itself was validated against the real, installed lazygit binary
(schema-checked theme keys, then loaded end-to-end under a pty against a
throwaway git repo — it reached full TUI initialization with no parse
errors).

The `lazygit` binary itself is provided by the **global mise config**, not
installed by this config — see [mise.md](./mise.md).
