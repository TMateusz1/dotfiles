# Neovim setup — implementation plan

Status: agreed design, not implemented. Upstream facts verified 2026-11-15.
Delete this file once the config is implemented (AGENTS.md: no change narratives).

## 1. Goals and principles

- IDE-grade Neovim 0.12.6 (already pinned in `mise/config.toml` as `aqua:neovim/neovim`).
- Runs in two places from the same dotfiles:
  - macOS host (kitty → nvim, occasionally).
  - Colima Linux VM (kitty on macOS → `colima ssh` → Zellij in the VM → nvim in the VM).
    This is the primary environment. The VM is provisioned by hand from this repo.
- lazy.nvim, hand-built, **no distro**. Borrow LazyVim's proven choices, not its code.
- Ecosystem first: **folke (snacks & co.) + mini.nvim**. Add a plugin only when snacks/mini lack it.
- **mise owns every binary** (LSPs, formatters, linters, tree-sitter CLI). No Mason.
- Catppuccin everywhere (Mocha default, Latte for light).
- Safety: commit-pinned `lazy-lock.json`, no auto-update checker, no luarocks, trusted maintainers.
  Updates only through `mise run global:update`, and the lockfile diff is reviewed in git.
- Leader `<Space>`, local leader `\`.

## 2. Decision log

| Area                       | Decision                                                                            |
| -------------------------- | ----------------------------------------------------------------------------------- |
| Plugin manager             | lazy.nvim, cloned by root `[bootstrap.repos]`, lockfile tracked                     |
| Core ecosystem             | snacks.nvim + mini.nvim + folke plugins                                             |
| File explorer (left)       | `snacks.explorer`, `<leader>e`, replaces netrw                                      |
| Symbol outline (right)     | `aerial.nvim`, `<leader>o`                                                          |
| Finder                     | `snacks.picker`                                                                     |
| Completion                 | `blink.cmp` with native `vim.snippet`                                               |
| Snippets                   | own `nvim/snippets/*.json`; **no** friendly-snippets, **no** Zed snippets           |
| LSP wiring                 | `nvim-lspconfig` (data only) + native `vim.lsp.config` / `vim.lsp.enable`           |
| TypeScript                 | `vtsls` (move to `tsgo` later, see §14)                                             |
| TS/JS/JSON/CSS format+lint | Biome by default; ESLint/Prettier only when the project has their config            |
| YAML / Kubernetes          | yaml-language-server + SchemaStore + `schema-companion.nvim` (k8s + CRD autodetect) |
| Helm                       | `helm-ls` (embeds yamlls for templates); yamlls never attaches to `helm`            |
| Formatting                 | `conform.nvim`, format-on-save, toggle `<leader>uf`                                 |
| Linting                    | `nvim-lint` for non-LSP linters                                                     |
| Git                        | gitsigns + lazygit (`snacks.lazygit`) + diffview                                    |
| Statusline                 | lualine, `globalstatus`                                                             |
| Tabline                    | bufferline, *buffers* mode, offsets for explorer and aerial                         |
| Dashboard / sessions       | `snacks.dashboard` + `persistence.nvim` (per dir + git branch, manual restore)      |
| Zellij navigation          | Zellij `vim-zellij-navigator` plugin + `smart-splits.nvim` v3 + zellij backend      |
| Zellij key collisions      | Zellij keeps all its modes; nvim adapts (jumplist back = `<S-Tab>`)                 |
| Clipboard                  | macOS: pbcopy. Linux/VM: OSC52 copy, paste from nvim registers / Cmd+V              |
| Treesitter                 | `nvim-treesitter` `main` + textobjects + context + ts-autotag                       |
| Repo checks                | `stylua` + `selene` via hk builtins                                                 |
| Not included               | noice, overseer, inc-rename, render-markdown, debugger (DAP), Mason, LuaSnip        |

## 3. Upstream status (verified 2026-11-15)

| Plugin / tool                                  | Repo                                              | Notes                                                                                                                          |
| ---------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| lazy.nvim                                      | `folke/lazy.nvim`                                 | latest tag `v11.17.5`                                                                                                          |
| snacks.nvim                                    | `folke/snacks.nvim`                               | active                                                                                                                         |
| which-key, trouble, persistence, todo-comments | `folke/*`                                         | stable, last pushes late 2025                                                                                                  |
| flash.nvim, lazydev.nvim                       | `folke/*`                                         | active                                                                                                                         |
| mini.nvim                                      | `nvim-mini/mini.nvim`                             | active (org renamed from `echasnovski`)                                                                                        |
| catppuccin                                     | `catppuccin/nvim`                                 | active; `auto_integrations`, `catppuccin.special.bufferline`                                                                   |
| lualine                                        | `nvim-lualine/lualine.nvim`                       | active                                                                                                                         |
| bufferline                                     | `akinsho/bufferline.nvim`                         | **last push 2025-01** — stable, low activity. Accept it; it is still the standard.                                             |
| aerial                                         | `stevearc/aerial.nvim`                            | active                                                                                                                         |
| conform / nvim-lint                            | `stevearc/conform.nvim`, `mfussenegger/nvim-lint` | active                                                                                                                         |
| blink.cmp                                      | `saghen/blink.cmp`                                | `v1.10.2`, ships prebuilt fuzzy binaries with `.sha256` per platform                                                           |
| nvim-lspconfig                                 | `neovim/nvim-lspconfig`                           | active, provides `lsp/*.lua` defaults                                                                                          |
| SchemaStore.nvim                               | `b0o/SchemaStore.nvim`                            | active                                                                                                                         |
| schema-companion                               | `cenk1cenk2/schema-companion.nvim`                | active (pushed 2026-05), **small (≈70★)**, needs `nvim-lua/plenary.nvim`. Fallback: plain yamlls + modelines.                  |
| smart-splits                                   | `smart-splits-nvim/smart-splits.nvim`             | **moved** from `mrjones2014`; `v3.0.0`; backends are separate plugins                                                          |
| zellij backend                                 | `smart-splits-nvim/backend-zellij-lua`            | official org, "feature complete" (Rust rewrite in progress)                                                                    |
| vim-zellij-navigator                           | `hiasr/vim-zellij-navigator`                      | `0.3.0` wasm, Zellij ≥ 0.42.2 (we have 0.45.1)                                                                                 |
| gitsigns                                       | `lewis6991/gitsigns.nvim`                         | active                                                                                                                         |
| diffview                                       | `sindrets/diffview.nvim`                          | **last push 2024-08** (unmaintained but stable). Fallback if it breaks on 0.12: active fork `dlyongemallo/diffview-plus.nvim`. |
| grug-far                                       | `MagicDuck/grug-far.nvim`                         | active                                                                                                                         |
| nvim-treesitter                                | `nvim-treesitter/nvim-treesitter`                 | was archived 2026-04-03, **now unarchived and active**, default branch `main`                                                  |
| ts textobjects / context / autotag             | `nvim-treesitter/*`, `windwp/nvim-ts-autotag`     | active; textobjects on `main`                                                                                                  |

LSP maintainers:

| Server                  | Maintainer                                     | mise backend                                         |
| ----------------------- | ---------------------------------------------- | ---------------------------------------------------- |
| gopls                   | Go team (Google)                               | `aqua:golang/tools/gopls`                            |
| vtsls                   | community (yioneko), wraps VSCode TS extension | `npm:@vtsls/language-server`                         |
| yaml-language-server    | Red Hat                                        | `npm:yaml-language-server`                           |
| helm-ls                 | community (`mrjosh/helm-ls`)                   | `aqua:mrjosh/helm-ls`                                |
| lua-language-server     | LuaLS community                                | `aqua:LuaLS/lua-language-server`                     |
| bash-language-server    | community (bash-lsp)                           | `npm:bash-language-server`                           |
| vscode-json / eslint LS | Microsoft code, community packaging            | `npm:vscode-langservers-extracted`                   |
| docker-language-server  | Docker Inc.                                    | `github:docker/docker-language-server` (not in aqua) |
| ty / ruff               | Astral                                         | `aqua:astral-sh/ty`, `aqua:astral-sh/ruff`           |
| rust-analyzer           | rust-lang                                      | rustup component via mise `rust`                     |
| taplo                   | tamasfe                                        | `aqua:tamasfe/taplo`                                 |
| rumdl                   | rvben                                          | `aqua:rvben/rumdl`                                   |
| biome                   | Biome project                                  | `aqua:biomejs/biome`                                 |

## 4. Repository wiring

### 4.1 Root `mise.toml`

```toml
[tools]
"aqua:JohnnyMorganz/StyLua" = "<latest>"  # Lua formatter for nvim/
"aqua:Kampfkarren/selene" = "0.32.0"       # Lua linter for nvim/

[dotfiles]
# Neovim writes only lazy-lock.json here, and that file is tracked.
"~/.config/nvim" = "nvim"

[bootstrap.repos]
# lazy.nvim itself; plugins are restored from nvim/lazy-lock.json.
# Keep this ref equal to the lazy.nvim `tag` in nvim/lua/config/lazy.lua.
"~/.local/share/nvim/lazy/lazy.nvim" = { url = "https://github.com/folke/lazy.nvim.git", ref = "v11.17.5" }
```

- The `lazy.nvim` spec pins `tag = "v11.17.5"` too, so lazy never moves itself away from the bootstrap ref.
  To bump lazy, change both places.
- Run `mise lock` afterwards so `mise.lock` stays current.

### 4.2 Global `mise/config.toml`

New block, in the file's existing comment style:

```toml
# Neovim tooling (LSPs, formatters, linters)
"aqua:tree-sitter/tree-sitter" = "<latest>"   # Parser compiler for nvim-treesitter
"aqua:golang/tools/gopls" = "0.24.0"          # Go LSP
"aqua:golangci/golangci-lint" = "<latest>"    # Go linter
"npm:@vtsls/language-server" = "0.3.0"        # TypeScript LSP
"aqua:biomejs/biome" = "<latest>"             # JS/TS/JSON/CSS formatter + linter
"npm:vscode-langservers-extracted" = "4.10.0" # JSON + ESLint LSPs
"npm:yaml-language-server" = "2.0.0"          # YAML LSP (also used by helm-ls)
"aqua:mrjosh/helm-ls" = "0.5.4"               # Helm LSP
"aqua:LuaLS/lua-language-server" = "<latest>" # Lua LSP
"aqua:JohnnyMorganz/StyLua" = "<latest>"      # Lua formatter
"npm:bash-language-server" = "5.8.1"          # Shell LSP (runs shellcheck itself)
"aqua:koalaman/shellcheck" = "0.11.0"         # Shell linter (used by bashls)
"aqua:mvdan/sh" = "<latest>"                  # shfmt
"github:docker/docker-language-server" = "0.20.1" # Dockerfile/Compose LSP
"aqua:hadolint/hadolint" = "<latest>"         # Dockerfile linter
"aqua:astral-sh/ty" = "<latest>"              # Python type checker LSP
"aqua:astral-sh/ruff" = "<latest>"            # Python linter + formatter (LSP)
"aqua:tamasfe/taplo" = "0.10.0"               # TOML LSP + formatter
"aqua:rvben/rumdl" = "0.2.76"                 # Markdown LSP + linter
"aqua:google/yamlfmt" = "0.21.0"              # YAML formatter
```

- `rust = { version = "1.99.1", components = "rust-analyzer,rustfmt,clippy" }`. rust-analyzer comes from rustup.
- The npm tools depend on the global `node`, which is already pinned.
  These are the only npm tools, accepted because no static alternatives exist.
- Resolve every `<latest>` with `mise latest <tool>` at implementation time.
  Then run `mise lock --global` for all three `lockfile_platforms`.
- `global:setup` in **both** `config.toml` and `config.macos.toml` gets a final step:

  ```sh
  # Restore plugins exactly as locked, then install the configured parsers.
  test ! -f "$HOME/.config/nvim/init.lua" || nvim --headless "+Lazy! restore" \
    "+lua require('nvim-treesitter').install(require('config.parsers')):wait(600000)" +qa
  ```

- `global:update` gets, before its final `mise run global:setup`:

  ```sh
  nvim --headless "+Lazy! update" "+lua require('nvim-treesitter').update():wait(600000)" +qa
  ```

  The resulting `nvim/lazy-lock.json` diff is reviewed and committed by the user.

### 4.3 `hk.pkl`

```pkl
// lua (nvim config)
["stylua"] = (Builtins.stylua) { glob = List("nvim/**/*.lua") }
["selene"] = (Builtins.selene) { glob = List("nvim/**/*.lua"); dir = "nvim" }
```

- `selene` runs from `nvim/` so it picks up `nvim/selene.toml`.
- Check the exact field names against hk 2.1.0's `stylua.pkl` and `selene.pkl` builtins.

### 4.4 `zellij/config.kdl`

Inside `shared_except "locked"`, replace the four `Ctrl <arrow>` binds with navigator calls:

```kdl
bind "Ctrl left" {
    MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm" {
        name "move_focus_or_tab"; payload "left";
        move_mod "ctrl"; use_arrow_keys "true";
    };
}
// Ctrl down → move_focus/down, Ctrl up → move_focus/up, Ctrl right → move_focus_or_tab/right
```

- Every call carries the **same** `move_mod "ctrl"` and `use_arrow_keys "true"`.
  The plugin configures itself from the first message it receives.
- `Alt h/j/k/l` stay as native Zellij `MoveFocusOrTab` and do **not** pass through nvim.
  The plugin has one move modifier, and Ctrl+arrows is the requirement.
  Inside nvim, `Alt+hjkl` is unused, so pressing it jumps straight to the neighbouring Zellij pane.
- All other Zellij modes are unchanged: `Ctrl-o/t/p/s/n/h/l/g/q`.
- Known upstream caveat: the first press per direction in a new session briefly flashes a pane.

### 4.5 `lazygit/config.yml`

- Add `os.editPreset: nvim-remote`. This file currently has uncommitted user edits, so add it on top of them.
  Files opened from lazygit inside nvim then land in the running nvim; outside nvim, lazygit starts a new nvim.
- `snacks.lazygit` uses `configure = false`, so the official Catppuccin lazygit theme already in that file stays in charge.

### 4.6 README

One line in the setup section: nvim is part of `bootstrap:all` / `global:setup`.
No caveat for the VM's C compiler, since the VM is already prepared.

## 5. Directory layout

```text
nvim/
├── init.lua                  -- leader, providers off, require config.*
├── lazy-lock.json            -- tracked; written by lazy
├── .stylua.toml              -- 2 spaces, column_width 120
├── selene.toml               -- std = "vim"
├── vim.yml                   -- selene std: `vim` global
├── lua/
│   ├── config/
│   │   ├── options.lua
│   │   ├── keymaps.lua       -- non-plugin keymaps
│   │   ├── autocmds.lua
│   │   ├── clipboard.lua
│   │   ├── diagnostics.lua
│   │   ├── parsers.lua       -- treesitter parser list (shared with global:setup)
│   │   └── lazy.lua          -- lazy.nvim setup
│   └── plugins/              -- one spec file per area; lazy imports "plugins"
│       ├── colorscheme.lua   -- catppuccin
│       ├── snacks.lua        -- snacks (picker, explorer, dashboard, …) + its keymaps
│       ├── ui.lua            -- lualine, bufferline, which-key, aerial, todo-comments, trouble
│       ├── editor.lua        -- mini.*, flash, grug-far, persistence, smart-splits
│       ├── completion.lua    -- blink.cmp, lazydev
│       ├── lsp.lua           -- nvim-lspconfig, SchemaStore, schema-companion, LspAttach
│       ├── format.lua        -- conform
│       ├── lint.lua          -- nvim-lint
│       ├── git.lua           -- gitsigns, diffview
│       └── treesitter.lua    -- nvim-treesitter, textobjects, context, autotag
├── after/
│   └── lsp/                  -- per-server overrides (after/ beats nvim-lspconfig's lsp/)
│       ├── gopls.lua  vtsls.lua  lua_ls.lua  yamlls.lua  helm_ls.lua
│       ├── jsonls.lua  bashls.lua  eslint.lua  biome.lua
│       └── ty.lua  ruff.lua  rust_analyzer.lua  docker_language_server.lua
└── snippets/
    ├── package.json          -- VSCode-style manifest for blink's snippet loader
    └── go.json               -- small starter set
```

- Overrides live in `after/lsp/`, not `lsp/`. Runtime-path order would otherwise let nvim-lspconfig's `lsp/` win.
  schema-companion also requires `after/lsp`.
- Go indentation needs no ftplugin, because Neovim's bundled Go ftplugin already sets `noexpandtab`.

## 6. Core config

### 6.1 `init.lua`

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- No remote-plugin providers are used.
for _, p in ipairs({ "node", "perl", "python3", "ruby" }) do vim.g["loaded_" .. p .. "_provider"] = 0 end
require("config.options")
require("config.clipboard")
require("config.diagnostics")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
```

### 6.2 `config/options.lua`

| Option                                              | Value                                                                     | Why                                                             |
| --------------------------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `number`, `relativenumber`                          | `true`, `true`                                                            | relative in normal mode; autocmd switches to absolute in insert |
| `signcolumn`                                        | `"yes"`                                                                   | no jumping when signs appear                                    |
| `cursorline`                                        | `true`                                                                    |                                                                 |
| `scrolloff` / `sidescrolloff`                       | `8` / `8`                                                                 |                                                                 |
| `wrap`                                              | `false`                                                                   | toggle `<leader>uw`                                             |
| `expandtab`, `shiftwidth`, `tabstop`, `softtabstop` | `true`, `2`, `2`, `2`                                                     | ftplugins override (Go uses tabs)                               |
| `shiftround`, `smartindent`                         | `true`                                                                    |                                                                 |
| `ignorecase`, `smartcase`                           | `true`                                                                    |                                                                 |
| `hlsearch`, `incsearch`                             | `true`                                                                    | `<Esc>` clears highlight                                        |
| `inccommand`                                        | `"split"`                                                                 | live `:s` preview                                               |
| `splitright`, `splitbelow`, `splitkeep`             | `true`, `true`, `"screen"`                                                |                                                                 |
| `undofile`, `undolevels`                            | `true`, `10000`                                                           |                                                                 |
| `swapfile`                                          | `false`                                                                   | persistent undo + git cover it                                  |
| `updatetime` / `timeoutlen`                         | `250` / `300`                                                             | which-key appears fast                                          |
| `confirm`                                           | `true`                                                                    | ask instead of failing on `:q` with changes                     |
| `mouse`                                             | `"a"`                                                                     |                                                                 |
| `termguicolors`                                     | `true`                                                                    |                                                                 |
| `laststatus`                                        | `3`                                                                       | one global statusline                                           |
| `showtabline`                                       | `2`                                                                       | bufferline always visible                                       |
| `showmode`                                          | `false`                                                                   | mode shown in lualine                                           |
| `cmdheight`                                         | `1`                                                                       |                                                                 |
| `pumheight`                                         | `10`                                                                      |                                                                 |
| `winborder`                                         | `"rounded"`                                                               | 0.11+ default border for floats                                 |
| `list`, `listchars`                                 | `true`, `{ tab = "» ", trail = "·", nbsp = "␣" }`                         |                                                                 |
| `fillchars`                                         | `{ eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }` |                                                                 |
| `foldmethod`, `foldexpr`                            | `"expr"`, `"v:lua.vim.treesitter.foldexpr()"`                             |                                                                 |
| `foldlevel`, `foldlevelstart`                       | `99`, `99`                                                                | open by default                                                 |
| `foldtext`                                          | `""`                                                                      | 0.10+ highlighted fold line                                     |
| `virtualedit`                                       | `"block"`                                                                 |                                                                 |
| `completeopt`                                       | `"menu,menuone,noselect"`                                                 | blink owns the UI anyway                                        |
| `shortmess:append`                                  | `"WIcC"`                                                                  | quieter messages                                                |
| `sessionoptions`                                    | `"buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"`        | no blank/terminal windows in sessions                           |
| `grepprg` / `grepformat`                            | `"rg --vimgrep"` / `"%f:%l:%c:%m"`                                        |                                                                 |
| `spelllang`                                         | `{ "en" }`                                                                | spell is off by default                                         |

### 6.3 `config/clipboard.lua`

- `clipboard` is set inside `vim.schedule` so the provider lookup doesn't slow startup.
- On macOS (`vim.fn.has("mac") == 1`), Neovim's built-in pbcopy/pbpaste provider is used, with `clipboard = "unnamedplus"`.
- Elsewhere (the VM), copy goes through OSC52 and paste reads Neovim's own unnamed register:

```lua
local osc52 = require("vim.ui.clipboard.osc52")
local function paste() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end
vim.g.clipboard = {
  name = "OSC 52 (copy only)",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste, ["*"] = paste },
}
```

- Copy path: nvim → Zellij (VM, which forwards OSC52 to the client) → kitty (`clipboard_control write-clipboard`) → macOS clipboard.
- Paste from macOS into nvim: Cmd+V, sent as bracketed paste through Zellij.
- **Test once during implementation:** swap `paste` for `osc52.paste("+")` and try `"+p` inside Zellij 0.45.1.
  If Zellij forwards the OSC52 read (kitty already allows it), keep it.
  Otherwise keep the register fallback. Without it, a read waits until it times out.
- Zellij's own copy-on-select already uses OSC52, because `copy_command` is unset.

### 6.4 `config/diagnostics.lua`

```lua
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { current_line = true, spacing = 2, source = "if_many" },
  virtual_lines = false,
  float = { border = "rounded", source = "if_many" },
  signs = { text = { [ERROR] = " ", [WARN] = " ", [INFO] = " ", [HINT] = "󰌵 " } },
})
```

- `virtual_text.current_line` gives "inline only on the current line" without the layout shifts `virtual_lines` causes.
- `<leader>uv` toggles `virtual_lines = { current_line = true }` for multi-line messages.

### 6.5 `config/autocmds.lua`

Everything goes in one `augroup("user", { clear = true })`:

1. **Number toggle**:
   - On `InsertEnter`, set `relativenumber = false`.
   - On `InsertLeave`, `FocusGained` and `BufEnter`, set it back to `true`.
   - Only when `vim.wo.number` is on and the buffer is a normal file (`buftype == ""`).
2. **Yank highlight**: `TextYankPost`, `vim.hl.on_yank({ timeout = 150 })`.
3. **Restore cursor**: on `BufReadPost`, jump to the `'"` mark, except for `gitcommit` and `gitrebase`.
4. **Close with `q`**: on `FileType` for `help, qf, man, lspinfo, checkhealth, notify, grug-far, gitsigns-blame, dbout`, map `q` to `:close` and set `buflisted = false`.
5. **Create parent directories**: `BufWritePre`, `vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")`, skipped for URLs.
6. **Equalise splits on resize**: on `VimResized`, run `tabdo wincmd =` (Zellij pane resizes).
7. **Reload changed files**: on `FocusGained`, `TermClose` and `TermLeave`, run `checktime`.
8. **Text filetypes**: on `FileType` for `gitcommit, markdown, text`, set `wrap` and `spell`.
9. **`nvim <dir>`**: on `VimEnter`, when argv is a single directory, `cd` into it, call `Snacks.dashboard.open()`, then open `Snacks.explorer()`.
   The result is the explorer on the left and the dashboard on the right.

### 6.6 `config/keymaps.lua` (non-plugin)

| Mode | Key               | Action                                                           |
| ---- | ----------------- | ---------------------------------------------------------------- |
| n    | `<Esc>`           | `<cmd>nohlsearch<cr><Esc>`                                       |
| n    | `<S-Tab>`         | `<C-o>` (jumplist back, because Zellij owns `Ctrl-o`)            |
| n    | `<Tab>`           | native (jumplist forward, same key as `Ctrl-i`); not remapped    |
| n,x  | `j` / `k`         | `v:count == 0 ? 'gj' : 'j'` (move by display lines when wrapped) |
| n    | `<S-h>` / `<S-l>` | previous / next buffer (`BufferLineCyclePrev/Next`)              |
| n    | `[b` / `]b`       | same as `<S-h>`/`<S-l>`                                          |
| x    | `<` / `>`         | indent and keep the selection                                    |
| n    | `n` / `N`         | `nzzzv` / `Nzzzv` (keep the match centred)                       |
| n    | `<leader>l`       | `:Lazy`                                                          |
| n    | `<leader>fn`      | new buffer                                                       |
| n    | `[q` / `]q`       | quickfix prev/next (from mini.bracketed)                         |
| n    | `[d` / `]d`       | native 0.11 diagnostic jumps (already default)                   |

Neovim defaults lost to Zellij, and their replacements:

| Default                               | Taken by Zellij for              | Use instead                                              |
| ------------------------------------- | -------------------------------- | -------------------------------------------------------- |
| `Ctrl-o` jumplist back                | session mode                     | `<S-Tab>`                                                |
| `Ctrl-t` tag pop / insert indent      | tab mode                         | `<S-Tab>` after `gd`; `>>` / `<C-t>` after `Ctrl-g` lock |
| `Ctrl-p` / `Ctrl-n` insert completion | pane / resize mode               | blink `<C-k>` / `<C-j>`                                  |
| `Ctrl-s` (unused)                     | scroll mode                      | `:w`                                                     |
| `Ctrl-h` insert backspace             | move mode                        | `<BS>`                                                   |
| `Ctrl-l` redraw                       | personal group (forwards Ctrl-l) | works through the Zellij group                           |
| `Ctrl-g` file info                    | lock                             | `:file` or the statusline                                |
| `Ctrl-q` (visual block alt)           | quit                             | `Ctrl-v`                                                 |

`Ctrl-g` locks Zellij, which gives every key back to nvim temporarily.

## 7. lazy.nvim (`config/lazy.lua`)

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  error("lazy.nvim missing: run `mise run bootstrap:plugins` from the dotfiles repo")
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "folke/lazy.nvim", tag = "v11.17.5" }, -- matches [bootstrap.repos]
    { import = "plugins" },
  },
  defaults = { lazy = true, version = false }, -- commits come from lazy-lock.json
  install = { missing = true, colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = { disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" } },
  },
})
```

- lazy.nvim is never cloned at runtime. Bootstrap owns it, and the explicit error says how to fix a missing copy.
- `version = false` everywhere except `blink.cmp` (`version = "1.*"`).
  Its prebuilt binary is only downloaded for a release tag, and that download is checked against the published `.sha256`.
- The lockfile path is the default (`stdpath("config")/lazy-lock.json`), which is the tracked `nvim/lazy-lock.json`.

## 8. Plugins and their options

Load events: `lazy = false` for the colorscheme, snacks, treesitter and smart-splits.
Everything else loads on `VeryLazy`, `BufReadPre`/`BufNewFile`, `InsertEnter`, `cmd` or `keys`.

### 8.1 `colorscheme.lua` — catppuccin

```lua
{ "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
  opts = {
    flavour = "auto",
    background = { light = "latte", dark = "mocha" },
    transparent_background = false,
    term_colors = true,
    dim_inactive = { enabled = false },
    auto_integrations = true, -- detects installed lazy plugins
    integrations = {
      snacks = { enabled = true, indent_scope_color = "lavender" },
      mini = { enabled = true },
      native_lsp = { enabled = true, underlines = { errors = { "undercurl" }, warnings = { "undercurl" } } },
    },
  },
  config = function(_, o) require("catppuccin").setup(o); vim.cmd.colorscheme("catppuccin") end }
