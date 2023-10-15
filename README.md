# Setting up a new computer

## Downloads
- [Vivaldi](https://vivaldi.com) (and sign in)
- [1Password](https://1password.com/downloads/mac/) and [browser extention](https://support.1password.com/cs/1password-classic-extension/)
- Desktop Backgrounds
- [Karabiner Elements](https://karabiner-elements.pqrs.org)
- [Alfred](https://www.alfredapp.com)
- [iTerm2](https://iterm2.com)
- [Homebrew](https://brew.sh)
- [Install fonts](https://github.com/powerline/fonts/tree/master/SourceCodePro)

## Command line stuff
- [Set up SSH key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
- Clone dotfiles (this repo!)
- Import iTerm profile
- `bash symlinks.sh`
- `brew install zsh`
- add `/usr/local/bin/zsh` to `/etc/shells`
- `chsh -s $(which zsh)`
- `brew install zsh-completions`
- `brew install zsh-syntax-highlighting`
- `brew install tmux`
- `brew install reattach-to-user-namespace`
- `brew install neovim`
    - symlink `nvim-lazy` into `~/.config/nvim`
- `brew install macvim`
- [oh-my-zsh](https://ohmyz.sh)
- `git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm`
- `brew install fzf`
- `brew install rg`
-  [nerd-fonts](https://github.com/ryanoasis/nerd-fonts#option-4-homebrew-fonts)

## Install Python
- `brew install pyenv pyenv-virtualenv`

## Fix italics in iTerm
- `tic fix_iterm_italics` and restart iTerm

## Setup anti doxing pre-commit hook
- Ensure `dox_words.txt` contains denylisted words, one per line
- Ensure `dont_dox_myself.sh` is executable with `chmod +x dont_dox_myself.sh`
- Symlink script into hooks dir with `mkdir .git/hooks; cd .git/hooks; ln -s ../../dont_dox_myself.sh pre-commit`

test
