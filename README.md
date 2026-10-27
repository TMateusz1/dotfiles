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
[tmux](./docs/core_tools.md#tmux)), or where the tool writes into its own
config directory and only individual files are symlinked (e.g.
[glow](./docs/util_tools.md#glow)).

`shell/.zshrc` (→ `~/.zshrc`) activates the shell integration these tools
need — see [docs/shell.md](./docs/shell.md).

## Layout

```text
mise.toml, mise.lock   # repo checks, hooks, and bootstrap settings/tasks
mise/                  # shared tools + macOS + opt-in desktop layers → ~/.config/mise/
git/                   # git config → ~/.config/git/
shell/                 # shell/.zshrc → ~/.zshrc (see docs/shell.md)
tmux/                  # config + metrics; SessionX and session persistence (see docs/core_tools.md#tmux)
zellij/                # Catppuccin Mocha, blue/green ribbons, lazygit popup (see docs/core_tools.md#zellij)
lazygit/               # lazygit config → ~/.config/lazygit/
bat/                   # bat config → ~/.config/bat/
eza/                   # eza theme → ~/.config/eza/
fzf/                   # fzf theme → ~/.config/fzf/ (see docs/util_tools.md#fzf)
ripgrep/               # ripgrep config → ~/.config/ripgrep/ (see docs/util_tools.md#ripgrep)
starship/              # starship prompt → ~/.config/starship.toml (flat, see docs/util_tools.md#starship)
k9s/                   # k9s config + skin (see docs/core_tools.md#k9s)
bottom/                # bottom (btm) system monitor → ~/.config/bottom/ (see docs/core_tools.md#bottom)
glow/                  # glow theme → ~/.config/glow/glamour.json only (see docs/util_tools.md#glow)
kitty/                 # kitty config + theme → ~/.config/kitty/ (see docs/desktop_tools.md)
zed/                   # macOS Zed: shared global_settings.json, local settings.json; JetBrains + Vim (see docs/desktop_tools.md#zed)
nvim/                  # neovim config → ~/.config/nvim/ (see docs/nvim.md)
docs/                  # notes on what's configured, and why
```

## Tools configured so far

| Topic                                                                                         | Docs                                             |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| mise                                                                                          | [docs/mise.md](./docs/mise.md)                   |
| git (+ delta)                                                                                 | [docs/git.md](./docs/git.md)                     |
| shell (zsh)                                                                                   | [docs/shell.md](./docs/shell.md)                 |
| Util tools (bat, zoxide, eza, fd, fzf, gh, glab, glow, jq, yq, ripgrep, starship)             | [docs/util_tools.md](./docs/util_tools.md)       |
| Core tools (Zellij, tmux, lazygit, k9s, bottom)                                               | [docs/core_tools.md](./docs/core_tools.md)       |
| Zellij keybindings (panes, tabs, stacks, resize, move)                                        | [docs/zellij.md](./docs/zellij.md)               |
| Desktop tools (kitty, Zed settings)                                                           | [docs/desktop_tools.md](./docs/desktop_tools.md) |
| Neovim (LSP, blink.cmp, conform, neotest, Treesitter, fzf-lua, Trouble, Neogit, Oil/Neo-tree) | [docs/nvim.md](./docs/nvim.md)                   |
| languages (Rust, Go, Python, Robot Framework, Protocol Buffers, Kubernetes, Helm)             | [docs/langs.md](./docs/langs.md)                 |
| linting / pre-commit (hk)                                                                     | [docs/linting.md](./docs/linting.md)             |
| bootstrap (symlinks, Zsh integration, desktop apps)                                           | [docs/bootstrap.md](./docs/bootstrap.md)         |

For everyday editor shortcuts, see the [Neovim keymap guide](./docs/nvim.md#keymap-guide)
and [search/check results workflow](./docs/nvim.md#search-and-check-results).
To extend language support, follow [Add a language to Neovim](./docs/nvim-add-new-lang.md).
Rust includes Clippy diagnostics on save, macro analysis and rustfmt formatting;
see [Rust setup](./docs/langs.md#rust).
Neovim LSPs (including the official JetBrains Kotlin server), formatters,
linters, and editing utilities are managed by Mason; see
[maintenance and project version overrides](./docs/mise.md#maintaining-editor-tools).

## Contributing / working on this repo

`mise install --locked` pulls the repo's own tooling (including
[hk](https://hk.jdx.dev)) and installs a pre-commit hook automatically — see
[docs/linting.md](./docs/linting.md).

## Conventions

See [AGENTS.md](./AGENTS.md) — directory naming, theming, mise settings,
and the general "keep it modern, minimal, and maintainable" philosophy this
repo follows.
