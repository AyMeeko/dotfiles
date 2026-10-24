#!/usr/bin/env bash
set -euo pipefail

case "${1:-picker}" in
  kill)
    # Only accept an exact display row from the live tmux source. fd/config/zoxide
    # rows are not session names, and stripping their first field can kill a decoy.
    selected=${2:-}
    [[ -n $selected ]] || exit 0
    while IFS=$'\t' read -r name display; do
      if [[ -n $name && $display == "$selected" ]]; then
        exec tmux kill-session -t "=$name"
      fi
    done < <(sesh list --tmux --icons --no-color --format $'{session}\t{name}')
    exit 0
    ;;
  notes)
    if [[ $(tmux display-message -p '#S') == notes ]]; then
      exec sesh last
    fi
    exec sesh connect --switch notes
    ;;
  picker) ;;
  *) printf 'Usage: %s [picker|notes|kill ROW]\n' "$0" >&2; exit 2 ;;
esac

# Keep shell expansions here rather than inside a tmux configuration string.
session=$(sesh list --icons --hide-attached --tmux | fzf-tmux -p 80%,70% \
  --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
  --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
  --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
  --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
  --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
  --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash -E .local/share/Trash . ~)' \
  --bind 'ctrl-d:execute("$HOME/.config/tmux/sesh-picker.sh" kill {})+change-prompt(⚡  )+reload(sesh list --icons)' \
  --preview-window 'right:55%' \
  --preview 'sesh preview {}') || {
    status=$?
    case "$status" in
      1|130) exit 0 ;; # No match or explicit cancellation is not a connection request.
      *) exit "$status" ;;
    esac
  }
[[ -n $session ]] || exit 0
exec sesh connect "$session"
