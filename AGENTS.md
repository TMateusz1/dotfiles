# AGENTS.md

Instructions for AI coding agents (and future-you) working in this repository.
Read this before adding, restructuring, or touching config in this repo.

## What this repo is

A public dotfiles repository. It holds this user's personal tool
configuration (shell, editor, TUIs, CLI tools, mise tool/task management,
etc.), meant to be symlinked into place on any machine. Symlinking itself
(the "installer"/stow step) is **not built yet** — it will be added later.
Directory naming today must already be compatible with that future step (see
below), even though no linking script exists yet.

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

## Repository layout

```text
mise.toml            # repo-local mise config: tools + tasks for working on this repo itself
mise.lock             # committed lockfile for the repo-local mise config
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
the upstream tool's expected config folder name. This keeps a future
symlink/stow script a dumb `for d in */; do ln -s "$d" "$XDG_CONFIG_HOME/$d"; done`-style
mapping. If a tool doesn't follow the XDG convention on its own (e.g. it
insists on `~/.toolrc` or a macOS `Application Support` path), still name
the repo directory after the tool, and note the real target path explicitly
in that directory's own short README (or in `docs/`) so the future linker
step can special-case it.

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
   work *on this repository* (linting, formatting, future install/symlink
   tooling, etc.). Lives at the repo root.
2. **Global** — `./mise/config.toml`: the user's global mise config,
   destined for `~/.config/mise/config.toml`. Governs tool versions/tasks
   available in *every* project on the machine, dotfiles repo or not.

Rules that apply to **both**:

- **Always commit a lockfile.** Set `lockfile = true` under `[settings]` in
  both configs, and commit the resulting `mise.lock` alongside its
  `mise.toml`/`config.toml`. Never leave tool resolution unpinned.
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
- Trusted, actively maintained plugins only (see "General config
  philosophy" above) — favor small, focused, well-known plugins over
  mega-plugins or obscure ones, and only add a plugin when a real gap
  exists (don't reach for a plugin to replace something Neovim already does
  natively).
- Goal is a genuinely modern, fast, IDE-like editing experience — LSP,
  treesitter, completion, fuzzy finding, git integration — not a
  from-scratch "minimal vimrc" exercise.
- Theme: Catppuccin (see above), via the official
  [catppuccin/nvim](https://github.com/catppuccin/nvim) plugin.

## Adding a new dotfile — checklist

1. Create `./<tool-name>/` named per the symlink convention above.
2. Add the tool's config using that tool's own native layout/format.
3. Apply Catppuccin theming if the tool supports theming.
4. If the tool needs a binary, prefer sourcing it via mise (global config)
   rather than a manual install step, unless there's a documented reason
   not to (e.g. Neovim LSP servers — see above).
5. Update `README.md` and add/update the relevant page under `docs/`.
6. Double-check the diff for secrets before committing (see "Hard rules").
