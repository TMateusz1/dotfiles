# Linting & pre-commit (`hk`)

Git hooks and lint/format checks are managed by
[hk](https://hk.jdx.dev), configured in `hk.pkl` (repo root). hk is
mise-integrated (`HK_MISE = 1` in `mise.toml`): the installed git hook runs
through `mise x`, so it works even for someone who hasn't activated mise in
their shell.

## Setup is automatic

`mise.toml` sets:

```toml
[hooks]
postinstall = "hk install --mise"
```

So simply running `mise install` in the repo (which you need anyway, to get
`hk`/`taplo`/`rumdl`/`yamlfmt`/`shellcheck` themselves) installs the
`pre-commit` git
hook too. No separate setup step.

## What's checked

Defined once in `hk.pkl` and shared by the `pre-commit` git hook, `hk check
--all`, and `hk fix --all`:

- **`rumdl`** — Markdown lint + fix (`**/*.md`). Config: `.rumdl.toml`
  disables `MD013` (line-length) — tables and links routinely exceed 80
  chars in these docs, and that's fine. `MD055` is pinned to
  `leading-and-trailing` (every table row starts and ends with `|`, i.e.
  GitHub-style tables) rather than the default `consistent`, which only
  checks agreement within a single table and wouldn't catch a whole new
  table written in a different style.
- **`taplo`** / **`taplo-format`** — TOML lint and format/fix (`**/*.toml`).
- **`yamlfmt`** — YAML format check/fix (`**/*.yml`, `**/*.yaml`). Format
  only — no semantic YAML linter is wired in; see
  [core_tools.md#lazygit](./core_tools.md#lazygit) for why. `.yamlfmt` at
  the repo root sets `retain_line_breaks: true` so intentional blank-line
  section separators (e.g. in `lazygit/config.yml`) survive formatting.
- **`zshrc-check`** — `shellcheck --shell=bash` (shellcheck has no zsh
  dialect, but `bash` mode was verified to produce zero false positives
  against this file's zsh-specific syntax while still catching a real
  issue), excluding `SC1090`/`SC1091` (unavoidable noise for an rc file
  that legitimately sources dynamic content). See
  [shell.md](./shell.md#validation). This one stays because shellcheck is
  a real, established linter — not something hand-rolled for the occasion.
- **`detect-private-key`**, **`check-merge-conflict`**,
  **`check-added-large-files`**, **`trailing-whitespace`**, **`newlines`** —
  general repo hygiene, all built into hk itself (`hk util ...`), no extra
  tool installs. `detect-private-key` in particular backs the "never commit
  secrets" rule in [AGENTS.md](../AGENTS.md).

## No established linter, no check

Several config formats in this repo have no real third-party linter:
tmux.conf, bat's/fzf's/ripgrep's flat args files, k9s's YAML schema, and
kitty's config. Earlier revisions of `hk.pkl` hand-rolled a custom step for
each of these anyway — loading tmux.conf on a throwaway server, piping a
line through bat, grepping k9s's stderr for an `ERROR` line, reaching into
kitty's internal `kitty.config` Python module, and so on. Each one
individually was verified to work at the time, but collectively they were
custom-built validation logic invented specifically because no real tool
existed — exactly the kind of thing worth being suspicious of long-term
(more surface to maintain, more places an internal API change silently
breaks a check no one's looking at). Removed. These files were verified by
hand against the real binary when each was set up (see their own
`docs/*_tools.md` entries) and aren't checked automatically going forward.
The rule now: wire up a step only when a real, established tool exists for
the format (like `shellcheck` above) — never build a bespoke one to fill
the gap.

## Why rumdl, not markdownlint

`markdownlint-cli2` is the more established, actively-recommended tool (same
author as the underlying `markdownlint` rule engine). It was tried and
dropped: installing it via mise's npm backend pulled in ~140 transitive
packages, and hit a real supply-chain trust gate — a transitive dependency
(`fastq`) had a version published by hand instead of through its usual
CI-signed pipeline. Investigation suggested it was a benign maintainer
publish, not a compromise, but it illustrated the actual cost of an
npm-based tool here: you inherit its whole dependency tree's trust posture,
not just the one package's reputation. `rumdl` is a single static Rust
binary via aqua with no transitive dependency tree to vet, consistent with
every other tool in this repo (mise, delta, atuin, hk, taplo) — traded off
here against `rumdl` being newer and single-maintainer. Revisit if that
trade stops feeling right.

## Running manually

```sh
mise run pre-commit   # shortcut for `hk run pre-commit` (staged files)
hk check --all        # check the whole repo, no fixes applied
hk fix --all          # check the whole repo, applying fixes
```

To bypass the hook once (use sparingly): `HK=0 git commit`.
