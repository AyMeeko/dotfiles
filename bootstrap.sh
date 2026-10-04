#!/usr/bin/env bash
set -euo pipefail

# Run as your normal user on an installed Omarchy system.
[[ $EUID -ne 0 ]] || { printf 'Run this as your normal user, not root.\n' >&2; exit 1; }
command -v omarchy >/dev/null || { printf 'This bootstrap requires Omarchy.\n' >&2; exit 1; }
if ! command -v chezmoi >/dev/null; then
  sudo pacman -S --needed --noconfirm chezmoi git
fi

shopt -s nullglob
keyboards=(/dev/input/by-id/*-event-kbd)
primary=${KMONAD_PRIMARY:-}
secondary=${KMONAD_SECONDARY:-}
if [[ -z $primary ]]; then
  # Prefer the programmable daily driver, then a laptop keyboard, then USB.
  for device in /dev/input/by-id/usb-DYGMA_*-event-kbd /dev/input/by-path/platform-*-event-kbd "${keyboards[@]}"; do
    [[ -e $device ]] || continue
    primary=$device
    break
  done
fi
[[ -e $primary ]] || { printf 'No keyboard found. Set KMONAD_PRIMARY to its stable /dev/input path.\n' >&2; exit 1; }
if [[ -z $secondary ]]; then
  for device in "${keyboards[@]}"; do
    [[ $device -ef $primary ]] && continue
    secondary=$device
    break
  done
fi
printf 'Primary keyboard: %s\nExternal keyboard: %s\n' "$primary" "${secondary:-none}"

# A local checkout can bootstrap itself; downloaded copies clone the published repo.
script_dir=$(dirname "$(realpath "$0")")
if [[ -f $script_dir/.chezmoiroot && -d $script_dir/.git ]]; then
  source_dir=$script_dir
else
  source_dir=${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}
fi
chezmoi --source "$source_dir" init "${DOTFILES_REPO:-https://github.com/AyMeeko/dotfiles.git}" \
  --branch "${DOTFILES_BRANCH:-chezmoi-migration}" \
  --promptChoice 'Machine role=omarchy' \
  --promptString "Internal keyboard device (/dev/input/by-id/ or by-path/)=$primary" \
  --promptString "External keyboard device (empty to omit)=$secondary" \
  --promptBool 'Install dependencies and activate services=true'
chezmoi --source "$source_dir" apply --force
printf '\nSetup complete. Log out and back in for your new shell and input group.\n'