```

- `background` defaults to `dark`, which gives Mocha. Neovim's terminal background detection switches to Latte when kitty is light.

### 8.2 `snacks.lua` — snacks.nvim (`lazy = false`, `priority = 1000`)

| Module                                              | Options                                                                                                                                                                                |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bigfile`                                           | `{ enabled = true }` (turns off treesitter, LSP and others on huge files)                                                                                                              |
| `quickfile`                                         | `{ enabled = true }` (fast render for `nvim file`)                                                                                                                                     |
| `notifier`                                          | `{ enabled = true, timeout = 3000, style = "compact" }`; `<leader>fN` notification history, `<leader>un` dismiss                                                                       |
| `input`                                             | `{ enabled = true }` (`vim.ui.input`, used by LSP rename)                                                                                                                              |
| `indent`                                            | `{ enabled = true, animate = { enabled = false } }`, scope highlight on                                                                                                                |
| `scope`                                             | `{ enabled = true }` (also gives `ii`/`ai` scope text objects and `[i`/`]i`)                                                                                                           |
| `words`                                             | `{ enabled = true, debounce = 200 }`; `]]`/`[[` jump between references                                                                                                                |
| `statuscolumn`                                      | `{ enabled = true, left = { "mark", "sign" }, right = { "fold", "git" }, folds = { open = false, git_hl = true } }`                                                                    |
| `dashboard`                                         | `{ enabled = true, preset = { keys = default keys } }`; sections: header, keys, recent files (cwd), projects, startup. The preset keys detect persistence for "Restore Session" (`s`). |
| `explorer`                                          | `{ enabled = true, replace_netrw = true }`                                                                                                                                             |
| `picker`                                            | see below                                                                                                                                                                              |
| `lazygit`                                           | `{ configure = false }` (keeps the repo's Catppuccin lazygit theme)                                                                                                                    |
| `gitbrowse`, `bufdelete`, `rename`, `zen`, `toggle` | default                                                                                                                                                                                |
| `scroll`, `animate`, `dim`                          | **off** (no animation)                                                                                                                                                                 |

Picker options:

```lua
picker = {
  ui_select = true,                                  -- vim.ui.select → picker
  layout = { preset = "default", cycle = true },     -- preview on the right
  matcher = { frecency = true },
  formatters = { file = { filename_first = true } },
  sources = {
    explorer = {
      layout = { preset = "sidebar", layout = { position = "left", width = 30 } },
      auto_close = false,
      follow_file = true,
      git_status = true, git_untracked = true,
      diagnostics = true,
      hidden = false, ignored = false,               -- toggle with H / I inside explorer
      jump = { close = false },
    },
    files = { hidden = true },                       -- dotfiles, still respects .gitignore
    grep = { hidden = true },
  },
  win = { input = { keys = { ["<C-j>"] = { "list_down", mode = { "i", "n" } }, ["<C-k>"] = { "list_up", mode = { "i", "n" } } } } },
}
```

`<C-j>`/`<C-k>` move through picker lists, the same as in blink (Zellij owns `Ctrl-p`).
All snacks keymaps are listed in §11.

### 8.3 `ui.lua`

**lualine** (`event = "VeryLazy"`):

```lua
options = {
  theme = "catppuccin",            -- check the theme name exported by catppuccin
  globalstatus = true,
  component_separators = "", section_separators = { left = "", right = "" },
  disabled_filetypes = { statusline = { "snacks_dashboard" } },
},
sections = {
  lualine_a = { "mode" },
  lualine_b = { "branch", { "diff", source = gitsigns_status_dict } },
  lualine_c = { { "diagnostics" }, { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
                { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "" } } },
  lualine_x = { lsp_and_formatters, { Snacks.profiler status if enabled } },
  lualine_y = { "progress", "location" },
  lualine_z = { function() return os.date(" %R") end },
},
extensions = { "lazy", "quickfix", "man", "trouble", "aerial" },
```

- `gitsigns_status_dict` reads `vim.b.gitsigns_status_dict` (added, changed, removed).
- `lsp_and_formatters` is a small inline component: `gopls, golangci-lint │ 󰉿 gofumpt`.
  It lists the names from `vim.lsp.get_clients({ bufnr = 0 })` and `require("conform").list_formatters(0)`.
  It also shows a dimmed `󰉿 off` when format-on-save is disabled for the buffer.

**bufferline** (`event = "VeryLazy"`, loads after catppuccin):

```lua
opts = {
  highlights = require("catppuccin.special.bufferline").get_theme(),
  options = {
    mode = "buffers",
    close_command = function(n) Snacks.bufdelete(n) end,
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
    diagnostics = "nvim_lsp",
    diagnostics_indicator = errors and warnings icons + counts,
    always_show_bufferline = true,
    show_buffer_close_icons = false,
    separator_style = "thin",
    offsets = {
      { filetype = "snacks_layout_box", text = "Explorer", highlight = "Directory", separator = true },
      { filetype = "aerial", text = "Outline", highlight = "Directory", separator = true },
    },
  },
}
```

- The offsets keep the tab bar from running over the explorer (left) and aerial (right).
- Pinning: `<leader>bp` runs `BufferLineTogglePin` and `<leader>bP` runs `BufferLineGroupClose ungrouped`.

**which-key** (`event = "VeryLazy"`):

```lua
opts = { preset = "helix", delay = 300, spec = {
  { "<leader>f", group = "find" }, { "<leader>g", group = "git" }, { "<leader>c", group = "code" },
  { "<leader>x", group = "diagnostics/quickfix" }, { "<leader>b", group = "buffer" },
  { "<leader>u", group = "ui/toggles" }, { "<leader>S", group = "session" },
  { "<leader>r", group = "replace" }, { "[", group = "prev" }, { "]", group = "next" },
  { "g", group = "goto" }, { "gs", group = "surround" },
} }
```

`<leader>?` shows the buffer-local keymaps (`require("which-key").show({ global = false })`).

**aerial** (`cmd = "AerialToggle"`, `keys = <leader>o`):

```lua
opts = {
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = { default_direction = "right", placement = "edge", min_width = 30, max_width = { 40, 0.2 }, resize_to_content = false },
  attach_mode = "global",          -- follows the current window
  show_guides = true,
  highlight_on_hover = true,
  autojump = false,
  close_on_select = false,
  filter_kind = false,             -- show all kinds (Go has few)
  icons = from mini.icons,
  keymaps = { ["<C-j>"] = "actions.down_and_scroll", ["<C-k>"] = "actions.up_and_scroll" },
}
```

`placement = "edge"` docks it on the far right regardless of splits, like Zed's outline panel.

**todo-comments** (`event = BufReadPost`): defaults. `]t`/`[t` jump between todos and `<leader>xt` opens them in Trouble. `<leader>ft` searches todos with the picker.

**trouble** (`cmd = "Trouble"`): `opts = { focus = true, modes = { symbols = { win = { position = "right" } } } }`. The symbols mode is unused; aerial owns the outline.

### 8.4 `editor.lua`

**mini.ai** (`event = "VeryLazy"`):

```lua
local ai = require("mini.ai")
opts = { n_lines = 500, custom_textobjects = {
  o = ai.gen_spec.treesitter({ a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                                i = { "@block.inner", "@conditional.inner", "@loop.inner" } }),
  f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
  c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
  t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },  -- tags
  d = { "%f[%d]%d+" },                                                  -- digits
  e = { { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" }, "^().*()$" }, -- CamelCase/snake word part
  g = function() ... whole buffer ... end,                              -- from mini.extra
  u = ai.gen_spec.function_call(),
  U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
} }
```

The `a` (argument) and `q` (quote) text objects are built into mini.ai.
The `ag`/`ig` whole-buffer object comes from `mini.extra`'s `gen_ai_spec.buffer()`, so add `mini.extra`.
It is part of mini.nvim, the same repo.

**mini.surround**: uses the `gs` prefix so it doesn't clash with flash's `s`.

```lua
opts = { mappings = { add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
                      highlight = "gsh", replace = "gsr", update_n_lines = "gsn" } }
```

**mini.pairs** (`event = "InsertEnter"`):

```lua
opts = { modes = { insert = true, command = true, terminal = false },
         skip_next = [=[[%w%%%'%[%"%.%`%$]]=], skip_ts = { "string" },
         skip_unbalanced = true, markdown = true }
