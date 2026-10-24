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
  Ghostty, Vivaldi, tmux, Neovim/build tools, KMonad, direnv, and a Nerd Font.
- Sets Vivaldi as the default web browser, used by Omarchy's Browser and
  Browser (private) hotkeys and when opening web links.
- Detects stable keyboard paths: Dygma first, then a platform/laptop keyboard,
  then USB. The next distinct USB keyboard becomes the external keyboard.
- Saves these paths, the `omarchy` role, and `setupEnabled = true` in local
  `~/.config/chezmoi/chezmoi.toml`; no device identity is committed.
- Backs up existing application configs to
  `~/.local/share/dotfiles-backups/<timestamp>/configs.tar.gz`. A stock LazyVim
  config is moved into that backup so its auto-loaded plugins cannot conflict.
- Applies the dotfiles, installs oh-my-zsh and Catppuccin tmux v2.1.3, and installs
  Ruby 3.4.10 via mise if no Ruby is configured already.
- Configures your global Git commit identity and routes GitHub HTTPS pushes
  through the 1Password-backed SSH client.
- Installs/restores the Neovim plugins from `lazy-lock.json`, baseline Treesitter
  parsers, and the four Mason-managed LSP servers, waiting for completion.
- Sets Zsh as the login shell, configures `/etc` uinput rules/module loading and
  `input` group membership, validates keymaps/units, and enables both configured
  KMonad services. Caps Lock becomes tap-Escape/hold-Control; Command/Super and
  Option/Alt are swapped on both the left and right sides of both keyboards.
- Installs the 1Password desktop app, `op` CLI and OpenSSH, configures SSH to use
  the 1Password agent, starts the app at login, and opens its Developer settings
  if the agent isn't enabled yet.
- Clones `AyMeeko/fonts` to `~/src/fonts` and installs missing font faces into
  `${XDG_DATA_HOME:-~/.local/share}/fonts/aymeeko`, refreshing the font cache.
  Existing system/user font faces are skipped, including duplicate OTF/TTF copies.
- Clones `AyMeeko/notes` to `~/notes`. Both personal repositories use SSH and
  require GitHub access through your 1Password SSH agent. If authentication fails,
  finish the 1Password steps below and rerun `chezmoi apply` to retry.

Authenticate when sudo requests your password. Log out and back in after setup.
OpenCode V2 reloads configuration automatically; `/reload` forces a full reload.
This restores your configured
user environment on top of Omarchy; OS installation, hardware-specific drivers,
account logins and other project repositories/data remain separate. SSH keys stored
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

New normal application windows open floating in the **large center** preset.
Already-floating dialogs/utilities and fullscreen apps keep their normal rules.
The default lives in `home/dot_config/hypr/windows.lua` and uses the same
monitor-aware geometry as the shortcuts below.

Window outlines use muted blue-gray (`#585b70` active, `#313244` inactive),
with 8-pixel rounded corners. Customize these in `home/dot_config/hypr/looknfeel.lua`.

The screensaver starts after 10 minutes idle, and the screen locks after
15 minutes. These delays are configured in `home/dot_config/omarchy/shell.json`
under `idle`, in seconds; Omarchy hot-reloads the file after `chezmoi apply`.

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

## Weylus tablet/stylus mirroring

Omarchy bootstrap builds and installs the local `weylus-pinned` Arch package
from upstream commit `38a01a8f8e429500c7e9f67fc1c88ca37a4d1e93` (verified source
archive checksum). This includes upstream's iPadOS fractional-pointer fix
`69b4941`; the old AUR `weylus-bin` release rejects modern iPad input with
"Failed to parse message". The pinned package replaces conflicting Weylus
packages only after the build and regression test succeed.

