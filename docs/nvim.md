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
| [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)                                         | Git gutter + hunk operations       | Shows added/changed/deleted lines and provides preview, stage, reset, blame and diff actions under `<leader>G` — see "Git signs and hunks" below.                                                                                                                                |
| [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)                                         | Buffer line                        | Shows listed buffers with the official Catppuccin component theme. `<leader>x` is the close-operations namespace; modified buffers use Neovim's native confirmation prompt.                                                                                                      |
| [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)                 | Indent guides + active scope       | Draws subtle guides with virtual text and highlights the current Treesitter scope. Uses Catppuccin's official integration.                                                                                                                                                       |
| [nvim-mini/mini.ai](https://github.com/nvim-mini/mini.ai)                                                     | Extended text objects              | Adds arguments, function calls, tags and robust pair objects while preserving Neovim's native `an`/`in` Treesitter selection.                                                                                                                                                    |
| [nvim-mini/mini.surround](https://github.com/nvim-mini/mini.surround)                                         | Surround editing                   | Adds coherent `sa`/`sd`/`sr` operations with dot-repeat, counts and Catppuccin highlighting.                                                                                                                                                                                     |
| [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Syntax-aware function navigation   | Supplies maintained `@function.outer` queries for `[f` and `]f`; configured against its `main` branch API.                                                                                                                                                                       |
| [Wansmer/treesj](https://github.com/Wansmer/treesj)                                                           | Split/join argument layouts        | `<leader>s` toggles the syntax node under the cursor between single-line and multiline forms using Treesitter.                                                                                                                                                                   |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim)                                               | Discoverable keymap guide          | Shows described mappings as keys are entered. Uses the modern layout preset, devicons and Catppuccin's official integration — see "Keymap guide" below.                                                                                                                          |
| [mbbill/undotree](https://github.com/mbbill/undotree)                                                         | Branching undo-history browser     | `<leader>U` toggles a focused history tree and diff panel stacked on the right — see "Undo tree" below.                                                                                                                                                                          |
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)                                     | Statusline                         | Uses the official `catppuccin` theme. Its right section leads with Neovim 0.12's `vim.ui.progress_status()` — see "Native UI" below.                                                                                                                                             |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)                                 | File explorer (left sidebar)       | `branch = "v3.x"`. Custom open/split keymaps — see "File explorer" below.                                                                                                                                                                                                        |
| [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)                           | Seamless tmux/nvim pane navigation | Not lazy-loaded — it defines its own `<C-h/j/k/l>` and `<C-\>` maps at load time. Arrow-key equivalents are added in `config`. Pairs with `tmux/.tmux.conf`, which forwards all three spellings to whichever app owns the pane — see [core_tools.md#tmux](./core_tools.md#tmux). |
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
hand-written palette. A `neo-tree` offset labels and aligns the file-explorer
sidebar with the buffer line.

Buffer navigation follows the usual bracket direction: `[b` selects the
previous displayed buffer and `]b` selects the next. For non-sequential
selection, `<leader><leader>` overlays a pick letter on every displayed
Bufferline entry; pressing a letter focuses that buffer. This mirrors
`<leader>xp`, which uses the same picker to close an entry instead.

`<leader>x` is the buffer-close namespace:

| Key          | Action                                    |
| ------------ | ----------------------------------------- |
| `<leader>xx` | Close the current buffer                  |
| `<leader>xX` | Close every buffer except the current one |
| `<leader>xh` | Close buffers left of the current buffer  |
| `<leader>xl` | Close buffers right of the current buffer |
| `<leader>xp` | Mark a displayed buffer, then close it    |

All five routes use the same close function, as do Bufferline's close icon
and right-click action. Clean buffers close immediately. A modified buffer
uses Neovim's native `:confirm bdelete`, which offers Save, Discard and Cancel;
nothing force-deletes unsaved work. Left and right mean Bufferline's visible
ordering, not numeric buffer IDs.

## Indent guides

[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
draws a hairline `▏` at each indentation level without changing the file text
or using conceal. The current Treesitter-aware scope becomes a thicker `▎`
rail, giving the cursor's block a clear visual anchor while keeping surrounding
guides quiet. Catppuccin's official integration colors ordinary guides with
muted `surface0` and the active scope with Mocha `lavender`. Scope start/end
underlines are disabled so the result stays clean rather than boxing in code.

It loads only when a real file is read or created. Dashboard, fzf-lua, help,
lazy.nvim and neo-tree buffers are excluded, as are terminal, prompt, quickfix
and other non-file buffer types. The scope indicator depends on a Treesitter
parser; ordinary indentation guides still work without one.

## Text objects and surrounds

The standalone [mini.ai](https://github.com/nvim-mini/mini.ai) and
[mini.surround](https://github.com/nvim-mini/mini.surround) modules are grouped
in `lua/plugins/minis.lua`; the full `mini.nvim` suite is not installed.
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
The `modern` preset, rounded border, existing `nvim-web-devicons` dependency and
Catppuccin's official integration keep it visually consistent with the rest of
the editor. `<leader>f` is labelled **Find**, `<leader>G` **Git** and
`<leader>x` **Close buffers**; individual entries come directly from the `desc`
already attached to each keymap. `<leader>?` shows only mappings local to the current buffer.

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

Most of this is auto-session's own defaults — `auto_save` and
`args_allow_single_directory` are already on, and `lazy_support` makes it
wait for lazy.nvim before restoring. Three options are set here:
`suppressed_dirs` keeps `~`, `/`, `/tmp` and `~/Downloads` from quietly
accumulating sessions; `auto_restore` leaves a bare `nvim` on the
[dashboard](#dashboard); and a `no_restore_cmds` hook opens neo-tree after a
directory argument fails to restore a session. See
[File explorer](#file-explorer-neo-tree).

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

`close_unsupported_windows` (a default) is what keeps this working with
[neo-tree](#file-explorer-neo-tree): a tree window can't be meaningfully
serialised, so it's closed before the session is written rather than being
restored as a broken buffer. On startup, the `no_restore_cmds` hook is the
other half of that pairing: it opens neo-tree only after auto-session has
confirmed that no session was restored.

### What each launch does

| Command                   | Result                                                                     |
| ------------------------- | -------------------------------------------------------------------------- |
| `nvim`                    | the [dashboard](#dashboard), always — restoring is one keypress away (`s`) |
| `nvim .` — session exists | restores the session; **no** neo-tree, **no** dashboard                    |
| `nvim .` — no session     | opens neo-tree on an empty editor                                          |
| `nvim <directory>`        | the same session-or-neo-tree decision for the supplied directory           |
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
| `e` | File explorer   | `Neotree toggle`            |
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

## File explorer: neo-tree

`<leader>e` toggles the tree (opens *and* focuses it if closed, closes it
if open — `:Neotree toggle`'s own default behavior, needs no extra logic).
Positioned `left`, per `filesystem.window.position`.

**`nvim .` opens neo-tree, not netrw — unless a session is waiting.**
Neo-tree is otherwise lazy-loaded on `:Neotree`/`<leader>e`. For a startup
directory argument, auto-session owns the decision: it first tries to
restore a session for that argument, then its `no_restore_cmds` hook opens
neo-tree only when no session was found. This also handles `nvim
path/to/project` correctly when the shell's cwd differs from the argument.

The directory-argument flag is captured while lazy.nvim reads the
auto-session spec, before startup plugins can rewrite the argument list.
The hook receives `is_startup` and ignores later no-restore events, so a cwd
change during an editing session cannot unexpectedly open the tree. A bare
`nvim` has no directory argument and therefore remains on the dashboard.

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
  `winborder = "rounded"` (the stable Neovim-wide default for native and
  plugin floating windows that do not explicitly override it);
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
  losing Esc's usual behavior.

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
with no extra plugin.

**Diagnostics.** `vim.diagnostic.status()` is deliberately *not* added: lualine
already renders a colored `diagnostics` component in `lualine_b`, and both read
the same counts. Adding it would show every count twice.

**`vim._extui` is not enabled.** The module doesn't exist in the pinned Neovim
0.12.5 — the experimental TUI replacement now lives at `vim._core.ui2`. The
leading underscore is upstream saying it is private and unstable, so this config
does not depend on it. Revisit if and when it gets a public name.

## Clipboard

`clipboard = "unnamedplus"`, so plain `y` and `p` are the system clipboard —
no `"+y` prefix, no extra keymaps. The part that takes thought is *which*
clipboard tool backs that register when Neovim is at the far end of
`laptop → ssh → tmux → nvim`:

| Where Neovim runs | Provider | How it reaches the local clipboard                                        |
| ----------------- | -------- | ------------------------------------------------------------------------- |
| locally           | `pbcopy` | macOS clipboard directly (`wl-copy`/`xclip` on a Linux desktop)           |
| over SSH, in tmux | `tmux`   | tmux's paste buffer, which tmux syncs with the terminal over OSC 52       |
| over SSH, no tmux | `osc52`  | Neovim writes/reads the clipboard through the terminal itself over OSC 52 |

```lua
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  vim.g.clipboard = vim.env.TMUX and "tmux" or "osc52"
end
```

All three are **Neovim's own built-in providers**, selected by name; local
runs are left to auto-detection, which already gets them right.

### Why this is three lines and not a clipboard module

Neovim 0.12's built-in `tmux` provider *is* the hand-rolled approach that was
carried around in earlier configs, upstreamed verbatim — copy is
`tmux load-buffer -w -`, paste is
`tmux refresh-client -l && sleep 0.05 && tmux save-buffer -`. There is
nothing left to write: `refresh-client -l` asks the outer terminal for its
clipboard and stores the reply in a tmux buffer, `save-buffer -` reads it
back.

That routing is also what makes the remote case *reliable*, not just short.
The classic OSC 52 failure — pasting base64 gibberish instead of the text —
happens when a terminal's reply to a clipboard query arrives after the
editor stopped listening and lands in the buffer as ordinary input. On the
tmux path no reply ever reaches Neovim: tmux consumes the escape sequence
and Neovim only ever reads a tmux buffer over a pipe. The direct `osc52`
path can still hit it in principle, but that path is now upstream's
implementation rather than a local copy of it.

### Why the providers are named instead of auto-detected

Auto-detection would pick the `tmux` provider on its own. It would *not*
pick OSC 52: that fallback is skipped whenever `'clipboard'` is non-empty
(upstream's reasoning, in `provider/clipboard.vim`, is that it "can be slow
and cause a lot of user prompts"), and `'clipboard'` is exactly what
`unnamedplus` sets. Opting in by name is the documented way around that.
Naming both also pins the choice on remote hosts where the detection order
might land elsewhere first — e.g. an `xclip` that talks to a forwarded
`$DISPLAY` rather than to the machine actually in front of you.

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
  false, true).desc` returns `"Clear search highlight"`.
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
- Buffer line: `[b` and `]b` cycle in visible order, while
  `<leader><leader>` invokes `BufferLinePick` for letter-based focus. The five
  `<leader>x` mappings resolve to current, others, left, right and pick-close
  operations; the configured close callback is shared by keyboard and mouse
  actions and runs `:confirm bdelete` rather than a forced deletion.
- Indent guides: `ibl` loads for real file buffers, uses Catppuccin's
  `IblIndent`/`IblScope` highlights, and stays disabled in dashboard,
  neo-tree, fzf-lua and other utility buffers.
- Mini editing: `aN`/`iN` and `aL`/`iL` provide Mini AI's extended object
  searches without replacing native `an`/`in`; Mini Surround owns the
  `sa`/`sd`/`sr` family and uses Catppuccin's `MiniSurround` highlight.
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
  highlighting all came back. The launch shapes in the table above were then
  checked: `nvim .` with a session restores the split with **no** tree;
  `nvim .` in a fresh directory opens the tree; bare `nvim` opens the
  [dashboard](#dashboard) without restoring or opening the tree; and `nvim
  main.go` opens just that file. A directory argument different from the
  shell's cwd was also checked: its own session restored with no tree. The
  session file is named for the absolute cwd, and a directory that was only
  browsed produced no session file at all.
- Dashboard: a real `nvim` in a scratch project, queried from inside a
  `VimEnter` autocommand. Plain `nvim` lands on `filetype=alpha`,
  `buftype=nofile`, one window, empty `v:errmsg`, with the banner, the cwd
  line and all nine buttons in the buffer, and all nine shortcut keys mapped
  to the commands in the table above. `require("auto-session.config")
  .auto_restore` is `false` for that launch and `true` for both `nvim .` and
  `nvim main.go` — the flag the whole "dashboard vs. restore" split hangs
  on. The other two launches land where they should and never on the
  dashboard: `nvim .` on `filetype=neo-tree` with two windows, `nvim
  main.go` on the `go` buffer alone. Theming was checked by resolving the
  groups rather than trusting the integration: `AlphaHeader`,
  `AlphaHeaderLabel`, `AlphaButtons`, `AlphaShortcut` and `AlphaFooter` all
  come back with real mocha colors (blue, peach, lavender, green, yellow),
  and `require("catppuccin").options.integrations.alpha` is `true` without
  `colorscheme.lua` mentioning it.
- Clipboard: `provider#clipboard#Executable()` — the name Neovim resolves for
  the register it will actually use — was checked in all three environments,
  with `provider#clipboard#Error()` empty each time: `pbcopy` locally,
  `tmux` with `SSH_TTY` + `TMUX` set, `OSC 52` with `SSH_TTY` and `TMUX`
  unset. Locally the round trip was run for real: `setreg("+", …)` inside
  Neovim, then `pbpaste` outside it returned the same string.
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