```

These are LazyVim's proven options: no pair before a word character or inside strings, and backticks handled for markdown.
`<leader>up` toggles it with `vim.g.minipairs_disable`.

**mini.icons** (`lazy = true`): `opts = {}` plus `init = MiniIcons.mock_nvim_web_devicons()`, so plugins that expect devicons still work.

**mini.bracketed** (`event = "VeryLazy"`). Disable the targets that collide with other bindings:

```lua
opts = { buffer = { suffix = "" },     -- bufferline owns [b ]b (visual order)
         diagnostic = { suffix = "" }, -- native 0.11 [d ]d
         file = { suffix = "" },       -- [f ]f = treesitter functions
         treesitter = { suffix = "" }, -- [t ]t = todo-comments
         indent = { suffix = "" } }    -- snacks.scope owns [i ]i
-- kept: comment c, conflict x, jump j, location l, oldfile o, quickfix q, undo u, window w, yank y
```

**mini.splitjoin**: default `gS` toggles split/join of arguments, tables and similar.

Commenting uses Neovim's native `gc`/`gcc`, which is treesitter-aware through `commentstring`. No plugin.

**flash.nvim** (`event = "VeryLazy"`):

```lua
opts = { modes = { search = { enabled = false }, char = { enabled = true, jump_labels = true } } }
keys = { { "s", flash.jump, mode = { "n", "x", "o" } }, { "S", flash.treesitter, mode = { "n", "x", "o" } },
         { "r", flash.remote, mode = "o" }, { "R", flash.treesitter_search, mode = { "o", "x" } } }
