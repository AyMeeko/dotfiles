# Dotfiles with chezmoi

Personal configuration for two Omarchy machines. Ubuntu WSL setup is planned
later; macOS is not currently supported. This repo also holds reference material
that is not deployed.

## Layout

The root `.chezmoiroot` selects `home/` as the managed source tree. Files such as
`home/dot_zshrc` and `home/dot_config/nvim/init.lua` become regular files at
`~/.zshrc` and `~/.config/nvim/init.lua`. They are **not symlinks** back to Git.
Root documentation, `karabiner/`, and the two unused `omarchy/` art files are
reference-only. The active screensaver lives at
`home/dot_config/omarchy/branding/screensaver.txt`.

| Configuration | Omarchy | Reserved WSL role |
| --- | --- | --- |
| Zsh, Neovim, tmux, OpenCode, custom Zsh theme | Yes | Shared base only; unverified |
| Ghostty, terminal preference, screensaver branding | Yes | Excluded |
| Internal KMonad keymap and user service | Required device path | Excluded |
| External KMonad keymap and user service | If external device path supplied | Excluded |

Other files in `~/.config`, including Omarchy branding and systemd user units,
are preserved. Chezmoi does not automatically install packages, change `/etc`,
or enable/restart services.

## New Omarchy machine

1. Install `chezmoi` using your package manager, plus the programs you want to use.
   The shell uses Zsh, oh-my-zsh, fzf, optional mise/direnv, and optional Arch
   Zsh completion/highlighting/autosuggestion packages. Install Git, Ghostty,
   tmux, OpenCode, and the [Neovim prerequisites](nvim-setup.md) as needed.
   Install KMonad at `/usr/bin/kmonad`; see the [KMonad guide](kmonad/kmonad_setup.md).
2. Find the internal keyboard's stable `/dev/input/by-id/` or `/dev/input/by-path/`
   path. External keyboard input is optional; leave it empty when not needed.
3. Once the chezmoi migration is published to the default branch, initialize:

   ```sh
   chezmoi init https://github.com/AyMeeko/dotfiles.git
   ```

   Choose `omarchy` and provide this machine's keyboard paths. The generated
   `~/.config/chezmoi/chezmoi.toml` stores `role`, `kmonadInternalDevice`, and
   `kmonadExternalDevice` under `[data]`. These values are machine-local, not
   committed to Git. There is no default keyboard path copied from another host.
   The default checkout is `~/.local/share/chezmoi`.
4. Inspect and apply:

   ```sh
   chezmoi diff
   chezmoi apply --dry-run --verbose
   chezmoi apply --interactive
   chezmoi diff
   ```

5. Install the tmux theme dependency manually:

   ```sh
   mkdir -p ~/.config/tmux-plugins/catppuccin
   git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux-plugins/catppuccin/tmux
   ```

6. Configure uinput permissions and enable KMonad deliberately using its guide.
   Open a fresh terminal; restart OpenCode to load its deployed configuration.
   SSH keys, application authentication (`gh auth login`, etc.), runtime installs,
   and fonts remain manual setup tasks.

The `wsl` role only establishes an exclusion boundary today; it is not a finished
Ubuntu setup recipe. Its package, shell and clipboard integration will follow.

## Migrating an existing symlink-based setup

Before switching to the new layout, preserve the old checkout and its local edits:

1. Inspect `git status` in the old repo and `readlink` for `~/.zshrc`, `~/.dotfiles`,
   and `~/.config/{ghostty,nvim,omz-custom,opencode,tmux}`. Save both modified and
   **untracked** files. Snapshot the linked directories' contents to a backup
   outside the old repo, the new chezmoi checkout and the destination directories.
   Record each link's exact original target for rollback.
2. Initialize chezmoi **without** `--apply`. Do not overwrite the existing old
   checkout or remove it while programs/services still use it.
3. Unlink only paths confirmed to be legacy links. For example, after backing up
   `~/.config/nvim`:

   ```sh
   test -L ~/.config/nvim && unlink ~/.config/nvim
   ```

   Repeat for the other legacy app links and linked `~/.zshrc`. This removes the
   link, not the old repo's files. Leave real directories and unrelated files alone.
   Karabiner is no longer deployed; retaining or retiring its old link is up to you.
   Never recursively delete the old link targets.
4. Run `chezmoi diff`, a verbose dry run, and `chezmoi apply --interactive`.
   Chezmoi creates ordinary directories/files. Reconcile backed-up local settings
   before accepting replacements; do not blindly force a conflict. Retire
   `~/.dotfiles` only after the new tmux workspace helper is deployed (it discovers
   the source with `chezmoi source-path`).
5. Check app behavior and follow the KMonad guide to update the running units.
   Keep the original checkout until both units no longer reference it.

Rollback: move the newly created managed files/directories aside and restore the
recorded links and saved unit files. Reload systemd manually if reverting units.
The independent backup and untouched old checkout retain your local data.

## Daily workflow

```sh
chezmoi edit ~/.zshrc            # edit managed source
chezmoi diff
chezmoi apply
chezmoi cd                     # enter the Git source checkout
git status                     # commit/push intentional changes as usual
```

For edits made directly in `~/.config`, capture them intentionally with
`chezmoi re-add <target>` or merge them before applying. For templated KMonad
files, edit the source templates instead of re-adding rendered machine paths.
`chezmoi add <new-target>` adds a user file to management. Review the source diff
before committing any machine-specific state. `chezmoi update` pulls and applies
upstream changes; use `chezmoi git pull` followed by `chezmoi diff`/`apply` when you
want to inspect first. Use `chezmoi edit-config` to change local keyboard paths;
rerunning `chezmoi init` preserves previously supplied values.

Removing an external device path stops managing its files but **does not remove
previously deployed files or disable an enabled service**. Disable the old unit
manually and archive/remove its old keymap/unit if retiring that keyboard.

## Verification / working on this migration

```sh
bash tests/chezmoi-smoke.sh kmonad
```

Requires chezmoi, Python 3.11+, and KMonad. Tests exercise both desktop device
profiles, the WSL exclusion boundary, init/re-init, copied-file deployment,
permissions, repeat apply, conflict handling and backup/unlink migration, all in
temporary homes with isolated config/state/cache. KMonad runs in parsing-only
`--dry-run` mode; no keyboard is grabbed and no service is restarted.

For a local unpublished checkout, use `chezmoi --source "$PWD" init` and continue
passing `--source "$PWD"` for diff/apply (prefer a temporary config/destination
while developing). Do not initialize the published remote expecting these
uncommitted migration files until they have been integrated and published.
