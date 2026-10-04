# Working in this dotfiles repository

## Purpose and supported systems

This is AyMeeko's personal dotfiles repository, managed by **chezmoi**. The goal
is to restore the configured user environment on a fresh Omarchy installation
with the two bootstrap commands in `README.md`, including dependencies and
services rather than only copying config files.

- **Omarchy (Arch Linux / Hyprland)** is the supported desktop platform.
- The `wsl` role is an exclusion boundary and shared base, not a finished setup.
- macOS is not currently supported; `karabiner/` is reference material.
- Account sign-in, OS installation and project data are outside bootstrap.

Read `README.md` for setup/workflow details, `nvim-setup.md` for Neovim, and
`kmonad/kmonad_setup.md` for keyboard remapping. Inspect the current files and
Git status before changing them; another session may have made newer changes.

## Repository map

- `.chezmoiroot` selects `home/` as the managed source tree.
- `home/.chezmoi.toml.tmpl` generates machine-local chezmoi configuration.
- `home/.chezmoiignore.tmpl` controls role-specific deployment and optional devices.
- `home/.chezmoitemplates/` contains shared templates, especially `kmonad-config`.
- `home/dot_config/` holds application configuration: Hyprland, Ghostty,
  Neovim, tmux, OpenCode, Omarchy branding, systemd units, and SSH environment.
- `home/dot_config/nvim/lua/personal_plugins/` contains auto-discovered Neovim
  plugin specs. Keep personal specs here so leftover stock LazyVim specs in
  `lua/plugins/` cannot get imported into this standalone config.
- `home/private_dot_ssh/private_config` manages the SSH client configuration.
- `home/dot_config/git/config.tmpl` manages global Git identity/preferences and
  GitHub HTTPS-to-SSH push routing. Local overrides go in `~/.config/git/local.conf`.
- `home/dot_zshrc` manages the shell configuration.
- `home/run_*.sh.tmpl` contains chezmoi setup scripts; `bootstrap.sh` is the entrypoint.
- `tests/` holds deployment, bootstrap, window-preset and Neovim checks.
- Root documentation, `kmonad/`, `karabiner/`, and root `omarchy/` art are not deployed.

Chezmoi naming matters: `dot_` becomes `.`, `private_` restricts permissions,
`executable_` sets executable permissions, and `.tmpl` files are rendered.
For example, `home/dot_config/tmux/executable_new_workspace.sh` deploys to
`~/.config/tmux/new_workspace.sh`. Deployment creates ordinary files, not links
back into Git. Do not recreate the old `~/.dotfiles` symlink layout.

## Editing and applying changes

**Edit the managed source in this repository first.** Editing only the deployed
`~/.config` file makes a change that the next apply can overwrite.

```sh
git status --short
chezmoi --no-pager diff
# Edit source files, then inspect the planned deployment:
chezmoi apply --dry-run --verbose
chezmoi apply
chezmoi --no-pager diff
```

- Confirm that chezmoi is using this checkout. Its local `sourceDir` should point
  to the Git checkout root; the config template uses `.chezmoi.workingTree` because
  `.chezmoi.sourceDir` can be the managed `home/` subtree.
- Use `chezmoi --source "$PWD" ...` from the repo root when explicitly targeting
  this checkout. Initialization affects local config; prefer an isolated test
  home/config for development rather than reinitializing the user's live setup.
- `chezmoi edit <target>` edits managed source; `chezmoi add <target>` adds a file.
- For intentional direct target edits, review and capture with `chezmoi re-add`
  or merge them into source. Do not re-add rendered keyboard configs: that would
  replace portable templates with this machine's device paths.
- Preserve unrelated files, known hosts, application state and existing edits.
  Inspect conflicts before replacing targets; do not routinely use `--force`.
- Applying with `setupEnabled = true` can run privileged scripts and restart
  keyboard services. Read the rendered scripts in the dry run before applying.
- Commit and push only when requested. Use the repository's existing style and
  stage only intended files. Keep this guide and relevant setup docs current.

## Machine-local data and bootstrap

`~/.config/chezmoi/chezmoi.toml` stores `role`, `kmonadInternalDevice`,
`kmonadExternalDevice`, and `setupEnabled` under `[data]`. These values belong to
the machine, not Git. Reinitialization preserves previously supplied values.

The Omarchy profile requires a primary keyboard path, even on a desktop; the
"internal" field means primary. Use stable physical `/dev/input/by-id/` or
`/dev/input/by-path/` entries. External input is optional. Clearing it stops
managing the external files but does not remove them or disable an old service.

`bootstrap.sh` installs chezmoi if needed, detects keyboard paths, initializes
the Omarchy profile with setup enabled, and applies it. A local checkout uses
itself; a downloaded bootstrap clones into `~/.local/share/chezmoi`. It currently
uses the **`chezmoi-migration` branch**. Keep its branch default and the README's
download URL in sync if that changes. Published commands only include pushed work.

