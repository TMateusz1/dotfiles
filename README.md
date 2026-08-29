# dotfiles

Personal dotfiles, managed with [mise](https://mise.jdx.dev) and themed
consistently with [Catppuccin](https://catppuccin.com) (Mocha) throughout.

This repo is public — see [AGENTS.md](./AGENTS.md) for the hard rule on
never committing secrets, and for the full set of conventions this repo
follows.

## Status

A symlink/install script hasn't been built yet — for now, treat this as
config-in-progress. Each tool directory is named so that a future linker can
map `<tool>/` → `~/.config/<tool>/` directly, except where a tool's own
target path forces an exception (documented in that tool's page under
`docs/`, e.g. [tmux](./docs/tmux.md)).

## Layout

```text
mise.toml, mise.lock   # tools/tasks for working on this repo itself
mise/                  # global mise config → ~/.config/mise/
git/                   # git config → ~/.config/git/
atuin/                 # atuin config → ~/.config/atuin/
tmux/                  # tmux config → ~/.tmux.conf (see docs/tmux.md)
lazygit/               # lazygit config → ~/.config/lazygit/
docs/                  # per-tool notes (what's configured, and why)
```

## Tools configured so far

| Tool                      | Docs                                 |
| ------------------------- | ------------------------------------ |
| mise                      | [docs/mise.md](./docs/mise.md)       |
| git (+ delta)             | [docs/git.md](./docs/git.md)         |
| atuin                     | [docs/atuin.md](./docs/atuin.md)     |
| tmux                      | [docs/tmux.md](./docs/tmux.md)       |
| lazygit                   | [docs/lazygit.md](./docs/lazygit.md) |
| linting / pre-commit (hk) | [docs/linting.md](./docs/linting.md) |

## Contributing / working on this repo

`mise install` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
