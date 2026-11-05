# dotfiles

Personal shell, editor and CLI configuration, managed with
[mise](https://mise.jdx.dev) and themed with Catppuccin Mocha.

From this repository, with mise installed:

```sh
mise run bootstrap:all
mise run global:setup
```

- Root `mise.toml` provisions dotfile symlinks, Zsh plugins and mise completion.
- `mise/config*.toml` installs global tools. On macOS, setup also installs
  Homebrew formulae (Colima, Docker, Buildx, Compose), apps and fonts, then links
  Docker CLI plugins. The native formula provider requires Apple Silicon.
  Lima is installed as Colima's dependency.
- Start the container runtime when needed: `colima start`.

Preview symlinks with `mise run bootstrap:dry-run`; inspect provisioning with
`mise run bootstrap:status`. Install repo checks with `mise install --locked`,
then run `mise exec -- hk run check --all`.

Keep secrets and Zed SSH connections in ignored local files. Shared Zed defaults
live in `zed/global_settings.json`; `zed/settings.json` stays machine-local.
See [AGENTS.md](AGENTS.md) for repository conventions.
