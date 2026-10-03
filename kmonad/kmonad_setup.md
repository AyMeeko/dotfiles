# KMonad on Omarchy

Both Omarchy machines use the shared keymap in
`home/.chezmoitemplates/kmonad-config`. Chezmoi deploys its rendered configuration
to `~/.config/kmonad/kmonad.kbd` and the user unit to
`~/.config/systemd/user/kmonad.service`. Caps Lock is tap-Escape/hold-Control;
Right Alt remains the compose-sequence key.

## Machine-specific input

Install KMonad at `/usr/bin/kmonad` and find the stable physical keyboard path:

```sh
ls -l /dev/input/by-id/ /dev/input/by-path/
```

During `chezmoi init`, supply the internal device path and, if applicable, the
external device path. Choose the physical keyboard's `*-event-kbd` entry rather
than a virtual KMonad output device. This machine previously used
`/dev/input/by-path/platform-i8042-serio-0-event-kbd` internally and
`/dev/input/by-id/usb-Compx_Flow84@Lofree-event-kbd` externally; these are examples,
not defaults for another machine. Leave external input empty if the keyboard is
absent or should not be configured.

The two device paths are local `[data]` values `kmonadInternalDevice` and
`kmonadExternalDevice` in `~/.config/chezmoi/chezmoi.toml`. Change them with
`chezmoi edit-config`, inspect the diff and apply. Empty internal input is rejected
for Omarchy. External input controls both its keymap and its unit.

## Permissions (manual privileged setup)

Check group membership and `/dev/uinput` access:

```sh
groups
ls -l /dev/uinput
```

If needed, add your user to `input` (then log out/in), load `uinput`, and configure
the system rules explicitly. For example, create `/etc/udev/rules.d/99-uinput.rules`
with `KERNEL=="uinput", GROUP="input", MODE="0660"`, and
`/etc/modules-load.d/uinput.conf` containing `uinput`. Then reload udev rules and
load the module with the appropriate privileged command. Chezmoi does not perform
these steps or modify `/etc`.

## Validate and activate manually

First ensure the configured physical devices exist and validate the rendered files:

```sh
kmonad --dry-run ~/.config/kmonad/kmonad.kbd
# Only when the external variant was configured:
kmonad --dry-run ~/.config/kmonad/kmonad-external.kbd
systemd-analyze --user verify ~/.config/systemd/user/kmonad.service
```

`--dry-run` checks syntax, not device accessibility or actual remapping. When ready
to change the running keyboard service (keep a working input/recovery route):

```sh
systemctl --user daemon-reload
systemctl --user enable kmonad.service
systemctl --user restart kmonad.service
systemctl --user status kmonad.service
journalctl --user -u kmonad.service --no-pager -n 30
```

Use the same commands for `kmonad-external.service` only if its device is present.
An `ExecCondition` checks for that device before starting, so a missing keyboard
skips startup rather than entering a five-second failure loop. After reconnecting
it, start/restart the external unit manually; this setup does not install a
hotplug activator. Chezmoi never enables or restarts these units automatically.

The units use systemd `%h` for the home directory and no longer depend on the Git
checkout. Existing service files must be backed up before accepting replacements.
Keep the old checkout until running services use the new paths.

## Removed legacy NixOS command

The old repo configs attempted `/run/current-system/sw/bin/sleep` followed by
`setxkbmap`, and the units set `LD_LIBRARY_PATH=/run/current-system/sw/lib`.
These paths do not exist on the inspected Omarchy machine; its journal reports
startup-command failures, while the internal remapper runs without a successful
command. The new config omits that dead startup command and library override.
The binary resolves its libraries through `/usr/lib`.

Configure desktop compose-key behavior through the actual Hyprland/XKB user
settings if needed; verify Right Alt compose behavior manually after deployment.
Do not replace the dead command with `setxkbmap` blindly on Wayland.

If retiring an external keyboard, remove its local data value, disable its unit
with `systemctl --user disable --now kmonad-external.service`, and archive/remove
the previously deployed unit/keymap manually. Ignoring a target in chezmoi does
not delete it or stop an existing service.
