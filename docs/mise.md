# mise

This repo uses [mise](https://mise.jdx.dev) as the tool manager, with separate
repo-local, global core, macOS and desktop layers:

| Layer       | Path                                              | Activation and purpose                                                   |
| ----------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| Repo-local  | `mise.toml` / `mise.lock`                         | Always in this repo; tools/tasks used to work on the dotfiles            |
| Global core | `mise/config.toml` / `mise/mise.lock`             | Always global; portable tools available in every project                 |
| macOS       | `mise/config.macos.toml` / `mise/mise.macos.lock` | Automatic on macOS; the local Docker CLI, Buildx and Colima/Lima runtime |
| Desktop     | `mise.desktop.toml`                               | Opt-in via `-E desktop`; GUI packages used only by the bootstrap task    |

`mise/miserc.toml` sets `auto_env = true`, so mise selects the macOS layer
from the host platform without adding `macos` to `MISE_ENV`. The desktop
environment remains explicit and can be combined with the automatic platform
layer.

The repo-local and global core configs both set:

```toml
[settings]
lockfile = true
disable_backends = ["asdf", "vfox"]
```

- `lockfile = true` — every tool install is pinned by a committed `mise.lock`
  (exact version + per-platform checksum), so setup is reproducible across
  machines.

  **A lockfile only counts if it actually reaches the machine.** The global
  core and macOS config files therefore each have a matching `[dotfiles]`
  entry for their lockfile. Without those entries, mise would maintain
  machine-local locks independently of the committed pins. All five global
  files (`config.toml`, `mise.lock`, `config.macos.toml`, `mise.macos.lock`
  and `miserc.toml`) are declared in `mise.toml`; see
  [bootstrap.md](./bootstrap.md#what-gets-symlinked).
- `disable_backends = ["asdf", "vfox"]` — tools are resolved through mise's
  own backends (aqua, cargo, ubi, etc.) only; no asdf/vfox plugin resolution.

Global config tasks are namespaced `global:<name>` so a convenience task
defined globally never shadows a same-named task in some future project's own
`mise.toml`.

## Tools currently pinned

Global (`mise/config.toml`):

- [`delta`](https://github.com/dandavison/delta) — git diff pager, see
  [git.md](./git.md)
- Util tools — `atuin`, `bat`, `zoxide`, `eza`, `fd`, `fzf`, `gh`, `glab`,
  `glow`, `jq`, `yq`, `ripgrep`, `starship` — see
  [util_tools.md](./util_tools.md)
- Core tools — `tmux`, `lazygit`, `k9s`, `bottom`, `yazi` — see
  [core_tools.md](./core_tools.md)
- Containers and Kubernetes — Helm, helm-ls, k9s, kind, hadolint and
  kubeconform. These remain portable core tools and do not assume ownership of
  a Docker daemon.
- Languages — `rust`, `go` (+ `gopls`, `goimports`, `golangci-lint`,
  `gofumpt`, `gotestsum`) and `python`; editor tooling includes basedpyright,
  Ruff, mypy, RobotCode/Robot Framework/Robocop, Helm 4/helm-ls, YAML language
  tooling, yamlfmt and kubeconform. uv powers the isolated `pipx:` Python CLI
  installs — see [langs.md](./langs.md)
- `neovim` — editor, see [nvim.md](./nvim.md)
- `tree-sitter` — the CLI nvim-treesitter needs to compile parsers; a hard
  runtime dependency of the Neovim config, deliberately the aqua build
  rather than npm — see [nvim.md](./nvim.md#the-tree-sitter-cli-is-a-hard-dependency)

Desktop (`mise.desktop.toml`, opt-in only — see [bootstrap.md](./bootstrap.md)):

- `kitty`, `font-jetbrains-mono-nerd-font` (via `brew-cask:`) — see
  [desktop_tools.md](./desktop_tools.md)

macOS (`mise/config.macos.toml`, loaded automatically):

- Docker CLI and Docker Buildx
- Colima and its required Lima VM manager
- The `global:docker:*` lifecycle tasks below

Repo-local (`mise.toml`):

- [`claude-code`](https://github.com/anthropics/claude-code)
- [`hk`](https://hk.jdx.dev), [`taplo`](https://github.com/tamasfe/taplo),
  [`rumdl`](https://github.com/rvben/rumdl),
  [`yamlfmt`](https://github.com/google/yamlfmt),
  [`shellcheck`](https://github.com/koalaman/shellcheck),
  [`stylua`](https://github.com/JohnnyMorganz/StyLua) — lint/format
  tooling, see [linting.md](./linting.md)

The repo-root `mise.toml` also declares `[dotfiles]` and
`[bootstrap.repos]` — not tools, but mise's own native symlinking and
git-checkout provisioning, applied explicitly (never automatically) via
`mise bootstrap dotfiles apply`/`mise bootstrap repos apply`. See
[bootstrap.md](./bootstrap.md).

## Global Docker tasks

The automatic macOS global layer provides Colima-backed Docker lifecycle tasks
from every directory on macOS. They are absent from core-only environments:

| Task                            | Purpose                                                   |
| ------------------------------- | --------------------------------------------------------- |
| `global:docker:start`           | Start the Docker runtime and activate its Docker context  |
| `global:docker:stop`            | Stop the VM while preserving its state                    |
| `global:docker:restart`         | Restart the runtime                                       |
| `global:docker:status`          | Show Colima status, active context and Buildx version     |
| `global:docker:ssh`             | Open an interactive shell in the Colima VM                |

Run them with `mise run <task>`, for example
`mise run global:docker:start`. The start task explicitly selects Colima's
Docker runtime and relies on Colima to create and activate its Docker context.
Lima is pinned separately because the standalone Colima release invokes
`limactl`; Colima declares it as a mise dependency so installation order is
deterministic.
No delete, reset or prune task is provided because those operations can remove
VM or image state and should remain deliberate one-off commands.

## Docker Buildx

`aqua:docker/buildx` installs an executable named
`docker-cli-plugin-docker-buildx` in mise's versioned install directory.
Docker does not discover CLI plugins from `PATH`, so the tool-level
`postinstall` hook links that executable to
`~/.docker/cli-plugins/docker-buildx`, the filename and user plugin directory
the Docker CLI expects.

The hook runs when mise installs or upgrades that buildx version. If the tool
was already installed before the hook was added or changed, run
`mise install --force aqua:docker/buildx` once to reinstall that version and
rerun its hook. Verify discovery with `docker buildx version`; this does not
require the Docker daemon to be running.

Moving to a core-only environment deactivates mise's Docker and Buildx tools,
but it cannot retract a plugin symlink created by an earlier post-install hook.
If that machine's Docker distribution should own Buildx, inspect
`~/.docker/cli-plugins/docker-buildx` and remove it only when it still points
into mise's versioned install directory.

## A quirk worth knowing: `mise/config.toml` is also read here

mise resolves config by walking up the directory tree, and `mise/config.toml`
relative to *any* directory is one of the filenames it recognizes — not only
`~/.config/mise/config.toml`. That means running mise anywhere in this repo
picks up `mise.toml` (repo-local tools), `mise/config.toml` (the staged global
core), and—on macOS with `auto_env` enabled—`mise/config.macos.toml`, in
addition to the machine's real global config. Run `mise config ls` from the
repo root to see the active layers.

In practice this is harmless here — both configs agree on `[settings]`, and
having `delta`/`atuin`/`tmux`/`lazygit`/`bat`/`zoxide`/`eza`/`fd`/`fzf`/`jq`/
`yq`/`ripgrep`/`starship`/`k9s`/`glow`/`bottom`/`yazi`/`gh`/`glab`/`neovim`/
`tree-sitter`/`rust`/`go` on `PATH` while hacking on this repo isn't a
problem — but it's
worth knowing so a stray tool showing up in `mise config` output inside
this repo doesn't come as a surprise.

**Caution when testing changes to the global config layers:** never run a mise
command with an explicit `--global` flag (e.g. `mise lock --global`, `mise
use --global`) from inside this repo without first setting
`MISE_GLOBAL_CONFIG_FILE` to point at `mise/config.toml` and enabling the
staged platform environment. Without that override, `--global` targets the
machine's *real* global config rather than this repo's staged copy—an easy way
to write a lockfile or tool pin outside the repo accidentally. The macOS
overlay owns `mise.macos.lock`, not `config.macos.lock`.

**A second, subtler version of the same risk: even a plain `mise install
<tool>@version`** for a tool not declared in *any* config (an ad-hoc
install used to poke at a real binary before adding it properly) can still
write a new entry into the machine's real `~/.config/mise/mise.lock` —
confirmed directly, no `--global` flag or env override involved. Since the
real global config is one of the active layers described above, and it has
`lockfile = true` set, mise locks against it too. Prefer installing a tool
to inspect it with `mise install aqua:owner/repo@version` from **outside**
any directory mise would resolve real global config against, or expect to
check the real lockfile afterward for stray entries.
