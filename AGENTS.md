# AGENTS.md

Instructions for coding agents working in this public dotfiles repository.

## Hard rules

- Never commit secrets, credentials, private infrastructure addresses or sensitive
  paths. Use ignored local overrides or environment variables for private data.
  Inspect the actual diff for sensitive content before any authorized commit.
- Never run Git commands that change repository or working-tree state (including
  add, commit, stash and push) unless the user explicitly requests that specific
  action in the current turn. Leave staging and commits to the user.
- Keep documentation minimal: a short README with setup commands and essential
  caveats. Do not create a docs directory, per-tool guides or change narratives.
  Use brief config comments only when they explain a non-obvious choice.

## Ownership and layout

- Root `mise.toml` and `mise.lock` own repository checks and native mise
  `[dotfiles]` / `[bootstrap.repos]` provisioning: dotfiles, Zsh plugins and
  shell integration. Do not build a custom installer or stow script.
- `mise/config.toml` and `mise/config.macos.toml` are the user's global configs,
  linked under `~/.config/mise/`. They own tool and macOS package installation.
  Expose only `global:setup`: install tools everywhere; on macOS also install
  packages and link Docker CLI plugins. Keep this separate from repo bootstrap.
- Name top-level config directories after the tool's lowercase config-directory
  name. Add every managed config to root `[dotfiles]`, using the tool's real path.
- Prefer whole-directory symlinks for read-only config. For tools that write into
  their config directory, link individual owned files and ignore generated state.
- Zed is an explicit exception: preserve its whole-directory link. Shared defaults
  belong in `zed/global_settings.json`; `zed/settings.json` holds ignored local
  overrides and SSH connections. Never copy these into shared defaults.

## Config conventions

- Use Catppuccin, defaulting to Mocha, and prefer official theme ports.
- Preserve Zed's Catppuccin Mocha/Latte, Material Icon Theme, JetBrains keymap and
  Vim editing/navigation. Prefer native features; add extensions for concrete needs.
- Zed manages editor language tooling; mise owns runtimes, compilers and repository
  checks. Keep related keymaps, snippets and tasks consistent.
- Prefer readable native config and maintained, trusted upstream projects. Add
  dependencies only when required by the task.
- Enable `lockfile = true` and `disable_backends = ["asdf", "vfox"]` in repo and
  global mise settings. Keep affected lockfiles current. Link global config and
  lockfiles together so the committed pins apply on the machine.
- Use established formatters and linters in `hk.pkl`. If none exists, verify with
  the real tool when editing; do not invent bespoke validation scripts.
- When adding a tool, verify its config and whether it writes local state, apply
  theming where supported, wire its dotfiles and installation, and update the
  README only when setup instructions or essential caveats change.
