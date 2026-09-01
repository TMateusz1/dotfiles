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

| Plugin                                                                                                        | Purpose                            | Notes                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------------------------------------------------------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [catppuccin/nvim](https://github.com/catppuccin/nvim)                                                         | Colorscheme (Mocha)                | Official Catppuccin port; no accent override — see "Theme" below.                                                                                                                                                                                                                |
| [ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua)                                                       | Fuzzy finder                       | Shells out to the real `fzf` binary already in this repo's global mise config, rather than reimplementing matching in Lua (unlike Telescope). Auto-adapts to the active colorscheme; no manual theme config.                                                                     |
| [stevearc/aerial.nvim](https://github.com/stevearc/aerial.nvim)                                               | Code outline                       | `<leader>cs` toggles a wide symbol outline on the right while keeping focus in the source window. Uses Treesitter with LSP fallback and the configured Nerd Font — see "Code outline" below.                                                                                     |
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                         | Git gutter + hunk operations       | Shows added/changed/deleted lines and provides preview, stage, reset, blame and diff actions under `<leader>G` — see "Git signs and hunks" below.                                                                                                                                |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                                         | Buffer line                        | Shows listed buffers with the official Catppuccin component theme. `<leader>x` is the close-operations namespace; modified buffers use Neovim's native confirmation prompt.                                                                                                      |
| [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)                 | Indent guides + active scope       | Draws subtle guides with virtual text and highlights the current Treesitter scope. Uses Catppuccin's official integration.                                                                                                                                                       |
| [nvim-mini/mini.ai](https://github.com/nvim-mini/mini.ai)                                                     | Extended text objects              | Adds arguments, function calls, tags and robust pair objects while preserving Neovim's native `an`/`in` Treesitter selection.                                                                                                                                                    |
| [nvim-mini/mini.icons](https://github.com/nvim-mini/mini.icons)                                               | File/directory icons               | Replaces `nvim-web-devicons`, which is no longer installed. Catppuccin themes its highlight groups; devicons' fixed brand colors were the one non-Catppuccin palette left — see "Icons" below.                                                                                   |
| [nvim-mini/mini.surround](https://github.com/nvim-mini/mini.surround)                                         | Surround editing                   | Adds coherent `sa`/`sd`/`sr` operations with dot-repeat, counts and Catppuccin highlighting.                                                                                                                                                                                     |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Syntax-aware function navigation   | Supplies maintained `@function.outer` queries for `[f` and `]f`; configured against its `main` branch API.                                                                                                                                                                       |
| [Wansmer/treesj](https://github.com/Wansmer/treesj)                                                           | Split/join argument layouts        | `<leader>s` toggles the syntax node under the cursor between single-line and multiline forms using Treesitter.                                                                                                                                                                   |
| [folke/noice.nvim](https://github.com/folke/noice.nvim)                                                       | Cmdline + message UI               | Renders the cmdline as a bar docked *above* the statusline, so the bottom reads tmux → lualine → commands. Pulls in `nui.nvim` — see "Bottom of the screen" below.                                                                                                               |
| [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)                                             | Auto-pairs                         | Inserts the closing bracket/quote, steps over one already there, and counts the quotes before the cursor so closing an open string does not double it — see "Pairs" below.                                                                                                       |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim)                                               | Discoverable keymap guide          | Shows described mappings as keys are entered. Uses the modern layout preset, mini.icons and Catppuccin's official integration — see "Keymap guide" below.                                                                                                                        |
| [mbbill/undotree](https://github.com/mbbill/undotree)                                                         | Branching undo-history browser     | `<leader>U` toggles a focused history tree and diff panel stacked on the right — see "Undo tree" below.                                                                                                                                                                          |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                                     | Statusline                         | Theme is `catppuccin-nvim`, **not** `catppuccin` — see "Theme" below. Its right section leads with Neovim 0.12's `vim.ui.progress_status()` — see "Native UI" below.                                                                                                             |
| [stevearc/oil.nvim](https://github.com/stevearc/oil.nvim)                                                     | Directory-as-buffer editing        | Replaces netrw. `-` opens the parent directory as an editable buffer, `<leader>o` the same in a float — see "File explorers" below. Not lazy-loaded, on the author's own advice.                                                                                                 |
| [mikavilpas/yazi.nvim](https://github.com/mikavilpas/yazi.nvim)                                               | Yazi file manager in a float       | `<leader>e`/`<leader>E` open the real `yazi` binary already pinned in the global mise config — see "File explorers" below.                                                                                                                                                       |
| [sphamba/smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim)                                     | Animated cursor trail              | Pure-Lua cursor smear drawn with virtual text; no terminal support required. Defaults kept — see "Cursor" below.                                                                                                                                                                 |
| [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)                           | Seamless tmux/nvim pane navigation | Not lazy-loaded — it defines its own `<C-h/j/k/l>` and `<C-\>` maps at load time. Arrow-key equivalents are added in `config`. Pairs with `tmux/.tmux.conf`, which forwards all three spellings to whichever app owns the pane — see [core_tools.md#tmux](./core_tools.md#tmux). |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                                             | LSP server definitions             | Only a data source: it puts `lsp/*.lua` on the runtimepath so `vim.lsp.enable()` can find servers. No `lspconfig.setup()` — see "LSP" below.                                                                                                                                     |
| [saghen/blink.cmp](https://github.com/saghen/blink.cmp)                                                       | Completion                         | Rust fuzzy matcher **built from source** with the mise-pinned toolchain, never downloaded — see "Completion" below.                                                                                                                                                              |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)                                             | Formatting                         | Format on save, switchable per buffer and globally under `<leader>u`. Formatters are mise binaries — see "Formatting".                                                                                                                                                           |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)                                           | Linting                            | Automatic linting stays narrow (hadolint); slower project/schema checks run asynchronously into quickfix on demand — see "Linting".                                                                                                                                              |
| [folke/lazydev.nvim](https://github.com/folke/lazydev.nvim)                                                   | Lua API completion                 | Teaches `lua_ls` the Neovim API while editing this config. `ft = "lua"`.                                                                                                                                                                                                         |
| [b0o/SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)                                               | JSON/YAML schema catalogue         | Pure Lua, no binary and no runtime download. Feeds `jsonls` and `yamlls`.                                                                                                                                                                                                        |
| [olexsmir/gopher.nvim](https://github.com/olexsmir/gopher.nvim)                                               | Go struct tags / interface stubs   | Thin wrapper over `gomodifytags` and `impl`; its own installer is switched off so the binaries come from mise — see "Go".                                                                                                                                                        |
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest)                                               | Test runner                        | With `neotest-golang`; drives `go test` directly, so it needs no binary beyond the Go toolchain — see "Testing".                                                                                                                                                                 |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)                         | Syntax parsing + highlighting      | `branch = "main"` (the rewrite, now upstream's default). Needs the `tree-sitter` CLI from the global mise config. 38 parsers — see "Treesitter" below.                                                                                                                           |
| [rmagatti/auto-session](https://github.com/rmagatti/auto-session)                                             | Per-directory session persistence  | Restores buffers, window layout and buffer-local options on reopen. Almost entirely defaults — see "Sessions" below.                                                                                                                                                             |
| [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim)                                                   | Start screen / dashboard           | Shown by a bare `nvim`; skipped whenever Neovim gets an argument. Its `dashboard` theme, re-skinned onto catppuccin's `Alpha*` highlight groups — see "Dashboard" below.                                                                                                         |

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
implementation to keep track of. Bound: `<leader>ff` (files in the cwd),
`<leader>fg` (live grep in the cwd), `<leader>fr` (recent files),
`<leader>fb` (open buffers), and `<leader>fh` (help tags).

It also registers as the implementation of `vim.ui.select`. Plugin prompts —
including future LSP code-action choices — therefore use the same fzf interface
instead of Neovim's numbered command-line menu. This requires fzf-lua to load
on `VeryLazy`; the external `fzf` process is still only started when a picker
is actually opened.

## Code outline

[aerial.nvim](https://github.com/stevearc/aerial.nvim) provides a persistent,
hierarchical symbol outline for the current source buffer. `<leader>cs` toggles
it on the right without moving focus away from the source window; once focused,
the outline keeps Aerial's standard navigation, split-opening and tree-folding
keys. It prefers Treesitter symbols and falls back to LSP and its other built-in
backends, so it remains useful before an LSP client attaches.

The outline occupies 40% of the editor, capped at 80 columns and with a
20-column minimum. That doubles Aerial's default 20%/40-column ceiling;
content-based resizing is disabled so short symbol names do not collapse it
back into a narrow strip.

The configured terminal uses a Nerd Font, so Aerial's symbol icons are enabled
explicitly. Its automatic detection only recognizes nvim-web-devicons or
lspkind, neither of which is installed because this config uses mini.icons.
The outline complements rather than replaces fuzzy symbol search:
`<leader>fs` remains fzf-lua's document-symbol picker and `<leader>fS` remains
its live workspace-symbol picker.

## Git signs and hunks

[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) uses Neovim's
built-in diff implementation to place Git additions, changes, deletions and
staged changes in the already-reserved sign column. Its Catppuccin integration
supplies the colors, and inline word diff and persistent blame text remain off
to keep normal editing quiet.

`[h` and `]h` move through hunks in the current file. Inside a `vimdiff`
window they preserve the same intent by delegating to native `[c`/`]c` change
navigation. Hunk operations are buffer-local and only exist when Gitsigns is
attached to a Git-backed buffer:

| Key          | Action                                            |
| ------------ | ------------------------------------------------- |
| `[h` / `]h`  | Previous / next hunk                              |
| `<leader>Gp` | Preview the current hunk in a rounded popup       |
| `<leader>Gs` | Stage an unstaged hunk, or unstage a staged hunk  |
| `<leader>Gr` | Reset the current hunk                            |
| `<leader>Gb` | Full blame details for the current line           |
| `<leader>GB` | Blame the complete buffer in a synchronized split |
| `<leader>Gd` | Diff the buffer against the Git index             |
| `<leader>GD` | Diff the buffer against the previous commit       |
| `ih`         | Select the current hunk as a text object          |

The stage/unstage and reset mappings also work on a Visual selection for
partial hunks. `<leader>G` is registered as the **Git** group in WhichKey;
the individual buffer-local entries come from their mapping descriptions.

## Buffer line

[bufferline.nvim](https://github.com/akinsho/bufferline.nvim) shows listed
buffers across the top of the editor. It loads on `VeryLazy`, after the
colorscheme, and uses Catppuccin's dedicated bufferline theme rather than a
hand-written palette. No `offsets` are configured: neither file explorer is a
sidebar — oil is an ordinary buffer and yazi is a float — so there is no window
for the buffer line to align around.

Buffer navigation follows the usual bracket direction: `[b` selects the
previous displayed buffer and `]b` selects the next. For non-sequential
selection, `<leader><leader>` overlays a pick letter on every displayed
Bufferline entry; pressing a letter focuses that buffer. This mirrors
`<leader>xp`, which uses the same picker to close an entry instead.

`<leader>q` is the context-aware quick close. In a floating window it closes
only that float. In an ordinary window it closes the current buffer; if that is
the final listed buffer (or there are no listed buffers, as on the dashboard),
it exits Neovim instead. Modified files still use the save/discard/cancel flow
below, so the shortcut never silently loses edits.

`<leader>Q` always applies that unsaved-aware quit flow to the entire Neovim
instance, even when a float or utility window is focused. Native `<C-w>q`
remains available for the distinct operation of closing only the current split.
`ZZ` and `ZQ` stay native and deliberately gain no leader aliases: they bypass
the consistent save/discard/cancel questions below.

`<leader>x` is the buffer-close namespace:

| Key          | Action                                    |
| ------------ | ----------------------------------------- |
| `<leader>xx` | Close the current buffer                  |
| `<leader>xX` | Close every buffer except the current one |
| `<leader>xh` | Close buffers left of the current buffer  |
| `<leader>xl` | Close buffers right of the current buffer |
| `<leader>xp` | Mark a displayed buffer, then close it    |

All five routes use the same close function, as do Bufferline's close icon
and right-click action. Clean buffers close immediately. A modified buffer asks
first — Save, Discard or Cancel — and nothing force-deletes unsaved work. That
question is a plain cmdline prompt rather than Neovim's native `:confirm`
dialog, for the reason given under
[Quitting and closing with unsaved changes](#quitting-and-closing-with-unsaved-changes).
Left and right mean Bufferline's visible ordering, not numeric buffer IDs.

## Indent guides

[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
draws a hairline `▏` at each indentation level without changing the file text
or using conceal. The current Treesitter-aware scope becomes a thicker `▎`
rail, giving the cursor's block a clear visual anchor while keeping surrounding
guides quiet. Catppuccin's official integration colors ordinary guides with
muted `surface0` and the active scope with Mocha `lavender`. Scope start/end
underlines are disabled so the result stays clean rather than boxing in code.

It loads only when a real file is read or created. Dashboard, fzf-lua, help,
lazy.nvim and oil buffers are excluded, as are terminal, prompt, quickfix
and other non-file buffer types. The scope indicator depends on a Treesitter
parser; ordinary indentation guides still work without one.

## Text objects and surrounds

The standalone [mini.ai](https://github.com/nvim-mini/mini.ai),
[mini.surround](https://github.com/nvim-mini/mini.surround) and
[mini.icons](https://github.com/nvim-mini/mini.icons) modules are grouped
in `lua/plugins/minis.lua`; the full `mini.nvim` suite is not installed. Each is
a separate plugin with its own lockfile pin, so nothing is pulled in that isn't
actually used.
mini.ai extends normal operator/Visual text objects with arguments (`a`),
function calls (`f`), tags (`t`), balanced quotes/brackets and an interactive
object (`?`). For example, `daa` deletes an argument and `vif` selects inside a
function call. The argument object includes comma-adjacent whitespace, so
deleting an item leaves a clean argument list rather than a leading space.

Mini AI's extended-search variants use uppercase suffixes so Neovim's native
`an`/`in` Treesitter incremental selection remains available:

| Key       | Action                              |
| --------- | ----------------------------------- |
| `aN`/`iN` | Around/inside the next text object  |
| `aL`/`iL` | Around/inside the previous object   |
| `g[`/`g]` | Move to the left/right object edge  |

mini.surround keeps its concise defaults:

| Key           | Action                                           |
| ------------- | ------------------------------------------------ |
| `sa`          | Add a surrounding around a motion or selection   |
| `sd`          | Delete a surrounding                             |
| `sr`          | Replace a surrounding                            |
| `sf`/`sF`     | Find a surrounding to the right/left             |
| `sh`          | Highlight the surrounding under the cursor       |
| `{action}l/n` | Apply an action to the previous/next surrounding |

These mappings deliberately claim the `s` prefix; use `cl` for Neovim's
single-character substitute operation. Surround edits support counts and
dot-repeat.

Function-definition navigation is Treesitter-aware rather than based on brace
layout. `[f` jumps to the previous function start and `]f` to the next, in
Normal, Visual and operator-pending modes; every jump is added to the jumplist.
The mappings use the official `nvim-treesitter-textobjects` companion because
mini.ai's `f` is specifically a function-*call* text object, not a definition.

## Icons

[mini.icons](https://github.com/nvim-mini/mini.icons) provides every icon in
the editor. `nvim-web-devicons` is not installed at all.

**The reason is the Catppuccin rule**, not novelty. devicons ships fixed brand
colors — Go's cyan, Rust's orange, Lua's blue — which are a second, unrelated
palette sitting inside an otherwise Catppuccin setup, and AGENTS.md is explicit
that a tool doesn't get its own theme. Catppuccin already defines nine
`MiniIcons*` highlight groups in its `mini` integration, which this config
already enables, so mini.icons is themed the moment it is installed: verified
by resolving the groups against the palette, `MiniIconsGreen` is `#a6e3a2` and
`MiniIconsOrange` is `#fab388`, exactly mocha's `green` and `peach`.

Two of the four consumers needed nothing. which-key lists mini.icons *ahead* of
devicons in its own provider table, and oil's `util.lua` carries a literal
`-- prefer mini.icons` comment, so both switch on their own. alpha declared
devicons but never called it — this config uses literal glyphs, and alpha only
touches devicons in its MRU helper, which isn't used. That dependency was dead.

bufferline and lualine have no mini.icons support and require
`nvim-web-devicons` by name, so the spec calls
`MiniIcons.mock_nvim_web_devicons()`, mini.icons' own supported API for exactly
this. It registers mini.icons under the old module name, so those requires keep
working with no devicons install. That is also why this is the one mini module
loaded with `lazy = false` and a `priority`: the mock has to exist before
bufferline, lualine or alpha run their setup.

The gain beyond color is that mini.icons knows categories devicons has no
concept of — directories, LSP kinds, OS — which is why oil now shows a distinct
folder glyph per directory rather than one generic icon.

The cost, stated plainly: icons are colored by Catppuccin hue rather than by
language brand. If you want a Go file to be Go-cyan specifically, that is the
reason to go back.

## Pairs

[nvim-autopairs](https://github.com/windwp/nvim-autopairs) on stock defaults
(`opts = {}`). Typing an opening bracket inserts its closing half; typing a
closing one that is already to the right of the cursor steps over it rather than
inserting a second. `▮` marks the cursor:

| You type | Buffer holds | You get     |                            |
| -------- | ------------ | ----------- | -------------------------- |
| `(`      | `▮`          | `(▮)`       | the pair is inserted       |
| `)`      | `(▮)`        | `()▮`       | steps over the closer      |
| `"`      | `▮`          | `"▮"`       | opens a pair               |
| `"`      | `"▮"`        | `""▮`       | steps over                 |
| `"`      | `"qafasf▮`   | `"qafasf"▮` | **closes the open string** |

That last row is the one worth understanding, because it is where a
neighbour-only auto-pairer gets it wrong. With the cursor at the end of
`"qafasf` there is no quote to the right to step over, so a plugin that looks
only at adjacent characters concludes you are starting a *new* string and helpfully
adds a pair — leaving `"qafasf""`. nvim-autopairs instead runs
`cond.not_add_quote_inside_quote()`, which calls `utils.is_in_quotes()` to count
the quotes on the line before the cursor. An odd count means the cursor is
already inside an open string, so the quote you typed is a closing one and no
pair is added. The same reasoning covers `'` and `` ` ``.

Two more mappings come free:

- **`<BS>`** between the halves of an empty pair deletes *both*. `(` then
  backspace leaves an empty line, not a stray `)`.
- **`<CR>`** between `{` and `}` puts the closer on its own line with an
  indented blank line between — the usual block-opening behavior. Parens and
  brackets do the same.

Nothing pairs after a `\`, and `'` does not pair after a word character, so
typing `don't` gives `don't` rather than a doubled apostrophe — the case that
makes naive auto-pairing unusable in prose and comments. Brackets still pair
normally inside a string, so `"abc` plus `(` gives `"abc()`.

**One known rough edge**, kept deliberately: pressing `<CR>` with the cursor
between the two halves of a *just-opened, still-empty* quote pair splits it
across three lines, the way it would for a brace. Quotes are the one pair where
that is wrong. It needs the exact sequence "type a quote, immediately press
Enter, having typed nothing between", and the result is visibly broken rather
than silently wrong, so it is not worth patching the plugin's rule table — which
is version-sensitive surgery — to avoid. Enter from inside an already-written
string (`x = "foo▮"`) is unaffected and just breaks the line normally.

`check_ts` is left off, its own default. It does work with this setup —
nvim-autopairs reads Treesitter through the native `vim.treesitter.*` API, not
the `nvim-treesitter.ts_utils` module that the `main`-branch rewrite pinned here
no longer ships, which was worth confirming rather than assuming. But the quote
handling above is what this was added for and needs no syntax tree, and enabling
`check_ts` would additionally stop brackets pairing inside strings, which is not
wanted.

**Why not mini.pairs.** It was the first choice, for consistency with the two
mini modules already here, and it is wrong for this. Its quote action is
`closeopen`, which decides purely from the neighbouring character — exactly the
`"qafasf""` failure above, and not something its `neigh_pattern` option can
express, since that also sees only one character on each side. Family
consistency is a good tiebreaker between plugins that both work; it is not a
reason to keep one that doesn't.

## Split/join arguments

[TreeSJ](https://github.com/Wansmer/treesj) uses the active Treesitter syntax
tree to find a supported node around the cursor. `<leader>s` toggles that node:
a one-line argument list becomes multiline, while a multiline list joins back
onto one line. The same action also works on nearby list-, dictionary- and
statement-like nodes supported by TreeSJ's language presets. Its upstream
`m`/`j`/`s` defaults are disabled so it only owns the requested leader mapping.

## Keymap guide

[which-key.nvim](https://github.com/folke/which-key.nvim) displays the mappings
available after a prefix, so pressing Space and pausing shows the leader map.
The `modern` preset, rounded border, mini.icons (which which-key prefers over
devicons on its own) and
Catppuccin's official integration keep it visually consistent with the rest of
the editor. `<leader>f` is labelled **Find**, `<leader>G` **Git** and
`<leader>x` **Close buffers**; individual entries come directly from the `desc`
already attached to each keymap; `<leader>q` is the direct **Smart close**
action and `<leader>Q` is **Smart quit all**, rather than either key forming a
prefix group. `<leader>?` shows only mappings local to the current buffer.

MiniClue was considered because Mini AI and Mini Surround are already present.
WhichKey is a better fit here: it discovers described mappings and their prefix
groups automatically, while MiniClue requires a separate trigger/clue registry
whose buffer-local mapping order also needs care. The key guide therefore stays
accurate as mappings are added without duplicating them in a second config.

## Undo tree

[undotree](https://github.com/mbbill/undotree) exposes Neovim's branching undo
history: edits made after going back become another branch rather than erasing
the branch that was previously ahead. `<leader>U` toggles the browser and moves
focus into it. Both its history tree and live diff are stacked in a 36-column
sidebar on the right; timestamps are compact and `?` opens its built-in help.

The plugin only visualizes and navigates Neovim's own undo history; it does not
write the edited file. Persistent undo is deliberately unchanged, so history
retention still follows Neovim's current `undofile` setting rather than being
silently broadened by installing a UI.

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

Robot Framework needs no custom *filetype* wiring: Neovim already resolves both
`.robot` and `.resource` to filetype `robot` (verified), so they share the
same parser and RobotCode client. The parser does need a version override,
however. nvim-treesitter still registers the tier-3 `robot` parser at
`v1.3.0`, before fixes for comment sections, newer settings, nested variable
subscripts, inline Python and braces inside arguments. The config uses
nvim-treesitter's supported `User TSUpdate` hook to keep the official
`Hubro/tree-sitter-robot` source but pin reviewed commit
`8f1a8d8c3875db2cd29865b5a1db7716b4eab4c3`.

Run `:TSUpdate robot` after first pulling that override on a machine with the
older parser. Clean installs and later `:TSUpdate` runs use the pin
automatically; Neovim does not contact the network to update it on every
startup. RobotCode semantic tokens complement the syntax tree for constructs
the upstream grammar does not yet model, including current `VAR`/`GROUP`
syntax.

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

Most of this is auto-session's own defaults — `auto_save` and
`args_allow_single_directory` are already on, and `lazy_support` makes it
wait for lazy.nvim before restoring. `suppressed_dirs` keeps `~`, `/`, `/tmp`
and `~/Downloads` from quietly accumulating sessions, while `auto_restore`
leaves a bare `nvim` on the [dashboard](#dashboard). Pre-save window cleanup is
disabled so every normal split reaches `mksession`; the remaining hooks
rehydrate Aerial's generated window, as described below.

This spec used to carry a third option — a `no_restore_cmds` hook that opened
neo-tree when a directory argument found no session, plus the argv inspection
that fed it. Both are gone. Oil replaces netrw, so Neovim has *already* put a
directory listing in the buffer by the time auto-session runs; if a session
restores it replaces that buffer, and if none does the listing simply stays.
The behavior that needed a hook is now the fall-through case. See
[File explorers](#file-explorers-oil-and-yazi).

### Restoring is automatic for `nvim .`, a choice for `nvim`

```lua
auto_restore = vim.fn.argc(-1) > 0,
```

A bare `nvim` should land on the dashboard, and a restored session would
take that screen away — so the automatic restore is switched off for exactly
that launch, and offered on the dashboard as `s` instead. `nvim .` is
unaffected and still restores on its own.

The expression is evaluated when lazy.nvim reads the plugin spec, which is
during startup and well before the `VimEnter` where auto-session decides
whether to restore, so the flag is already correct by then. `argc(-1)`
counts the global argument list rather than the current window's.

It gates the **automatic** restore only (`auto_restore_session` checks it;
`restore_session` does not), so the dashboard's own `s` button —
`:SessionRestore` — still works, as does every other explicit session
command.

Auto-*save* is deliberately left alone, which is what makes the dashboard's
restore button worth having: press `s`, work, quit, and the session is saved
as usual. Quitting straight from the dashboard without opening anything
saves nothing and — importantly — **deletes nothing**. auto-session's
`auto_delete_empty_sessions` only deletes when `v:this_session` is set, i.e.
when a session was actually loaded or saved this run, so an untouched
dashboard can't clear the session that was already on disk.

Both of auto-session's pruning paths are explicitly disabled:
`close_unsupported_windows = false` keeps unnamed/new buffers and plugin-backed
`nofile` splits, while an empty `close_filetypes_on_save` list also keeps
windows such as `checkhealth`. This preserves the complete normal-window split
topology instead of silently collapsing it before `mksession`. Floating windows
are not splits and remain outside Neovim's session model.

File, help and terminal windows round-trip natively. Generated plugin buffers
may restore as placeholders unless their plugin supports reconstruction.
Aerial is handled explicitly: auto-session's extra-data hooks record whether
the outline was open and replace each restored `aerial` placeholder through
Aerial's public `open_in_win()` API. The source is the adjacent window to its
left, matching the enforced right-side placement, and the previously focused
source window remains focused.

Sessions saved before split pruning was disabled already lost those windows.
Open the desired layout and save or exit once to replace an older session with
the complete topology.

### What each launch does

| Command                   | Result                                                                     |
| ------------------------- | -------------------------------------------------------------------------- |
| `nvim`                    | the [dashboard](#dashboard), always — restoring is one keypress away (`s`) |
| `nvim .` — session exists | restores the session, replacing oil's directory buffer; **no** dashboard   |
| `nvim .` — no session     | leaves oil's listing of that directory on screen                           |
| `nvim <directory>`        | the same session-or-oil outcome for the supplied directory                 |
| `nvim file.go`            | no restore and no save — a file argument means "just edit this file"       |

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

## Dashboard

A bare `nvim` opens [alpha-nvim](https://github.com/goolord/alpha-nvim)'s
start screen: a "NEOVIM" banner, the current directory, and nine buttons.
Nothing else opens it — give Neovim any argument and it stays out of the way
(see [What each launch does](#what-each-launch-does)).

| Key | Action          | Runs                        |
| --- | --------------- | --------------------------- |
| `f` | Find file       | `FzfLua files`              |
| `r` | Recent files    | `FzfLua oldfiles`           |
| `g` | Live grep       | `FzfLua live_grep`          |
| `n` | New file        | `ene` + `startinsert`       |
| `e` | File explorer   | `Yazi cwd`                  |
| `s` | Restore session | `SessionRestore`            |
| `c` | Config          | `FzfLua files cwd=<config>` |
| `l` | Lazy            | `Lazy`                      |
| `q` | Quit            | `qa`                        |

`f` and `g` operate in the current working directory; `r` reads Neovim's
recent-file history. They deliberately reuse what the config already binds
elsewhere — `f`/`r`/`g` are the same fzf-lua pickers as
`<leader>ff`/`<leader>fr`/`<leader>fg`, and `e` is `<leader>e`'s tree — so
the dashboard is a shortcut to this setup, not a second set of habits. `s`
is the counterpart to
[auto-session's suppressed auto-restore](#restoring-is-automatic-for-nvim--a-choice-for-nvim);
`c` points at `stdpath("config")`, which is this repo's `nvim/`.

The current directory is shown under the banner because it is the thing that
decides what `s` will restore — sessions are keyed by cwd.

### Why alpha-nvim

Its own `dashboard` theme covers the whole layout, so the config here is a
header, a button list and a footer rather than a layout engine. The
alternatives: `snacks.dashboard` loses for the same reason `snacks.picker`
did (a multi-module library where a single-purpose plugin will do — see
[Fuzzy finder](#fuzzy-finder-fzf-lua-not-telescope-or-snackspicker)),
`mini.starter` is the same trade in a smaller package, and
`dashboard-nvim` is the closest match but noticeably less actively
maintained. alpha also has an official Catppuccin integration, which
`mini.starter` only gets via catppuccin's blanket `mini` support.

### Theming: the `Alpha*` groups have to be asked for

catppuccin ships an `alpha` integration and enables it by itself
(`auto_integrations` detects the installed plugin, so `colorscheme.lua`
needs no new option), defining `AlphaHeader`, `AlphaHeaderLabel`,
`AlphaButtons`, `AlphaShortcut` and `AlphaFooter`. The dashboard theme
doesn't use any of them — its defaults are the generic `Type`, `Keyword` and
`Number` — so every section here names its group explicitly. Without that
the dashboard still renders, just in unrelated colors, which is an easy
thing to mistake for "catppuccin doesn't support this".

### The footer, and why it isn't set inline

The footer reports lazy.nvim's plugin count and startup time, which don't
exist yet while the dashboard is being built: lazy computes `startuptime` on
`UIEnter`, and `UIEnter` is not ordered against the `VimEnter` that draws
the dashboard. So the footer is filled in from whichever comes second — an
`UIEnter` autocommand, or, if a UI is already attached by the time the spec
runs, a `vim.schedule` — and the buffer redrawn. `AlphaRedraw` is a no-op
when no dashboard is showing, so the `nvim .`/`nvim file.go` launches don't
have to be special-cased.

## File explorers: oil and yazi

Two explorers, because they answer different questions. Oil is for *editing the
filesystem*; yazi is for *looking around it*.

| Key          | Opens                                                  |
| ------------ | ------------------------------------------------------ |
| `-`          | oil on the parent of the current file, in that window  |
| `<leader>o`  | oil on the same directory, in a floating window        |
| `<leader>e`  | yazi, floating, focused on the current file            |
| `<leader>E`  | yazi, floating, at the current working directory       |

### oil.nvim — the directory is a buffer

Oil shows a directory as normal, editable text. Renaming a file is `cw`,
deleting one is `dd`, creating one is `o` and a new name — then `:w` applies the
whole set as real filesystem operations. Because it is an ordinary buffer, `-`
goes "up" repeatedly, `<C-o>` walks back down the jumplist, and the cursor lands
on the file you came *from* rather than at the top of the listing.

`default_file_explorer = true` takes netrw's place, which is what makes `nvim .`
and `nvim path/to/dir` open a listing at all — and, as described under
[Sessions](#sessions), is why auto-session no longer needs a hook to open
something for a directory argument. That hijack has to be in place before the
first directory buffer exists, so oil is the one plugin here deliberately loaded
with `lazy = false`; its own README warns against lazy-loading it for exactly
this reason.

`view_options.show_hidden = true` — a file explorer that hides dotfiles is not
much use in a dotfiles repo. `delete_to_trash = true` sends deletions to the
macOS Trash instead of unlinking them, via oil's own `adapters/trash/mac.lua`;
this is a native adapter, not a shell out to a `trash` binary that would have to
be installed separately.

Normal-mode `=` remains Neovim's native indent operator, so `==`, `=ap` and
`gg=G` all work alongside the Oil mappings.

### yazi.nvim — the real yazi, in a float

`<leader>e` opens [yazi](./core_tools.md#yazi) itself in a floating terminal,
already positioned on the current file; `<leader>E` opens it at the cwd instead.
Everything yazi does — previews, image rendering, its own keymaps, plugins and
Catppuccin theme — comes along, because this is the actual binary and not a
reimplementation. Selecting a file opens it in Neovim; selecting several opens
them all.

The binary is the one already pinned in the global mise config
(`aqua:sxyazi/yazi`), so nothing new is installed for this. `plenary.nvim` is a
genuine dependency here — `yazi/utils.lua` and `yazi/renameable_buffer.lua`
require `plenary.path` directly — and it stayed in the lockfile for that reason
after neo-tree, its previous consumer, was removed.

The float takes a **square** border — `yazi_floating_window_border = "single"`
— rather than inheriting the global `winborder = "rounded"`. Yazi paints its own
status bar across the bottom of that window, and that bar is square
(see [core_tools.md#yazi](./core_tools.md#yazi)) to match tmux and lualine; a
rounded frame around a square bar reads as a mismatch. This is the only float in
the config that opts out of `winborder`, and it does so deliberately.

`open_for_directories` is left `false`. Yazi *can* take netrw's place too, but
two plugins fighting over directory buffers is a bug waiting to happen, and oil
is the better fit for that job since it produces a real buffer rather than a
terminal. Directories belong to oil; yazi is only ever something you open on
purpose.

### Why neo-tree was dropped

The sidebar tree it provided was the least-used of the three ideas and the most
entangled: it needed a bufferline `offsets` entry to align, an
indent-blankline exclusion, an auto-session `no_restore_cmds` hook plus argv
capture to handle `nvim .`, three custom window mappings to make `<CR>` behave,
and `nui.nvim` and `plenary.nvim` as dependencies. Oil and yazi together cover
more ground and deleted every one of those integration points except the
plenary dependency, which yazi still needs. (`nui.nvim` later came back on its
own account, as noice's dependency — see
[Bottom of the screen](#bottom-of-the-screen).)

## Cursor

[smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) animates a
short trail between the cursor's old and new positions. It is included on
defaults — the plugin draws the smear with virtual text and Neovim's own
highlight groups, so it needs no terminal features and picks up Catppuccin's
colors without configuration.

It is loaded on `VeryLazy`, so it costs nothing at startup and nothing at all
until the first cursor move after the UI is up.

## Base config (`lua/config/`)

Config that doesn't depend on any plugin, loaded before lazy.nvim bootstraps:

- **`options.lua`**: `termguicolors` (required for Catppuccin's true-color
  palette to render correctly — a real dependency, not decoration);
  `winborder = "rounded"` (the stable Neovim-wide default for native and
  plugin floating windows that do not explicitly override it);
  `cmdheight = 0` (gives up the reserved cmdline row so lualine sits on the
  tmux bar — see [Bottom of the screen](#bottom-of-the-screen));
  `title = true` (publishes the current buffer title; tmux captures it as the
  pane title and forwards it to the Kitty tab/window title);
  `number` + `relativenumber` together (the common "hybrid" line-number
  style — absolute on the cursor's own line, relative everywhere else);
  `hlsearch`/`incsearch` plus `ignorecase`/`smartcase` (case-insensitive
  search unless the pattern itself has a capital letter); `cursorline`;
  `expandtab`/`shiftwidth`/`tabstop` at 2 spaces, matching this repo's own
  convention elsewhere; `splitright`/`splitbelow`; `wrap = false`;
  `scrolloff = 8`; `signcolumn = "yes"` (keeps the gutter reserved even
  with no signs, so Gitsigns marks — and LSP diagnostics later — appear
  without shifting text sideways).
  It also sets `sessionoptions` — see [Sessions](#sessionoptions) — and the
  clipboard, below.
- **`keymaps.lua`**: `<Esc>` in normal mode also runs `:nohlsearch`, so a
  search's highlighted matches clear without needing a separate keybind or
  losing Esc's usual behavior. `<leader>w` writes the current file.
  `<leader>q` closes the focused float, current buffer or editor according to
  context; `<leader>Q` always quits the entire editor. Both close mappings use
  the unsaved-aware flow — see
  [Quitting and closing with unsaved changes](#quitting-and-closing-with-unsaved-changes).
- **`filetypes.lua`**: Helm chart detection — see [Helm](#helm).
- **`buffers.lua`**: the shared buffer-close and quit-all flow, including the
  unsaved-changes prompt.

## Native UI

Neovim 0.12 ships enough UI of its own that three of the four things a plugin
would usually be added for are already covered.

**Float borders.** `vim.o.winborder = "rounded"` is a global default, so every
float that doesn't pass its own `border` picks it up — hover and diagnostic
popups, Gitsigns' hunk preview and blame, LSP floats later. Only which-key
still sets `border` explicitly, because its own `preset` config would otherwise
supply one. Nothing else in this config hardcodes a border.

**Progress.** Lualine's right section starts with Neovim's public
`vim.ui.progress_status()`, trimmed. It summarizes running `Progress` events as
`42%(1)` — average percentage and count — and returns an empty string when
nothing is running, which lualine drops without leaving padding or a separator
behind. That covers what fidget.nvim would be installed for once LSP arrives,
with no extra plugin. Note this is *progress*, which is separate from messages:
messages are noice's, below.

**Diagnostics.** `vim.diagnostic.status()` is deliberately *not* added: lualine
already renders a colored `diagnostics` component in `lualine_b`, and both read
the same counts. Adding it would show every count twice.

**`vim._extui` is not enabled.** The module doesn't exist in the pinned Neovim
0.12.5 — the experimental TUI replacement now lives at `vim._core.ui2`. The
leading underscore is upstream saying it is private and unstable, so this config
does not depend on it. It would not have solved the layout problem anyway:
`ui2` opens its cmdline window with `relative = 'laststatus', row = 1`, which is
the row *below* the statusline — the same place the built-in cmdline already
sits. Moving the cmdline above the statusline is what noice is here for.

## LSP

Nine servers, all enabled from `lua/plugins/lsp.lua`:

| Server          | Language         | Executable source                   |
| --------------- | ---------------- | ----------------------------------- |
| `gopls`         | Go               | `go:golang.org/x/tools/gopls`       |
| `lua_ls`        | Lua              | `aqua:LuaLS/lua-language-server`    |
| `yamlls`        | YAML, Kubernetes | `npm:yaml-language-server`          |
| `jsonls`        | JSON             | `npm:vscode-langservers-extracted`  |
| `helm_ls`       | Helm charts      | `aqua:mrjosh/helm-ls`               |
| `ruff`          | Python           | `aqua:astral-sh/ruff`               |
| `basedpyright`  | Python           | `npm:basedpyright`                  |
| `robotcode`     | Robot Framework  | `pipx:robotcode` global/local-first |
| `rust_analyzer` | Rust             | `aqua:rust-lang/rust-analyzer`      |

**No mason.nvim.** Every baseline binary is pinned in mise and resolved from
`$PATH`; Neovim configures clients and never installs anything. RobotCode adds
one local-first rule: a project's `.venv/bin/robotcode` is selected before the
global binary. An activated nonstandard environment still wins through normal
`$PATH` ordering.

### Configured natively, not through a framework

Neovim 0.11+ reads `lsp/<name>.lua` from the runtimepath. `nvim-lspconfig` is
present **only** to put those definitions there — 413 of them — and nothing
calls `require("lspconfig").setup()`, which is the older API. Servers are turned
on with `vim.lsp.enable{...}` and this repo's overrides are layered on with
`vim.lsp.config(name, {...})`.

### Keymaps: classic navigation, FZF for locations

Location requests use short Vim-style keys and fzf-lua. A single result jumps
directly; multiple results open the picker instead of filling quickfix:

| Key  | Action          |
| ---- | --------------- |
| `gd` | Definition      |
| `gD` | Declaration     |
| `gr` | References      |
| `gI` | Implementation  |
| `gy` | Type definition |
| `gK` | Signature help  |
| `K`  | Hover           |

Neovim 0.12's native `gra` / `gri` / `grn` / `grr` / `grt` / `grx` mappings
are removed at startup. Leaving them in place would make the exact `gr` mapping
wait for another key. Their useful LSP actions are available under the maps
above and the Code namespace instead; `gI` intentionally replaces Vim's
insert-at-column-one command.

Go buffers add one deliberately separate operation: `gi` generates the methods
needed to implement an interface selected by name. It replaces Vim's
last-insert-position command only for Go; `gI` remains LSP navigation in every
LSP buffer.

| Key          | Action                                            |
| ------------ | ------------------------------------------------- |
| `<leader>ca` | Code action with preview (Normal and Visual mode) |
| `<leader>cd` | Line diagnostics in a float                       |
| `<leader>cf` | Format buffer (independent of format-on-save)     |
| `<leader>ci` | `:LspInfo`                                        |
| `<leader>cl` | Run a code lens                                   |
| `<leader>cr` | Rename symbol                                     |
| `<leader>cR` | Restart the client                                |
| `<leader>cs` | Toggle Aerial's document-symbol sidebar           |
| `<leader>uh` | Toggle inlay hints                                |

Code actions always open fzf-lua, including when only one action is available,
so the proposed edit can be previewed before applying it. Visual mode passes
the selected range to the LSP request. Neovim's useful non-conflicting defaults
remain: `gO` for document symbols, `]d` / `[d` for diagnostics, `i_<C-s>` for
signature help and `gx` for opening links.

Picker-based search remains under Find: `<leader>fs` (document symbols),
`<leader>fS` (workspace symbols) and `<leader>fd` (document diagnostics).

### Diagnostics

`virtual_lines = { current_line = true }` rather than `virtual_text`. gopls
messages routinely run past the window width and inline text truncates them;
virtual lines wrap, and restricting them to the cursor's line stops the buffer
from reflowing while typing. `signcolumn` was already `yes`, so the gutter signs
cost no width.

### gopls

`gofumpt`, `staticcheck` and `usePlaceholders` are on, along with the
`unusedparams`/`unusedwrite`/`shadow`/`nilness`/`any` analyses and the full
inlay-hint set. The filters are recursive (`-**/vendor`, `-**/node_modules`,
`-**/.git`): operator repos vendor large dependency trees, and indexing them
makes gopls slow to start and fills completion with duplicate symbols.

### Python and Robot Framework

Python intentionally attaches both basedpyright and Ruff. Basedpyright owns
type-aware completion, navigation and hover, but its diagnostics and type
checking are disabled. Ruff owns live lint diagnostics, import organization and
formatting; mypy is the authoritative project-wide static checker and runs on
demand into quickfix with `<leader>cpm`.

RobotCode is globally pinned with its language-server, analysis and lint extras,
alongside global Robot Framework and Robocop commands. Its launcher checks the
project root in this order:

1. `.venv/bin/robotcode` (or `venv/bin/robotcode`), even without activation;
2. the first `robotcode` on `$PATH`, so an activated custom environment wins;
3. mise's global RobotCode fallback.

If a conventional project `.venv` contains libraries but not RobotCode, its
`site-packages` is passed to the global server through `PYTHONPATH`. Completion
therefore sees project keyword libraries without requiring every project to
install its own language server.

RobotCode advertises Robot-specific semantic tokens rather than only the
standard LSP token vocabulary. Catppuccin therefore links the language-scoped
`@lsp.type.*.robot` groups to its existing Treesitter palette: headers,
settings and control flow; test and keyword declarations/calls; variables and
arguments; namespaces; delimiters; escapes; documentation and errors all remain
distinct. The separator/terminator tokens that only cover layout whitespace
stay intentionally unstyled. These semantic highlights layer on top of
Treesitter and are available for both `.robot` and `.resource` buffers.

### Kubernetes

yamlls receives an explicit Kubernetes schema for conventional manifest paths:
`k8s/**`, `kubernetes/**`, `deploy/**`, `deployment/**`,
`deployments/**`, `manifests/**`, `base/**`, `overlays/**`, and
`*.k8s.yaml`/`*.k8s.yml`. Both `.yaml` and `.yml` are covered at any
directory depth. Other layouts can opt in per file with a YAML language-server
schema modeline. Schema validation stays interactive in the LSP; the fuller
kubeconform check is an on-demand quickfix command described under
[Linting](#linting). Inside a Helm chart the schema arrives by a different
route, but it is generated from the same directory and filename lists; see
below.

### Helm

Helm needed one thing beyond enabling `helm_ls`: **a filetype**. Neovim has no
built-in one, chart templates are `.yaml` files, and nvim-lspconfig declares
`filetypes = { "helm", "yaml.helm-values" }` for helm-ls. Left alone, templates
stayed `yaml`, helm-ls never attached, and yaml-language-server attached instead
and treated every `{{ ... }}` as broken YAML. The installed `helm` treesitter
parser sat unused for the same reason.

nvim-lspconfig's own docs point at the `vim-helm` plugin for this. It is a
handful of filetype rules, which `vim.filetype.add()` does natively, so
`lua/config/filetypes.lua` handles it instead of adding a plugin.

**Detection keys off the chart, not off a directory name.** An upward search for
`Chart.yaml` finds the chart root; everything else is decided by the path
*relative to that root*:

| Path relative to the chart root        | Filetype           | Servers                |
| -------------------------------------- | ------------------ | ---------------------- |
| `Chart.yaml`, `Chart.lock`             | `yaml`             | yamlls                 |
| `values*.yaml`, `values*.yml`          | `yaml.helm-values` | helm-ls                |
| `crds/**`, `ci/**`, any dotted segment | `yaml`             | yamlls                 |
| anything else `.yaml`/`.yml`/`.tpl`    | `helm`             | helm-ls only           |

The earlier version of this rule required a directory literally named
`templates/`. Plenty of charts do not use that name — `deploy/template/` is
common — and for those the rule failed silently, leaving exactly the
broken-YAML behaviour it existed to prevent. Keying off `Chart.yaml` is also
simply the truer test: a chart is a chart because of its `Chart.yaml`.

The carve-outs are the parts of a chart Helm never renders. `crds/` and `ci/`
are plain YAML by Helm's own definition, and the dotted-segment rule keeps
`.github/workflows/*.yaml` out of the Helm filetype when the repository root
*is* the chart root. Searching upward stops at the *nearest* `Chart.yaml`, so a
subchart under `charts/` resolves against its own root.

`values.yaml` deliberately keeps a `yaml`-prefixed compound filetype for tools
that understand dotted filetypes, while the `.helm-values` suffix lets helm-ls
attach. helm-ls's values schema support is what makes `.Values.*` completion
inside a template resolve against the real file.

helm-ls is told explicitly that `values.yaml` is the main values file,
`values.lint.yaml` is the lint overlay and `values*.y*ml` finds additional
values files. helm-ls passes that last value to Go's `filepath.Glob`, so the
single pattern deliberately covers both `.yaml` and `.yml` without relying
on unsupported brace expansion.

**The Kubernetes schema inside a chart comes from helm-ls, not from the yamlls
client.** Template buffers are filetype `helm`, which yamlls does not handle;
helm-ls spawns its *own* yaml-language-server for them, and that instance is
configured through `helm-ls.yamlls.config`, entirely separately from the
`vim.lsp.config("yamlls", ...)` block. helm-ls defaults its Kubernetes mapping
to `templates/**`. That covers a conventional chart, but a chart YAML detected
as filetype `helm` under `k8s/**`, `deploy/**`, `manifests/**` or another
configured Kubernetes path still bypasses standalone yamlls. `lsp.lua`
therefore builds the internal glob from the same shared directory/suffix lists:

```lua
config = {
  schemas = { kubernetes = helm_kubernetes_file_match },
  completion = true,
  hover = true,
},
```

helm-ls exposes only one string glob per schema, so the generated value is a
single picomatch brace expression covering `template/**`, `templates/**`, all
of the conventional Kubernetes directories above, and `*.k8s.yaml`/`.yml`.
Values files keep helm-ls's generated values schema through its custom schema
provider rather than being treated as Kubernetes resources.

Verified end to end against a scratch chart at `deploy/Chart.yaml` with a
`deploy/template/` directory and against `chart/k8s/deployment.yaml`.
Both buffers resolve to filetype `helm`, attach only `helm_ls`, and offer
`replicas`, `selector`, `strategy` and the rest of
`io.k8s.api.apps.v1.DeploymentSpec` alongside Helm's Go-template snippets.

One known gap, unrelated to this config: yaml-language-server resolves the
bundled Kubernetes schema for some kinds and not others — `kind: Deployment`
completes, `kind: Service` returns nothing. That behaves identically for a plain
manifest outside any chart, so it is the server's schema handling, not the
filetype or glob wiring.

`<leader>ckl` (kubeconform, under [Linting](#linting)) is registered for
filetype `yaml` only, so it does not appear on `helm` buffers. Checking a
template properly would mean rendering the chart with `helm template` first,
which is a separate feature rather than a filetype list to extend.

helm-ls has its built-in `helm lint` and yamlls integrations enabled. The
globally pinned Helm 4 CLI is therefore a runtime dependency, not merely a
separate shell convenience.

### Documentation

No extra plugin — `K` is enough, and noice renders the markdown gopls returns.
`K` again enters the hover window so it can be scrolled. `K` **on an import
path** gives the whole package's documentation, which covers package browsing
without a dedicated godoc plugin.

## Completion

[blink.cmp](https://github.com/saghen/blink.cmp), sources `lsp`, `path`,
`snippets`, `buffer`, using Neovim's native `vim.snippet`.

**The fuzzy matcher is built from source, not downloaded.** blink ships a Rust
library and by default fetches a prebuilt copy from GitHub releases — which
AGENTS.md forbids. `build = "cargo build --release"` compiles it locally with
the `rust` toolchain already pinned in the global mise config. That is the same
carve-out, for the same reason, as nvim-treesitter compiling its parsers: the
artifact is built here, and the toolchain that builds it is pinned and never
fetched by Neovim. AGENTS.md records both exceptions explicitly.

### Keys

The `enter` preset with `completion.list.selection.preselect = false`. One key,
one job:

| Key                                  | Action                                                         |
| ------------------------------------ | -------------------------------------------------------------- |
| `<Tab>`                              | **Only** ever the next snippet field — otherwise a literal tab |
| `<S-Tab>`                            | Previous snippet field                                         |
| `<C-n>` / `<C-p>`, `<Down>` / `<Up>` | Select next / previous item                                    |
| `<CR>`                               | Accept — but only once an item is actually selected            |
| `<C-space>`                          | Show menu, then documentation                                  |
| `<C-e>`                              | Cancel                                                         |
| `<Esc>`                              | Stop an active snippet, then leave Insert/Select mode          |
| `<C-b>` / `<C-f>`                    | Scroll the documentation window                                |
| `<C-k>`                              | Signature help                                                 |

**Why not `super-tab`, where `<Tab>` accepts.** It collides in the one place it
matters. Typing inside a snippet placeholder opens the completion menu, and
`super-tab`'s handler calls `accept()` *before* `snippet_forward` — so a Tab
meant as "next field" takes a suggestion instead. With `preselect = true`
(blink's default) an item is selected the moment the menu opens, which makes
that collision structural rather than occasional. blink's own docs flag it: the
`super-tab` entry in `config/keymap.lua` suggests setting
`completion.trigger.show_in_snippet = false` to work around it.

Splitting the keys removes the ambiguity instead of working around it, and
`preselect = false` is what keeps `<CR>` honest — with an item preselected,
Enter would accept whenever the menu happened to be open and could never just
insert a newline. blink's docs recommend exactly this pairing for the `enter`
preset. The cost is one extra keystroke (`<C-n>`) to take the top suggestion,
and ghost text only appears once something is selected.

The menu still opens inside snippet placeholders, which is now harmless and
sometimes useful — completion for a type name in a `${2:string}` field. If it
ever becomes noise, `completion.trigger.show_in_snippet = false` turns it off
without touching any keys.

Escape ends a native snippet session before performing its ordinary mode exit.
`vim.snippet.stop()` clears the `$1`/`$2` placeholder highlights and disables
later Tab/Shift-Tab jumps without undoing the expanded text or edits already
made inside it. Blink owns the Insert- and Select-mode mappings, so the handler
lives in Blink's `enter` keymap and then deliberately falls through to the
original Escape behavior.

`fuzzy.implementation` is `prefer_rust`, not `rust`: if the build ever fails on
a new machine, completion degrades to the Lua matcher instead of breaking the
config. The cost of that safety is that a failed build is **silent**, so the
validation below checks the Rust module actually loaded.

### Snippets

`friendly-snippets` plus this repo's own `nvim/snippets/go.json`. blink's
default snippet source scans `stdpath("config") .. "/snippets"`, and a bare
directory needs no manifest — the filename becomes the filetype, so `go.json`
is picked up as Go snippets.

friendly-snippets publishes its Kubernetes set for `yaml`, but Helm templates
use the deliberately separate `helm` filetype. A dedicated Blink provider
exposes only friendly-snippets' `kubernetes.json` in `helm` buffers. It does not
extend Helm with YAML wholesale, so Docker Compose snippets do not leak into
charts; it is also not enabled for `yaml.helm-values`, where Kubernetes resource
scaffolds would be inappropriate.

The custom set is aimed at controller work rather than at generic Go: a
`Reconcile` skeleton with `IgnoreNotFound` handling, `SetupWithManager`,
`RequeueAfter`, the controller-runtime logger, a kubebuilder RBAC marker,
wrapped-error returns, a parallel table-driven test, and a context with timeout.

## Formatting

[conform.nvim](https://github.com/stevearc/conform.nvim). Every formatter is a
mise binary; conform only sequences them.

| Filetype | Formatters                 |
| -------- | -------------------------- |
| Go       | `goimports` then `gofumpt` |
| Lua      | `stylua`                   |
| Python   | `ruff_format`              |
| YAML     | `yamlfmt`                  |
| TOML     | `taplo`                    |
| JSON     | `jq`                       |
| Shell    | `shfmt`                    |

`yaml.helm-values` inherits the YAML formatter, so values files use the same
globally available yamlfmt outside this dotfiles repo. Helm templates are not
fed to a generic YAML formatter because Go-template expressions are not plain
YAML. For Robot Framework, conform's LSP fallback uses whichever RobotCode
client won the local/global selection; the separately exposed `robocop format`
command is also available globally.

**Format on save is on by default and switchable at two levels**, because the
common failure mode is opening someone else's repo with a different style:

| Key          | Scope                                            |
| ------------ | ------------------------------------------------ |
| `<leader>us` | Global — `vim.g.disable_autoformat`              |
| `<leader>uS` | Current buffer only — `vim.b.disable_autoformat` |

`format_on_save` is a *function* that returns `nil` when either flag is set,
which is conform's own documented pattern. `<leader>cf` still formats on demand
regardless of the toggles.

## Linting

[nvim-lint](https://github.com/mfussenegger/nvim-lint) automatically runs only
fast, file-local checks that do not duplicate a language server:

| Linter     | Files      | Trigger            |
| ---------- | ---------- | ------------------ |
| `hadolint` | Dockerfile | Open and write     |

Potentially slower checks use the shared asynchronous runner, replace the
quickfix list on completion, open it when findings exist and close it after a
clean run. They never block Neovim and never run on save:

| Key           | Check                                         |
| ------------- | --------------------------------------------- |
| `<leader>cgl` | `golangci-lint run` for the current Go module |
| `<leader>cgL` | The same project check with `--fix`           |
| `<leader>ckl` | kubeconform for the current YAML file         |
| `<leader>cpm` | mypy for the current Python project           |

gopls already runs staticcheck and the unusedparams/shadow/nilness analyses,
so running golangci-lint on every write would duplicate messages and add
latency on large repositories. kubeconform likewise stays explicit because
most YAML is not Kubernetes, and a filename/path heuristic should not decide
whether every save launches schema validation. mypy is similarly explicit: it
walks the project and maintains `.mypy_cache`, while Ruff remains the fast live
feedback path.

This is separate from `hk.pkl`, which formats and lints **this repository's own
files** at commit time. conform and nvim-lint act in the editor, on whatever
project is open. See [linting.md](./linting.md).

## Go

gopls covers completion, navigation, refactoring and code actions. Two things it
does not do are filled by [gopher.nvim](https://github.com/olexsmir/gopher.nvim),
a thin wrapper whose own installer is switched off (`installation = false`) so
the binaries come from mise:

| Key                        | Action                              | Binary          |
| -------------------------- | ----------------------------------- | --------------- |
| `<leader>cta`              | Add `json` struct tags              | `gomodifytags`  |
| `<leader>cty`              | Add `yaml` struct tags              | `gomodifytags`  |
| `<leader>ctr`              | Remove struct tags                  | `gomodifytags`  |
| `gi` / `<leader>cI`        | Pick and implement an interface     | `gopls`, `impl` |
| `<leader>ce`               | Expand `if err != nil`              | —               |
| `<leader>cgl`              | Lint current project                | `golangci-lint` |
| `<leader>cgL`              | Lint and apply fixes                | `golangci-lint` |

Place the cursor anywhere inside a named struct, save the buffer, then press
`gi`. The live FZF search contains interfaces from the workspace, loaded
dependencies and the standard library. Results are always package-qualified,
so the same query can distinguish names such as `io.Reader` from another
package's `Reader`. Selecting one appends only its missing pointer-receiver
methods; selecting an interface the type already satisfies leaves the buffer
unchanged. Generic structs retain their receiver type parameters, and selecting
a generic interface asks for its concrete arguments. The generated buffer stays
unsaved so the normal `goimports` plus `gofumpt` save pipeline remains in
control.

Bare `:GoImpl` opens this same picker, which also makes an older loaded
`<leader>cI` command mapping safe. Supplying arguments keeps the original
gopher behavior, for example `:GoImpl io.Reader`.

gopher.nvim is less well known than `ray-x/go.nvim`; it was chosen because
go.nvim is a mega-plugin, which this repo's plugin rule argues against. If it
stops being maintained, the fallback is three `nvim_create_user_command`
wrappers around the same two binaries — the binaries are the part that matters.

## Testing

[neotest](https://github.com/nvim-neotest/neotest) with
[neotest-golang](https://github.com/fredrikaverpil/neotest-golang), which shells
out to `go test -json`. No extra binary beyond the Go toolchain.

| Key          | Runs                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------- |
| `<leader>tt` | Nearest test                                                                                |
| `<leader>tf` | Tests in the file                                                                           |
| `<leader>tp` | Tests in the **package** — the current file's directory, which in Go is exactly the package |
| `<leader>ta` | Everything under the cwd                                                                    |
| `<leader>ts` | Summary panel                                                                               |
| `<leader>to` | Output of the last test                                                                     |
| `<leader>tS` | Stop the current run                                                                        |

`<leader>ta` on a large repo takes a while; treat it as "start it and watch the
summary panel" rather than an instant action, and `<leader>tS` aborts.

## Bottom of the screen

The three bars at the bottom of the terminal are kitty → tmux → Neovim, and by
default Neovim stacks them in an awkward order. Reading upward you get the tmux
status line, then Neovim's cmdline, then lualine — so the statusline is
sandwiched between two other bars instead of sitting on the tmux one:

```text
   buffer text            buffer text
   ...                    ...
   lualine          →     :wq          ← commands
   :wq                    lualine      ← statusline, now on the tmux bar
   tmux status            tmux status
```

Two changes get the right-hand layout, and neither is optional on its own.

**`cmdheight = 0`** (in `options.lua`) gives up Neovim's reserved cmdline row,
which moves the statusline to the bottom-most row — measured, not assumed: with
`lines = 24` the statusline moves from row 22 to row 23. Without this there is a
permanently blank row between lualine and tmux.

**noice.nvim** then renders the cmdline itself. This part genuinely needs a
plugin. Neovim's cmdline is structurally the last row of the TUI grid; there is
no option that reorders it, and the experimental `vim._core.ui2` positions its
own cmdline window at `relative = 'laststatus', row = 1`, i.e. right back below
the statusline. Drawing the cmdline anywhere else means drawing it in a floating
window, which is what noice does.

The config picks noice's full-width `cmdline` bar rather than its default
centred popup, and lifts it one row:

```lua
cmdline = {
  view = "cmdline",
  format = { input = { view = "cmdline" } },
},
views = { cmdline = { position = { row = "99%", col = 0 } } },
```

The explicit `input` format matters: Noice normally overrides its general
cmdline view for `vim.fn.input()` and uses the centred `cmdline_input` popup.
Routing that format back to `cmdline` keeps save/discard/cancel questions on the
same bottom row as commands and searches.

### Why the row is `"99%"` and not `lines - 2`

nui — noice's windowing layer — resolves a percentage as
`floor((container - size) * pct)`, where the container is the whole editor grid
**including the statusline row**, and `size` is the float's *content* height,
not its outer box. noice's `cmdline` view is one content row with no border, so
`"100%"` resolves to `lines - 1`: exactly on top of lualine. `"99%"` resolves to
`floor((lines - 1) * 0.99)`, which is `lines - 2` — one row higher — for every
height up to about 102 rows, beyond which it drifts to a one-row gap.

An absolute `lines - 2` would be exact at every height but wrong after a
resize twice over: nui only re-evaluates *percentages* on each mount, and noice
caches view instances with their options snapshotted at creation, so a later
config update would not reach them. The percentage is the value that survives a
terminal resize, which is why it wins over the arithmetically neater option.

This was worth measuring rather than deriving. A first attempt kept noice's
bordered popup and computed `"99%"` against a 3-row box; the box landed on rows
37–39 of a 40-row screen with its bottom border over the statusline, because nui
had positioned it by its 1-row *content* and grown the border around it.

### What the result actually is

Verified against a running instance: cmdline, search, input prompts and messages
all render on the row immediately above the statusline, and lualine keeps the
bottom row.
`laststatus` stays at `2`, so splits still get their own statuslines.

Messages are noice's now too, and land in the same place — a content-width box
on that row rather than a full-width bar, so it reads as a notification rather
than a second cmdline. `long_message_to_split` is the one preset enabled, so a
long message opens a real split instead of being truncated. Neither
`nvim-notify` nor `snacks.nvim` is installed; noice's `notify` view falls back
to its built-in `mini` view, which needs no extra plugin.

`<leader>fn` opens Noice's complete message history in fzf-lua, including
notifications, errors, warnings, ordinary messages and LSP messages. The
picker requests reverse modification-time order from Noice and disables fzf's
own relevance sort, so the newest matching entry stays first; the preview
retains the complete formatted message.

### Quitting and closing with unsaved changes

**Neovim's native `:confirm` dialog cannot be used while noice is active.**
Since Neovim 0.11.3 the dialog is delivered to the UI through `ext_cmdline`,
and noice's handling of that path is broken: the question renders as a centred
`" Confirm "` box that never takes an answer, leaving the editor apparently
frozen. This is upstream and unfixed —
[folke/noice.nvim#1136](https://github.com/folke/noice.nvim/issues/1136) is
closed as *not planned*, and
[#1185](https://github.com/folke/noice.nvim/issues/1185) confirms that a
`routes` override cannot redirect it either, because noice intercepts confirm
prompts before its own route table is consulted. This repository pins Neovim
0.12.5, so it is squarely in the affected range.

Two consequences follow.

**`'confirm'` is deliberately left off.** Turning it on is the obvious way to
make `:q` and `:qa` offer to save instead of failing with `E37`, and it would
route every one of those into the broken dialog. `:qa` on a modified buffer
therefore still errors, which is at least honest and non-blocking.

**`lua/config/buffers.lua` asks its own question instead**, and both the
buffer-close flow (`<leader>xx`, Bufferline's close icon and right-click) and
`<leader>q` (smart close) go through it. `<leader>Q` calls the same quit-all
branch directly:

| Situation               | Prompt                                                                 |
| ----------------------- | ---------------------------------------------------------------------- |
| Close a clean buffer    | none — closes immediately                                              |
| Close a modified buffer | `Save changes to <file>? [y]es, [n]o, [c]ancel`                        |
| Quit, nothing unsaved   | none — quits immediately                                               |
| Quit with unsaved work  | `Unsaved: <files>. [w]rite all and quit, [d]iscard and quit, [c]ancel` |

It uses `vim.fn.input()` rather than `vim.ui.select()`, and the reason is this
section's own layout. The whole question lives in the *cmdline prompt*, which
noice renders for as long as the prompt is open. A `vim.ui.select()` list is
emitted as ordinary messages instead, and with no notification backend
installed those land in the `mini` view — which times out after two seconds, so
the question would fade while it was still being read.

Escape, `Ctrl-C` and an empty answer all mean cancel. Nothing here force-deletes
unsaved work without an explicit `n`/`d`.

## Clipboard

`clipboard = "unnamedplus"`, so plain `y` and `p` are the system clipboard —
no `"+y` prefix, no extra keymaps. The part that takes thought is *which*
clipboard tool backs that register when Neovim is at the far end of
`laptop → ssh → tmux → nvim`:

| Where Neovim runs | Provider                       | How it reaches the local clipboard                                        |
| ----------------- | ------------------------------ | ------------------------------------------------------------------------- |
| locally           | automatic (`pbcopy`, etc.)     | macOS clipboard directly (`wl-copy`/`xclip` on a Linux desktop)           |
| over SSH, in tmux | `tmux OSC 52 (synchronized)`   | tmux's paste buffer, synchronized with the terminal over OSC 52           |
| over SSH, no tmux | Neovim's built-in `osc52`      | Neovim writes/reads the clipboard through the terminal itself over OSC 52 |

```lua
require("config.clipboard").setup()
```

Local runs are left to Neovim's auto-detection, which already gets them right.
Direct SSH uses Neovim's built-in OSC 52 provider. The tmux path is a small
custom provider because the upstream timing assumption is too short for this
network path.

### Why the tmux path has a clipboard module

Neovim 0.12's built-in tmux provider copies correctly with
`tmux load-buffer -w -`, but paste runs
`tmux refresh-client -l && sleep 0.05 && tmux save-buffer -`. A fixed 50 ms
sleep can read the old buffer when the clipboard reply crosses SSH more slowly.

`config/clipboard.lua` keeps the upstream copy command. For paste it snapshots
tmux's buffer names, targets the current client with `refresh-client -l`, then
polls every 15 ms for at most two seconds. tmux documents a clipboard reply as
a **new** paste buffer, so its name is the synchronization signal. This is
stronger than comparing contents: copying the same text twice and copying an
empty clipboard both still create a new buffer. The provider reads that exact
buffer by name; a failed, interrupted or timed-out request returns an empty
characterwise register and warns once instead of pasting stale data. Paste
requests are serialized within one Neovim process.

tmux 3.7c has a separate upstream bug where an OSC 52 reply split across reads
can be parsed as keyboard input when `escape-time` is very short. The tmux
config temporarily uses 100 ms rather than 10 ms to mitigate it; revisit that
value after [tmux/tmux#5388](https://github.com/tmux/tmux/issues/5388) is in a
stable release.

### Why the providers are named instead of auto-detected

Auto-detection would pick Neovim's built-in `tmux` provider on its own, which
would reintroduce the fixed delay. It would *not* pick OSC 52: that fallback is
skipped whenever `'clipboard'` is non-empty
(upstream's reasoning, in `provider/clipboard.vim`, is that it "can be slow
and cause a lot of user prompts"), and `'clipboard'` is exactly what
`unnamedplus` sets. Opting in by name is the documented way around that.
Explicitly selecting both remote paths also prevents detection from landing on
an `xclip` that talks to a forwarded `$DISPLAY` rather than to the machine
actually in front of you.

The assignment runs in `options.lua`, before lazy.nvim starts: the clipboard
provider is resolved once, on first use, and reads `g:clipboard` at that
moment — set it later and it is silently ignored (`:h faq-runtime`).

### What has to be true outside Neovim

- **tmux** ([core_tools.md](./core_tools.md#tmux)) — `set -s set-clipboard on`,
  `allow-passthrough on`, the `Ms` terminal-override and the `clipboard`
  terminal-feature. All four are already in `tmux/.tmux.conf`.
- **kitty** ([desktop_tools.md](./desktop_tools.md#kitty)) —
  `clipboard_control` includes `read-clipboard`/`read-primary`, already set.
  Without the read permissions a terminal answers copy requests but not
  paste requests, which is the usual reason remote `y` works and `p` doesn't.
  This intentionally lets programs reached through the terminal read the
  macOS clipboard without prompting; `read-clipboard-ask` is the safer but
  interactive alternative.

Restart Neovim after changing provider code. After changing tmux/Kitty
clipboard settings, start a fresh tmux server and a fresh Kitty window so
terminal capabilities and permissions are renegotiated end to end.

One consequence of `unnamedplus` worth knowing: deletes and changes (`d`,
`c`, `x`) write to the system clipboard too, since they go through the same
unnamed register. That's standard `unnamedplus` behavior, not something this
config adds.

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

### The lualine theme is named `catppuccin-nvim`, not `catppuccin`

`options.theme = "catppuccin"` in `lualine.lua` produces a startup notice and a
statusline that silently isn't Catppuccin at all:

```text
### options.theme
Theme `catppuccin` not found, falling back to `auto`.
```

The name is simply gone. Catppuccin's commit `384f304`, *"fix!: move special
integrations to `catppuccin-nvim`"*, renamed `lua/lualine/themes/catppuccin.lua`
to `catppuccin-nvim.lua` (it did the same to the barbecue theme). The `!` marks
it as breaking, and it breaks quietly: lualine falls back to `auto`, which
generates a passable palette from the active highlight groups, so the statusline
still looks plausible and nothing errors.

Note this rename hit *only* the lualine and barbecue theme files.
`catppuccin.special.bufferline`, which `bufferline.lua` calls for its
highlights, was not part of that commit and still resolves.

Of the names that do exist, `catppuccin-nvim` is the right one. It is a
one-line shim — `return require "catppuccin.utils.lualine"()` — that takes no
flavour argument and therefore resolves `require("catppuccin").flavour`, which
catppuccin sets in `M.load()` when a colorscheme is applied. So the statusline
follows whatever `colorscheme.lua` applied, and `flavour` there stays the single
source of truth. The per-flavour files (`catppuccin-mocha` and friends) pass
their flavour in explicitly, which would hardcode the choice a second place and
let the two drift apart.

## Validation

Verified against the real, installed `nvim` binary (0.12.5, via mise). The
installation, parser and save/restore-cycle checks used scratch
`XDG_DATA_HOME`/`XDG_CONFIG_HOME`/`XDG_STATE_HOME`/`XDG_CACHE_HOME`/`HOME`
directories. Startup routing was also exercised through the live config and
an existing session with `VimLeavePre` disabled before exit, so the session
was read but not rewritten.

- `nvim --headless "+Lazy! sync" "+qa"` installed every plugin for real
  (confirmed each one's fetch/checkout tasks finished with no errors) and
  produced the committed `lazy-lock.json`.
- Base config: `vim.wo.relativenumber`, `vim.o.hlsearch`, and
  `vim.wo.cursorline` are all `true`; and `vim.fn.maparg("<Esc>", "n",
  false, true).desc` returns `"Clear search highlight"`. `<leader>w` resolves
  to `:write` with the description `Save file`.
- Fuzzy finder: `<leader>ff`, `<leader>fg` and `<leader>fr` resolve to
  `FzfLua files`, `FzfLua live_grep` and `FzfLua oldfiles`, matching the
  dashboard's `f`, `g` and `r` actions respectively. `vim.ui.select` is
  registered to fzf-lua rather than the built-in numbered prompt.
- Gitsigns, in a scratch repo with two known hunks at lines 2 and 7: the
  buffer attaches (`b:gitsigns_status_dict` is set) and both lines get signs.
  From line 1, `]h` lands on 2 then 7 and `[h` returns to 2. `stage_hunk`
  puts `f.txt | 2 +-` in `git diff --cached`; running it again on the same
  hunk empties the index, confirming one key toggles both ways. `reset_hunk`
  restores the original line text, `vih` selects exactly the hunk's line
  range, and `preview_hunk` opens a float whose `border` is the rounded
  box-drawing set inherited from `winborder`. Against this repo (which has
  real history) `diffthis()` and `diffthis("~")` each open two `diff` windows,
  and `blame_line({ full = true })` renders the commit that last touched the
  line, with `blame()` opening a `gitsigns-blame` split.
- Native UI: `vim.o.winborder` is `"rounded"`. Firing a synthetic `Progress`
  autocmd puts ` 42%(1) ` in the rendered lualine statusline — so the `%%`
  the runtime returns survives into a single literal `%` — while an idle
  statusline is byte-identical to one without the component. `lualine_b` still
  holds `branch, diff, diagnostics`, and `vim.diagnostic.status()` is not
  added on top of it. `require("vim._extui")` fails on 0.12.5; only the
  private `vim._core.ui2` exists, and nothing here loads it.
- Notification history, with synthetic older and newer Noice messages: the
  lines passed to fzf-lua put the newer message first, and `--no-sort` keeps
  fuzzy filtering from changing that chronological order. `<leader>fn` resolves
  to the described `Notification history` callback.
- Buffer line: `[b` and `]b` cycle in visible order, while
  `<leader><leader>` invokes `BufferLinePick` for letter-based focus. The five
  `<leader>x` mappings resolve to current, others, left, right and pick-close
  operations; the configured close callback is shared by keyboard and mouse
  actions. `<leader>q` closes a focused float first, otherwise closes the
  current buffer, and delegates to the unsaved-aware quit flow when the current
  buffer is the final listed one. `<leader>Q` resolves directly to Smart quit
  all; native `<C-w>q` remains the split-only close.
- Indent guides: `ibl` loads for real file buffers, uses Catppuccin's
  `IblIndent`/`IblScope` highlights, and stays disabled in dashboard,
  oil, fzf-lua and other utility buffers.
- Icons: after removing every `nvim-web-devicons` dependency, lazy.nvim
  uninstalls the plugin (`plugins["nvim-web-devicons"]` is `nil` and the
  directory is gone), yet `require("nvim-web-devicons")` still resolves and
  both APIs the remaining consumers use return real values —
  `get_icon("init.lua")` gives `` with `MiniIconsGreen`, and
  `get_icon_color("main.go")` gives `󰟓` with `#74c7ed`. Rendering was checked
  end to end rather than through the API alone: lualine's filetype component
  resolves to the highlight group `lualine_x_filetype_MiniIconsAzure_normal`
  (it was `..._DevIconReadme_normal` before), and an oil listing of a scratch
  project comes back as `󰉋 ../`, `󰴉 src/`, `Cargo.toml`, `󰟓 main.go` with
  `MiniIconsPurple`/`MiniIconsAzure`/`MiniIconsOrange` extmarks — note the
  directory has its own glyph, which devicons could not do. `MiniIconsGreen`
  and `MiniIconsOrange` resolve to mocha's `green`/`peach`, confirming
  Catppuccin owns the colors.
- Yazi's float border: `require("yazi.config").default()` would give
  `"rounded"` (it reads `winborder`), and the effective config is `"single"`,
  while `vim.o.winborder` stays `"rounded"` for every other float.
- Mini editing: `aN`/`iN` and `aL`/`iL` provide Mini AI's extended object
  searches without replacing native `an`/`in`; Mini Surround owns the
  `sa`/`sd`/`sr` family and uses Catppuccin's `MiniSurround` highlight.
- Pairs: fifteen cases driven as real typed keystrokes into a scratch buffer,
  comparing the resulting buffer text against an expected string. The reported
  failure is fixed and stays fixed: `"qafasf` plus `"` yields `"qafasf"`, and
  the same holds for `'abc` and a backtick-opened string. The cases that must
  not regress all pass too — an empty line plus `"` opens a pair, `"hi"` plus
  `"` opens another (even count, so a new string), `"` before `"` steps over,
  `(` opens, `()` steps over, `({[` gives `({[]})`, `don` plus `'` does not
  pair, `<BS>` after `(` clears the line, `{`+`<CR>` gives `{`, an indented
  blank line and `}`, and `(` inside an unterminated string still pairs.
  The single deliberate difference from mini.pairs is recorded above: `"`
  immediately followed by `<CR>` splits the empty quote pair across three
  lines. Checked separately that `<CR>` from inside a written string
  (`x = "foo▮"`) is an ordinary line break, and that `{▮}` and `(▮)` still
  produce the indented three-line split.
- Function navigation: `[f` and `]f` resolve through Treesitter's
  `@function.outer` query and move to previous/next definitions in all three
  motion-capable modes, with jumplist entries enabled.
- TreeSJ: `<leader>s` splits a one-line Lua argument list and joins the resulting
  multiline form back again, with no default `m`/`j`/`s` maps installed.
- Keymap guide: WhichKey loads with its modern preset, detects the existing
  leader mappings from their descriptions, groups `<leader>f` and `<leader>x`,
  and uses Catppuccin's `WhichKey*` highlight groups.
- Undo tree: `<leader>U` opens the real history and diff buffers on the right,
  focuses the history tree, and closes both on the second press.
- Lualine theme: with `theme = "catppuccin"` lualine records the
  "Theme `catppuccin` not found, falling back to `auto`" notice; with
  `catppuccin-nvim` its notice list is empty. The colors are real Catppuccin
  Mocha rather than `auto`'s generated approximation, checked against the
  palette: `lualine_a_normal` resolves to bg `#89b4fb` (mocha `blue`) on fg
  `#181826` (`mantle`), `lualine_a_insert` to `#a6e3a2` (`green`) and
  `lualine_a_visual` to `#cba6f8` (`mauve`). The flavour really is followed
  rather than coincidentally matching: after `:colorscheme catppuccin-latte`
  the same theme returns `#1e66f6`, latte's `blue`. Note that
  `catppuccin.setup{ flavour = ... }` alone does *not* move it — `M.flavour` is
  assigned in `M.load()`, so the colorscheme has to actually be applied.
- Bottom-of-screen layout: `cmdheight = 0` moves the statusline from row 22 to
  row 23 of a 24-row screen, i.e. onto the bottom row. The cmdline placement
  was then measured on a *running* instance rather than in the usual headless
  harness, because noice draws nothing when no UI is attached
  (`nvim_list_uis()` is empty and Neovim emits no cmdline events). A headless
  server was driven over `--listen`, with a second headless Neovim acting as
  the UI client via `nvim_ui_attach` at 120x40, and keystrokes sent with
  `--remote-send`. With `lines = 40`, pressing `:` and typing `set number`
  produces the cmdline at 1-based screen row 39 with the statusline at row 40 —
  one row above, as intended. Reading `nvim_win_get_config().row` alone is
  misleading here: noice mounts two windows, and the one holding the text is
  `relative = "win"` with `row = 0` *inside* the other, so both had to be
  resolved through `screenpos()` to confirm they occupy the same screen row.
  A `vim.fn.input()` save prompt now resolves to the same cmdline view and row,
  rather than Noice's centred `cmdline_input` popup. `:echo` and `vim.notify`
  also render on row 39, sized to their content, so neither covers lualine.
- LSP, against a real Go module in a scratch directory (`go.mod`, a type with
  unaligned struct fields, an unused variable, a passing test and a Dockerfile),
  driven through a login shell so `$PATH` carries the mise tools. gopls attaches
  with `cmd = { "gopls" }`, and a real diagnostic comes back —
  `declared and not used: unused`, source `compiler`. All nine server
  definitions resolve in nvim-lspconfig's `lsp/` directory. The classic
  location maps (`gd`, `gD`, `gr`, `gI`, `gy`) and Code maps are buffer-local
  after attachment, including `<leader>ca` in both Normal and Visual mode.
  The conflicting native `gr*` globals are absent, while the retained native
  hover, diagnostic, document-symbol and signature-help maps still resolve.
- Go interface generation, against real standard-library source and scratch Go
  packages. A `Reader` workspace-symbol query returns package-qualified
  `io.Reader`; selecting it for `Worker[T]` generates a valid generic receiver.
  A generic `Mapper[T]` selection accepts concrete type arguments, while
  selecting `io.Closer` for a type that already has `Close()` leaves its buffer
  and changed tick untouched. `gi` and `<leader>cI` share this flow only in Go
  buffers; `gI` remains the LSP implementation map. Bare `:GoImpl` reaches the
  picker while `:GoImpl io.Reader` still forwards the explicit argument.
- Snippet expansion, after the accept key turned out to be the problem rather
  than the snippets. The `errw` snippet resolves from the registry with the
  right body, and `vim.snippet.expand` — the same mechanism blink drives —
  turns it into a filled-in `fmt.Errorf` call with the snippet left active and
  a forward jump available. `<Tab>`/`<S-Tab>` are mapped in insert mode and
  `keymap.preset` resolves to `enter`. The configured Escape handler stops the
  native snippet session, clears its tabstop extmarks, preserves the expanded
  text and falls through to the normal mode exit; subsequent Tab/Shift-Tab no
  longer move between placeholders.
  Note `completion.list.selection.preselect` reads back as a *function* rather
  than the `false` it is set to: `config/init.lua` wraps that option in a
  per-mode dispatcher (default/cmdline/term), so the boolean lives inside it.
  Worth recording, because it looks at first glance like the setting was
  overridden. Driving the menu-plus-Tab interaction from the headless harness
  proved unreliable — feeding keys into an open menu produced garbled buffer
  text — so the keymap split is verified by configuration and by blink's own
  documented semantics, not by a simulated keypress.
- Helm snippet routing, through Blink's configured providers rather than the
  raw friendly-snippets registry: a `helm` buffer enables the normal four
  sources plus the isolated `kubernetes_snippets` provider, which returns
  `k-deployment` while excluding Docker Compose's `docker-compose`; a
  `yaml.helm-values` buffer keeps the normal sources and returns neither
  Kubernetes nor Docker Compose scaffolds.
- Helm, on a real chart fixture (`Chart.yaml`, `values.yaml`,
  `templates/deployment.yaml` with `{{ .Release.Name }}`). Before the filetype
  rule this was a genuine hole found by testing rather than by reading: the
  template came up as `yaml` with **yamlls** attached and helm-ls absent. After
  it, the same file is `helm` with `helm_ls` attached and yamlls correctly out
  of the way. `vim.filetype.match` resolves all five cases, the last two being
  the guards that matter: a `templates/deployment.yaml` with **no** `Chart.yaml`
  above it stays `yaml`, and so does an unrelated `/tmp/zwykly.yaml`.
  Both `values.yaml` and an additional `values.staging.yml` come back
  `yaml.helm-values` with helm_ls attached, and helm-ls loads both when
  completing `.Values.*`.
- Completion is genuinely on the Rust matcher, not the silent Lua fallback:
  `require("blink.cmp.fuzzy.rust")` loads, and `target/release/libblink_cmp_fuzzy.dylib`
  exists after the build. This is worth checking explicitly precisely because
  `prefer_rust` degrades quietly. The 9 custom Go snippets are all present in
  the registry blink builds for `go` (68 entries in total, the rest from
  friendly-snippets).
- Format on save, all four states, checking the file on disk after `:w` for the
  alignment `gofmt` introduces: enabled → formatted; `<leader>us` (global) →
  untouched; `<leader>uS` (buffer) → untouched; re-enabled → formatted again.
  conform reports both `goimports` and `gofumpt` as available for Go. Note the
  first attempt at this test asserted on the wrong line — `gofmt` aligns
  `Name string` into `Name     string` and leaves the longest field alone, so
  the original predicate could never have gone true.
- Python and Robot Framework, against scratch projects rather than just config
  inspection. basedpyright and Ruff attach while basedpyright publishes no
  diagnostics; `<leader>cpm` uses a project-local mypy when present and parses
  its JSON type error into the correct quickfix line and column. RobotCode
  attaches once from the global mise binary and once through an executable
  marker proving `.venv/bin/robotcode` takes precedence. Both `.robot` and
  `.resource` receive RobotCode semantic tokens, whose custom highlight groups
  resolve through Catppuccin. The pinned parser handles comment sections,
  name/tag settings, nested subscripts, inline Python and braced arguments
  without parse errors; RobotCode supplies semantic highlighting for
  `VAR`/`GROUP`.
- Kubernetes schema completion, with yamlls loading the configured built-in
  Kubernetes schema for the conventional-directory and `*.k8s.yaml` fixtures,
  while an unrelated YAML file remains free of Kubernetes-only completion.
  A string-valued `spec.replicas` is reported as `Expected "integer"`.
- Linting, including the mappings themselves: `<leader>cgl` and
  `<leader>cgL` run the real golangci-lint JSON command asynchronously and put
  its `govet` finding in quickfix; the uppercase mapping executes the `--fix`
  variant. `<leader>ckl` downloads the Kubernetes schema, reports an invalid
  `spec.replicas` as an error and uses kubeconform's actual
  `statusValid`/`statusInvalid` JSON vocabulary. None of these batch checks is
  registered on `BufWritePost`.
- Testing: the neotest-golang adapter loads, recognises `main_test.go` as a test
  file and resolves the module root correctly. Discovery and a full run could
  not be driven from the headless harness — neotest's `discover_positions` must
  be called from an async context and errors out otherwise — so this is
  verified as far as the harness allows, plus `go test -json` (the exact
  mechanism the adapter shells out to) reporting two passing actions on the
  fixture.
- Colorscheme: `vim.g.colors_name` is `"catppuccin-mocha"` and
  `require("catppuccin").options.flavour` is `"mocha"` — together these
  confirm `opts` actually reached `setup()` (see "Theme" above). Checked
  the negative case too: with `flavour = "latte"` the `Normal` background
  really does change, so the option is genuinely wired, not just present.
- File explorers, against a scratch project holding `a.txt`, `b.txt` and
  `sub/`. From `a.txt`, pressing `-` yields a `filetype=oil` buffer whose
  `get_current_dir()` is the project, listing `../`, `sub/`, `a.txt` and
  `b.txt` — with the cursor already on `a.txt`, the file it came from.
  Pressing `<leader>o` opens a float whose border is the rounded set inherited from
  `winborder`. `nvim .` with no session leaves exactly that listing on
  screen, which is the behavior the deleted `no_restore_cmds` hook used to
  provide. Normal-mode `=` remains unmapped and retains its native indent
  operator, while `<leader>o` resolves to Oil's floating view. `:Yazi` and
  `:Oil` both exist, yazi resolves
  `open_for_directories` to `false`, and smear-cursor loads with
  `enabled = true`. `neo-tree.nvim` and `nui.nvim` are gone from both the
  lockfile and lazy's plugin list, with no plugin reporting an error.
- Treesitter: all 38 parsers installed and compiled for real via the
  `tree-sitter` CLI, then every target filetype opened as an actual buffer
  and checked for `vim.treesitter.highlighter.active` — `go`, `gomod`,
  `rust`, `javascript`, `typescript`, `typescriptreact`, `sh`, `python`,
  pinned `robot` (both `.robot` and `.resource`), `toml`, `json`, `yaml`, `xml`,
  `dosini`, `dockerfile`, `make`, `markdown`, `sql`, `csv` and `lua` all
  came back active with an empty `v:errmsg`. The negative case matters as
  much: a `.tex` buffer (language known, grammar not installed) and a
  buffer with no filetype at all both stay off *and* silent.
- Sessions: driven through a real save/restore cycle. Note auto-session
  **disables itself under `--headless`** (`in_headless_mode()` gates the
  auto-restore path on `nvim_list_uis()`), so the usual headless harness
  silently proves nothing here — a headless `nvim .` shows oil's listing
  even when a session exists, which is the harness's limit and not the
  routing's. Driving `:AutoSession restore` explicitly from that same
  headless launch does exercise the ordering that matters, and it resolves
  correctly: the single oil window is replaced by the session's two file
  windows. The full cycle the test ran
  Neovim with `--embed` so a UI is registered. Opened two files in a split
  with `shiftwidth=7` on one of them, quit, and reopened: the split layout,
  both buffers, `shiftwidth=7` vs. `2`, both filetypes and live treesitter
  highlighting all came back. The launch shapes in the table above were then
  checked: `nvim .` with a session restores the split with **no** tree;
  `nvim .` in a fresh directory opens the tree; bare `nvim` opens the
  [dashboard](#dashboard) without restoring or opening the tree; and `nvim
  main.go` opens just that file. A directory argument different from the
  shell's cwd was also checked: its own session restored with no tree. The
  session file is named for the absolute cwd, and a directory that was only
  browsed produced no session file at all. The complete-layout path was
  exercised separately with ordinary source splits, an unlisted `nofile`
  plugin-style split and Aerial: every split returned, while the restored
  Aerial window reattached to the correct source, symbols repopulated, focus
  stayed in that source, and an 80-column editor restored the requested
  32-column outline.
- Dashboard: a real `nvim` in a scratch project, queried from inside a
  `VimEnter` autocommand. Plain `nvim` lands on `filetype=alpha`,
  `buftype=nofile`, one window, empty `v:errmsg`, with the banner, the cwd
  line and all nine buttons in the buffer, and all nine shortcut keys mapped
  to the commands in the table above. `require("auto-session.config")
  .auto_restore` is `false` for that launch and `true` for both `nvim .` and
  `nvim main.go` — the flag the whole "dashboard vs. restore" split hangs
  on. The other two launches land where they should and never on the
  dashboard: `nvim .` on `filetype=oil`, `nvim main.go` on the `go` buffer
  alone. Theming was checked by resolving the
  groups rather than trusting the integration: `AlphaHeader`,
  `AlphaHeaderLabel`, `AlphaButtons`, `AlphaShortcut` and `AlphaFooter` all
  come back with real mocha colors (blue, peach, lavender, green, yellow),
  and `require("catppuccin").options.integrations.alpha` is `true` without
  `colorscheme.lua` mentioning it.
- Clipboard: `provider#clipboard#Executable()` — the name Neovim resolves for
  the register it will actually use — was checked in all three environments:
  local auto-detection, `tmux OSC 52 (synchronized)` with SSH + tmux, and
  `OSC 52` with SSH but no tmux. A headless command simulation delayed the
  tmux reply beyond the old 50 ms limit and covered identical, empty and
  multiline clipboards plus refresh failure and timeout; none of the failures
  returned the old buffer. The macOS/SSH round trip still needs an attached
  Kitty client because reading a real desktop clipboard is deliberately not an
  automated test.
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