Setup installs missing build/runtime dependencies, including Rust and TypeScript,
and uses Arch's shared FFmpeg rather than compiling a separate copy. The package
recipe and regression test live under `home/dot_local/share/dotfiles/weylus/`
and deploy to `~/.local/share/dotfiles/weylus/`. Builds run as your normal user;
only dependency/package installation requests sudo or graphical authorization.
Failed builds are retained under `~/.cache/dotfiles/weylus/` for diagnosis and
retried on the next apply. An already-installed matching version is skipped.
When updating the recipe, bump its package version/release and the expected
version in `run_once_after_24-weylus.sh.tmpl` together. As with other locally
built Arch packages, shared-library upgrades can require rebuilding the package.

Bootstrap also installs Wayland/PipeWire capture dependencies. The existing KMonad uinput rule and
`input` group membership also allow Weylus to generate pen/touch events; no
second, conflicting udev rule is installed. Log out and back in after a fresh
bootstrap to activate group membership.

Launch **Weylus** from the application launcher (or run `weylus`). Setup seeds
`~/.config/weylus/weylus.toml` with Wayland support enabled only if the file does
not exist. Existing settings are preserved; for an existing config, enable
Wayland/PipeWire support in Weylus yourself. The config, including any access
code, stays machine-local and is not deployed or committed. The launcher uses
saved settings without command-line overrides.

1. Set an **access code** in Weylus, then click **Start**.
2. On your tablet, open the displayed URL/QR code in a modern browser (Safari
   on iPad), with both devices on the same trusted network.
3. Select the PipeWire capture source and approve the desktop screen-sharing
   picker. Test pen pressure in an application that supports it, such as Krita.
4. Stop Weylus when finished. It does not autostart or run a background service.

Wayland support is experimental; per-window input mapping and cursor capture
have upstream limitations. Connections are **unencrypted**, even with an access
code. No firewall rules are changed automatically. If a firewall blocks the
tablet, allow TCP **1701** (both web and WebSocket) only from your trusted
tablet/network; do not expose these ports to the internet. This setup mirrors
an existing display, not a new virtual monitor.

### Optional UFW access from a trusted LAN

