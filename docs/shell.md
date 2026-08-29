# Shell (`shell/.zshrc`)

`shell/.zshrc` maps to **`~/.zshrc`** — a flat file directly in `$HOME`,
*not* an XDG path. zsh only looks elsewhere (e.g. under
`$XDG_CONFIG_HOME/zsh/`) if `$ZDOTDIR` is set before zsh starts, normally
from `/etc/zshenv` or `~/.zshenv` — neither exists in this repo, so the
real, current target is `~/.zshrc`. Same shape of exception as
[tmux](./core_tools.md#tmux)/[starship](./util_tools.md#starship).

This is the file that activates most of the "deferred: shell integration"
notes written across [util_tools.md](./util_tools.md) and
[core_tools.md](./core_tools.md) while those tools were set up one at a
time. Cross-checked every one of those notes against this file specifically
(see below).

## What's configured

- `path+=(...)` for `~/.local/bin`, `~/bin`, `~/go/bin` (only if the
  directory exists), deduped via `typeset -U path PATH`.
- `TERM` fallback to `xterm-256color` if the current `$TERM` has no
  terminfo entry available (e.g. SSH'ing somewhere that doesn't know
  `tmux-256color`/`xterm-ghostty`) — same class of concern already noted in
  [tmux.conf's own comment](./core_tools.md#tmux) about not hardcoding a
  terminal-specific `TERM`.
- `mise activate zsh`, then oh-my-zsh (`$ZSH_THEME` empty — starship owns
  the prompt instead, avoiding a double-prompt conflict), then starship,
  atuin, zoxide, eza aliases, fzf, a `tc()` tmux session helper, and
  finally `.zshrc.local` for machine-local overrides — all individually
  guarded by `command -v`/`[[ -r ... ]]` checks, so this degrades cleanly
  on a machine missing some of these tools.
- `zsh-syntax-highlighting` is sourced last, after `.zshrc.local` — correct
  per its own upstream requirement to load after every other widget/hook is
  registered.

## Found and fixed while setting this up

**`XDG_CONFIG_HOME` was never exported.** Added
`export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"` near the top.
This isn't cosmetic — three separate things depended on it:

- [fzf](./util_tools.md#fzf) and [ripgrep](./util_tools.md#ripgrep) only
  auto-discover their config files via `$XDG_CONFIG_HOME`-based env vars;
  without it, those references would have resolved to `/fzf/config` and
  `/ripgrep/config` (leading slash, no `$HOME`) — broken paths.
- Resolves the exceptions documented for [k9s](./core_tools.md#k9s) and
  [Go's own env file](./langs.md#go): both default to
  `~/Library/Application Support/...` on macOS specifically *because*
  `$XDG_CONFIG_HOME` isn't set by default. Now it is.

**`fzf/config` and `ripgrep/config` were vendored but never actually wired
up.** The original file hardcoded its own `FZF_DEFAULT_OPTS` inline —
using this repo's blue accent, not the official catppuccin/fzf palette
`fzf/config` was vendored with — and never referenced
`RIPGREP_CONFIG_PATH` at all. Since the inline colors were already the
better match for this repo's convention (and already proven working),
**`fzf/config`'s content was updated to match them exactly** (pure
de-duplication — verified byte-identical rendering before and after), and
both:

```sh
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
```

are now wired in. **One real robustness bug found doing this:** fzf
*hard-fails* (exit `2`, not a graceful fallback) if `FZF_DEFAULT_OPTS_FILE`
points to a file that doesn't exist — verified directly. Since this repo
isn't symlinked into place yet (and the file could go missing for other
reasons later), the export is guarded:
`[[ -r "$XDG_CONFIG_HOME/fzf/config" ]] && export ...`. ripgrep, by
contrast, degrades gracefully on a missing `RIPGREP_CONFIG_PATH` (just a
stderr warning, still exits `0`) — verified directly, no guard needed
there.

**`LS_COLORS` was live and actively conflicting with the eza theme.**
[util_tools.md#eza](./util_tools.md#eza) had flagged this as a
"watch for it" caveat; testing this exact shell environment showed it was
not hypothetical — `LS_COLORS` was genuinely set (inherited from elsewhere
in the environment) and was overriding eza's directory/executable colors
with plain ANSI codes instead of the Catppuccin theme. Added `unset
LS_COLORS` right in the eza block. Verified color output before/after: only
the theme's true-color codes appear now.

**Ctrl-R/Ctrl-F was investigated as a suspected conflict — turned out to be
correct.** atuin binds Ctrl-R first; fzf's own init (`source <(fzf --zsh)`)
runs after and would normally also claim Ctrl-R for its history widget,
which looked like it would silently override atuin's binding. Verified
directly with `bindkey`: it doesn't. `FZF_CTRL_R_COMMAND=''` — set to an
*empty string*, not left unset — is fzf's own documented mechanism (traced
through `fzf --zsh`'s generated script) for opting its `Ctrl-R` binding out
entirely, leaving Ctrl-R on `atuin-search` and the separately-bound Ctrl-F
on `fzf-history-widget`, exactly as intended. (Also exported the variable,
since `shellcheck` correctly flags a plain, non-exported assignment as
"appears unused" — it's genuinely read by the dynamically-sourced fzf
script, not by this file.)

## Validation

No zsh dialect exists in `shellcheck` (only sh/bash/dash/ksh), and it
hard-errors (`SC2148`) on a shebang-less file with no dialect specified —
but `--shell=bash` was verified empirically to produce **zero** false
positives against this file's zsh-specific syntax (`path+=`, `typeset -U`,
etc.), while still catching one real issue (the `FZF_CTRL_R_COMMAND` case
above, since fixed). `SC1090`/`SC1091` ("can't follow this source") are
excluded in `zshrc-check` — unavoidable noise for an rc file that
legitimately sources dynamic/generated content (oh-my-zsh, `.zshrc.local`,
fzf's own init). Verified the check has teeth: fails on injected broken
syntax, passes on the real file.

`shellcheck` is a repo-local tool (`mise.toml`, not the global config) —
it's for linting this repo's own shell script, not something the user runs
directly day to day.
