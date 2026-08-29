# dotfiles

Personal dotfiles, managed with [mise](https://mise.jdx.dev) and themed
consistently with [Catppuccin](https://catppuccin.com) (Mocha) throughout.

This repo is public — see [AGENTS.md](./AGENTS.md) for the hard rule on
never committing secrets, and for the full set of conventions this repo
follows.

## Status

Symlinking is implemented (via mise's own `[dotfiles]`/`[bootstrap.repos]`
— see [docs/bootstrap.md](./docs/bootstrap.md)) but **not yet applied to
any machine**. Each tool directory is named so that `<tool>/` → normally
`~/.config/<tool>/`, except where a tool's own target path forces an
exception (documented in that tool's entry under `docs/`, e.g.
[tmux](./docs/core_tools.md#tmux)).

`shell/.zshrc` (→ `~/.zshrc`) already activates most of the shell
integration these tools need — see [docs/shell.md](./docs/shell.md).

## Layout

```text
mise.toml, mise.lock   # tools/tasks for working on this repo itself
mise/                  # global mise config → ~/.config/mise/
git/                   # git config → ~/.config/git/
shell/                 # shell/.zshrc → ~/.zshrc (see docs/shell.md)
atuin/                 # atuin config → ~/.config/atuin/
tmux/                  # tmux config → ~/.tmux.conf (see docs/core_tools.md#tmux)
lazygit/               # lazygit config → ~/.config/lazygit/
bat/                   # bat config → ~/.config/bat/
eza/                   # eza theme → ~/.config/eza/
fzf/                   # fzf theme → ~/.config/fzf/ (see docs/util_tools.md#fzf)
ripgrep/               # ripgrep config → ~/.config/ripgrep/ (see docs/util_tools.md#ripgrep)
starship/              # starship prompt → ~/.config/starship.toml (flat, see docs/util_tools.md#starship)
k9s/                   # k9s config + skin (see docs/core_tools.md#k9s)
docs/                  # notes on what's configured, and why
```

## Tools configured so far

| Topic                                                                    | Docs                                       |
| ------------------------------------------------------------------------ | ------------------------------------------ |
| mise                                                                     | [docs/mise.md](./docs/mise.md)             |
| git (+ delta)                                                            | [docs/git.md](./docs/git.md)               |
| shell (zsh)                                                              | [docs/shell.md](./docs/shell.md)           |
| Util tools (atuin, bat, zoxide, eza, fd, fzf, jq, yq, ripgrep, starship) | [docs/util_tools.md](./docs/util_tools.md) |
| Core tools (tmux, lazygit, k9s)                                          | [docs/core_tools.md](./docs/core_tools.md) |
| languages (rust, go)                                                     | [docs/langs.md](./docs/langs.md)           |
| linting / pre-commit (hk)                                                | [docs/linting.md](./docs/linting.md)       |
| bootstrap (symlinks + zsh plugins)                                       | [docs/bootstrap.md](./docs/bootstrap.md)   |

## Contributing / working on this repo

`mise install` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