If the tablet's browser hangs before displaying Weylus, check `sudo ufw status
verbose`. With UFW active and incoming connections denied, explicitly opt in to
LAN access below. First use `ip -brief address` to identify the interface and
trusted subnet; **replace these example values for each machine/network**:

```sh
sudo ufw allow in on wlp3s0 from 192.168.0.0/24 to any port 1701 proto tcp comment 'Weylus web trusted LAN'
sudo ufw status verbose
```

These persistent rules allow only the specified source subnet on the specified
interface, not arbitrary internet clients. They are machine-local firewall state,
not automatically applied by chezmoi. Remove them with the same commands prefixed
with `sudo ufw delete allow` instead of `sudo ufw allow` when no longer needed.
The old 0.11.4 binary used a separate WebSocket port (9001); the pinned build
does not need that legacy rule.

Verify the setup logic without installing packages or starting a server:

```sh
python -B tests/weylus-smoke.py
```

## Sesh / tmux session switching

This restores the upstream sesh setup from the work dotfiles immediately before
commit `c30155c` introduced the personal fork. Bootstrap installs the normal AUR
`sesh-bin` package through `omarchy pkg aur add`; `zoxide` and `fd` are included in
the system dependencies. No fork, OpenCode plugin, or work-specific path is used.
The AUR installation runs as the normal user and can request sudo authorization;
failed setup is retried on the next apply. The reserved WSL role only deploys the
shared config; it does not install Arch packages.

| tmux shortcut | Action |
| --- | --- |
| Prefix + `t` | Open the fzf session picker (80% × 70%, preview at right) |
| Prefix + `K` | Return to the previous session with `sesh last` |
| Prefix + `J` | Toggle between notes and the previous session |
| Prefix + Shift + `R` | Rename the current session (prompt prefilled with its name) |

The picker initially lists unattached tmux sessions. Ctrl+A lists all sources,
Ctrl+T tmux, Ctrl+G configured sessions, Ctrl+X zoxide directories, and Ctrl+F
searches directories under home (two levels deep). Tab/Shift+Tab move selection.
**Ctrl+D kills the highlighted tmux session**, after revalidating it against the
live tmux source and using its exact name rather than prefix matching. Directory,
zoxide, and configured-session rows cannot be mistaken for a session to kill.
Escape/cancellation never connects to an empty selection.

`home/dot_config/sesh/sesh.toml` explicitly maps `notes` to `~/notes`, which the
personal-repositories setup clones. Zsh initializes zoxide so visited directories
populate its source; existing zoxide history is preserved. The helper lives at
`~/.config/tmux/sesh-picker.sh`. Existing shell and tmux workspace helpers remain.
Closing a session keeps the client in tmux when another session is available.
The left status bar displays the current session in a rounded Catppuccin segment;
the existing window list and right-side clock remain in place.

After applying, use Prefix + `r` to reload tmux and start a new shell (or source
`~/.zshrc`) to activate zoxide. Verify without opening a live picker or changing
user sessions:

```sh
python -B tests/sesh-smoke.py
```

The test mocks external picker/install actions, exercises real fzf placeholder
expansion on an isolated pseudo-terminal, and loads the real tmux config on a
disposable socket. It never kills or switches sessions on the user's server.

### Session persistence

Bootstrap installs **TPM**, **tmux-resurrect**, and **tmux-continuum** under
`~/.tmux/plugins/`. New clones start at pinned revisions; existing installations
and local edits are preserved, never automatically pulled or reset. TPM can
install/update plugins interactively with Prefix + Shift+I / Prefix + Shift+U.
Catppuccin remains separately pinned under `~/.config/tmux-plugins/`.

- **Prefix + Ctrl+S** saves the tmux environment manually.
- **Prefix + Ctrl+R** restores the last saved environment manually.
- Continuum saves every **15 minutes** and automatically restores on **tmux server
  startup**, not on an ordinary config reload. Keep the status line enabled:
  Continuum's save trigger is part of `status-right`. It loads last so the theme
  and clock do not overwrite that trigger.
- Login-time tmux autostart and pane-content capture are explicitly disabled.
  Resurrect restores layouts, working directories and its conservative supported
  program list—not arbitrary processes, unsaved application data, or account state.

Snapshots are machine-local and **not managed by chezmoi or committed to Git**.
Resurrect reuses `~/.tmux/resurrect/` when it already exists; otherwise it uses
`${XDG_DATA_HOME:-~/.local/share}/tmux/resurrect/`. Preserve those files separately
if moving machines. They can contain working paths and command arguments even
with pane capture disabled. Continuum avoids automatic saving/restoring when it
detects another tmux server, to keep distinct environments from overwriting saves.

Configuration-only deployments still work when plugins have not been installed.
Full Omarchy bootstrap installs them without launching/stopping a tmux server or
running a restore. Verify with:

```sh
python -B tests/tmux-plugins-setup.py
python -B tests/tmux-plugins-runtime.py
```

The setup test mocks Git and checks failed installs, repeat runs, conflicts and
state preservation. The runtime test requires the installed plugins and theme;
it copies them to a disposable home, directs all plugin tmux calls to its own
socket, and tests real save/autosave/startup-restore behavior. Continuum's
process-inventory query is simulated as a sole-server environment, and service
management calls are captured rather than sent to the live user manager. The test
also isolates the runtime directory/session bus. Actual process inspection and
persistence run normally. User sessions, services and snapshots are untouched.

## OpenCode

Chezmoi manages `home/dot_config/opencode/` as ordinary files, independent of any
work-dotfiles checkout. This setup targets **OpenCode V2**. Server configuration
lives in `opencode.json`; terminal preferences live in `cli.json` (not `tui.json`).
Existing OpenCode installations are respected; upgrading a V1 binary is separate.

- **BetterPlan** is the default planning-only agent; the built-in Plan is disabled.
  It can write notes under `~/notes/ai/`, not project code. Switch to **Build** to
  implement. **Investigate** is for research; Oracle, Librarian, code-reviewer, and
  OpenCode expert are supporting read-only agents.
- **Superpowers 6.4.2** is pinned to its release commit; **Plannotator 0.28.7** uses
  manual workflow. `/plannotator-review`, `/plannotator-annotate <path>`, and
  `/plannotator-last` open review only when requested. Review approval does not
  authorize implementation, commits, or pushes.
- Omarchy bootstrap installs the pinned Plannotator CLI with a verified release
  checksum if none exists. It downloads only the binary: no vendor installer may
  rewrite chezmoi-managed configs or add integrations. OpenCode installs package
  plugins on first load; network access is required. No separate runtime npm/Bun
  dependency installation is needed for the local plugins.
- Work MCP servers, corporate tools/rules, Jira routing, Herdr/sesh, and
  `git-dance` are intentionally excluded. Provider/account sign-in remains local.

### Work dossiers

Say **"start the opencode-port work"** or **"pick up opencode-port"** to select
`~/notes/ai/work/opencode-port/`. Dossiers use explicit descriptive slugs, not
ticket IDs or branch conventions, and may span repositories and sessions.

```text
~/notes/ai/work/<slug>/
  resume.md       # last-verified state, scope, next steps, durable pointers
  plan.md         # current plan, when needed
  research.md     # findings/evidence, when needed
  decisions.md    # decisions/rationale, when needed
  transient/sdd/  # disposable task/review packaging and recovery ledger
  archive/        # completed/superseded plans
