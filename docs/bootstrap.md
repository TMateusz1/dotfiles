# Bootstrap (symlinks, Zsh integration, desktop apps)

How this repo actually gets applied to a machine, via mise's own native
`[dotfiles]` and `[bootstrap.repos]` — not a hand-rolled install script.
Declared in the repo-root `mise.toml`. **Nothing here runs automatically**
— not on `mise install`, not via any hook. It's applied explicitly:

```sh
cd ~/dev/dotfiles          # or wherever this repo is cloned
mise run bootstrap:tools      # install tools from the committed lockfiles
mise run bootstrap:status     # what would change — read-only
mise run bootstrap:dry-run    # preview the dotfile symlinks specifically
mise run bootstrap:dotfiles   # apply symlinks — see "What gets symlinked" below
mise run bootstrap:plugins    # provision oh-my-zsh and Zsh plugins
mise run bootstrap:zsh-completion  # install mise's generated Zsh completion
mise run bootstrap:all        # complete setup, including apps and fonts on macOS
```

The tasks are thin wrappers (`mise tasks ls` for the full list) — nothing
they run couldn't be typed out as plain `mise bootstrap dotfiles ...`/
`mise bootstrap repos ...`/`mise completion zsh --install` commands; they just
save re-typing the longer form. All are idempotent (safe to re-run); the
dotfile and repo bootstrap operations refuse to clobber a real pre-existing
file/directory at any target without `--force`.

`bootstrap:all` first completes `bootstrap:tools` (`mise install --locked`),
then runs the dotfile, plugin and Zsh completion tasks. On macOS it also runs
`global:apps:install` for apps and fonts. Other platforms skip that step.
A failed tool install stops provisioning. Automatic tool installation before
tasks is disabled in the repo-local and global core settings, so status tasks can report missing tools
and provisioning uses the explicit locked installation step.

Use `mise install --locked` for a fresh checkout or a CI job as well. Missing
lock metadata should be fixed by updating the appropriate committed lockfile,
then retrying installation. Locked installs still download artifacts; they
are not an offline mode. App/font casks use their current published versions,
while plugin repository checkouts use their declared revisions rather than
`mise.lock`.

## Why mise's own feature, not a script

`mise bootstrap` is a whole declarative provisioning subsystem (accounts,
packages, files, services, repos, dotfiles, ...). We use `[dotfiles]`,
`[bootstrap.repos]` and macOS `[bootstrap.packages]`. These make every
"deferred" placement decision documented across
[util_tools.md](./util_tools.md)/[core_tools.md](./core_tools.md) (starship's flat `~/.config/starship.toml`, `shell/.zshrc`
→ `~/.zshrc`) is just an ordinary target/source pair — no special-casing
logic needed, and no restructuring of this repo's existing directory names.

The shell files map individually to `~/.zshenv`, `~/.zprofile`, and `~/.zshrc`.
They supply the minimal SSH environment, mise shims for IDEs, and interactive
integrations respectively. Provision them on the machine running the tools
and Git hooks. Existing `.zprofile` login setup can be preserved in
`~/.zprofile.local`, which the shared profile sources before loading shims.
Resolve existing-file conflicts rather than forcing replacement. See
[Shell environment and IDEs](./shell.md).

**A key fact this relies on:** relative dotfile `source` paths resolve
against *the directory of the config file that declares the entry* — not
against `dotfiles.root`. So `mise.toml` declaring `"~/.zshrc" =
"shell/.zshrc"` resolves that source relative to the repo root, regardless
of where the repo is cloned or what `dotfiles.root` is set to elsewhere.
This repo deliberately never sets `dotfiles.root` — it isn't needed since
every entry here uses an explicit source, never the home-mirroring `{}`
shorthand.

## What gets symlinked

