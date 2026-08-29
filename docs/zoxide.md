# zoxide

No config file exists here (or anywhere) for
[zoxide](https://github.com/ajeetdsouza/zoxide) — checked its `--help`
output directly: it's driven entirely by environment variables and a shell
hook (`eval "$(zoxide init <shell>)"`), with no `~/.config/zoxide/*` file it
reads.

## Environment variables (not yet set anywhere)

zoxide reads these if present; none are set by this repo yet:

- `_ZO_DATA_DIR` — where the ranked-directory database lives
- `_ZO_ECHO` — print the matched directory before jumping
- `_ZO_EXCLUDE_DIRS` — globs to exclude from ranking
- `_ZO_FZF_OPTS` — flags passed to `fzf` for interactive selection
- `_ZO_MAXAGE` — prune entries once total "age" exceeds this
- `_ZO_RESOLVE_SYMLINKS` — resolve symlinks before storing a path

## Deferred: shell integration

The `eval "$(zoxide init zsh)"` line has to live in a shell startup file
(`.zshrc` or similar), which doesn't exist in this repo yet. Nothing to
configure here until that lands — tracked as a gap, not forgotten.

The `zoxide` binary itself is provided by the **global mise config** — see
[mise.md](./mise.md).
