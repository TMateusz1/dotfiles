# Neovim (`nvim/`)

`nvim/` maps to `~/.config/nvim` — the standard XDG target, no exception
needed (unlike [tmux](./core_tools.md#tmux)/[starship](./util_tools.md#starship)/[k9s](./core_tools.md#k9s)).
See [AGENTS.md](../AGENTS.md#neovim-conventions-nvim) for the conventions
this config follows (lazy.nvim, no mason.nvim, LSP server binaries from
mise only, Catppuccin theming).

## What's here so far

- `init.lua` — sets `mapleader`/`maplocalleader` to Space (must happen
  before lazy loads any plugin that maps `<leader>`), sets
  `termguicolors` (required for Catppuccin's true-color palette to render
  correctly — a real dependency, not decoration), then bootstraps
  [lazy.nvim](https://lazy.folke.io/installation) using its own documented
  install snippet verbatim: on first run it `git clone`s itself into
  `stdpath("data")`, then `require("lazy").setup({ spec = { { import =
  "plugins" } }, ... })` loads every `lua/plugins/*.lua` file as a plugin
  spec.
- `lua/plugins/colorscheme.lua` — the
  [catppuccin/nvim](https://github.com/catppuccin/nvim) plugin spec,
  `flavour = "mocha"`, `priority = 1000` (loads before other plugins that
  might reference its highlight groups), applied via an `init` callback so
  the colorscheme is set as soon as the plugin loads.

This is a deliberately minimal first step — plugin manager and theme only.
Per AGENTS.md's stated goal (a genuinely modern, IDE-like setup — LSP,
treesitter, completion, fuzzy finding, git integration), more will land in
`lua/plugins/` incrementally; nothing here designs ahead for those.

## Plugin manager: lazy.nvim

The de facto modern standard, not an arbitrary pick — lockfile-based
reproducibility (`lazy-lock.json`, generated once plugins are installed,
not shipped here yet since none have been installed against this config),
lazy-loading, and the officially documented bootstrap snippet used above
verbatim rather than a hand-rolled installer.

## Theme

Catppuccin Mocha via the official
[catppuccin/nvim](https://github.com/catppuccin/nvim) plugin, per
AGENTS.md's "prefer the official Catppuccin port" rule. No accent
override, unlike [bottom](./core_tools.md#bottom)/[k9s](./core_tools.md#k9s)
elsewhere in this repo — catppuccin/nvim doesn't expose a single "accent"
setting the way those ports do; its colors are fixed per flavour.

## Validation

Verified against the real, installed `nvim` binary (0.12.5, via mise),
fully sandboxed: `XDG_DATA_HOME`/`XDG_CONFIG_HOME`/`XDG_STATE_HOME`/
`XDG_CACHE_HOME`/`HOME` all pointed at a scratch directory, so nothing
touched the real `~/.config/nvim` or `~/.local/share/nvim`. `nvim --headless
"+qa"` loaded this config cleanly; lazy.nvim bootstrapped itself and
cloned catppuccin/nvim for real; `vim.g.colors_name` confirmed as
`"catppuccin"` after load.

## Declared, not applied

This machine already has a separate, pre-existing Neovim setup at the real
`~/.config/nvim` (its own `lazy-lock.json`, plugins, sessions — unrelated
to this repo). `mise.toml`'s `[dotfiles]` table now has
`"~/.config/nvim" = "nvim"`, same as every other tool here, but — same as
the rest of this repo (see [bootstrap.md](./bootstrap.md)) — nothing gets
applied automatically. Running `mise bootstrap dotfiles apply` would
replace that existing setup with this one; that's a deliberate action left
for you to take explicitly, when ready, not something done as part of
adding this config.
