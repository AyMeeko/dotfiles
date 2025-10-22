#!/usr/bin/env bash

options=$(ls ~/src; echo ".dotfiles")

selected=$(echo "$options" | fzf)

if [[ -z $selected ]]; then
    exit 0
fi

if [[ $selected == ".dotfiles" ]]; then
    target_dir=~/.dotfiles
else
    target_dir=~/src/$selected
fi

tmux neww -n "$selected" -c "$target_dir"