```

- Search integration stays off so `/` behaves normally. `f`/`t` get jump labels.
- `s` replaces Vim's `s` (use `cl` instead).

**grug-far** (`cmd = "GrugFar"`):

```lua
opts = { headerMaxWidth = 80, transient = true }
keys = { { "<leader>rr", open (prefill current file's filetype glob), mode = { "n", "x" } },
         { "<leader>rw", open with prefills.search = <cword> } }
```

In visual mode, `<leader>rr` searches for the selected text (`require("grug-far").with_visual_selection()`).

**persistence.nvim** (`event = "BufReadPre"`):

```lua
opts = { branch = true, need = 1 }
keys = { { "<leader>Ss", load() }, { "<leader>Sl", load({ last = true }) },
         { "<leader>SS", select() }, { "<leader>Sd", stop() } }
```

- Sessions are never restored automatically. Use the dashboard `s` key or `<leader>Ss`.
- A `PersistenceSavePre` autocmd closes the snacks explorer and aerial, so they aren't saved as empty windows.

**smart-splits.nvim** (`lazy = false`):

```lua
{ "smart-splits-nvim/smart-splits.nvim", version = "^3.0.0", lazy = false,
  dependencies = { { "smart-splits-nvim/backend-zellij-lua", main = "smart-splits-backend-zellij-lua",
                     opts = { move_cursor = { pane_or_tab = true }, fullscreen = { block_nav = true },
                              split = { left = false, right = false, up = false, down = false } } } },
  opts = { mux = { backend = "smart-splits-backend-zellij-lua" }, at_edge = "wrap",
           ignored_buftypes = { "nofile", "quickfix", "prompt" }, ignored_filetypes = { "snacks_layout_box" },
           default_amount = 3 } }
```

- `ignored_filetypes` is an exception list: the explorer stays reachable with arrows. Remove that entry if it causes trouble.
- `at_edge = "wrap"` applies only outside Zellij. Inside Zellij the backend hands off at the edge.
- `pane_or_tab = true` matches Zellij's `MoveFocusOrTab` on left and right.

Keymaps in modes `n`, `i`, `t`:

| Key                                        | Action                                                  |
| ------------------------------------------ | ------------------------------------------------------- |
| `<C-Left>` `<C-Down>` `<C-Up>` `<C-Right>` | `move_cursor_*` (crosses into Zellij panes at the edge) |
| `<A-Left>` `<A-Down>` `<A-Up>` `<A-Right>` | `resize_*` (nvim splits only; Zellij keeps `Alt +/-`)   |
| `<leader><C-Left>` …                       | `swap_buf_*` (move a buffer to the neighbouring split)  |

- Insert mode loses Ctrl+arrow word jumps. Use `<S-Left>`/`<S-Right>`, which are native word motions in insert mode.
- Window splits use native `<C-w>s`/`<C-w>v`/`<C-w>q`. No `<leader>w` group.

### 8.5 `completion.lua`

**blink.cmp** (`event = { "InsertEnter", "CmdlineEnter" }`, `version = "1.*"`):

```lua
opts = {
  keymap = {
    preset = "none",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" }, ["<C-k>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" }, ["<Up>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" }, ["<C-d>"] = { "scroll_documentation_down", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },     -- GeistMono Nerd Font Mono
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    accept = { auto_brackets = { enabled = true } },
    menu = { border = "rounded", draw = { treesitter = { "lsp" }, columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } } } },
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
    ghost_text = { enabled = true },
  },
  signature = { enabled = true, window = { border = "rounded" } },
  snippets = { preset = "default" },              -- native vim.snippet
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      snippets = { opts = { friendly_snippets = false, search_paths = { vim.fn.stdpath("config") .. "/snippets" } } },
    },
  },
  cmdline = { enabled = true, keymap = { preset = "cmdline" }, completion = { menu = { auto_show = true } } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
}
```

- `mini.icons` provides the kind icons (`kind_icon` text and highlight from `MiniIcons.get("lsp", kind)`).
- Capabilities: `vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })`, in `lsp.lua`.

**lazydev.nvim** (`ft = "lua"`): `opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } }, "snacks.nvim", "lazy.nvim" } }`.

**Snippets** (`nvim/snippets/`):

- `package.json`: `{ "name": "user-snippets", "contributes": { "snippets": [ { "language": "go", "path": "./go.json" } ] } }`.
- `go.json`: starter set of `iferr` (`if err != nil { return ${1:err} }`), `fn`, `meth`, `tt` (table test skeleton) and `test` (`func Test…(t *testing.T)`).
- Add a language by adding a JSON file and a `package.json` entry.

### 8.6 `lsp.lua`

Plugins:

- `neovim/nvim-lspconfig` (`event = { "BufReadPre", "BufNewFile" }`). It provides only the `lsp/*.lua` defaults on the runtime path. Never call `require("lspconfig")`.
- `b0o/SchemaStore.nvim` (`lazy = true`).
- `cenk1cenk2/schema-companion.nvim` (`lazy = true`, depends on `nvim-lua/plenary.nvim`), `opts = {}`.

`config` function:

```lua
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(), root_markers = { ".git" } })
vim.lsp.enable({
  "gopls", "vtsls", "eslint", "biome", "jsonls", "yamlls", "helm_ls", "lua_ls", "bashls",
  "docker_language_server", "ty", "ruff", "rust_analyzer", "taplo", "rumdl",
})
```

`LspAttach` autocmd (buffer-local keymaps):

| Key                      | Action                                                                                             |
| ------------------------ | -------------------------------------------------------------------------------------------------- |
| `gd`                     | `Snacks.picker.lsp_definitions()`                                                                  |
| `gD`                     | definition in a vertical split (`vsplit` + `vim.lsp.buf.definition()`) — same as Zed's `g shift-d` |
| `gr`                     | `Snacks.picker.lsp_references()` (`nowait = true`; native `grn`/`gra`/`grr`/`gri` still exist)     |
| `gI`                     | `Snacks.picker.lsp_implementations()`                                                              |
| `gy`                     | `Snacks.picker.lsp_type_definitions()`                                                             |
| `K`                      | hover (native)                                                                                     |
| `gK` / `<C-k>` in insert | signature help (blink covers insert mode automatically)                                            |
| `<leader>ca`             | `vim.lsp.buf.code_action()` (n, x)                                                                 |
| `<leader>cr`             | `vim.lsp.buf.rename()` (uses `snacks.input`)                                                       |
| `<leader>cR`             | `Snacks.rename.rename_file()` (rename the file and update imports)                                 |
| `<leader>cd`             | `vim.diagnostic.open_float()`                                                                      |
| `<leader>cl`             | `:checkhealth vim.lsp`                                                                             |
| `<leader>co`             | organize imports (`source.organizeImports` code action, applied)                                   |

- Inlay hints are off by default. `<leader>uh` runs `Snacks.toggle.inlay_hints()`.
- `snacks.words` highlights the symbol under the cursor, so no `documentHighlight` autocmd is needed.

Per-server overrides in `after/lsp/<name>.lua`:

- **gopls**:

  ```lua
  settings = { gopls = {
    gofumpt = true, usePlaceholders = false, completeUnimported = true, staticcheck = true,
    semanticTokens = true, directoryFilters = { "-.git", "-node_modules", "-.vscode", "-.idea" },
    analyses = { unusedparams = true, unusedwrite = true, nilness = true, shadow = true },
    codelenses = { generate = true, test = true, tidy = true, upgrade_dependency = true, vendor = true },
    hints = { assignVariableTypes = true, compositeLiteralFields = true, constantValues = true,
              functionTypeParameters = true, parameterNames = true, rangeVariableTypes = true },
  } }
  ```

  - Organize imports runs on save. A `BufWritePre *.go` autocmd in `lsp.lua` sends a synchronous `source.organizeImports` code action.
    This is the snippet documented by gopls in `gopls/doc/vim.md`.
  - gopls itself formats with gofumpt through conform's LSP fallback.
- **vtsls**:

  ```lua
  settings = { complete_function_calls = true, vtsls = { enableMoveToFileCodeAction = true, autoUseWorkspaceTsdk = true,
    experimental = { completion = { enableServerSideFuzzyMatch = true } } },
    typescript = { updateImportsOnFileMove = { enabled = "always" }, suggest = { completeFunctionCalls = true },
      inlayHints = { parameterNames = { enabled = "literals" }, parameterTypes = { enabled = true },
        variableTypes = { enabled = false }, propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true }, enumMemberValues = { enabled = true } } } }
  -- javascript = same as typescript
  ```

  Formatting is disabled in vtsls (`on_init` clears `documentFormattingProvider`). Biome or Prettier format instead.
- **eslint**: nvim-lspconfig's default root markers mean it attaches only when an ESLint config exists. `settings = { workingDirectories = { mode = "auto" } }`.
- **biome**: the default root markers (`biome.json`, `biome.jsonc`) give lint diagnostics and code actions only in Biome projects. Formatting goes through conform (§9).
- **jsonls**: `settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true }, format = { enable = false } } }`.
- **yamlls** (schema-companion wrapper, following its README):

  ```lua
  local sc = require("schema-companion")
  return sc.setup_client(sc.adapters.yamlls.setup({
    sources = {
      sc.sources.matchers.kubernetes.setup({ version = "master" }), -- apiVersion/kind → yannh schemas; CRDs → datreeio catalog
      sc.sources.lsp.setup(),
      sc.sources.none.setup(),
    },
  }), {
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },   -- never "helm"
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = { keyOrdering = false, format = { enable = false }, validate = true, hover = true, completion = true,
               schemaStore = { enable = false, url = "" }, schemas = require("schemastore").yaml.schemas() },
    },
  })
  ```

  - Kubernetes schemas are fetched over the network from GitHub when a manifest is opened.
  - `:lua require("schema-companion").select_schema()` picks a schema by hand.
- **helm_ls**:

  ```lua
  sc.setup_client(sc.adapters.helmls.setup({ sources = { sc.sources.matchers.kubernetes.setup({ version = "master" }) } }), {
    settings = { ["helm-ls"] = { yamlls = { enabled = true, path = "yaml-language-server",
      config = { schemas = { kubernetes = "templates/**" }, completion = true, hover = true } } } } })
  ```

  - **Helm and YAML together:** files in a chart's `templates/` get filetype `helm`, so helm-ls handles them.
    helm-ls starts its own yaml-language-server for the YAML parts.
  - `values.yaml` and `Chart.yaml` stay `yaml`, so yamlls handles them with the SchemaStore Chart schema.
  - Filetype detection lives in `options.lua`:

    ```lua
    vim.filetype.add({ pattern = { [".*/templates/.*%.ya?ml"] = function(path)
        return vim.fs.root(path, "Chart.yaml") and "helm" or "yaml" end,
      [".*/templates/.*%.tpl"] = "helm", ["helmfile.*%.ya?ml"] = "helm" } })
    ```

    Check first whether Neovim 0.12's own detection already covers part of this, and keep only what's missing.
- **lua_ls**: `settings = { Lua = { workspace = { checkThirdParty = false }, completion = { callSnippet = "Replace" }, hint = { enable = true, setType = false, arrayIndex = "Disable" }, doc = { privateName = { "^_" } }, format = { enable = false } } }`. StyLua formats.
- **bashls**: `filetypes = { "sh", "bash" }` (zsh files stay unattached, because bashls misparses them). shellcheck runs automatically when it is on `PATH`.
- **docker_language_server**: defaults (Dockerfile, Compose, Bake).
- **ty**: defaults (`ty server`). **ruff**: `init_options = { settings = { logLevel = "error" } }`. Hover is disabled in `on_attach` so ty's hover wins.
- **rust_analyzer**: `settings = { ["rust-analyzer"] = { check = { command = "clippy" }, cargo = { allFeatures = true } } }`.
- **taplo**: defaults (format through LSP). **rumdl**: defaults (`rumdl server`; check that nvim-lspconfig ships `lsp/rumdl.lua`, otherwise write `cmd`, `filetypes` and `root_markers` in `after/lsp/rumdl.lua`).

## 9. Formatting — `format.lua` (conform.nvim)

`event = "BufWritePre"`, `cmd = "ConformInfo"`, `keys = <leader>cf` (n, x: format, with ranges in visual mode).

```lua
opts = {
  default_format_opts = { lsp_format = "fallback", timeout_ms = 1500 },
  format_on_save = function(buf)
    if vim.g.autoformat == false or vim.b[buf].autoformat == false then return end
    return {}
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" }, bash = { "shfmt" },
    yaml = { "yamlfmt" },
    javascript = web, javascriptreact = web, typescript = web, typescriptreact = web,
    json = web, jsonc = web, css = web, graphql = web,
    python = { "ruff_organize_imports", "ruff_format" },
    toml = { "taplo" },
    -- go, rust, markdown, dockerfile: LSP fallback (gopls+gofumpt, rust-analyzer→rustfmt, rumdl)
    -- helm: intentionally not formatted (templates break)
  },
  formatters = {
    prettier = { require_cwd = true },  -- only when a Prettier config exists in the project
    shfmt = { prepend_args = { "-i", "2", "-ci" } },
  },
}
-- local web = { "prettier", "biome-check", stop_after_first = true }
```

- `biome-check` formats, sorts imports and applies safe fixes. Without a `biome.json` it uses Biome's defaults.
- Prettier runs from the project's `node_modules`. It is never installed globally.
- Toggles: `<leader>uf` sets `vim.g.autoformat` (global) and `<leader>uF` sets `vim.b.autoformat` (buffer). Both are `Snacks.toggle` with a statusline indicator.
- `formatexpr` is `v:lua.require'conform'.formatexpr()`, so `gq` uses conform.

## 10. Linting — `lint.lua` (nvim-lint)

`event = { "BufReadPost", "BufWritePost", "InsertLeave" }`.

```lua
linters_by_ft = {
  go = { "golangcilint" },
  dockerfile = { "hadolint" },
  lua = { "selene" },
}
```

- The autocmd is debounced by 100 ms. It runs `require("lint").try_lint(names)` with names filtered by `vim.fn.executable(cmd) == 1`.
  - Example: selene is only on `PATH` inside the dotfiles repo, through root `mise.toml`, so outside it the linter is skipped silently.
  - For lua, it also requires `vim.fs.root(0, "selene.toml")`.
- Everything else is linted by its LSP: TS/JS (vtsls types, eslint, biome), YAML/Helm (yamlls/helm-ls), shell (bashls + shellcheck), Python (ruff), Rust (clippy), TOML (taplo), Markdown (rumdl).

Format and lint matrix:

| Language | LSP                                     | Format                             | Lint                                         |
| -------- | --------------------------------------- | ---------------------------------- | -------------------------------------------- |
| Go       | gopls                                   | gopls (gofumpt) + organize imports | golangci-lint (nvim-lint), gopls staticcheck |
| TS/JS    | vtsls (+eslint / biome per project)     | Prettier if configured, else Biome | eslint / biome LSP                           |
| JSON     | jsonls + SchemaStore                    | Biome / Prettier                   | jsonls schema validation                     |
| YAML     | yamlls + SchemaStore + schema-companion | yamlfmt                            | yamlls validation                            |
| Helm     | helm-ls (+ embedded yamlls)             | —                                  | helm-ls (`helm lint`)                        |
| Lua      | lua_ls + lazydev                        | stylua                             | selene (repo)                                |
| Shell    | bashls                                  | shfmt                              | shellcheck (via bashls)                      |
| Docker   | docker-language-server                  | —                                  | hadolint                                     |
| Python   | ty + ruff                               | ruff                               | ruff                                         |
| Rust     | rust-analyzer                           | rustfmt (LSP)                      | clippy                                       |
| TOML     | taplo                                   | taplo                              | taplo                                        |
| Markdown | rumdl                                   | rumdl (LSP)                        | rumdl                                        |

## 11. Git — `git.lua`

**gitsigns.nvim** (`event = { "BufReadPre", "BufNewFile" }`):

```lua
opts = {
  signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" }, topdelete = { text = "" },
            changedelete = { text = "▎" }, untracked = { text = "▎" } },
  signs_staged = { same set },
  signs_staged_enable = true,
  current_line_blame = false,
  current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
  preview_config = { border = "rounded" },
  on_attach = buffer-local keymaps below,
}
```

Hunk keymaps:

| Key          | Action                                                            |
| ------------ | ----------------------------------------------------------------- |
| `]h` / `[h`  | `nav_hunk("next"/"prev")` (in diff mode, falls back to `]c`/`[c`) |
| `]H` / `[H`  | last / first hunk                                                 |
| `<leader>gs` | stage hunk (n, x for a range)                                     |
| `<leader>gr` | reset hunk (n, x)                                                 |
| `<leader>gS` | stage buffer                                                      |
| `<leader>gR` | reset buffer                                                      |
| `<leader>gu` | undo the last stage                                               |
| `<leader>gp` | preview hunk inline                                               |
| `<leader>gb` | blame line (full popup)                                           |
| `<leader>ub` | toggle inline current-line blame                                  |
| `ih` (o, x)  | select hunk text object                                           |

**snacks.lazygit / gitbrowse** keymaps: see §12.

**diffview.nvim** (`cmd = { "DiffviewOpen", "DiffviewFileHistory" }`):

```lua
opts = { enhanced_diff_hl = true, view = { merge_tool = { layout = "diff3_mixed" } },
         file_panel = { win_config = { position = "left", width = 30 } } }
```

`<leader>gd` runs `DiffviewOpen`, `<leader>gD` runs `DiffviewClose`, and `<leader>gh` runs `DiffviewFileHistory %`. Merge conflicts: open `DiffviewOpen` during a merge to get the three-way view.

## 12. Treesitter — `treesitter.lua`

Why not just the `tree-sitter` CLI plus Neovim's built-in Treesitter:

- Neovim 0.12.6 bundles only `c, lua, markdown, markdown_inline, query, vim, vimdoc`.
- The CLI only compiles parsers. Highlights, injections, folds, indents and textobjects queries come from nvim-treesitter.
- Those queries are pinned to matching parser revisions.
- The `main` branch is just that installer plus the queries. Highlighting is Neovim's own engine.
- **nvim-treesitter** (`branch = "main"`, `lazy = false`, `build = ":TSUpdate"`). The main branch doesn't support lazy-loading.

  ```lua
  config = function()
    require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
    require("nvim-treesitter").install(require("config.parsers")) -- async, no-op when present
    vim.api.nvim_create_autocmd("FileType", { callback = function(ev)
      if not pcall(vim.treesitter.start, ev.buf) then return end
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end })
  end
  ```

  - It needs the `tree-sitter` CLI (from mise) and a C compiler (Xcode CLT on macOS; already in the VM).
- `config/parsers.lua` returns:

  ```text
  bash, c, css, diff, dockerfile, git_config, git_rebase, gitattributes, gitcommit, gitignore,
  go, gomod, gosum, gotmpl, gowork, helm, html, javascript, jsdoc, json, kdl, lua, luadoc,
  luap, make, markdown, markdown_inline, printf, python, query, regex, rust, sql, toml, tsx,
  typescript, vim, vimdoc, xml, yaml
  ```

  `kdl` is for `zellij/config.kdl`.
- **nvim-treesitter-textobjects** (`branch = "main"`, `event = "VeryLazy"`):
  - `setup({ move = { set_jumps = true } })`.
  - `]f`/`[f` go to the next/previous `@function.outer` start and `]F`/`[F` to the end.
  - `]c`/`[c` do the same for `@class.outer`, but only when not in diff mode, where Vim's own `]c` jumps between changes.
  - `]a`/`[a` jump between `@parameter.inner`.
  - mini.ai reads its queries, so textobjects needs no select keymaps of its own.
- **nvim-treesitter-context** (`event = "BufReadPost"`): `opts = { max_lines = 3, multiline_threshold = 1, mode = "cursor" }`. `<leader>ut` toggles it.
- **nvim-ts-autotag** (`event = "BufReadPre"`): `opts = {}` (auto close and rename for HTML/JSX/TSX tags).

## 13. Keymap reference (complete)

Leader is `<Space>`. which-key shows each group.

### Top level

| Key               | Action                                                          |
| ----------------- | --------------------------------------------------------------- |
| `<leader><space>` | buffers picker                                                  |
| `<leader>/`       | grep (same as `<leader>fg`)                                     |
| `<leader>e`       | explorer toggle (`Snacks.explorer()`, follows the current file) |
| `<leader>o`       | aerial toggle (right)                                           |
| `<leader>l`       | Lazy                                                            |
| `<leader>?`       | buffer keymaps (which-key)                                      |

### `<leader>f` — find (snacks.picker)

| Key  | Picker                                           |
| ---- | ------------------------------------------------ |
| `ff` | files (root = cwd)                               |
| `fg` | grep                                             |
| `fG` | git status (changed files)                       |
| `fs` | LSP workspace symbols (root)                     |
| `fS` | LSP document symbols                             |
| `fw` | grep word under cursor / visual selection (n, x) |
| `fb` | buffers                                          |
| `fr` | recent files (cwd)                               |
| `fh` | help                                             |
| `fk` | keymaps                                          |
| `fd` | diagnostics (workspace); `fD` buffer diagnostics |
| `fc` | nvim config files                                |
| `ft` | todo comments                                    |
| `fR` | resume last picker                               |
| `f/` | lines in buffer                                  |
| `fN` | notification history                             |
| `fn` | new file (non-picker)                            |

### `<leader>g` — git

| Key                                     | Action                                                                  |
| --------------------------------------- | ----------------------------------------------------------------------- |
| `gg`                                    | lazygit (cwd root)                                                      |
| `gl`                                    | lazygit log                                                             |
| `gf`                                    | lazygit current file history                                            |
| `gs` / `gr` / `gS` / `gR` / `gu` / `gp` | hunk stage / reset / stage buffer / reset buffer / undo stage / preview |
| `gb`                                    | blame line                                                              |
| `gB`                                    | browse on remote (`Snacks.gitbrowse()`, n, x)                           |
| `gd` / `gD`                             | diffview open / close                                                   |
| `gh`                                    | diffview file history (current file)                                    |
| `]h` `[h` `]H` `[H`                     | hunk navigation                                                         |

### `<leader>c` — code

`ca` action · `cr` rename symbol · `cR` rename file · `cf` format · `cd` line diagnostics · `co` organize imports · `cl` LSP health

### `<leader>x` — diagnostics/quickfix (trouble)

`xx` workspace diagnostics · `xX` buffer diagnostics · `xq` quickfix · `xl` location list · `xt` todos

### `<leader>b` — buffers

`bd` delete (`Snacks.bufdelete()`) · `bo` delete others (`Snacks.bufdelete.other()`) · `bp` pin · `bP` close unpinned

### `<leader>u` — toggles (Snacks.toggle, shown with state in which-key)

`uf` format-on-save (global) · `uF` (buffer) · `uh` inlay hints · `uw` wrap · `us` spell · `ul` relative numbers · `ud` diagnostics · `uv` virtual lines · `ub` inline blame · `ut` treesitter context · `up` autopairs · `uz` zen · `un` dismiss notifications · `uc` conceal

### `<leader>S` — session

`Ss` restore cwd session · `Sl` restore last · `SS` select session · `Sd` stop saving this session

### `<leader>r` — replace

`rr` grug-far (n, x) · `rw` grug-far with word under cursor

### Motions and goto

| Key                                                                | Action                                             |
| ------------------------------------------------------------------ | -------------------------------------------------- |
| `gd` / `gD` / `gr` / `gI` / `gy` / `K`                             | LSP (see §8.6)                                     |
| `[f` `]f` / `[F` `]F`                                              | function start / end                               |
| `[c` `]c`                                                          | class (outside diff mode)                          |
| `[a` `]a`                                                          | parameter                                          |
| `[d` `]d`                                                          | diagnostic (native)                                |
| `[h` `]h`                                                          | git hunk                                           |
| `[t` `]t`                                                          | todo comment                                       |
| `[[` `]]`                                                          | LSP reference (snacks.words)                       |
| `[i` `]i`                                                          | scope edge (snacks.scope)                          |
| `[q` `]q`, `[l` `]l`, `[x` `]x`, `[j` `]j`, `[y` `]y`, `[u` `]u` … | mini.bracketed                                     |
| `[b` `]b`, `<S-h>` `<S-l>`                                         | buffer prev / next                                 |
| `s` / `S`                                                          | flash jump / flash treesitter                      |
| `gsa` `gsd` `gsr` `gsf` `gsh`                                      | surround add / delete / replace / find / highlight |
| `gS`                                                               | split/join                                         |
| `gc` / `gcc`                                                       | comment (native)                                   |
| `<S-Tab>` / `<Tab>`                                                | jumplist back / forward                            |
| `<C-Arrows>`                                                       | move between nvim splits and Zellij panes          |
| `<A-Arrows>`                                                       | resize nvim split                                  |

### Text objects (mini.ai + snacks.scope + gitsigns)

`af/if` function · `ac/ic` class · `aa/ia` argument · `ao/io` block/loop/conditional · `aq/iq` quote · `ab/ib` bracket · `at/it` tag · `ad/id` digits · `ae/ie` word part · `ag/ig` whole buffer · `au/iu` call · `ai/ii` scope · `ih` hunk

### Explorer (snacks defaults, listed for reference)

`<CR>`/`l` open · `h` close dir · `a` add · `d` delete · `r` rename · `c` copy · `m` move · `y` yank path · `H` hidden · `I` ignored · `<BS>` up · `.` cd here · `u` update · `]g`/`[g` next git change · `]d`/`[d` diagnostic · `q` close

## 14. Implementation order

Each step ends with one focused real check (see the lean-verification memory). No test harness.

1. **Wiring**:
   - Add the root `[dotfiles]` and `[bootstrap.repos]` entries, stylua and selene, and the hk steps.
   - Add the global tools and run `mise lock --global`.
   - Check: `mise run bootstrap:dry-run`, `mise install --locked`, `hk check`.
2. **Skeleton**:
   - Write `init.lua`, `config/*` and the colorscheme, then generate `lazy-lock.json`.
   - Check: `nvim --headless "+checkhealth lazy" +qa`, and that opening a file shows Mocha.
3. **Snacks + UI**:
   - Add snacks, lualine, bufferline, which-key and mini.icons.
   - Check: the dashboard appears, `<leader>e` opens the explorer, and the bufferline offset lines up with the explorer.
4. **Editor**:
   - Add the mini modules, flash, persistence and grug-far.
   - Check that `s` (flash) and `gsa` (surround) don't clash.
5. **Treesitter**:
   - Install parsers in the VM.
   - Check: `:checkhealth nvim-treesitter`, and that `vaf` selects a Go function.
6. **LSP + completion**:
   - Add lspconfig, blink, lazydev and the `after/lsp/*` overrides.
   - Check: in a Go file, `gd`, completion and a snippet expansion all work.
   - Check: in a k8s Deployment, a schema is detected (`schema-companion` statusline or the `select_schema` picker).
   - Check: in a Helm chart, `templates/*.yaml` gets helm-ls and `values.yaml` gets yamlls.
7. **Format + lint**:
   - Add conform and nvim-lint.
   - Check: `:ConformInfo` in Go, TS (with and without a Prettier config), YAML and Lua.
8. **Git**:
   - Add gitsigns and diffview, and the lazygit `editPreset`.
   - Check: stage a hunk, open lazygit, open a file from lazygit.
9. **Aerial**:
   - Check: `<leader>o` docks on the right, and bufferline offsets on both sides.
10. **Zellij**:
    - Add the navigator plugin.
    - Check in the VM: `Ctrl+arrows` move between two nvim splits and then cross into a neighbouring Zellij pane and back.
      `Ctrl+Right` at the right edge goes to the next tab.
11. **Clipboard**:
    - In the VM: `yy` lands in the macOS clipboard.
    - Test the OSC52 read (§6.3) and keep the result.
12. **Setup tasks**:
    - Add the nvim step to `global:setup` / `global:update` on both platforms.
    - Check: a fresh `mise run global:setup` gives a working nvim on the first start.
13. Run stylua, selene and `hk check`. Update the README line. Delete this plan.

## 15. Revisit later

- **tsgo**: Microsoft's native TypeScript LSP (`@typescript/native-preview`, `tsgo --lsp --stdio`). It was still in preview in 2026.
  When it reaches feature parity, switch `vtsls` → `tsgo` in `vim.lsp.enable`, since nvim-lspconfig already ships `lsp/tsgo.lua`.
- **backend-zellij-rs**: switch from the Lua backend once upstream marks it stable.
- **diffview**: if the original breaks on Neovim 0.12+, move to `dlyongemallo/diffview-plus.nvim`.
- **Debugger** (nvim-dap + nvim-dap-view + delve via mise): out of scope for now.
- **Task runner** (overseer): add only if Zed-style tasks are missed.
