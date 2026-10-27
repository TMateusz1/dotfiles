# dotfiles

Personal dotfiles, managed with [mise](https://mise.jdx.dev) and themed
consistently with [Catppuccin](https://catppuccin.com) (Mocha) throughout.
Zed pairs that theme with Material icons and a JetBrains/Vim keymap.
For explicit Java/Kotlin imports, see the [Zed import settings](./docs/desktop_tools.md#java-and-kotlin-imports).

This repo is public — see [AGENTS.md](./AGENTS.md) for the hard rule on
never committing secrets, and for the full set of conventions this repo
follows.

## Status

Symlinking is implemented via mise's own `[dotfiles]`/`[bootstrap.repos]`;
`mise run bootstrap:status` is the authoritative view of what is applied on
the current machine. See [docs/bootstrap.md](./docs/bootstrap.md).

Each tool directory is named so that `<tool>/` → normally
`~/.config/<tool>/`, except where a tool's own target path forces an
exception (documented in that tool's entry under `docs/`, e.g.
[starship](./docs/util_tools.md#starship)), or where the tool writes into its own
config directory and only individual files are symlinked (e.g.
[Zellij](./docs/core_tools.md#zellij)).

`shell/.zshrc` (→ `~/.zshrc`) activates the shell integration these tools
need — see [docs/shell.md](./docs/shell.md).
On macOS, `mise run bootstrap:all` also installs Kitty, Zed and fonts through
mise's native `brew-cask:` provisioning. The default editor is `zed --wait` when available,
otherwise system `vi`.
Neovim is also available as a plain terminal editor through [mise](./docs/mise.md#tools-currently-pinned).

## Layout

```text
mise.toml, mise.lock   # repo checks, hooks, and bootstrap settings/tasks
mise/                  # shared tools + macOS tools/apps → ~/.config/mise/
git/                   # git config → ~/.config/git/
shell/                 # shell/.zshrc → ~/.zshrc (see docs/shell.md)
zellij/                # Catppuccin Mocha, blue/green ribbons, lazygit popup (see docs/core_tools.md#zellij)
lazygit/               # lazygit config → ~/.config/lazygit/
bat/                   # bat config → ~/.config/bat/
eza/                   # eza theme → ~/.config/eza/
fzf/                   # fzf theme → ~/.config/fzf/ (see docs/util_tools.md#fzf)
ripgrep/               # ripgrep config → ~/.config/ripgrep/ (see docs/util_tools.md#ripgrep)
starship/              # starship prompt → ~/.config/starship.toml (flat, see docs/util_tools.md#starship)
k9s/                   # k9s config + skin (see docs/core_tools.md#k9s)
bottom/                # bottom (btm) system monitor → ~/.config/bottom/ (see docs/core_tools.md#bottom)
kitty/                 # kitty config + theme → ~/.config/kitty/ (see docs/desktop_tools.md)
zed/                   # macOS Zed: shared global_settings.json, local settings.json; JetBrains + Vim (see docs/desktop_tools.md#zed)
docs/                  # notes on what's configured, and why
```

## Tools configured so far

| Topic                                                                       | Docs                                             |
| --------------------------------------------------------------------------- | ------------------------------------------------ |
| mise                                                                        | [docs/mise.md](./docs/mise.md)                   |
| git (+ delta)                                                               | [docs/git.md](./docs/git.md)                     |
| shell (zsh)                                                                 | [docs/shell.md](./docs/shell.md)                 |
| Util tools (bat, zoxide, eza, fd, fzf, gh, glab, jq, yq, ripgrep, starship) | [docs/util_tools.md](./docs/util_tools.md)       |
| Core tools (Zellij, lazygit, k9s, bottom)                                   | [docs/core_tools.md](./docs/core_tools.md)       |
| Zellij keybindings (panes, tabs, stacks, resize, move, personal group)      | [docs/zellij.md](./docs/zellij.md)               |
| Desktop tools (kitty, Zed settings)                                         | [docs/desktop_tools.md](./docs/desktop_tools.md) |
| languages (runtimes, Zed tooling, Kubernetes and Helm)                      | [docs/langs.md](./docs/langs.md)                 |
| linting / pre-commit (hk)                                                   | [docs/linting.md](./docs/linting.md)             |
| bootstrap (symlinks, Zsh integration, desktop apps)                         | [docs/bootstrap.md](./docs/bootstrap.md)         |

For editor shortcuts, language support, formatting and test tasks, see
[Zed](./docs/desktop_tools.md#zed). Runtimes and compilers are pinned by mise;
see [languages](./docs/langs.md).

## Contributing / working on this repo

`mise install --locked` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
