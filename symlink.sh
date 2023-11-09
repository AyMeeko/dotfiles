#!/bin/bash

FILES=(
  'tmux.conf'
  'tmux-cht-command'
  'tmux-cht-languages'
  'tmux-colors'
  'zshrc'
)

cd ~

for file in "${FILES[@]}"
do
  ln -s "$HOME/src/dotfiles/${file}" ".${file}"
done

ln -s "$HOME/src/dotfiles/zsh-theme" "$HOME/.oh-my-zsh/themes/my.zsh-theme"

mkdir -p $HOME/.config
ln -s "$HOME/src/dotfiles/nvim-split" "$HOME/.config/nvim"
