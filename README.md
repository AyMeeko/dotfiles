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
are preserved. With `setupEnabled = true`, chezmoi also installs dependencies,
configures the login shell and KMonad permissions, and enables keyboard services.

## New Omarchy machine

After installing Omarchy and connecting to the internet, run these two commands
in a terminal **as your normal user**:

```sh
curl -fsSLo /tmp/dotfiles-bootstrap.sh https://raw.githubusercontent.com/AyMeeko/dotfiles/chezmoi-migration/bootstrap.sh
bash /tmp/dotfiles-bootstrap.sh
```

The bootstrap uses the `chezmoi-migration` branch, where this setup currently
lives. After merging it, update that branch default in `bootstrap.sh` and the
download URL together. To use an existing checkout, run `bash bootstrap.sh`
from this repository instead. It records that checkout as chezmoi's source;
downloaded bootstraps use `~/.local/share/chezmoi`.

The setup automatically:

- Installs chezmoi and the required Arch packages, including Zsh enhancements,
  Ghostty, tmux, Neovim/build tools, KMonad, direnv, and a Nerd Font.
- Detects stable keyboard paths: Dygma first, then a platform/laptop keyboard,
  then USB. The next distinct USB keyboard becomes the external keyboard.
- Saves these paths, the `omarchy` role, and `setupEnabled = true` in local
  `~/.config/chezmoi/chezmoi.toml`; no device identity is committed.
- Backs up existing application configs to
  `~/.local/share/dotfiles-backups/<timestamp>/configs.tar.gz`. A stock LazyVim
  config is moved into that backup so its auto-loaded plugins cannot conflict.
- Applies the dotfiles, installs oh-my-zsh and Catppuccin tmux v2.1.3, and installs
  Ruby 3.4.10 via mise if no Ruby is configured already.
- Installs/restores the Neovim plugins from `lazy-lock.json`, baseline Treesitter
  parsers, and the four Mason-managed LSP servers, waiting for completion.
- Sets Zsh as the login shell, configures `/etc` uinput rules/module loading and
  `input` group membership, validates keymaps/units, and enables both configured
  KMonad services. Caps Lock becomes tap-Escape/hold-Control.

Authenticate when sudo requests your password. Log out and back in after setup,
and restart OpenCode to load its configuration. This restores your configured
user environment on top of Omarchy; OS installation, hardware-specific drivers,
SSH private keys, account logins, and project repositories/data remain separate.
GitHub/OpenCode authentication cannot be reconstructed from public dotfiles.

For different keyboards, override detection on the second command:

```sh
KMONAD_PRIMARY=/dev/input/by-path/platform-i8042-serio-0-event-kbd \
KMONAD_SECONDARY=/dev/input/by-id/your-keyboard-event-kbd \
bash /tmp/dotfiles-bootstrap.sh
```

On subsequent runs, existing local values are retained; use `chezmoi edit-config`
to change them. Only two keyboards are configured. If no physical keyboard can
be detected, bootstrap stops and asks for `KMONAD_PRIMARY`.

To deploy files without installing packages/changing system settings, initialize
manually with `chezmoi init https://github.com/AyMeeko/dotfiles.git`, supply the
keyboard paths, and answer **no** to “Install dependencies and activate services”.
Then inspect `chezmoi diff` and `chezmoi apply --dry-run --verbose` before applying.

## Setup lifecycle

`run_once_before_05-*` backs up existing config before deployment.
`run_onchange_before_10-*` installs system dependencies and permissions when that
script or its rendered device inputs change. `run_once_after_20-*` installs user
dependencies once; a failed run is retried by `chezmoi apply`.
`run_onchange_after_30-*` validates and restarts keyboard services when their
keymap, units, or device paths change. A routine repeat apply does not reinstall
plugins or restart services. Changing a run-once script causes its new content
to run once again.

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
python tests/bootstrap-smoke.py
```

Requires chezmoi, Python 3.11+, and KMonad. Tests exercise both desktop device
profiles, the WSL exclusion boundary, init/re-init, copied-file deployment,
permissions, repeat apply, conflict handling and backup/unlink migration, all in
temporary homes with isolated config/state/cache and `setupEnabled = false`.
Enabled setup scripts are rendered and syntax-checked without execution; bootstrap
wiring uses mocked commands. KMonad runs in parsing-only `--dry-run` mode; no
keyboard is grabbed and no service is restarted by the tests.

For a local unpublished checkout, use `chezmoi --source "$PWD" init` and continue
passing `--source "$PWD"` for diff/apply (prefer a temporary config/destination
while developing). Do not initialize the published remote expecting these
uncommitted migration files until they have been integrated and published.
