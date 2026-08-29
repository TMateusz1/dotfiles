# mise

This repo uses [mise](https://mise.jdx.dev) as the tool manager, in two
separate roles — don't confuse them:

| Config | Path | Purpose |
|---|---|---|
| Repo-local | `mise.toml` / `mise.lock` (repo root) | Tools/tasks needed to work *on this dotfiles repo itself* |
| Global | `mise/config.toml` / `mise/mise.lock` | The user's global mise config, symlinked to `~/.config/mise/config.toml` — governs tool versions available in every project on the machine |

Both configs set:

```toml
[settings]
lockfile = true
disable_backends = ["asdf", "vfox"]
```

- `lockfile = true` — every tool install is pinned by a committed `mise.lock`
  (exact version + per-platform checksum), so setup is reproducible across
  machines.
- `disable_backends = ["asdf", "vfox"]` — tools are resolved through mise's
  own backends (aqua, cargo, ubi, etc.) only; no asdf/vfox plugin resolution.

Global config tasks (if/when added) are namespaced `global:<name>` so a
convenience task defined globally never shadows a same-named task in some
future project's own `mise.toml`.

## Tools currently pinned

Global (`mise/config.toml`):

- [`delta`](https://github.com/dandavison/delta) — git diff pager, see
  [git.md](./git.md)
- [`atuin`](https://github.com/atuinsh/atuin) — shell history, see
  [atuin.md](./atuin.md)

Repo-local (`mise.toml`):

- [`claude-code`](https://github.com/anthropics/claude-code)
