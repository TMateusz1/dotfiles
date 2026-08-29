# fzf

`fzf/config` is a flat options file (one flag per line, same format as
[bat](./bat.md)'s), vendored verbatim from the official
[catppuccin/fzf](https://github.com/catppuccin/fzf) Mocha theme (the `.rc`
variant — a plain options file, as opposed to the `.sh` variant which wraps
the same content in a shell `export`).

Unlike the other tools' Catppuccin themes in this repo, catppuccin/fzf ships
one fixed Mocha palette rather than per-accent variants, so this doesn't use
the blue accent used elsewhere (delta, atuin, tmux, lazygit, eza) — using
the official theme as-is took priority over hand-editing it for
consistency.

## Deferred: activating it

[fzf](https://github.com/junegunn/fzf) has no auto-discovered config path.
Loading this file requires `export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"`
(or the resolved absolute path) in a shell startup file, which doesn't
exist in this repo yet — same gap as [zoxide](./zoxide.md)'s shell hook.

## Validation

No linter exists for fzf's options-file format. `fzf-check` in `hk.pkl`
loads this file via `FZF_DEFAULT_OPTS_FILE` and runs a throwaway filter;
fzf exits `2` specifically on a bad flag (vs. `0`/`1` for a normal
found/not-found result), so the check distinguishes a real config error
from an expected non-match. Verified both directions: passes against this
file, fails against a deliberately broken one.

The `fzf` binary itself is provided by the **global mise config** — see
[mise.md](./mise.md).
