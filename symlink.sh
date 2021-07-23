#!/bin/bash

FILES=(
	'tmux.conf'
	'tmux-colors'
	'vimrc'
  'zshrc'
)

cd ~

for file in "${FILES[@]}"
do
	ln -s "$HOME/src/dotfiles/${file}" ".${file}"
done

mkdir -p ~/.vim/colors
ln -s "$HOME/src/dotfiles/apprentice.vim" "$HOME/.vim/colors/apprentice.vim"

ln -s "$HOME/src/dotfiles/zsh-theme" "$HOME/.oh-my-zsh/themes/my.zsh-theme"
