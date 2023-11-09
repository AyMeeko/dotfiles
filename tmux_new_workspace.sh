#!/usr/bin/env bash

selected=`ls ~/src/ | fzf`
if [[ -z $selected ]]; then
    exit 0
fi

tmux neww -n $selected -c ~/src/$selected
