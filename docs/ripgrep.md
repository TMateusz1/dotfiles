# ripgrep

`ripgrep/config` is a flat options file (one flag per line — verified in
[ripgrep](https://github.com/BurntSushi/ripgrep)'s man page). No official
Catppuccin theme exists for ripgrep (its theming surface is narrow — just a
handful of `--colors type:attr:value` settings, not a full palette), so
this is hand-authored rather than vendored, using this repo's established
blue accent (`#89b4fa`, RGB `137,180,250`) for matches and paths, and a
muted subtext tone (`#a6adc8`, RGB `166,173,200`) for line numbers:

```text
--smart-case
--colors=match:fg:137,180,250
--colors=path:fg:137,180,250
--colors=line:fg:166,173,200
```

## Deferred: activating it

ripgrep has no auto-discovered config path — only `RIPGREP_CONFIG_PATH`,
an environment variable that must point at this file. That has to be set
in a shell startup file, which doesn't exist in this repo yet — same gap
as [zoxide](./zoxide.md) and [fzf](./fzf.md).

## Validation

No linter exists for ripgrep's options-file format. `ripgrep-check` in
`hk.pkl` loads this file via `RIPGREP_CONFIG_PATH` and runs a throwaway
search; ripgrep exits `2` specifically on a bad flag (vs. `0`/`1` for a
normal found/not-found result), so the check distinguishes a real config
error from an expected non-match — same pattern as
[fzf-check](./fzf.md#validation). Verified both directions.

The `ripgrep` (`rg`) binary itself is provided by the **global mise
config** — see [mise.md](./mise.md).
