# dotfiles

Personal dotfiles, managed with [mise](https://mise.jdx.dev) and themed
consistently with [Catppuccin](https://catppuccin.com) (Mocha) throughout.

This repo is public — see [AGENTS.md](./AGENTS.md) for the hard rule on
never committing secrets, and for the full set of conventions this repo
follows.

## Status

Symlinking is implemented via mise's own `[dotfiles]`/`[bootstrap.repos]`
(see [docs/bootstrap.md](./docs/bootstrap.md)) and **fully applied on this
machine** — every declared target is a live symlink into this repo
(`mise run bootstrap:status` reports them all as `applied`).

Each tool directory is named so that `<tool>/` → normally
`~/.config/<tool>/`, except where a tool's own target path forces an
exception (documented in that tool's entry under `docs/`, e.g.
[tmux](./docs/core_tools.md#tmux)), or where the tool writes into its own
config directory and only individual files are symlinked (e.g.
[glow](./docs/util_tools.md#glow)).

`shell/.zshrc` (→ `~/.zshrc`) activates the shell integration these tools
need — see [docs/shell.md](./docs/shell.md).

## Layout

```text
mise.toml, mise.lock   # tools/tasks for working on this repo itself
mise.desktop.toml      # GUI/desktop apps, opt-in only (see docs/bootstrap.md)
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
bottom/                # bottom (btm) system monitor → ~/.config/bottom/ (see docs/core_tools.md#bottom)
yazi/                  # yazi file manager → ~/.config/yazi/ (see docs/core_tools.md#yazi)
glow/                  # glow theme → ~/.config/glow/glamour.json only (see docs/util_tools.md#glow)
kitty/                 # kitty config + theme → ~/.config/kitty/ (see docs/desktop_tools.md)
nvim/                  # neovim config → ~/.config/nvim/ (see docs/nvim.md)
docs/                  # notes on what's configured, and why
```

## Tools configured so far

| Topic                                                                                    | Docs                                             |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------ |
| mise                                                                                     | [docs/mise.md](./docs/mise.md)                   |
| git (+ delta)                                                                            | [docs/git.md](./docs/git.md)                     |
| shell (zsh)                                                                              | [docs/shell.md](./docs/shell.md)                 |
| Util tools (atuin, bat, zoxide, eza, fd, fzf, gh, glab, glow, jq, yq, ripgrep, starship) | [docs/util_tools.md](./docs/util_tools.md)       |
| Core tools (tmux, lazygit, k9s, bottom, yazi)                                            | [docs/core_tools.md](./docs/core_tools.md)       |
| Desktop tools (kitty)                                                                    | [docs/desktop_tools.md](./docs/desktop_tools.md) |
| Neovim (Catppuccin, Treesitter/TreeSJ, fzf-lua, Gitsigns, Mini editing, undo tree)       | [docs/nvim.md](./docs/nvim.md)                   |
| languages (rust, go)                                                                     | [docs/langs.md](./docs/langs.md)                 |
| linting / pre-commit (hk)                                                                | [docs/linting.md](./docs/linting.md)             |
| bootstrap (symlinks, zsh plugins, desktop apps)                                          | [docs/bootstrap.md](./docs/bootstrap.md)         |

## Contributing / working on this repo

`mise install` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
