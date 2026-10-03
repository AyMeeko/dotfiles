#!/usr/bin/env bash

options=()
for directory in "$HOME"/src/*/; do
    [[ -d "$directory" ]] || continue
    options+=("$(basename "$directory")")
done
dotfiles_dir=""
if command -v chezmoi >/dev/null 2>&1; then
    dotfiles_dir=$(chezmoi source-path 2>/dev/null) || dotfiles_dir=""
    [[ -d "$dotfiles_dir" ]] && options+=("[dotfiles]")
fi
[[ ${#options[@]} -gt 0 ]] || exit 0

selected=$(printf '%s\n' "${options[@]}" | fzf) || exit 0

if [[ -z $selected ]]; then
    exit 0
fi

if [[ $selected == "[dotfiles]" ]]; then
    target_dir="$dotfiles_dir"
else
    target_dir=~/src/$selected
fi

[[ -d "$target_dir" ]] && tmux neww -n "$selected" -c "$target_dir"
