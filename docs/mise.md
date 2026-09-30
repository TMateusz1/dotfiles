# mise

This repo uses [mise](https://mise.jdx.dev) as the tool manager, with separate
repo-local, global core, macOS and desktop layers:

| Layer       | Path                                              | Activation and purpose                                                   |
| ----------- | ------------------------------------------------- | ------------------------------------------------------------------------ |
| Repo-local  | `mise.toml` / `mise.lock`                         | Repo checks, hooks, and bootstrap tasks/settings                         |
| Global core | `mise/config.toml` / `mise/mise.lock`             | Shared languages, LSPs, editor, terminal, and CLI tools                  |
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
- Containers and Kubernetes — Helm, helm-ls, k9s, kind, hadolint and
  kubeconform. These remain portable core tools and do not assume ownership of
  a Docker daemon.
- Languages — `rust`, `go` (+ `gopls`, `goimports`, `golangci-lint`,
  `gofumpt`, `gotestsum`) and `python`; editor tooling includes basedpyright,
  Ruff, mypy, RobotCode/Robot Framework/Robocop, Buf for Protocol Buffers,
  Helm 4/helm-ls, YAML language
  tooling, yamlfmt and kubeconform. uv powers the isolated `pipx:` Python CLI
  installs — see [langs.md](./langs.md)
- `neovim` — editor, see [nvim.md](./nvim.md)
- Shared editor executables are grouped by language: each group keeps its
  language servers, formatters, linters, and utilities together. Python and
  Robot Framework share a group, as do YAML, Helm, and Kubernetes. Shared
  runtimes, editor infrastructure, and general CLI tools have their own groups.
  StyLua, Taplo, and shfmt are global tools, so Lua, TOML, and shell formatting
  work outside this dotfiles repository too. Tools with several roles, such
  as Ruff and Buf, are declared once in their language's group.
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

The global core config provides two maintenance tasks, available from any
project after the global config is provisioned:

```sh
mise run global:tools:status
mise run global:tools:outdated
```

`status` runs `mise ls --current` and `mise doctor`. `outdated` runs
`mise outdated --bump`, comparing exact pins against newer releases. Both use
the caller's directory, so project overrides are included. They do not install
or upgrade tools or rewrite pins; the outdated check can fetch release metadata
and update mise's cache. To inspect shared defaults without project overrides,
run them from a directory outside a project.

You can pass tool keys to limit the outdated check, for example:

```sh
mise run global:tools:outdated aqua:mvdan/sh aqua:tamasfe/taplo
```

Verified both tasks against the real mise binary outside this repository,
including a filtered outdated check. Config files and lockfiles were unchanged
after execution. The bootstrap dependency order was checked with mise's dry run;
a temporary task fixture confirmed that a failed tool-install dependency stops
`bootstrap:all` before any provisioning command runs.

Use `mise/config.toml` for shared defaults and a project's own `mise.toml`
for project requirements. The root `mise.toml` retains the tools needed to
check this dotfiles repository independently; overlapping pins should match
the global defaults unless this repository deliberately needs a different
version. Neovim config selects tools and supplies editor settings; mise owns
their installation and versions.

To change a shared tool, edit its exact version in `mise/config.toml`. For an
overlapping repository check tool, also update the root declaration. From the
repository root, refresh only that tool's global lock entry, for example:

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise lock --global aqua:mvdan/sh
MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise install --locked aqua:mvdan/sh
```

If the root declaration also changed, refresh its lock with `mise lock <tool>`.
Review the config and lockfile diffs and verify the new tool in a real file.
Keep exact pins: refreshing a lock alone does not upgrade an exact version.
Use the same procedure for other tools by replacing the fully qualified key.

### Update one group at a time

Use the language sections in `mise/config.toml` as update units. Treat shared
runtime changes as separate decisions: a Node upgrade affects several servers,
and a Python upgrade also requires checking the `uvx_args` runtime references.

1. Check available releases with `global:tools:outdated`, or limit the native
   command to selected keys, for example:

   ```sh
   mise outdated --bump go:golang.org/x/tools/gopls go:golang.org/x/tools/cmd/goimports aqua:mvdan/gofumpt aqua:golangci/golangci-lint
   ```

2. Review the tools' release notes and change only the intended exact pins.
   Update matching repo-local declarations when applicable. Leave other
   language groups and Neovim plugin versions for separate changes.
3. Refresh only the selected global lock entries, then install those tools:

   ```sh
   MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise lock --global go:golang.org/x/tools/gopls go:golang.org/x/tools/cmd/goimports aqua:mvdan/gofumpt aqua:golangci/golangci-lint
   MISE_GLOBAL_CONFIG_FILE="$PWD/mise/config.toml" mise install --locked go:golang.org/x/tools/gopls go:golang.org/x/tools/cmd/goimports aqua:mvdan/gofumpt aqua:golangci/golangci-lint
   ```

4. Restart Neovim for editor tool changes and verify one representative project.
   For Go, check LSP attachment/navigation, formatting, lint results, and a test
   run. For Python/Robot, check imports, diagnostics, formatting, and a test.
   For configuration languages, check schema diagnostics and formatting.
5. Review the config and lockfile diff before starting another group. Keep the
   prior pins available so a regression can be resolved by restoring those
   declarations and lock entries and reinstalling their locked versions.

Update terminal tools separately from language tooling: tmux, lazygit, k9s,
bottom, yazi, and glow form a useful group. Verify configuration loading and a
normal workflow in each changed tool. Start a separate tmux server when testing
a new binary against an existing running server. CLI utilities can be another
small group. Neovim itself and its plugins deserve a separate update because
API changes can affect several integrations at once.

For reproducible setup and CI, use `mise install --locked` after checking out
the config and matching lockfiles. This repository has no CI workflow; the
existing checks can be run with `hk check --all` after the locked installation.

### Project-specific versions

Add only the overrides a project needs, using the same fully qualified tool
keys as the global config. For example, in that project's `mise.toml`:

```toml
[settings]
lockfile = true
disable_backends = ["asdf", "vfox"]

[tools]
"aqua:mvdan/sh" = "3.14.1" # Replace with the exact version this project requires.
```

From the project directory, run `mise lock` and `mise install --locked`, then
track both `mise.toml` and `mise.lock` in the project. Other tools inherit their
global defaults. Project configuration takes precedence according to
[mise's configuration hierarchy](https://mise.jdx.dev/configuration.html#configuration-hierarchy).
Rules and style settings belong in the tool's project configuration file;
the mise pin selects the executable version.

Launch `nvim` from the project after mise has activated its environment, or
use `mise exec -- nvim`. Verify a tool's selected version with `mise which
shfmt` and `shfmt --version`. Inside Neovim, `:lua print(vim.fn.exepath("shfmt"))`
shows the executable visible to the editor. A running Neovim process retains
its launch environment: restart it after changing tool pins or switching to
a project with different requirements. Explicit project virtualenv selection
in a language integration can take precedence over the general PATH lookup.

For adding another language, follow
[Add a language to Neovim](./nvim-add-new-lang.md).

Verified on macOS ARM64 from a temporary directory outside this repository,
starting with a clean system PATH: mise resolved all 23 checked editor
executables, and the real Neovim configuration formatted Lua, TOML, and shell
buffers through Conform using the globally declared binaries. A temporary
project pin selected shfmt 3.14.0 over the global 3.14.1 default; this checked
configuration precedence without installing that alternate version. Existing
tool pins and lock entries were preserved. The three added global tools have
lock entries for macOS ARM64 and Linux ARM64/x64; Linux execution was not tested.

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
