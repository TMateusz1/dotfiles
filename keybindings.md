# Keybindings

Quick reference for Neovim (`<leader>` and `<localleader>` are both `Space`) and Zellij (locked by default; `Ctrl+g` unlocks).

## Neovim

### General & Windows

| Key                         | Mode    | Action                                                                  |
| --------------------------- | ------- | ----------------------------------------------------------------------- |
| `Esc`                       | n       | Close LSP floats and clear search highlight                             |
| `Ctrl+s`                    | n, i, x | Save file                                                               |
| `Ctrl+w`                    | n       | Delete buffer (`Snacks.bufdelete`)                                      |
| `Ctrl+Arrows`               | n, i, t | Move focus across splits and Zellij panes (`smart-splits`)              |
| `Alt+Arrows`                | n, i, t | Resize split / Zellij pane                                              |
| `<leader>Ctrl+Arrows`       | n       | Swap buffer with neighbor split                                         |
| `<leader>wv` / `<leader>wx` | n       | Vertical / horizontal split                                             |
| `<leader>wd` / `<leader>wo` | n       | Close window / close other windows                                      |
| `<leader>w=`                | n       | Equalize window sizes                                                   |
| `<leader>fn`                | n       | New empty buffer                                                        |
| `<leader>l`                 | n       | Open Lazy plugin manager                                                |
| `<leader>?`                 | n       | Show buffer-local keymaps (`which-key`)                                 |
| `q`                         | n       | Close utility windows (`help`, `qf`, `grug-far`, `nvim-undotree`, etc.) |

### Files, Explorer, Buffers & Tags

| Key                         | Mode | Action                                                                           |
| --------------------------- | ---- | -------------------------------------------------------------------------------- |
| `<leader>e`                 | n    | Toggle Neo-tree filesystem explorer                                              |
| `<leader>E`                 | n    | Open Oil (edit directory as a buffer; `Ctrl+s`/`:w` applies changes, `q` closes) |
| `<leader>be`                | n    | Toggle Neo-tree buffer explorer                                                  |
| `<leader><space>`           | n    | Pick buffer by letter (`BufferLinePick`)                                         |
| `Shift+h` / `Shift+l`       | n    | Previous / next buffer (`[b` / `]b` also work)                                   |
| `<leader>bd` / `<leader>bo` | n    | Delete buffer / delete other buffers                                             |
| `<leader>bc`                | n    | Pick buffer to close                                                             |
| `<leader>bh` / `<leader>bl` | n    | Close buffers to the left / right                                                |
| `<leader>bp` / `<leader>bP` | n    | Pin buffer / close unpinned buffers                                              |
| `<leader>m`                 | n    | Toggle Grapple tag on current file (branch-scoped)                               |
| `<leader>M`                 | n    | Open Grapple tags menu                                                           |
| `<leader>1` .. `<leader>5`  | n    | Jump to Grapple tag 1..5                                                         |

### Picker (`Snacks.picker`)

Inside pickers: `Ctrl+x` opens horizontal split, `Ctrl+v` opens vertical split.

| Key                         | Mode | Action                                     |
| --------------------------- | ---- | ------------------------------------------ |
| `<leader>/` or `<leader>fg` | n    | Live grep                                  |
| `<leader>ff`                | n    | Find files (includes hidden)               |
| `<leader>fw`                | n, x | Grep word under cursor or visual selection |
| `<leader>fb`                | n    | Buffers                                    |
| `<leader>fr`                | n    | Recent files (cwd)                         |
| `<leader>fG`                | n    | Git status                                 |
| `<leader>fs` / `<leader>fS` | n    | Workspace / document LSP symbols           |
| `<leader>fd` / `<leader>fD` | n    | Workspace / buffer diagnostics             |
| `<leader>ft`                | n    | TODO comments                              |
| `<leader>f/`                | n    | Lines in current buffer                    |
| `<leader>fh` / `<leader>fk` | n    | Help tags / keymaps                        |
| `<leader>fc`                | n    | Neovim config files                        |
| `<leader>fR`                | n    | Resume last picker                         |
| `<leader>fN`                | n    | Notification history                       |

### LSP, Code & Diagnostics

