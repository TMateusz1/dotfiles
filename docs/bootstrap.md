# Bootstrap (symlinks + zsh plugins)

How this repo actually gets applied to a machine, via mise's own native
`[dotfiles]` and `[bootstrap.repos]` — not a hand-rolled install script.
Declared in the repo-root `mise.toml`. **Nothing here runs automatically**
— not on `mise install`, not via any hook. It's applied explicitly:

```sh
cd ~/dev/dotfiles          # or wherever this repo is cloned
mise run bootstrap:status     # what would change — read-only
mise run bootstrap:dry-run    # preview the dotfile symlinks specifically
mise run bootstrap:dotfiles   # apply symlinks — see "What gets symlinked" below
mise run bootstrap:zsh-plugins  # clone/update oh-my-zsh + its 3 custom plugins
mise run bootstrap:all        # both of the above, in one go
```

The tasks are thin wrappers (`mise tasks ls` for the full list) — nothing
they run couldn't be typed out as plain `mise bootstrap dotfiles ...`/
`mise bootstrap repos ...` commands; they just save re-typing the longer
form. Both are idempotent (safe to re-run) and refuse to clobber a real
pre-existing file/directory at any target without `--force`.

## Why mise's own feature, not a script

`mise bootstrap` is a whole declarative provisioning subsystem (accounts,
packages, files, services, repos, dotfiles, ...). We only use two pieces of
it — `[dotfiles]` and `[bootstrap.repos]` — but using them means every
"deferred" placement decision documented across
[util_tools.md](./util_tools.md)/[core_tools.md](./core_tools.md) (tmux's
`~/.tmux.conf`, starship's flat `~/.config/starship.toml`, `shell/.zshrc`
→ `~/.zshrc`) is just an ordinary target/source pair — no special-casing
logic needed, and no restructuring of this repo's existing directory names.

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
"~/.zshrc" = "shell/.zshrc"
"~/.tmux.conf" = "tmux/.tmux.conf"
"~/.config/starship.toml" = "starship/starship.toml"
"~/.config/git" = "git"
"~/.config/atuin" = "atuin"
"~/.config/bat" = "bat"
"~/.config/eza" = "eza"
"~/.config/fzf" = "fzf"
"~/.config/ripgrep" = "ripgrep"
"~/.config/lazygit" = "lazygit"
"~/.config/k9s" = "k9s"
```

Directory entries (`git`, `atuin`, `bat`, ...) symlink the *whole*
directory in one line — e.g. `"~/.config/git" = "git"` brings
`git/config` and `git/delta.gitconfig` along together, since
`git/config`'s own `[include]` already wires in delta. Nothing extra is
needed for delta specifically.

`fd`, `jq`, `yq`, `zoxide` have no entries — as documented in
[util_tools.md](./util_tools.md), none of them has a config file to
symlink.

## Zsh plugins

```toml
[bootstrap.repos]
"~/.oh-my-zsh" = { url = "https://github.com/ohmyzsh/ohmyzsh.git", ref = "master" }
"~/.oh-my-zsh/custom/plugins/zsh-autosuggestions" = { url = "...", ref = "v0.7.1" }
"~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" = { url = "...", ref = "0.8.0" }
"~/.oh-my-zsh/custom/plugins/you-should-use" = { url = "...", ref = "1.11.1" }
```

`ref` pins each plugin to a real, current tag (checked directly against
each repo) — reproducible, matching this repo's general "always lock"
stance. oh-my-zsh itself has no tagged releases (it's designed to track
`master` via its own self-update mechanism), so it's pinned to `master`
rather than a specific commit — the one entry here that's a rolling
reference rather than a fixed one.

## Verified without touching this machine

`mise bootstrap dotfiles status`/`apply` read the **real, live**
`~/.config/mise/config.toml` for merging — `MISE_GLOBAL_CONFIG_FILE`
does *not* redirect this away from it, unlike ordinary tool-config
resolution. So this was validated two ways, neither touching this
machine's real files:

1. Confirmed the schema is well-formed by declaring structurally identical
   `[dotfiles]`/`[bootstrap.repos]` entries in a fully isolated sandbox
   (throwaway `HOME`, throwaway sources) and running `mise bootstrap
   dotfiles status` / `apply --dry-run` / `bootstrap repos status` there —
   correct source resolution, correct planned `ln -sf` commands, correct
   repo tracking.
2. Actually ran `mise bootstrap dotfiles status` against the real
   machine, read-only, to sanity-check integration — and it surfaced a
   real conflict (see below), which is exactly the kind of thing this
   step exists to catch.

**Found, not fixed — needs your decision:** this machine's *real* global
mise config already has a `[dotfiles]` entry for `~/.config/git` (source
resolving to `~/.config/git/delta.gitconfig`), predating this repo's own
entry for the same target and conflicting with it. Likely a leftover from
earlier experimentation with `dotfiles.root`/`dotfiles.default_mode`
(already set in that same real config, pointing at `~/.dotfiles`, not this
repo). Not touched — reconciling or removing that old entry is a call
about your live machine config, not this repo.
