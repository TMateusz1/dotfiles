# mise

This repo uses [mise](https://mise.jdx.dev) as the tool manager, with separate
repo-local, global core, macOS and desktop layers:

| Layer       | Path                                              | Activation and purpose                                                   |
| ----------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| Repo-local  | `mise.toml` / `mise.lock`                         | Repo checks, hooks, and bootstrap tasks/settings                         |
| Global core | `mise/config.toml` / `mise/mise.lock`             | Language runtimes, editor, terminal, and CLI tools                       |
| macOS       | `mise/config.macos.toml` / `mise/mise.macos.lock` | Automatic on macOS; the local Docker CLI, Buildx and Colima/Lima runtime |
| Desktop     | `mise/config.desktop.toml`                        | Opt-in via `-E desktop`; GUI packages used only by the bootstrap task    |

`mise/miserc.toml` sets `auto_env = true`, so mise selects the macOS layer
from the host platform without adding `macos` to `MISE_ENV`. The desktop
environment remains explicit and can be combined with the automatic platform
layer.

The repo-local and global core configs both set:

```toml
[settings]
lockfile = true
disable_backends = ["asdf", "vfox"]
task.run_auto_install = false
```

- `lockfile = true` — tool resolutions are pinned by a committed `mise.lock`
  (exact versions, plus artifact URLs and checksums where the backend supplies
  them), so other machines can use the same resolutions.

  **A lockfile only counts if it actually reaches the machine.** The global
  core and macOS config files therefore each have a matching `[dotfiles]`
  entry for their lockfile. Without those entries, mise would maintain
  machine-local locks independently of the committed pins. All six global
  files (`config.toml`, `mise.lock`, `config.macos.toml`, `mise.macos.lock`,
  `config.desktop.toml`, and `miserc.toml`) are declared in `mise.toml`. See
  [bootstrap.md](./bootstrap.md#what-gets-symlinked).
- `disable_backends = ["asdf", "vfox"]` — tools are resolved through mise's
  own backends (aqua, cargo, ubi, etc.) only; no asdf/vfox plugin resolution.
- `task.run_auto_install = false` — task execution does not implicitly install
  missing tools. Install explicitly with `mise install --locked` or this repo's
  `bootstrap:tools` task. This also affects tasks in projects inheriting the
  global setting: install their declared tools before running them.

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
- Containers and Kubernetes — Helm, k9s and kind. Helm remains a runtime
  dependency for Mason's helm-ls chart linting.
- Languages — Rust, Go, Python and Node; uv remains for package management.
  Neovim's language servers, formatters,
  linters and Go editing utilities are installed by Mason instead; see
  [langs.md](./langs.md).
- `neovim` — editor, see [nvim.md](./nvim.md)
- `tree-sitter` — the CLI nvim-treesitter needs to compile parsers; a hard
  runtime dependency of the Neovim config, deliberately the aqua build
  rather than npm — see [nvim.md](./nvim.md#the-tree-sitter-cli-is-a-hard-dependency)

Desktop (`mise/config.desktop.toml`, opt-in only — see [bootstrap.md](./bootstrap.md)):

- `kitty`, `font-jetbrains-mono-nerd-font`, `font-geist-mono-nerd-font`
  (via `brew-cask:`) — see
  [desktop_tools.md](./desktop_tools.md)

macOS (`mise/config.macos.toml`, loaded automatically):

- Docker CLI and Docker Buildx
- Colima and its required Lima VM manager
- The `global:docker:*` lifecycle tasks below

Repo-local (`mise.toml`):

hk uses the registry-recommended `packslip:github.com/jdx/hk` backend; Neovim
uses `aqua:neovim/neovim`. Old shorthand installations can retain a previous
backend even after the tracked config changes. Inspect `mise ls` and use a
targeted `mise uninstall <tool>@<version>` to remove obsolete installations
after verifying the configured replacement works.

- [`hk`](https://hk.jdx.dev), [`taplo`](https://github.com/tamasfe/taplo),
  [`rumdl`](https://github.com/rvben/rumdl),
  [`yamlfmt`](https://github.com/google/yamlfmt),
  [`shellcheck`](https://github.com/koalaman/shellcheck),
  [`stylua`](https://github.com/JohnnyMorganz/StyLua) — lint/format
  tooling, see [linting.md](./linting.md)

AI coding agents are not provisioned by either mise layer. The repo-local
Node.js pin was removed with Codex; global Node.js remains for npm-based LSPs.

The repo-root `mise.toml` also declares `[dotfiles]` and
`[bootstrap.repos]` — not tools, but mise's own native symlinking and
git-checkout provisioning, applied explicitly (never automatically) via
`mise bootstrap dotfiles apply`/`mise bootstrap repos apply`. See
[bootstrap.md](./bootstrap.md).

## Maintaining editor tools

Neovim's editor tools are pinned in
[nvim/lua/plugins/mason.lua](../nvim/lua/plugins/mason.lua), installed by
[mason.nvim](https://github.com/mason-org/mason.nvim) and ensured by
[mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim).
They live in Neovim's data directory, outside this public repository.

Edit the selected package's exact version, then run `:MasonToolsInstall` to
apply the pin. For a fresh machine or headless installation:

```sh
nvim --headless '+MasonToolsInstallSync' '+qa'
```

Automatic installation of missing or differently pinned packages runs at
startup. Automatic version upgrades are disabled. `:Mason` shows installation
status and `:MasonLog` shows failures. `:MasonToolsClean` removes Mason packages
not declared in the list; use it only when those extra packages are unwanted.
Native LSP configuration and enablement remain in `lsp.lua`; mason-lspconfig is
not required. All configured packages use Mason's official registry.

Mason prepends its bin directory to Neovim's PATH. Verify selection with
`:lua print(vim.fn.exepath("shfmt"))`, `:ConformInfo`, and `:LspInfo`.
A project's mise tool pin alone does not override Mason in the editor; use an
explicit client/formatter command for that case. RobotCode and mypy already
prefer conventional project virtualenv binaries.

Mise continues to own runtimes, compilers, Neovim, terminal and shell tools,
Helm, the Treesitter CLI, and independent repository hk checks. Keep their
config and lockfiles together and install with `mise install --locked`.
The global maintenance commands still inspect mise tools:

```sh
mise run global:tools:status
mise run global:tools:outdated
```

After migrating tools, preview `mise prune --dry-run <tool> ...`, then use
`mise prune <tool> ...` for only the migrated tool keys. Versions referenced
by other tracked project configs remain installed. Repo-local StyLua, Taplo
and yamlfmt remain required for hk; jq remains a general shell utility.

For adding another language, follow
[Add a language to Neovim](./nvim-add-new-lang.md).

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