| Key                         | Mode | Action                                        |
| --------------------------- | ---- | --------------------------------------------- |
| `K`                         | n    | LSP hover                                     |
| `gK`                        | n    | Signature help                                |
| `gd` / `gD`                 | n    | Definition (picker) / definition in vsplit    |
| `gr`                        | n    | References (picker)                           |
| `gI` / `gy`                 | n    | Implementations / type definitions            |
| `<leader>ca`                | n, x | Code action                                   |
| `<leader>cr` / `<leader>cR` | n    | Rename symbol / rename file (updates imports) |
| `<leader>cf`                | n, x | Format (`conform.nvim`)                       |
| `<leader>co`                | n    | Organize imports                              |
| `<leader>cc`                | n    | Run codelens                                  |
| `<leader>cd`                | n    | Line diagnostics float                        |
| `<leader>cs`                | n    | Select YAML/Helm schema (`schema-companion`)  |
| `<leader>cl`                | n    | LSP health (`:checkhealth vim.lsp`)           |
| `<leader>o`                 | n    | Toggle Aerial symbol outline                  |
| `<leader>xx` / `<leader>xX` | n    | Trouble workspace / buffer diagnostics        |
| `<leader>xq` / `<leader>xl` | n    | Trouble quickfix / location list              |
| `<leader>xt`                | n    | Trouble TODOs                                 |
| `[d` / `]d`                 | n    | Previous / next diagnostic (native)           |

### Editing, Motion & Search/Replace

| Key                         | Mode            | Action                                                 |
| --------------------------- | --------------- | ------------------------------------------------------ |
| `s` / `S`                   | n, x, o         | Flash jump / Flash Treesitter select                   |
| `r` / `R`                   | o / o, x        | Remote Flash / Treesitter search                       |
| `gsa` / `gsd` / `gsr`       | n, x / n / n    | Add / delete / replace surrounding (`mini.surround`)   |
| `gsf` / `gsF` / `gsh`       | n               | Find right / find left / highlight surrounding         |
| `gS`                        | n               | Split / join arguments or blocks (`mini.splitjoin`)    |
| `]f` / `[f` (`]F` / `[F`)   | n, x, o         | Next / prev function start (end)                       |
| `]c` / `[c` (`]C` / `[C`)   | n, x, o         | Next / prev class start (end)                          |
| `]a` / `[a`                 | n, x, o         | Next / prev parameter                                  |
| `]t` / `[t`                 | n               | Next / prev TODO comment                               |
| `]i` / `[i`                 | n               | Next / prev scope (`snacks.scope`)                     |
| `<leader>rr`                | n, x            | Search and replace (`grug-far`, filtered by extension) |
| `<leader>rw`                | n               | Search and replace word under cursor (`grug-far`)      |
| `Space+r` / `Space+c` / ... | n (in grug-far) | Localleader actions inside `grug-far`                  |

### Completion (`blink.cmp`)

| Key                                        | Mode | Action                                       |
| ------------------------------------------ | ---- | -------------------------------------------- |
| `Ctrl+Space`                               | i    | Show completion / toggle docs                |
| `Enter`                                    | i, c | Accept selected item                         |
| `Ctrl+e`                                   | i, c | Hide menu                                    |
| `Ctrl+n` / `Ctrl+p` or `Ctrl+j` / `Ctrl+k` | i, c | Next / previous item (`Up`/`Down` also work) |
| `Tab` / `Shift+Tab`                        | i, c | Snippet forward/back or next/prev item       |
| `Ctrl+u` / `Ctrl+d`                        | i    | Scroll documentation up / down               |

### Git

| Key                         | Mode | Action                                                 |
| --------------------------- | ---- | ------------------------------------------------------ |
| `<leader>gg`                | n    | Lazygit                                                |
| `<leader>gl` / `<leader>gf` | n    | Lazygit log / current file history                     |
| `<leader>gd` / `<leader>gD` | n    | Diffview open / close                                  |
| `<leader>gh`                | n    | Diffview file history                                  |
| `<leader>gm` / `<leader>gM` | n    | Diffview review against `origin/main` (diff / commits) |
| `<leader>gB`                | n, x | Open file/selection on remote (`Snacks.gitbrowse`)     |
| `]h` / `[h` (`]H` / `[H`)   | n    | Next / prev (last / first) git hunk                    |
| `<leader>gs` / `<leader>gr` | n, x | Stage / reset hunk                                     |
| `<leader>gS` / `<leader>gR` | n    | Stage / reset buffer                                   |
| `<leader>gu`                | n    | Undo stage hunk                                        |
| `<leader>gp` / `<leader>gb` | n    | Preview hunk inline / full blame line                  |
| `ih`                        | o, x | Select git hunk textobject                             |

### Tests (`neotest`) & Sessions (`persistence`)

| Key                         | Mode | Action                                       |
| --------------------------- | ---- | -------------------------------------------- |
| `<leader>tt` / `<leader>tT` | n    | Run nearest test / run current file          |
| `<leader>ta` / `<leader>tl` | n    | Run all tests / re-run last test             |
| `<leader>tS`                | n    | Stop running test                            |
| `<leader>ts`                | n    | Toggle test summary                          |
| `<leader>to` / `<leader>tO` | n    | Open test output / toggle output panel       |
| `[T` / `]T`                 | n    | Prev / next failed test                      |
| `<leader>Ss` / `<leader>Sl` | n    | Restore session (cwd) / restore last session |
| `<leader>SS` / `<leader>Sd` | n    | Select session / stop saving session         |

