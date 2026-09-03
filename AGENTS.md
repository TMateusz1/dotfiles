# AGENTS.md

Instructions for AI coding agents (and future-you) working in this repository.
Read this before adding, restructuring, or touching config in this repo.

## What this repo is

A public dotfiles repository. It holds this user's personal tool
configuration (shell, editor, TUIs, CLI tools, mise tool/task management,
etc.), symlinked into place on a machine by mise's own native `[dotfiles]`
provisioning — declared in the repo-root `mise.toml`, applied explicitly
with `mise run bootstrap:all`. There is no hand-rolled installer/stow
script and shouldn't be one. See [docs/bootstrap.md](./docs/bootstrap.md).

## Hard rules

- **This repo is public. Never commit secrets** — API keys, tokens, SSH
  keys, `.env` files, hostnames/IPs tied to private infra, credentials of any
  kind. If a tool's config normally holds a secret, keep the secret out of
  the tracked file (e.g. via an untracked local override, an env var
  reference, or a `*.local.*` file that's gitignored) and document the
  pattern in that tool's own docs.
- Before every commit, actually look at the diff for anything that looks
  like a token, key, or personal-but-sensitive path — not just filenames.
- Keep **README.md** and **docs/** current as the repo grows. A structural
  change (new dotfile directory, new convention, new mise task) is not done
  until the docs reflect it. Don't let docs drift — future sessions and the
  user rely on them being accurate, not historical.
- **Never run git commands that mutate repo/working-tree state on your
  own** — no `add`, `commit`, `stash`, `push`, or similar, without the user
  explicitly asking for that specific action in that turn. Git is the
  user's tool, not the agent's: edit files, and leave staging/committing/
  everything else git to the user.

## Repository layout

```text
mise.toml             # repo-local mise config: tools + tasks for working on this repo
                      #   itself, plus the [dotfiles]/[bootstrap.repos] tables that
                      #   define what gets symlinked where
mise.lock             # committed lockfile for the repo-local mise config
mise/config.desktop.toml # GUI/desktop packages, loaded only via `-E desktop` (opt-in)
hk.pkl                # lint/format steps + git hooks (see docs/linting.md)
.rumdl.toml           # markdown lint config
.yamlfmt              # YAML format config
.stylua.toml          # Lua format config
.gitignore            # includes tool-written state that must never be committed
<tool>/               # one directory per dotfile/tool, e.g. nvim/, k9s/, mise/
  ...                 # that tool's config, laid out as that tool expects it
docs/                 # per-topic documentation (conventions, per-tool notes, setup)
README.md             # repo overview, quickstart, links into docs/
```

`./mise/` is special: it holds the **global** mise config
(`mise/config.toml`, destined for `~/.config/mise/config.toml`), as opposed
to the top-level `mise.toml`, which is this repo's *own* local mise config
(tools/tasks needed to work on the dotfiles repo itself). Don't confuse the
two — see "mise conventions" below.

## Directory / symlink naming convention

Each top-level tool directory is named to mirror where it will eventually be
symlinked under `$XDG_CONFIG_HOME` (`~/.config/<name>`), e.g.:

- `nvim/` → `~/.config/nvim`
- `k9s/` → `~/.config/k9s`
- `mise/` → `~/.config/mise`

Use the tool's own lowercase config-dir name as the directory name — no
prefixes, no `dot-` / `.` leading dots, no abbreviations that don't match
the upstream tool's expected config folder name. This keeps most
`[dotfiles]` entries a trivial `"~/.config/<tool>" = "<tool>"` pair. If a
tool doesn't follow the XDG convention on its own (e.g. it insists on
`~/.toolrc` or a macOS `Application Support` path), still name the repo
directory after the tool, give its `[dotfiles]` entry the real target path,
and document that exception in the tool's `docs/` entry.

**Directory entry vs. file entries.** Symlinking the whole directory
(`"~/.config/<tool>" = "<tool>"`) is the default and is right for tools
that only ever *read* their config. It is wrong for a tool that **writes
into its own config directory** — with a directory symlink, that tool
writes straight into this git repo. For those, symlink the specific files
this repo owns instead (e.g. `"~/.config/glow/glamour.json" =
"glow/glamour.json"`), leave the tool's generated file machine-local, and
add it to `.gitignore` as a second line of defence. Check for this when
adding a tool: run it once and see whether anything appears or changes in
its config directory.

## Visual consistency: Catppuccin everywhere

Every tool that supports theming uses the **Catppuccin** theme family
(pick the flavor — Mocha/Macchiato/Frappé/Latte — but be consistent across
tools; default to **Mocha** unless a specific tool's docs say otherwise).
Prefer the official Catppuccin port/plugin for a given tool over a
hand-rolled palette. Do not introduce a different theme "just for this one
tool" — consistency across the whole setup is a stated goal, not a nice-to-have.

## General config philosophy

- Modern, actively maintained tools/plugins over legacy ones.
- Keep configs easy to read and maintain — prefer plain, well-organized
  config over cleverness. A new dotfile's config should be understandable
  without needing this repo's git history.
- Only add a plugin/dependency when the task actually requires it — don't
  pre-install things "for later."
- Trusted sources only for anything executable (plugins, LSPs, scripts):
  well-known, actively maintained projects — not random forks or
  single-maintainer toys with no track record, given this repo is public
  and its config gets executed on the user's machine.

## mise conventions

There are (at least) two mise configs in this repo — don't mix them up:

1. **Repo-local** — `./mise.toml` (+ `./mise.lock`): tools/tasks needed to
   work *on this repository* (linting, formatting), plus the `[dotfiles]`
   and `[bootstrap.repos]` tables and the `bootstrap:*` tasks that apply
   this repo to a machine. Lives at the repo root.
2. **Global** — `./mise/config.toml`: the user's global mise config,
   destined for `~/.config/mise/config.toml`. Governs tool versions/tasks
   available in *every* project on the machine, dotfiles repo or not.

Rules that apply to **both**:

- **Always commit a lockfile.** Set `lockfile = true` under `[settings]` in
  both configs, and commit the resulting `mise.lock` alongside its
  `mise.toml`/`config.toml`. Never leave tool resolution unpinned. For the
  global config this means **two** `[dotfiles]` entries — `config.toml` and
  `mise.lock` both have to reach `~/.config/mise/`, or the committed pins
  never take effect on the machine and mise quietly maintains its own
  unpinned lockfile there instead.
- **Disable asdf and vfox backends.** Set
  `disable_backends = ["asdf", "vfox"]` under `[settings]`. We manage tools
  through mise's native/aqua/ubi-style backends only — no asdf or vfox
  plugin resolution.

Rule specific to the **global** config:

- Any task defined in the global mise config must be namespaced under
  `global:`, e.g. a task named `global:update` (not `update`). This is so a
  short, convenient task name defined globally never silently shadows or
  collides with a same-named task in some future project's own
  `mise.toml`. Repo-local tasks (in `./mise.toml`, for working on this repo)
  do *not* use this prefix — the prefix is only for tasks meant to be
  available everywhere.

## Linting conventions (`hk.pkl`)

- Only wire up a lint/format step for a config format when a real,
  established tool exists for it (rumdl, taplo, yamlfmt, shellcheck, ...).
- If no such tool exists for a format, **don't build one.** No hand-rolled
  shell script that reaches into a tool's internals, loads a config on a
  throwaway server, or greps stderr for an error string to fake a check —
  even when a plausible mechanism exists, it's more fragile/invented than
  the thing it's protecting, and it's maintenance surface for a safety net
  that only looks real. Verify that config by hand against the real binary
  when you write it (document what you checked, in that tool's `docs/`
  page), and leave it unchecked going forward rather than maintaining
  bespoke validation logic for a gap no real tool fills.

## Neovim conventions (`nvim/`)

- Standard modern layout: `init.lua` bootstraps
  [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager,
  with plugin specs and their config split across `lua/` (e.g.
  `lua/plugins/*.lua`, `lua/config/*.lua`) rather than one giant `init.lua`.
- **No mason.nvim** (or mason-lspconfig, mason-tool-installer, etc.) and no
  auto-downloading of LSP/formatter/linter binaries from within Neovim.
  LSP server binaries are expected to already be on `$PATH`, provided by
  mise (global config or a per-project mise config) or installed manually by
  the user. Neovim config only *configures* LSP clients (e.g. via
  `nvim-lspconfig` / native `vim.lsp.config`), it never installs them.
  - **Two carve-outs, both for locally compiled artifacts** — never for
    fetched executables. In each case the rule still binds where it counts:
    the toolchain doing the compiling is pinned in the global mise config,
    never fetched by Neovim.
    - **Treesitter parsers**: nvim-treesitter compiles per-language grammars
      locally from source. The `tree-sitter` CLI that compiles them is a
      pinned mise tool, and never the npm build. See
      [docs/nvim.md](./docs/nvim.md#treesitter).
    - **blink.cmp's fuzzy matcher**: blink ships a Rust library and by
      default *downloads* a prebuilt copy from GitHub releases, which this
      rule forbids. It is therefore built from source (`cargo build
      --release`) with the `rust` toolchain pinned in the global mise
      config. See [docs/nvim.md](./docs/nvim.md#completion).
- Trusted, actively maintained plugins only (see "General config
  philosophy" above) — favor small, focused, well-known plugins over
  mega-plugins or obscure ones, and only add a plugin when a real gap
  exists (don't reach for a plugin to replace something Neovim already does
  natively).
- Goal is a genuinely modern, fast, IDE-like editing experience — LSP,
  treesitter, completion, fuzzy finding, git integration — not a
  from-scratch "minimal vimrc" exercise.
- Keep [which-key.nvim](https://github.com/folke/which-key.nvim) synchronized
  with every keymap change. Each mapping must have an accurate `desc` so
  WhichKey discovers and labels it automatically; when a leader-key namespace
  is added, renamed, or removed, update the group declarations in
  `nvim/lua/plugins/which-key.lua` in the same change. Do not duplicate the
  mappings themselves in WhichKey's spec.
- Theme: Catppuccin (see above), via the official
  [catppuccin/nvim](https://github.com/catppuccin/nvim) plugin.

## Adding a new dotfile — checklist

1. Create `./<tool-name>/` named per the symlink convention above.
2. Add the tool's config using that tool's own native layout/format.
3. Apply Catppuccin theming if the tool supports theming.
4. If the tool needs a binary, prefer sourcing it via mise (global config)
   rather than a manual install step, unless there's a documented reason
   not to (e.g. Neovim LSP servers — see above). Re-run `mise lock` for
   whichever config you touched and commit the updated lockfile.
5. **Add a `[dotfiles]` entry in `mise.toml`** — without it the config is
   never symlinked anywhere and the tool silently keeps using its defaults.
   Run the tool once first and check whether it writes into its own config
   directory; if it does, symlink individual files rather than the
   directory (see "Directory entry vs. file entries" above).
6. Verify the config against the tool's real binary — actually load it and
   confirm the settings took effect, rather than assuming (see "Linting
   conventions": most of these formats have no linter to catch mistakes).
7. Update `README.md` and add/update the relevant page under `docs/`.
8. Double-check the diff for secrets before committing (see "Hard rules").