```toml
[dotfiles]
"~/.zshenv" = "shell/.zshenv"
"~/.zprofile" = "shell/.zprofile"
"~/.zshrc" = "shell/.zshrc"
"~/.config/zellij/config.kdl" = "zellij/config.kdl"
"~/.config/starship.toml" = "starship/starship.toml"
"~/.config/git" = "git"
"~/.config/bat" = "bat"
"~/.config/eza" = "eza"
"~/.config/fzf" = "fzf"
"~/.config/ripgrep" = "ripgrep"
"~/.config/lazygit" = "lazygit"
"~/.config/k9s" = "k9s"
"~/.config/kitty" = "kitty"
"~/.config/zed" = "zed"
"~/.config/bottom" = "bottom"
"~/.config/mise/config.toml" = "mise/config.toml"
"~/.config/mise/mise.lock" = "mise/mise.lock"
"~/.config/mise/config.macos.toml" = "mise/config.macos.toml"
"~/.config/mise/mise.macos.lock" = "mise/mise.macos.lock"
"~/.config/mise/miserc.toml" = "mise/miserc.toml"
```

Directory entries (`git`, `bat`, `eza`, ...) symlink the *whole*
directory in one line — e.g. `"~/.config/git" = "git"` brings
`git/config` and `git/delta.gitconfig` along together, since
`git/config`'s own `[include]` already wires in delta. Nothing extra is
needed for delta specifically.

