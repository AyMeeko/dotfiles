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
| 1Password SSH client, agent environment, desktop autostart | Yes | Excluded |
| Hyprland pointer settings and ultrawide window presets | Yes | Excluded |

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
  KMonad services. Caps Lock becomes tap-Escape/hold-Control; Command/Super and
  Option/Alt are swapped on both the left and right sides of both keyboards.
- Installs the 1Password desktop app, `op` CLI and OpenSSH, configures SSH to use
  the 1Password agent, starts the app at login, and opens its Developer settings
  if the agent isn't enabled yet.

Authenticate when sudo requests your password. Log out and back in after setup,
and restart OpenCode to load its configuration. This restores your configured
user environment on top of Omarchy; OS installation, hardware-specific drivers,
account logins and project repositories/data remain separate. SSH keys stored
in 1Password become available after authorizing its agent as described below.
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

## Ultrawide window presets

These shortcuts match the physical macOS modifier keys, using the KMonad swap
(Option = Super, Command = Alt):

| Physical shortcut | Preset |
| --- | --- |
| Shift + Option + Command + H | Large left half |
| Control + Option + Command + F | Small center |
| Shift + Option + Command + K | Large center |
| Shift + Option + Command + L | Large right half |

On a 3840×1600 monitor with the top bar, the large center is approximately
2250×1542, the small center 1620×1156, and each half 1125×1542. The large presets
leave 16-pixel margins above/below the usable area. Left/right halves
occupy the two halves of the **centered large region**, not halves of the screen.
The presets use the active window's monitor, respect display scaling and panel
reservations, and scale to fit other monitor sizes. Applying one exits fullscreen
and makes the window floating. Use Super+T (physical Option+T) to return to tiling.

Bindings live in `home/dot_config/hypr/bindings.lua`. To tune sizes, edit
`LARGE_HEIGHT_FRACTION`, `LARGE_ASPECT_RATIO`, `SMALL_WIDTH_SCALE`, and
`SMALL_HEIGHT_SCALE` in
`home/dot_config/hypr/window-presets.py`, then run `chezmoi apply`.

## Setup lifecycle

`run_once_before_05-*` backs up existing config before deployment.
`run_onchange_before_10-*` installs system dependencies and permissions when that
script or its rendered device inputs change. `run_once_after_20-*` installs user
dependencies once; a failed run is retried by `chezmoi apply`.
`run_onchange_after_30-*` validates and restarts keyboard services when their
keymap, units, or device paths change. A routine repeat apply does not reinstall
plugins or restart services. Changing a run-once script causes its new content
to run once again.

## SSH keys through 1Password

The bootstrap installs everything needed; it does not require `op` or 1Password
to be installed or signed in beforehand. `~/.ssh/config` points OpenSSH at
`~/.1password/agent.sock`, and Zsh plus the systemd user environment set
`SSH_AUTH_SOCK` for tools such as `ssh-add`. 1Password starts at desktop login.
`ssh-start` now lists the agent's keys instead of loading `~/.ssh/aymeeko`.

On each fresh machine, complete the account authorization in the 1Password app:

1. Sign in to your existing 1Password account.
2. In **Settings > Developer**, enable **Use the SSH Agent**.
3. To use `op` with desktop authentication, enable **Unlock using system
   authentication** under **Security**, and **Integrate with 1Password CLI**
   under **Developer**.

These are 1Password's required app authorization steps; its CLI does not provide
a supported command to turn those settings on. The bootstrap opens the Developer
settings if the socket is absent and continues applying the rest of the setup.
Private keys stay in 1Password rather than being exported into files or Git.
All active **SSH Key** items in your Personal, Private, or Employee vaults are
available by default. Existing keys must be saved as SSH Key items, not just
text fields or attachments. Their public keys must already be authorized on
GitHub or the servers you connect to.

In a fresh terminal, verify:

```sh
ssh-start                  # list available key fingerprints
op signin                  # connect the CLI to your desktop account
op vault list              # authenticate the CLI through the desktop app
ssh -T git@github.com       # authorize the request in 1Password
```

GitHub's successful SSH test prints an authentication greeting and exits with
status 1 because it doesn't provide shell access. HTTPS Git remotes still use
HTTPS authentication; use an SSH remote (e.g. `git@github.com:AyMeeko/dotfiles.git`)
when you want Git to authenticate through this agent. The initial public dotfiles
clone uses HTTPS so setup works before you've signed in to 1Password.

Put host-specific overrides in `~/.ssh/config.d/*.conf`, which is included before
the default agent setting. For multiple keys/accounts or more than six keys,
select a host's key with a **public** `IdentityFile` and `IdentitiesOnly yes`.
Custom/shared vaults can be selected later using
`~/.config/1Password/ssh/agent.toml`; your Personal/Private vaults need no such file.

References: [SSH agent](https://developer.1password.com/docs/ssh/agent/) and
[CLI app integration](https://developer.1password.com/docs/cli/app-integration/).

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
python -B tests/window-presets.py
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