### UI & Toggles (`<leader>u`)

| Key                         | Action                                 |
| --------------------------- | -------------------------------------- |
| `<leader>uf` / `<leader>uF` | Format on save (global / buffer)       |
| `<leader>ud` / `<leader>uv` | Diagnostics / diagnostic virtual lines |
| `<leader>uh`                | Inlay hints                            |
| `<leader>ub`                | Inline git blame                       |
| `<leader>ut`                | Treesitter context                     |
| `<leader>um`                | Render markdown                        |
| `<leader>uw` / `<leader>us` | Wrap / spell                           |
| `<leader>ul` / `<leader>uc` | Relative line numbers / conceal        |
| `<leader>up`                | Autopairs                              |
| `<leader>uz`                | Zen mode                               |
| `<leader>uu`                | Undotree (built-in)                    |
| `<leader>un`                | Dismiss notifications                  |

---

## Zellij

Zellij starts in **locked** mode so `Ctrl+<letter>` reaches Neovim and Zsh directly. Left `Option` sends `Alt` in Kitty.

### Always-On Shortcuts (Work in Locked Mode)

| Key                                    | Action                                                  |
| -------------------------------------- | ------------------------------------------------------- |
| `Ctrl+g`                               | Unlock into normal mode (or return to locked mode)      |
| `Ctrl+Arrows`                          | Move focus across Neovim splits and Zellij panes/tabs   |
| `Alt+h` / `Alt+j` / `Alt+k` / `Alt+l`  | Move focus across Zellij panes (and tabs on left/right) |
| `Ctrl+Shift+Left` / `Ctrl+Shift+Right` | Previous / next tab (`Ctrl+Shift+[` / `]` also work)    |
| `Alt+1` .. `Alt+9`                     | Go to tab 1..9                                          |
| `Alt+i` / `Alt+o`                      | Move current tab left / right                           |
| `Alt+m` / `Alt+n`                      | New tab / new pane                                      |
| `Alt+f`                                | Toggle floating panes                                   |
| `Alt+g`                                | Open floating Lazygit                                   |
| `Alt+[` / `Alt+]`                      | Previous / next swap layout                             |
| `Alt++` (`Alt+=`) / `Alt+-`            | Increase / decrease pane size                           |
| `Alt+p` / `Alt+Shift+p`                | Toggle pane in group / toggle group marking             |

### Modal Modes (Press `Ctrl+g` First)

Press `Enter`, `Esc`, or `Ctrl+g` to return to locked mode. `Ctrl+q` quits Zellij while unlocked.

| Mode Trigger       | Key                               | Action                                                 |
| ------------------ | --------------------------------- | ------------------------------------------------------ |
| `Ctrl+p` (Pane)    | `n` / `d` / `r` / `s`             | New pane (auto / down / right / stacked)               |
| `Ctrl+p` (Pane)    | `x` / `f` / `Shift+f`             | Close pane / fullscreen / no-UI fullscreen             |
| `Ctrl+p` (Pane)    | `w` / `e` / `i` / `z`             | Toggle floating / embed / pin / frames                 |
| `Ctrl+p` (Pane)    | `c` / `;` / `p`                   | Rename pane / last pane / switch focus                 |
| `Ctrl+t` (Tab)     | `n` / `x` / `r` / `s`             | New tab / close tab / rename tab / sync panes          |
| `Ctrl+t` (Tab)     | `b` / `[` / `]` / `Tab`           | Break pane to new / left / right tab / toggle last tab |
| `Ctrl+n` (Resize)  | `h`/`j`/`k`/`l` (`H`/`J`/`K`/`L`) | Increase (decrease) pane size in direction             |
| `Ctrl+h` (Move)    | `h`/`j`/`k`/`l` / `n` / `p`       | Move pane in direction / forward / backward            |
| `Ctrl+s` (Scroll)  | `j`/`k`/`u`/`d`/`[`/`]`           | Scroll lines / half-page / prev-next prompt            |
| `Ctrl+s` (Scroll)  | `s` / `e` / `c`                   | Search scrollback / edit in Neovim / copy last output  |
| `Ctrl+o` (Session) | `d` / `D` / `w`                   | Detach / force-delete session / session manager        |
| `Ctrl+o` (Session) | `l` / `c` / `p`                   | Layout manager / configuration / plugin manager        |
