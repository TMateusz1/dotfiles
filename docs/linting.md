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
`hk`/`taplo`/`rumdl`/`yamlfmt` themselves) installs the `pre-commit` git
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
  [lazygit.md](./lazygit.md#validation) for why. `.yamlfmt` at the repo
  root sets `retain_line_breaks: true` so intentional blank-line section
  separators (e.g. in `lazygit/config.yml`) survive formatting.
- **`tmux-check`** — not a linter (none exists for tmux config), but a
  custom step that loads `tmux/.tmux.conf` on a throwaway, isolated tmux
  server and reports syntax/unknown-option errors. See
  [tmux.md](./tmux.md).
- **`detect-private-key`**, **`check-merge-conflict`**,
  **`check-added-large-files`**, **`trailing-whitespace`**, **`newlines`** —
  general repo hygiene, all built into hk itself (`hk util ...`), no extra
  tool installs. `detect-private-key` in particular backs the "never commit
  secrets" rule in [AGENTS.md](../AGENTS.md).

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
