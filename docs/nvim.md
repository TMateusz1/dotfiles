# Neovim (`nvim/`)

`nvim/` maps to `~/.config/nvim` — the standard XDG target, no exception
needed (unlike [tmux](./core_tools.md#tmux)/[starship](./util_tools.md#starship)/[k9s](./core_tools.md#k9s)).
See [AGENTS.md](../AGENTS.md#neovim-conventions-nvim) for the conventions
this config follows (lazy.nvim, no mason.nvim, LSP server binaries from
mise only, Catppuccin theming).

## Layout

- `init.lua` — sets `mapleader`/`maplocalleader` to Space (must happen
  before lazy loads any plugin that maps `<leader>`), requires
  `config.options`/`config.keymaps` (below), then bootstraps
  [lazy.nvim](https://lazy.folke.io/installation) using its own documented
  install snippet verbatim: on first run it `git clone`s itself into
  `stdpath("data")`, then `require("lazy").setup({ spec = { { import =
  "plugins" } }, ... })` loads every `lua/plugins/*.lua` file as a plugin
  spec.
- `lua/config/options.lua`, `lua/config/keymaps.lua` — base editor config,
  independent of any plugin (see "Base config" below).
- `lua/plugins/*.lua` — one file per plugin spec (see "Plugins" below).

## Plugins

| Plugin                                                | Purpose             | Notes                                                             |
| ----------------------------------------------------- | ------------------- | ----------------------------------------------------------------- |
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Colorscheme (Mocha) | Official Catppuccin port; no accent override — see "Theme" below. |

Per AGENTS.md's stated goal (a genuinely modern, IDE-like setup — LSP,
treesitter, completion, fuzzy finding, git integration), more rows will
land here incrementally; nothing in this config designs ahead for those.

## Base config (`lua/config/`)

Config that doesn't depend on any plugin, loaded before lazy.nvim bootstraps:

- **`options.lua`**: `termguicolors` (required for Catppuccin's true-color
  palette to render correctly — a real dependency, not decoration);
  `number` + `relativenumber` together (the common "hybrid" line-number
  style — absolute on the cursor's own line, relative everywhere else);
  `hlsearch`/`incsearch` plus `ignorecase`/`smartcase` (case-insensitive
  search unless the pattern itself has a capital letter); `cursorline`;
  `expandtab`/`shiftwidth`/`tabstop` at 2 spaces, matching this repo's own
  convention elsewhere; `splitright`/`splitbelow`; `wrap = false`;
  `scrolloff = 8`; `signcolumn = "yes"` (reserves the gutter now, so
  turning on LSP diagnostics/git-signs later doesn't shift text).
- **`keymaps.lua`**: `<Esc>` in normal mode also runs `:nohlsearch`, so a
  search's highlighted matches clear without needing a separate keybind or
  losing Esc's usual behavior.

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
cloned catppuccin/nvim for real. Confirmed directly, all against the real
binary: `vim.g.colors_name` is `"catppuccin"`; `vim.wo.relativenumber`,
`vim.o.hlsearch`, and `vim.wo.cursorline` are all `true`; and
`vim.fn.maparg("<Esc>", "n", false, true).desc` returns `"Clear search
highlight"`, confirming the keymap is actually registered.

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
