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

| Plugin                                                                              | Purpose                            | Notes                                                                                                                                                                                                        |
| ----------------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [catppuccin/nvim](https://github.com/catppuccin/nvim)                               | Colorscheme (Mocha)                | Official Catppuccin port; no accent override — see "Theme" below.                                                                                                                                            |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)                             | Fuzzy finder                       | Shells out to the real `fzf` binary already in this repo's global mise config, rather than reimplementing matching in Lua (unlike Telescope). Auto-adapts to the active colorscheme; no manual theme config. |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)           | Statusline                         | Ships an official `catppuccin` theme table — used as-is.                                                                                                                                                     |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)       | File explorer (left sidebar)       | `branch = "v3.x"`. Custom open/split keymaps — see "File explorer" below.                                                                                                                                    |
| [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless tmux/nvim pane navigation | Pairs with `tmux/.tmux.conf`'s own smart pane-switching (see [core_tools.md#tmux](./core_tools.md#tmux)) — that config already forwards `C-hjkl`/`C-arrows` to whichever app owns the pane.                  |

Per AGENTS.md's stated goal (a genuinely modern, IDE-like setup — LSP,
treesitter, completion, git integration), more rows will land here
incrementally; nothing in this config designs ahead for those.

## Fuzzy finder: fzf-lua, not Telescope or snacks.picker

Considered against Telescope (mature but no longer the speed/feature
leader without a compiled native extension) and `snacks.picker` (part of
the [snacks.nvim](https://github.com/folke/snacks.nvim) bundle — deliberately
not adopted; this config stays on single-purpose plugins rather than a
multi-module library). fzf-lua wins on a repo-specific point neither
alternative has: it drives the actual `fzf` binary this repo already pins,
themes, and documents (see
[util_tools.md#fzf](./util_tools.md#fzf)) — no second fuzzy-matching
implementation to keep track of. Bound: `<leader>ff` (files), `<leader>fg`
(live grep), `<leader>fb` (buffers), `<leader>fh` (help tags).

## File explorer: neo-tree

`<leader>e` toggles the tree (opens *and* focuses it if closed, closes it
if open — `:Neotree toggle`'s own default behavior, needs no extra logic).
Positioned `left`, per `filesystem.window.position`.

Three custom `filesystem.window.mappings`, since the defaults don't match
the requested behavior:

- **`<CR>`** — opens the file *and* closes the tree, but only for an actual
  file. A custom function (not a built-in command string) checks
  `node.type ~= "directory"` before closing, so pressing Enter on a
  directory still just expands/collapses it, as normal — confirmed
  directly against the real plugin (see "Validation" below).
- **`<C-v>`** — `open_vsplit`, a built-in command; opens the file in a
  vertical split and leaves the tree open (built-in commands never
  auto-close).
- **`<C-s>`** — `open_split`, same as above but horizontal.

**One thing to know about `<C-s>`:** some shells/terminals treat it as a
flow-control character (XOFF, historically used to pause terminal output)
if `stty ixon` is active. Neovim's own raw-mode terminal handling generally
takes over once you're inside it, and this wasn't an issue in testing, but
if `<C-s>` ever appears to "freeze" a real terminal (most often outside
Neovim, e.g. a plain shell), that's `stty -ixon` to look into, not a bug in
this config.

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
reproducibility (`lazy-lock.json`, committed here, pins every plugin to an
exact commit, machine-generated and re-written by lazy.nvim itself, not
hand-edited), lazy-loading, and the officially documented bootstrap
snippet used above verbatim rather than a hand-rolled installer.

## Theme

Catppuccin Mocha via the official
[catppuccin/nvim](https://github.com/catppuccin/nvim) plugin, per
AGENTS.md's "prefer the official Catppuccin port" rule. No accent
override, unlike [bottom](./core_tools.md#bottom)/[k9s](./core_tools.md#k9s)
elsewhere in this repo — catppuccin/nvim doesn't expose a single "accent"
setting the way those ports do; its colors are fixed per flavour.

## Validation

Verified against the real, installed `nvim` binary (0.12.5, via mise),
always fully sandboxed: `XDG_DATA_HOME`/`XDG_CONFIG_HOME`/`XDG_STATE_HOME`/
`XDG_CACHE_HOME`/`HOME` all pointed at a scratch directory, so nothing
touched the real `~/.config/nvim` or `~/.local/share/nvim` at any point.

- `nvim --headless "+Lazy! sync" "+qa"` installed every plugin for real
  (confirmed each one's fetch/checkout tasks finished with no errors) and
  produced the committed `lazy-lock.json`.
- Base config: `vim.g.colors_name` is `"catppuccin"`; `vim.wo.relativenumber`,
  `vim.o.hlsearch`, and `vim.wo.cursorline` are all `true`; and
  `vim.fn.maparg("<Esc>", "n", false, true).desc` returns `"Clear search
  highlight"`.
- neo-tree's custom keymaps: driven interactively via `nvim --headless
  --listen <socket>` plus `--remote-send`/`--remote-expr` (real keystrokes
  and real window/buffer queries, not a simulation) against a scratch test
  project. Confirmed: opening the tree and pressing `<CR>` on a file opens
  it *and* drops the window count back to 1 (tree closed); reopening the
  tree and pressing `<C-v>` opens a vertical split while the tree remains
  open (window count 3: tree + 2 file windows); `<C-s>` behaves the same
  for a horizontal split (window count 4).
- `vim.fn.maparg("<C-Left>", "n")` resolves to `<Cmd>TmuxNavigateLeft<CR>`,
  confirming the arrow-key mappings registered correctly alongside
  vim-tmux-navigator's own default `<C-h/j/k/l>` bindings.

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