Setup phases:

1. `run_once_before_05-*`: back up existing configs; move stock LazyVim aside.
2. `run_onchange_before_10-*`: install missing packages, set Zsh as the login shell,
   configure uinput/module loading and input-group access. Existing mise/OpenCode
   installations are respected rather than replaced with conflicting packages.
3. `run_once_after_20-*`: install shell/tmux dependencies, Ruby as needed, and
   pinned Neovim plugins/parsers/LSPs. The bootstrap Lua files wait for completion.
4. `run_onchange_after_30-*`: validate and activate configured KMonad services.
   Template hashes make keymap/unit changes trigger a service update.
5. `run_once_after_40-*`: configure the user-manager SSH agent environment and
   open 1Password settings when its agent is not available.

Run-once scripts are tracked by their content; changed content runs again and
failed runs are retried. Run-onchange scripts also depend on rendered content.
When adding automation, consider ordering, repeat-apply behavior, failure
recovery, and whether referenced file changes need to affect the script hash.
Keep system setup guarded by both the Omarchy role and `setupEnabled`.

## SSH and secrets

Use **1Password's desktop SSH agent**, not exported private-key files. The
bootstrap installs `1password`, `1password-cli` (`op`), and OpenSSH. SSH uses
`~/.1password/agent.sock`; Zsh and the user-manager environment set `SSH_AUTH_SOCK`.
Default agent selection includes SSH Key items in Personal/Private/Employee vaults.

On a fresh machine the user must sign in and enable the SSH agent and CLI app
integration in 1Password. The supported CLI cannot enable those app settings.
Do not copy its local account/settings databases or attempt to bypass sign-in.
Do not commit keys, tokens, passwords, session exports, or account state. Fetch
only the secret fields actually needed for a requested task; SSH needs no export.

Useful checks: `ssh-add -l`, `op signin`, `op whoami`, `ssh -T git@github.com`.
GitHub's successful SSH greeting exits with status 1; that is not an auth failure.
The Omarchy global Git config routes GitHub HTTPS pushes over SSH using
`pushInsteadOf`. Public clones/fetches still use HTTPS so bootstrap works before
1Password sign-in. Commit identity is configured globally with AyMeeko's GitHub
noreply email; agents should not need temporary author/committer environment values.
GitHub CLI API authentication still requires `gh auth login` separately.
Host-specific SSH overrides go in `~/.ssh/config.d/*.conf`.

## Desktop and application considerations

- For Omarchy desktop/system customization, load the Omarchy skill when the
  harness provides it. Never modify packaged `/usr/share/omarchy/` files.
- Hyprland config is Lua on the supported setup. Read the existing bindings and
  input settings rather than assuming an older Hyprland config format. After
  applying changes, use `hyprctl reload` and `hyprctl configerrors` in the desktop.
- KMonad performs modifier swapping as well as Caps Lock tap-Escape/hold-Control.
  Distinguish physical key labels from logical Super/Alt in shortcut discussions.
- Ultrawide window geometry lives in `home/dot_config/hypr/window-presets.py`;
  presets use the active monitor, scale, and usable area instead of fixed coordinates.
- Neovim is standalone, not LazyVim. Preserve `lazy-lock.json` pins unless a plugin
  update is requested. `DOTFILES_BOOTSTRAP=1` suppresses normal automatic installs/
  updates while the bootstrap explicitly restores plugins and installs tools.
- OpenCode's theme belongs in `tui.json`, not `opencode.json`. Validate config
  changes against current schemas and tell the user to restart OpenCode afterward.
- Use terminal `sudo` for interactive privileged setup and desktop `pkexec` where
  there is no usable terminal prompt, following the existing setup-script pattern.

## Verification

Run checks relevant to the change from the repository root:

```sh
bash tests/chezmoi-smoke.sh kmonad
python tests/bootstrap-smoke.py
python -B tests/window-presets.py
git diff --check
```

The chezmoi smoke test needs chezmoi, Python 3.11+, and KMonad. It deploys into
isolated homes with setup disabled, checks roles/permissions/idempotence and
conflicts, and syntax-checks enabled setup scripts without running them.
Bootstrap tests mock system commands; window-preset tests do not move live windows.

For Neovim changes, inspect and run the relevant checks:

- `python -B tests/nvim-startup-smoke.py`: needs installed plugins; isolates config,
  cache and state, checks personal-spec discovery, stock-spec isolation and pins.
- `python -B tests/nvim-clipboard-smoke.py`: exercises the deployed config in the
  local Wayland session; requires Neovim and wl-clipboard and temporarily uses
  the clipboard, restoring its previous contents afterward.

Documentation-only changes usually need only `git diff --check`. Repository
tests do not prove live permissions, device availability, GUI authentication or
service health; check those separately when applying a live setup change.