Zed also uses a whole-directory link so settings, keybindings and tasks share
one config directory. It writes a prompt database there, so `.gitignore`
allows only `global_settings.json`, `keymap.json`, `tasks.json` and the declared
Go snippets. `settings.json` (including SSH connections) and everything else
under `zed/` is ignored. This is a deliberate exception to the usual rule of
using file links for tools that write into their config directory. See
[desktop_tools.md#zed](./desktop_tools.md#zed) for migrating an existing
directory without discarding its local data.

These tools deliberately use **file** entries instead:

- **Zellij** — only `zellij/config.kdl` maps to
  `~/.config/zellij/config.kdl`. Its configuration UI can write settings and
  backups, so the directory remains machine-local. See
  [core_tools.md#zellij](./core_tools.md#zellij).
- **mise** — the global setup is managed file-by-file: portable tools use
  `config.toml`/`mise.lock`, the automatically selected macOS Docker layer uses
  `config.macos.toml`/`mise.macos.lock`; the macOS config also contains the
  app-install task. `miserc.toml` enables platform environments
  early enough for discovery. Every config and lockfile this repo owns is
  symlinked because omitted locks silently become machine-local and can drift.
  `~/.config/mise/` is not symlinked wholesale because it also holds
  machine-local state this repo doesn't own.

`fd`, `jq`, `yq`, `zoxide` have no entries — as documented in
[util_tools.md](./util_tools.md), none of them has a config file to
symlink. `gh` and `glab` are deliberately excluded too: both keep
credentials in the same directory (glab, in the very same file) as their
settings, so neither is safe to symlink into a public repo — see
[util_tools.md#gh](./util_tools.md#gh).

## Removing tools and integrations

Removing tool declarations does not uninstall existing binaries or delete
obsolete home-directory symlinks, plugin checkouts or saved sessions.
Those remain machine-local; this change updates the repository configuration.

## Zsh completion

`bootstrap:zsh-completion` runs `mise completion zsh --install`, which writes
the generated `_mise` function to
`~/.local/share/zsh/site-functions/_mise`. The file is machine-local generated
state rather than a tracked dotfile: mise owns its format and can refresh it
when mise itself changes.

`bootstrap:all` runs this task alongside the dotfile and plugin tasks
after installing locked tools, so a fresh machine needs only
`mise run bootstrap:all`. The matching
`fpath` entry lives in `shell/.zshrc` before Oh My Zsh loads; Oh My Zsh already
runs `compinit`, so bootstrap does not add a duplicate initialization.

## Zsh plugins

```toml
[bootstrap.repos]
"~/.oh-my-zsh" = { url = "https://github.com/ohmyzsh/ohmyzsh.git", ref = "master" }
"~/.oh-my-zsh/custom/plugins/zsh-autosuggestions" = { url = "...", ref = "v0.7.1" }
"~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" = { url = "...", ref = "0.8.0" }
"~/.oh-my-zsh/custom/plugins/you-should-use" = { url = "...", ref = "1.11.1" }
```

`ref` pins the Zsh plugins to real tags — reproducible, matching this repo's general "always lock"
stance. oh-my-zsh itself has no tagged releases (it's designed to track
`master` via its own self-update mechanism), so it's pinned to `master`
rather than a specific commit — the one entry here that's a rolling
reference rather than a fixed one.

`bootstrap:plugins` applies these repositories through native mise provisioning.
The former `bootstrap:zsh-plugins` task remains as a compatibility alias.

## macOS apps

`mise/config.macos.toml` declares Kitty, Zed and both Nerd Fonts under
`[bootstrap.packages]` using `brew-cask:`. Apply all four with:

```sh
mise run global:apps:install
```

`mise run bootstrap:all` includes this task on macOS. Loading the config or
running `mise install --locked` does not install apps. Mise installs these
casks directly; Homebrew is not required. Existing Homebrew-owned casks are
recognized and left under Homebrew management.
App/font versions are separate from mise's tool lockfiles.
The Kitty and Zed configs use the ordinary `[dotfiles]` entries; see
[desktop tools](./desktop_tools.md).

## Checking the current machine

Run `mise run bootstrap:status` for the authoritative view of which declared
targets are live symlinks into this repo. Repository changes never apply or
replace home-directory files automatically.

The lockfile target needed `--force` on the way there because it was
*occupied* by a real file rather than absent:

| Target                        | What was in the way                                                                                                      |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `~/.config/mise/mise.lock`    | a lockfile mise generated itself before this repo declared the entry, since drifted (see below)                          |

The `mise.lock` case is the instructive one: the machine's own lockfile was
*not* a copy of this repo's — it was missing `gh` and `glab` and
still carried entries from the older repo. That drift is precisely the
failure mode the `[dotfiles]` entry exists to prevent.

An occupied target is a different problem from a conflicting *declaration*
(next section), and `--force` only resolves the former.

### A conflict that had to be cleared first (resolved)

`mise bootstrap dotfiles status`/`apply` read the **real, live**
`~/.config/mise/config.toml` when merging declarations —
`MISE_GLOBAL_CONFIG_FILE` does *not* redirect that, unlike ordinary
tool-config resolution. Before this repo was applied, that file was a
symlink into `~/dev/dotfiles2` and carried its own `[dotfiles]` table
declaring nearly every path this repo also declares. mise reports that as
`conflicting dotfile declarations`, one target at a time, and **`--force`
does not help**: `--force` only overrides a real file or directory
occupying a target, whereas two configs declaring the same target is a
different error that can only be fixed by removing the losing declaration.
Deleting that old table was the fix. `~/.config/mise/config.toml` now
symlinks to this repo's `mise/config.toml`, which declares no `[dotfiles]`
at all — the tables live in the repo-root `mise.toml` instead, so the
global config can never conflict with itself this way again.

### One-time migration from the old repo

An earlier setup may still have `config.macos.toml` and `miserc.toml` symlinks
pointing into `~/dev/dotfiles2`. They are active configuration, not inert
leftovers: the old macOS file carries duplicate `[dotfiles]` entries for:

```text
~/Library/Application Support/k9s/config.yaml                  ← config.macos.toml
~/Library/Application Support/k9s/skins/catppuccin-mocha.yaml  ← config.macos.toml
~/Library/Application Support/lazygit/config.yml               ← config.macos.toml
```

This repo deliberately uses the XDG paths instead. Replace the two live old
symlinks with the tracked files, then apply the newly added lockfile:

```sh
mise bootstrap dotfiles apply --force \
  ~/.config/mise/config.macos.toml \
  ~/.config/mise/miserc.toml
mise bootstrap dotfiles apply ~/.config/mise/mise.macos.lock
```

The `*.backup.<timestamp>` symlinks are ignored by mise and can be removed
separately after verifying they are no longer needed.
