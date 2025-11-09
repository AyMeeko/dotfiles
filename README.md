# Setting up a new computer

## Downloads
- Browser of choice (Vivaldi, Arc, Firefox)
- [1Password](https://1password.com/downloads/mac/) and [browser extention](https://support.1password.com/cs/1password-classic-extension/)
- [Karabiner Elements](https://karabiner-elements.pqrs.org)
- [Alfred](https://www.alfredapp.com)
- [Homebrew](https://brew.sh)
- [Install fonts](https://github.com/microsoft/cascadia-code)

## Command line stuff
- [Set up SSH key](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
- Clone dotfiles (this repo!)
- `bash symlinks.sh`
- `brew install zsh`
- add `/usr/local/bin/zsh` to `/etc/shells`
- `chsh -s $(which zsh)`
- `brew install zsh-autosuggestions`
- `brew install zsh-completions`
- `brew install zsh-syntax-highlighting`
- `brew install ghostty`
- `brew install tmux`
- `brew install reattach-to-user-namespace`
- `brew install neovim`
- [oh-my-zsh](https://ohmyz.sh)
- `brew install fzf`
- `brew install rg`
- `brew install opencode`
- `brew install gh`
- install Node

## Install other things
```sh
mkdir -p ~/.config/tmux-plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux-plugins/catppuccin/tmux

npm install -g @github/copilot
npm install -g @githubnext/github-copilot-cli
curl https://cursor.com/install -fsS | bash
```

## Logging in to everything

- `gh auth login`
