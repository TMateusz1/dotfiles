# fd

No config file lives here. [fd](https://github.com/sharkdp/fd) has a real,
XDG-mapped global ignore file — `$XDG_CONFIG_HOME/fd/ignore` (verified in
its docs) — but no default patterns are added; there's nothing to exclude
by default beyond what fd already respects (`.gitignore`, `.ignore`,
`.fdignore`). Revisit if a real need for global excludes shows up.

The `fd` binary itself is provided by the **global mise config** — see
[mise.md](./mise.md).