```

Files are created lazily. Standalone plans without an active dossier go in
`~/notes/ai/plans/YYYY-MM-DD-<slug>.md`. No notes, account state, or dossier contents
are deployed by chezmoi. The notes repository is cloned separately during setup.
Superpowers artifacts are redirected outside project repos; a local plugin blocks
direct `.superpowers` writes and best-effort literal shell mutations. This is a
guardrail, **not a sandbox**: computed shell paths and symlinks can bypass it.
Preserve unique evidence/reusable tooling before cleaning up reviewed scratch.

### Sound notifications

The server-side `notification` plugin plays the same managed clips as the work
setup, using Linux `ffplay` from the bootstrap's `ffmpeg` dependency:

| Event | Sound |
| --- | --- |
| Main-session completion | `~/.config/opencode/sounds/jobs_done.mp3` |
| Main-session question | `~/.config/opencode/sounds/question.mp3` |
| Permission request, including child sessions | `question.mp3` |

Child completions/questions, failed turns, and interrupted turns stay silent.
Native CLI sounds are disabled in `cli.json` so multiple panes on the same shared
service do not echo the same event. Desktop-notification preferences are unchanged.
Locationless completions are resolved to their owning session; if session metadata
cannot be read, that cue is skipped rather than played by unrelated locations or
mistakenly treated as a main-session cue. Audio errors are logged without stopping
subsequent notifications. Reload/unload cancels the subscription and active playback.

Replay memory retains the last 1,024 eligible event IDs per live subscription;
new events in the same session still sound. A reload creates fresh replay memory.
Sounds play on the **service host**, including background sessions without an
attached pane. A remote/headless server cannot play them on your local machine,
and separate service processes have independent playback. Paths honor
`XDG_CONFIG_HOME` when set. No native fallback sounds are enabled.

To check local audio (these commands make sound):

```sh
ffplay -nodisp -autoexit -loglevel error -nostats ~/.config/opencode/sounds/jobs_done.mp3
ffplay -nodisp -autoexit -loglevel error -nostats ~/.config/opencode/sounds/question.mp3
```

Verification (no live service restarts, model prompts, or GUI reviews):

```sh
python -B tests/opencode-setup-smoke.py
bun test
python -B tests/opencode-runtime-smoke.py
```

The runtime smoke test requires installed OpenCode V2 and network access for the
pinned packages. It copies configuration to an isolated home and starts only its
own authenticated loopback server. It checks agent/skill/command discovery and
plugin activation without touching the shared service. It also sends a real
child-session permission event to a fake audio executable, so automated checks
remain silent and require no model prompt. The Bun tests cover event filtering,
deduplication, process arguments, playback failures, and cancellation.

## Setup lifecycle

`run_once_before_05-*` backs up existing config before deployment.
`run_onchange_before_10-*` installs system dependencies and permissions when that
script or its rendered device inputs change. `run_once_after_20-*` installs user
dependencies once; a failed run is retried by `chezmoi apply`.
`run_once_after_25-*` selects Vivaldi as the default browser once, preserving
later manual browser preferences on routine repeat applies.
`run_once_after_22-*` installs the missing Plannotator CLI without changing configs.
`run_once_after_21-*` installs the upstream sesh AUR package if it is missing.
`run_once_after_23-*` installs missing TPM/persistence plugin clones, preserving
existing checkouts and snapshots without loading plugins into a live server.
`run_once_after_24-*` builds/installs pinned Weylus and seeds missing machine-local Wayland
settings without replacing saved settings or access codes.
`run_onchange_after_30-*` validates and restarts keyboard services when their
keymap, units, or device paths change. A routine repeat apply does not reinstall
plugins or restart services. Changing a run-once script causes its new content
to run once again.

`run_once_after_50-*` clones the fonts and notes repositories after the 1Password
setup. Existing checkouts are reused without pulling or changing local work;
unrelated paths are never overwritten. Font installation checks individual
PostScript face names rather than only family names. Failed clones/installations
are retried on the next apply.

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
status 1 because it doesn't provide shell access. On Omarchy, the managed global
Git config automatically pushes `https://github.com/` remotes over SSH through
1Password. Clones and pulls still use HTTPS so the public bootstrap works before
sign-in. Explicit SSH remotes also work normally. Other hosts keep their original
authentication method.

