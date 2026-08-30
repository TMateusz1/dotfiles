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

| Plugin                                                                                | Purpose                            | Notes                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [catppuccin/nvim](https://github.com/catppuccin/nvim)                                 | Colorscheme (Mocha)                | Official Catppuccin port; no accent override — see "Theme" below.                                                                                                                                                                                                                |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)                               | Fuzzy finder                       | Shells out to the real `fzf` binary already in this repo's global mise config, rather than reimplementing matching in Lua (unlike Telescope). Auto-adapts to the active colorscheme; no manual theme config.                                                                     |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)             | Statusline                         | Ships an official `catppuccin` theme table — used as-is.                                                                                                                                                                                                                         |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)         | File explorer (left sidebar)       | `branch = "v3.x"`. Custom open/split keymaps — see "File explorer" below.                                                                                                                                                                                                        |
| [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)   | Seamless tmux/nvim pane navigation | Not lazy-loaded — it defines its own `<C-h/j/k/l>` and `<C-\>` maps at load time. Arrow-key equivalents are added in `config`. Pairs with `tmux/.tmux.conf`, which forwards all three spellings to whichever app owns the pane — see [core_tools.md#tmux](./core_tools.md#tmux). |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing + highlighting      | `branch = "main"` (the rewrite, now upstream's default). Needs the `tree-sitter` CLI from the global mise config. 38 parsers — see "Treesitter" below.                                                                                                                           |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session)                     | Per-directory session persistence  | Restores buffers, window layout and buffer-local options on reopen. Almost entirely defaults — see "Sessions" below.                                                                                                                                                             |

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

## Treesitter

Uses nvim-treesitter's **`main` branch**, which is a full rewrite and now
upstream's default branch. This matters when reading anything written about
treesitter elsewhere: the familiar `master`-branch API — `ensure_installed`,
`highlight = { enable = true }`, `require('nvim-treesitter.configs').setup` —
**does not exist here**. Upstream's own README calls it "a different plugin
you need to set up from scratch". `main` requires Neovim 0.12+, which the
version pinned in the global mise config satisfies.

### The tree-sitter CLI is a hard dependency

`main` compiles every parser locally, so it needs the `tree-sitter` CLI
(≥ 0.26.1) on `PATH` at runtime — it is not optional and not bundled. It's
pinned in the **global** mise config as `aqua:tree-sitter/tree-sitter`,
which also satisfies upstream's explicit instruction to install it "via
your package manager, **not npm**" — that lines up with this repo's general
preference for static binaries over npm dependency trees (see
[linting.md](./linting.md#why-rumdl-not-markdownlint) for the same
reasoning applied to a linter).

This is *not* a violation of [AGENTS.md](../AGENTS.md)'s "Neovim never
installs binaries" rule — see the carve-out there. The rule exists to keep
LSP/formatter/linter *executables* under mise's control; treesitter
grammars are per-language build artifacts of a CLI that mise itself pins.

### Parsers

38 are declared, in one list in `lua/plugins/treesitter.lua`:

| Group           | Parsers                                                                                                                                        |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Go              | `go`, `gomod`, `gosum`, `gowork`, `gotmpl`                                                                                                     |
| Rust            | `rust`                                                                                                                                         |
| JavaScript / TS | `javascript`, `jsdoc`, `typescript`, `tsx`                                                                                                     |
| Shell           | `bash`                                                                                                                                         |
| Python          | `python`, `robot`                                                                                                                              |
| Data / config   | `toml`, `json`, `yaml`, `xml`, `ini`, `csv`, `sql`, `dockerfile`, `make`, `markdown`, `markdown_inline`, `regex`, `ssh_config`, `editorconfig` |
| git             | `diff`, `gitattributes`, `gitcommit`, `gitignore`, `git_config`, `git_rebase`                                                                  |
| Neovim itself   | `lua`, `luadoc`, `vim`, `vimdoc`, `query`                                                                                                      |

Robot Framework works with no extra wiring: Neovim already resolves both
`.robot` and `.resource` to filetype `robot` (verified), so the parser is
picked up automatically. Worth knowing that upstream classes `robot` as a
**tier 3** parser — no listed maintainer, unlike the tier 1/2 grammars
behind everything else here — so it's the most likely one to lag behind
Robot Framework syntax changes.

### Why highlighting is enabled by capability, not by a filetype list

Upstream's documented pattern is a `FileType` autocommand with an explicit
`pattern = { ... }` list. This config instead resolves the language for
whatever filetype loads and starts treesitter if a parser exists:

```lua
local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
if lang then pcall(vim.treesitter.start, args.buf, lang) end
```

The reason is that **filetype names and parser names are frequently not the
same**, so an explicit list written from the parser names above would
silently miss files. Confirmed directly, three of the requested languages
are exactly this case:

| File   | Filetype          | Parser |
| ------ | ----------------- | ------ |
| `.sh`  | `sh`              | `bash` |
| `.tsx` | `typescriptreact` | `tsx`  |
| `.ini` | `dosini`          | `ini`  |

Deriving the language at runtime keeps the parser list the single source of
truth and makes those aliases work for free. The `pcall` is load-bearing
rather than defensive habit: Neovim maps plenty of filetypes to a language
whose grammar isn't installed here (`tex` → `latex`, for one), and
`vim.treesitter.start` *raises* for those — without the guard, opening a
`.tex` file prints a parse error. Verified both directions.

## Sessions

Sessions are keyed by working directory: quit inside a project, come back to
it later, and the buffers, window layout and buffer-local options are back.
The session file is named after the absolute path of the cwd, under
`stdpath("data")/sessions/`.

Nearly everything here is auto-session's own defaults — `auto_save`,
`auto_restore` and `args_allow_single_directory` are all already on, and
`lazy_support` makes it wait for lazy.nvim before restoring. The only option
this config sets is `suppressed_dirs`, so that running Neovim in `~`, `/`,
`/tmp` or `~/Downloads` doesn't quietly start accumulating sessions for
directories that aren't projects.

`close_unsupported_windows` (a default) is what keeps this working with
[neo-tree](#file-explorer-neo-tree): a tree window can't be meaningfully
serialised, so it's closed before the session is written rather than being
restored as a broken buffer. The other half of that pairing lives in
neo-tree's own spec, which skips loading entirely when a session exists.

### What each launch does

| Command                   | Result                                                               |
| ------------------------- | -------------------------------------------------------------------- |
| `nvim .` — session exists | restores the session; **no** neo-tree                                |
| `nvim .` — no session     | opens neo-tree on an empty editor                                    |
| `nvim`                    | restores the session for the cwd, nothing else                       |
| `nvim file.go`            | no restore and no save — a file argument means "just edit this file" |

That last row is auto-session's `args_allow_files_auto_save = false`
default, deliberately kept: opening a single file to make a quick edit
shouldn't overwrite the session you built up in that project.

Browsing a directory without opening anything doesn't create a session
either: `auto_delete_empty_sessions` (also a default) discards a session
whose buffers were all empty or unnamed. So a directory you only looked at
still greets you with the tree next time, which is the intent.

### `sessionoptions`

`lua/config/options.lua` sets `sessionoptions` to Neovim's default list plus
`winpos` and **`localoptions`**. `localoptions` is the one that matters for
"settings come back too" — without it a restore brings back the buffer list
and window layout but drops per-buffer state. Verified by setting
`shiftwidth=7` on one buffer, quitting, and finding it still 7 after the
restore while a sibling buffer stayed at 2.

## File explorer: neo-tree

`<leader>e` toggles the tree (opens *and* focuses it if closed, closes it
if open — `:Neotree toggle`'s own default behavior, needs no extra logic).
Positioned `left`, per `filesystem.window.position`.

**`nvim .` opens neo-tree, not netrw — unless a session is waiting.**
`hijack_netrw_behavior = "open_default"` is what replaces netrw
(upstream's default, but set explicitly here since the `init` hook depends
on it). A hijack only works once the plugin has loaded, though, and
neo-tree is otherwise lazy-loaded on `:Neotree`/`<leader>e` — so opening a
directory would still have landed in netrw. The `init` hook covers that
case: a single argument that is a directory loads neo-tree eagerly. Every
other launch keeps it lazy.

That hook also asks auto-session whether a session already exists for the
cwd (`session_exists_for_cwd()`), and skips loading neo-tree if so — see
[Sessions](#sessions). **The decision has to happen there, before neo-tree
loads.** Letting the tree open and closing it afterwards from a
`post_restore_cmds` hook was tried and does not work: neo-tree re-opens
itself from `argv` once startup settles, so the window comes straight back
(observed going 2 → 3 windows again ~300 ms after a successful close).

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
  It also sets `sessionoptions` — see [Sessions](#sessionoptions).
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

**The colorscheme is applied from `config`, not `init` — and that
distinction is load-bearing.** lazy.nvim runs `init` during startup
*before* the plugin is loaded, so calling `vim.cmd.colorscheme("catppuccin")`
there applies the scheme before lazy's `opts` handler ever reaches
`catppuccin.setup()`. Every option in `opts` is then silently discarded.
It's an easy mistake to miss because the visible result looks correct:
mocha is catppuccin's own default for a dark background, so `flavour`
appears to work while doing nothing. The tell is `vim.g.colors_name` —
`"catppuccin"` means `setup()` never ran, `"catppuccin-mocha"` means it
did. Using `config = function(_, opts) require("catppuccin").setup(opts)
… end` is what makes `opts` real, and matters as soon as anything beyond
`flavour` is set (integrations, `transparent_background`, custom
highlights).

## Validation

Verified against the real, installed `nvim` binary (0.12.5, via mise),
always fully sandboxed: `XDG_DATA_HOME`/`XDG_CONFIG_HOME`/`XDG_STATE_HOME`/
`XDG_CACHE_HOME`/`HOME` all pointed at a scratch directory, so nothing
touched the real `~/.config/nvim` or `~/.local/share/nvim` at any point.

- `nvim --headless "+Lazy! sync" "+qa"` installed every plugin for real
  (confirmed each one's fetch/checkout tasks finished with no errors) and
  produced the committed `lazy-lock.json`.
- Base config: `vim.wo.relativenumber`, `vim.o.hlsearch`, and
  `vim.wo.cursorline` are all `true`; and `vim.fn.maparg("<Esc>", "n",
  false, true).desc` returns `"Clear search highlight"`.
- Colorscheme: `vim.g.colors_name` is `"catppuccin-mocha"` and
  `require("catppuccin").options.flavour` is `"mocha"` — together these
  confirm `opts` actually reached `setup()` (see "Theme" above). Checked
  the negative case too: with `flavour = "latte"` the `Normal` background
  really does change, so the option is genuinely wired, not just present.
- neo-tree's custom keymaps: driven interactively via `nvim --headless
  --listen <socket>` plus `--remote-send`/`--remote-expr` (real keystrokes
  and real window/buffer queries, not a simulation) against a scratch test
  project. Confirmed: opening the tree and pressing `<CR>` on a file opens
  it *and* drops the window count back to 1 (tree closed); reopening the
  tree and pressing `<C-v>` opens a vertical split while the tree remains
  open (window count 3: tree + 2 file windows); `<C-s>` behaves the same
  for a horizontal split (window count 4).
- Treesitter: all 38 parsers installed and compiled for real via the
  `tree-sitter` CLI, then every target filetype opened as an actual buffer
  and checked for `vim.treesitter.highlighter.active` — `go`, `gomod`,
  `rust`, `javascript`, `typescript`, `typescriptreact`, `sh`, `python`,
  `robot` (both `.robot` and `.resource`), `toml`, `json`, `yaml`, `xml`,
  `dosini`, `dockerfile`, `make`, `markdown`, `sql`, `csv` and `lua` all
  came back active with an empty `v:errmsg`. The negative case matters as
  much: a `.tex` buffer (language known, grammar not installed) and a
  buffer with no filetype at all both stay off *and* silent.
- Sessions: driven through a real save/restore cycle. Note auto-session
  **disables itself under `--headless`** (it checks `nvim_list_uis()`), so
  the usual headless harness silently proves nothing here; the test ran
  Neovim with `--embed` so a UI is registered. Opened two files in a split
  with `shiftwidth=7` on one of them, quit, and reopened: the split layout,
  both buffers, `shiftwidth=7` vs. `2`, both filetypes and live treesitter
  highlighting all came back. All four launch shapes in the table above were
  then checked: `nvim .` with a session restores the split with **no** tree;
  `nvim .` in a fresh directory opens the tree; plain `nvim` restores
  without a tree; `nvim main.go` opens just that file. The session file is
  named for the absolute cwd, and a directory that was only browsed produced
  no session file at all.
- `vim.fn.maparg("<C-Left>", "n")` resolves to `<Cmd>TmuxNavigateLeft<CR>`
  and `maparg("<C-h>", "n")` to the plugin's own
  `:<C-U>TmuxNavigateLeft<CR>`, confirming the arrow-key mappings register
  alongside vim-tmux-navigator's `<C-h/j/k/l>` defaults rather than
  replacing them.

## Applied

`mise.toml`'s `[dotfiles]` table declares `"~/.config/nvim" = "nvim"` like
every other tool here, and it is live: `~/.config/nvim` symlinks to this
repo's `nvim/`. The previous setup it replaced still exists untouched in
`~/dev/dotfiles2/nvim`, which is no longer referenced by anything here.

One consequence worth knowing: `nvim/lazy-lock.json` is inside the repo, so
lazy.nvim rewrites a *tracked* file whenever plugins are installed or
updated. That's intended — it's the lockfile, and it should be committed —
but it does mean `:Lazy update` shows up as a working-tree change.
