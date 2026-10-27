# Zellij key reference

This reference follows [the checked-in config](../zellij/config.kdl) for
Zellij 0.45.1. The bottom status bar only shows a subset of these bindings.
For installation and theme notes, see [core tools](./core_tools.md#zellij).

`Ctrl+p → r` means press Ctrl+p, release it, then press r. Keys in the
tables below are pressed after entering the named mode. Lowercase and
uppercase letters are different bindings.

Navigation stays in its mode so keys can be repeated. Enter or Esc returns
to Normal. Actions such as opening/closing panes or tabs, fullscreen,
floating, pinning, frames, and synchronization return to Normal themselves.
Renaming uses Enter to accept, Esc to undo and return to Pane/Tab mode,
or Ctrl+c to leave renaming. Ctrl+g toggles Locked mode, where other Zellij
bindings pass through to the application.

## Unstacking panes

Focus a pane in the stack, press **Ctrl+n**, then **-** one or more times,
then **Enter**. With the default stacked-resize behavior, decreasing size
splits panes out of the stack as space permits. Increasing with `+` can
merge neighboring panes into stacks. If you enlarged the same pane without
changing focus or adding panes, decreasing can undo its previous sizes.
See the [official stacked-resize tutorial](https://zellij.dev/tutorials/stacked-resize/).

To extract a particular pane instead, `Ctrl+p → e` makes it floating;
repeat that sequence to embed it again. `Ctrl+t → b` moves it into a new
tab. These keep its process running. `Ctrl+p → s` creates another stacked
pane; it is not an unstack toggle.

## Pane mode: Ctrl+p

| Key                  | Action                                                                             |
| -------------------- | ---------------------------------------------------------------------------------- |
| `←` / `h`            | Focus the pane to the left                                                         |
| `↓` / `j`            | Focus the pane below; navigate down a stack                                        |
| `↑` / `k`            | Focus the pane above; navigate up a stack                                          |
| `→` / `l`            | Focus the pane to the right                                                        |
| `p`                  | Cycle focus to the next pane                                                       |
| `;`                  | Focus the previously active pane                                                   |
| `n`                  | Open a pane with automatic placement; can join an existing stack or floating layer |
| `r`                  | Open a pane to the right                                                           |
| `d`                  | Open a pane below                                                                  |
| `s`                  | Open a new pane stacked with the focused pane                                      |
| `c`                  | Rename the focused pane; type its name and press Enter                             |
| `f`                  | Toggle focused-pane fullscreen, keeping Zellij's UI                                |
| `Shift+f` (`F`)      | Toggle fullscreen including hiding Zellij's UI                                     |
| `e`                  | Toggle the focused pane between tiled and floating                                 |
| `w`                  | Toggle the floating layer; creates a floating pane if none exists                  |
| `i`                  | Toggle pinning a floating pane so it stays visible over the tiled layer            |
| `z`                  | Toggle pane frames                                                                 |
| `x`                  | Close the focused pane and its running program                                     |
| `Ctrl+p`, Enter, Esc | Return to Normal                                                                   |

## Tab mode: Ctrl+t

| Key                   | Action                                                            |
| --------------------- | ----------------------------------------------------------------- |
| `←` / `↑` / `h` / `k` | Go to the previous tab                                            |
| `→` / `↓` / `l` / `j` | Go to the next tab                                                |
| `1`–`9`               | Go to that tab number and return to Normal                        |
| Tab                   | Toggle between the current and previously active tab              |
| `n`                   | Open a new tab                                                    |
| `r`                   | Rename the current tab; type its name and press Enter             |
| `b`                   | Move the focused pane into a new tab                              |
| `[`                   | Move the focused pane into a new tab to the left                  |
| `]`                   | Move the focused pane into a new tab to the right                 |
| `s`                   | Toggle synchronized input: keyboard input goes to the tab's panes |
| `x`                   | Close the current tab and its panes/programs                      |
| `Ctrl+t`, Enter, Esc  | Return to Normal                                                  |

## Resize mode: Ctrl+n

| Key                         | Action                                        |
| --------------------------- | --------------------------------------------- |
| `+` / `=`                   | Increase size automatically; can form stacks  |
| `-`                         | Decrease size automatically; can split stacks |
| `←` / `h`                   | Increase to the left                          |
| `↓` / `j`                   | Increase downward                             |
| `↑` / `k`                   | Increase upward                               |
| `→` / `l`                   | Increase to the right                         |
| `Shift+h/j/k/l` (`H/J/K/L`) | Decrease in the corresponding direction       |
| `Ctrl+n`, Enter, Esc        | Return to Normal                              |

## Move mode: Ctrl+h

These keys move pane positions, rather than merely moving focus.

| Key                  | Action                        |
| -------------------- | ----------------------------- |
| `←` / `h`            | Move the focused pane left    |
| `↓` / `j`            | Move it down                  |
| `↑` / `k`            | Move it up                    |
| `→` / `l`            | Move it right                 |
| `n` / Tab            | Swap forward in layout order  |
| `p`                  | Swap backward in layout order |
| `Ctrl+h`, Enter, Esc | Return to Normal              |

## Shared shortcuts

These are also available while in Pane and Tab mode. They are disabled
in Locked mode. Switching modes takes effect immediately.

| Shortcut          | Action                                           |
| ----------------- | ------------------------------------------------ |
| `Ctrl+p`          | Enter Pane mode, or leave it when already there  |
| `Ctrl+t`          | Enter Tab mode, or leave it when already there   |
| `Ctrl+n`          | Enter Resize mode                                |
| `Ctrl+h`          | Enter Move mode                                  |
| `Ctrl+s`          | Enter Scroll mode                                |
| `Ctrl+o`          | Enter Session mode                               |
| `Ctrl+b`          | Enter tmux compatibility mode                    |
| `Ctrl+g`          | Enter Locked mode; press it again to unlock      |
| `Ctrl+l`          | Open the configured lazygit popup                |
| `Ctrl+q`          | Quit the session and stop its programs           |
| `Alt+←` / `Alt+h` | Focus left, or switch tab at the left edge       |
| `Alt+→` / `Alt+l` | Focus right, or switch tab at the right edge     |
| `Alt+↓` / `Alt+j` | Focus downward                                   |
| `Alt+↑` / `Alt+k` | Focus upward                                     |
| `Alt+n`           | Open a pane with automatic placement             |
| `Alt+f`           | Toggle the floating layer                        |
| `Alt++` / `Alt+=` | Increase size automatically                      |
| `Alt+-`           | Decrease size automatically                      |
| `Alt+[` / `Alt+]` | Select previous/next predefined swap layout      |
| `Alt+i` / `Alt+o` | Move the current tab left/right in the tab bar   |
| `Alt+p`           | Toggle focused-pane membership in the pane group |
| `Alt+Shift+p`     | Toggle group marking while navigating            |

Kitty uses `macos_option_as_alt left`: on macOS, use left Option for these
Alt shortcuts. Right Option retains native character input. After changing
this setting, fully quit and reopen Kitty; a config reload does not apply it.

## Validation

The tables were compared against every binding in the Pane, Tab, Resize,
and Move blocks and the shared blocks in the checked-in config. Stack
resizing and pane extraction were checked against upstream documentation;
this documentation change does not alter any keybindings.
