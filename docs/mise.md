# mise

This repo uses [mise](https://mise.jdx.dev) as the tool manager, in two
separate roles — don't confuse them:

| Config     | Path                                  | Purpose                                                                                                                                    |
| ---------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Repo-local | `mise.toml` / `mise.lock` (repo root) | Tools/tasks needed to work *on this dotfiles repo itself*                                                                                  |
| Global     | `mise/config.toml` / `mise/mise.lock` | The user's global mise config, symlinked to `~/.config/mise/config.toml` — governs tool versions available in every project on the machine |

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
- Util tools — `atuin`, `bat`, `zoxide`, `eza`, `fd`, `fzf`, `jq`, `yq`,
  `ripgrep`, `starship` — see [util_tools.md](./util_tools.md)
- Core tools — `tmux`, `lazygit`, `k9s` — see
  [core_tools.md](./core_tools.md)
- Languages — `rust`, `go` (+ `gopls`, `goimports`, `golangci-lint`,
  `gofumpt`, `gotestsum`) — see [langs.md](./langs.md)

Repo-local (`mise.toml`):

- [`claude-code`](https://github.com/anthropics/claude-code)
- [`hk`](https://hk.jdx.dev), [`taplo`](https://github.com/tamasfe/taplo),
  [`rumdl`](https://github.com/rvben/rumdl),
  [`yamlfmt`](https://github.com/google/yamlfmt),
  [`shellcheck`](https://github.com/koalaman/shellcheck) — lint/format
  tooling, see [linting.md](./linting.md)

The repo-root `mise.toml` also declares `[dotfiles]` and
`[bootstrap.repos]` — not tools, but mise's own native symlinking and
git-checkout provisioning, applied explicitly (never automatically) via
`mise bootstrap dotfiles apply`/`mise bootstrap repos apply`. See
[bootstrap.md](./bootstrap.md).

## A quirk worth knowing: `mise/config.toml` is also read here

mise resolves config by walking up the directory tree, and `mise/config.toml`
relative to *any* directory is one of the filenames it recognizes — not only
`~/.config/mise/config.toml`. That means running mise anywhere in this repo
picks up **both** `mise.toml` (repo-local tools) *and* `mise/config.toml`
(the staged global config) as active layers, in addition to your machine's
real `~/.config/mise/config.toml`. Run `mise config` from the repo root to
see this for yourself.

In practice this is harmless here — both configs agree on `[settings]`, and
having `delta`/`atuin`/`tmux`/`lazygit`/`bat`/`zoxide`/`eza`/`fd`/`fzf`/`jq`/
`yq`/`ripgrep`/`starship`/`k9s`/`rust`/`go` on `PATH` while hacking on this
repo isn't a problem — but it's worth knowing so a stray tool showing up in
`mise
config` output inside this repo doesn't come as a surprise.

**Caution when testing changes to `mise/config.toml`:** never run a mise
command with an explicit `--global` flag (e.g. `mise lock --global`, `mise
use --global`) from inside this repo without first setting
`MISE_GLOBAL_CONFIG_FILE` to point at `mise/config.toml`. Without that
override, `--global` means the machine's *real* `~/.config/mise/config.toml`
— a mistake made once already, which wrote an unwanted `mise.lock` into a
real `~/.config/mise/` outside this repo. Plain `mise install`/`mise x --`
(no `--global`) are fine and is how this repo's own tooling gets tested —
they resolve against the ambient project-tier configs described above
without touching the real global config file.
