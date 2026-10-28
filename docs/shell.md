# Shell environment and IDEs

The three files map individually to **`~/.zshenv`**, **`~/.zprofile`**, and
**`~/.zshrc`**, directly in `$HOME` rather than under XDG. This setup does not
set `ZDOTDIR`; if a machine sets it elsewhere, Zsh looks for the files there.

`.zshenv` supplies the minimal environment for every Zsh invocation, including
non-interactive SSH commands used to start Zed's remote server. It adds the
existing `~/.local/bin` directory to `PATH`, where the standard mise installer
puts `mise`, and deduplicates the path. Appending preserves any project tool
directories already selected by `mise exec`. It starts no processes, prints
nothing, and does not load prompt plugins, project tools, or interactive hooks.

`.zprofile` follows mise's official IDE integration: it evaluates
`mise activate zsh --shims` for login shells. Shims resolve a tool against the
current project's config when the executable is invoked, so GUI editors can
find project tools without an interactive prompt hook. This is the upstream
approach for editors including VS Code and JetBrains IDEs; Zed also loads a
project shell environment. Shims prepare the tool process, not the entire
editor's environment. See [mise's IDE guide](https://mise.jdx.dev/ide-integration.html)
and [shims setup](https://mise.jdx.dev/dev-tools/shims.html#add-shims-to-path).

The profile sources `~/.zprofile.local` first for machine-local login setup.
If an existing `.zprofile` contains package-manager initialization or other
local settings, preserve those in `.zprofile.local` or merge deliberately
before provisioning the shared profile. Bootstrap does not force replacement.

`.zshrc` activates the interactive "shell integration" pieces documented
across [util_tools.md](./util_tools.md) and [core_tools.md](./core_tools.md)
for individual tools. Getting these files (and oh-my-zsh plus its custom
plugins) actually onto a machine is [bootstrap.md](./bootstrap.md)'s job,
not the startup files' job.

The division is deliberate: minimal executable discovery for non-interactive
SSH, official shims for IDEs, full activation for interactive terminals, and
explicit `mise exec` for scripts and Git hooks. No editor-specific wrapper,
project path, or pinned executable path is embedded in the shell startup files.

## Zed Remote and Git hooks

An SSH command can start non-interactive Zsh, which reads `.zshenv` but not
`.zshrc`. Without the minimal PATH, a remote Git hook launching `mise x -- hk
run pre-commit --from-hook` can fail with `zsh: command not found: mise` even
when mise works in an interactive terminal. This failure happens before mise
can load the project's tools and `[env]`; changing Zed's local terminal
settings does not fix the remote server's environment. See
[Zsh startup files](https://zsh.sourceforge.io/Doc/Release/Files.html) and
[Zed Remote Development](https://zed.dev/docs/remote-development).

Apply the startup files on the affected machine, from its updated dotfiles
checkout after preserving any existing local profile settings:

```sh
"$HOME/.local/bin/mise" bootstrap dotfiles apply --yes '~/.zshenv' '~/.zprofile' '~/.zshrc'
```

Mise must already be installed on that machine. If it lives somewhere other
than `~/.local/bin`, make that installation directory available to the remote
shell instead. If `~/.zshenv` already exists, merge the PATH entry into it or
resolve the provisioning conflict; do not overwrite machine-local settings.
Restart Zed's remote server/reconnect after applying the file so Git inherits
the corrected PATH. Each project still needs its own trusted mise config,
installed tools, and hk hook. `mise exec` resolves that project's environment
from the Git working directory; no interactive mise activation is needed.
`hk install --mise` is the upstream-supported per-project hook installation;
it makes the hook use `mise x` to load the project's tools and `[env]`. The
installer still needs mise available on the hook's runtime PATH for this
installation mode. See [hk's mise integration](https://hk.jdx.dev/mise_integration.html).

This change has not been deployed or verified on the affected SSH host.

## What's configured

- `export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"` near the
  top. This isn't cosmetic — several things in this repo depend on it:
  [fzf](./util_tools.md#fzf) and [ripgrep](./util_tools.md#ripgrep) only
  auto-discover their config files via `$XDG_CONFIG_HOME`-based env vars
  (below); and it's what resolves the exceptions documented for
  [k9s](./core_tools.md#k9s) and [Go's own env file](./langs.md#go), both of
  which default to `~/Library/Application Support/...` on macOS specifically
  when this variable isn't set.
- `path+=(...)` for `~/.local/bin`, `~/bin`, `~/go/bin` (only if the
  directory exists), deduped via `typeset -U path PATH`.
- After mise activation, `EDITOR` is `zed --wait` when `zed` is on `PATH`,
  otherwise system `vi`; `VISUAL` follows `EDITOR`. Zed's
  [`--wait`](https://zed.dev/docs/reference/cli#-w---wait) keeps commands such
  as Git waiting until the edited file is closed. This checks availability,
  not whether a graphical session is usable: if a headless SSH server has
  the full `zed` CLI installed, override both variables to `vi` in
  `~/.zshrc.local`. Zed's headless server alone does not supply that CLI.
- `TERM` fallback to `xterm-256color` if the current `$TERM` has no
  terminfo entry available (e.g. SSH'ing somewhere that doesn't know
  `xterm-kitty`) instead of hardcoding a terminal-specific `TERM`.
- Startup follows its dependency order: base environment and `PATH`, mise
  activation and completion path, oh-my-zsh, native Zsh history, starship, zoxide, fzf,
  tool aliases/helpers, and finally `.zshrc.local` for machine-local
  overrides. Mise must precede the guarded tool checks; oh-my-zsh initializes
  completion before zoxide and fzf.
  `$ZSH_THEME` remains empty because starship owns the prompt. Every optional
  component is individually guarded by `command -v`/`[[ -r ... ]]`, so the
  setup degrades cleanly on a machine missing some tools.
- `mise run bootstrap:zsh-completion` installs mise's generated Zsh completion
  under `~/.local/share/zsh/site-functions` and is included in the one-command
  `mise run bootstrap:all` flow. The task runs
  `mise completion zsh --install`, which is idempotent and refreshes the
  generated `_mise` file when needed. `.zshrc` adds its directory to `fpath`
  before oh-my-zsh runs `compinit`, so a second explicit `compinit` is neither
  needed nor desirable.
- `zsh-syntax-highlighting` is sourced last, after `.zshrc.local` — required
  by its own upstream docs to load after every other widget/hook is
  registered.
- In the eza block: `unset LS_COLORS`. eza prefers `LS_COLORS`/`EZA_COLORS`
  over its own `theme.yml` for file-kind colors, with no warning, if either
  is set — see [util_tools.md#eza](./util_tools.md#eza). Unsetting it here
  keeps eza's Catppuccin theme in effect regardless of what the wider
  environment sets.
- `export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/config"`, guarded as
  `[[ -r "$XDG_CONFIG_HOME/fzf/config" ]] && export ...` — fzf hard-fails
  (exit `2`) if this points to a file that doesn't exist, unlike ripgrep
  below, so the export only fires when the file is actually readable.
- `export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"`, unguarded
  — ripgrep degrades gracefully on a missing file (a stderr warning, still
  exits `0`), so no existence check is needed.
- `unset FZF_CTRL_R_COMMAND` removes the previous exported opt-out, even
  when inherited from a parent shell. fzf's init (`source <(fzf --zsh)`)
  binds `Ctrl-R` to `fzf-history-widget` in the emacs, vi insert and vi
  command keymaps. `Ctrl-F` remains a shortcut to the same widget.
- `za work` uses `zellij attach --create work` outside Zellij and
  `zellij action switch-session work` inside it, switching the current client
  without nesting another Zellij. Inside a session, bare `za` opens the
  floating session manager; outside, it keeps native attach/create behavior.
  Quote names containing spaces, e.g. `za "new session"`. Reloading this file
  removes the former `za` alias before defining the function.
  `zs` (`zellij -l welcome`) opens the welcome screen from outside Zellij;
  see [core tools](./core_tools.md#zellij).

## Native Zsh history

`HISTFILE="$HOME/.zsh_history"` keeps history in Zsh's standard file.
`HISTSIZE=200000` retains up to 200,000 events in memory and
`SAVEHIST=100000` saves up to 100,000 to disk. These settings follow
oh-my-zsh so they take precedence over its defaults, and also work when
oh-my-zsh is absent.

`EXTENDED_HISTORY` records timestamps and durations; `SHARE_HISTORY` appends
commands and imports history from other shells. `HIST_EXPIRE_DUPS_FIRST`
expires duplicate events first, `HIST_IGNORE_DUPS` skips consecutive
duplicates, `HIST_IGNORE_SPACE` excludes commands beginning with a space,
and `HIST_VERIFY` lets you review history expansions before running them.

`Ctrl-R` and `Ctrl-F` open fzf's history picker. Enter places the selected
command on the command line for editing; a second Enter executes it. Up
and Down retain Zsh/oh-my-zsh's normal history navigation.

After switching history integrations, run `exec zsh` to start a fresh shell
with the new hooks and bindings. Existing `~/.zsh_history` entries are read
by Zsh normally.

## Validation

`shellcheck --shell=bash` covers all three startup files (`zshrc-check` in
`hk.pkl`) — shellcheck has no zsh dialect, but `bash` mode produces zero
false positives against this file's zsh-specific syntax (`path+=`,
`typeset -U`, etc.) with a scoped `SC2034` suppression for `SAVEHIST`,
which Zsh reads internally. It still catches real issues, such as a plain
(non-exported) variable assignment that's only read by a dynamically
sourced script. `SC1090`/`SC1091` ("can't follow this source") are excluded
in `zshrc-check` — unavoidable noise for an rc file that legitimately
sources dynamic/generated content (oh-my-zsh, `.zshrc.local`, fzf's own
init).

`shellcheck` is a repo-local tool (`mise.toml`, not the global config) —
it's for linting this repo's own shell script, not something the user runs
directly day to day.

The 2026-10-15 native history setup was checked with real Zsh and fzf in a
PTY using a temporary home and synthetic history. `Ctrl-R` resolved to
`fzf-history-widget` in emacs, vi insert and vi command keymaps, including
with the previous empty `FZF_CTRL_R_COMMAND` inherited. `Ctrl-F` and the
history options were verified too. Selecting a saved command inserted it
into the editable buffer; the following Enter executed it. Zsh syntax,
ShellCheck, TOML, YAML, Markdown and repository hygiene checks passed.