Put host-specific overrides in `~/.ssh/config.d/*.conf`, which is included before
the default agent setting. For multiple keys/accounts or more than six keys,
select a host's key with a **public** `IdentityFile` and `IdentitiesOnly yes`.
Custom/shared vaults can be selected later using
`~/.config/1Password/ssh/agent.toml`; your Personal/Private vaults need no such file.

References: [SSH agent](https://developer.1password.com/docs/ssh/agent/) and
[CLI app integration](https://developer.1password.com/docs/cli/app-integration/).

## Git identity and push authentication

Chezmoi deploys the global Git config at `~/.config/git/config`, including:

- `user.name = AyMeeko`
- `user.email = 87551537+AyMeeko@users.noreply.github.com`
- Existing Omarchy Git aliases, rebase/diff/conflict-resolution preferences.
- On Omarchy, `pushInsteadOf = https://github.com/` under `[url "git@github.com:"]`.

The same bootstrap applies these settings on a fresh machine. Ordinary commits
use the configured identity without temporary `GIT_AUTHOR_*`/`GIT_COMMITTER_*`
environment variables, and GitHub pushes use the SSH agent after 1Password sign-in.
The commit identity and remote authentication are separate: missing identity
prevents creating commits; a missing/unlocked agent or unauthorized key prevents
SSH pushes. `gh` API commands still require their own `gh auth login`.

Verify from a repository:

```sh
git var GIT_AUTHOR_IDENT
git var GIT_COMMITTER_IDENT
git remote get-url --push origin
```

Machine-specific Git settings can go in `~/.config/git/local.conf`, included last
and preserved by chezmoi. An existing `~/.gitconfig` or repository-local config
can also override these global defaults. The bootstrap backs up an existing
`~/.config/git/config` before replacing it.

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
python -B tests/personal-repositories-smoke.py
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
