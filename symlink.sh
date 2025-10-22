#!/bin/bash

FILES=(
  'ghostty'
  'karabiner'
  'nvim'
  'omz-custom'
  'tmux'
)

cd "$HOME"
ln -s "$HOME/src/dotfiles/zshrc.sh" ".zshrc"
ln -s "$HOME/src/dotfiles" ".dotfiles"
mkdir -p "$HOME/.config"
cd "$HOME/.config"

for file in "${FILES[@]}"
do
  ln -s "$HOME/.dotfiles/${file}" "."
done
