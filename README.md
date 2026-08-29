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
target path forces an exception (documented in that tool's entry under
`docs/`, e.g. [tmux](./docs/cli_tools.md#tmux)).

## Layout

```text
mise.toml, mise.lock   # tools/tasks for working on this repo itself
mise/                  # global mise config → ~/.config/mise/
git/                   # git config → ~/.config/git/
atuin/                 # atuin config → ~/.config/atuin/
tmux/                  # tmux config → ~/.tmux.conf (see docs/cli_tools.md#tmux)
lazygit/               # lazygit config → ~/.config/lazygit/
bat/                   # bat config → ~/.config/bat/
eza/                   # eza theme → ~/.config/eza/
fzf/                   # fzf theme (needs shell wiring, see docs/cli_tools.md#fzf)
ripgrep/               # ripgrep config (needs shell wiring, see docs/cli_tools.md#ripgrep)
docs/                  # notes on what's configured, and why
```

## Tools configured so far

| Topic                                                                        | Docs                                     |
| ---------------------------------------------------------------------------- | ---------------------------------------- |
| mise                                                                         | [docs/mise.md](./docs/mise.md)           |
| git (+ delta)                                                                | [docs/git.md](./docs/git.md)             |
| CLI tools (atuin, tmux, lazygit, bat, zoxide, eza, fd, fzf, jq, yq, ripgrep) | [docs/cli_tools.md](./docs/cli_tools.md) |
| languages (rust, go)                                                         | [docs/langs.md](./docs/langs.md)         |
| linting / pre-commit (hk)                                                    | [docs/linting.md](./docs/linting.md)     |

## Contributing / working on this repo

`mise install` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
