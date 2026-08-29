# dotfiles

Personal dotfiles, managed with [mise](https://mise.jdx.dev) and themed
consistently with [Catppuccin](https://catppuccin.com) (Mocha) throughout.

This repo is public — see [AGENTS.md](./AGENTS.md) for the hard rule on
never committing secrets, and for the full set of conventions this repo
follows.

## Status

A symlink/install script hasn't been built yet — for now, treat this as
config-in-progress. Each tool directory is already named so that a future
linker can map `<tool>/` → `~/.config/<tool>/` directly.

## Layout

```
mise.toml, mise.lock   # tools/tasks for working on this repo itself
mise/                  # global mise config → ~/.config/mise/
git/                   # git config → ~/.config/git/
atuin/                 # atuin config → ~/.config/atuin/
docs/                  # per-tool notes (what's configured, and why)
```

## Tools configured so far

| Tool | Docs |
|---|---|
| mise | [docs/mise.md](./docs/mise.md) |
| git (+ delta) | [docs/git.md](./docs/git.md) |
| atuin | [docs/atuin.md](./docs/atuin.md) |

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
