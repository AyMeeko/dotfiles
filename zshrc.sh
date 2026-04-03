# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="my-theme"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
ZSH_CUSTOM=~/.config/omz-custom

plugins=(bundler git ruby)

source $ZSH/oh-my-zsh.sh

alias ls='ls -G'
alias be='bundle exec'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gpr='git pull --rebase'
alias gd='git diff --color'
alias gdc='git diff --cached --color'
alias s='rg -S'
alias fzf-tmux="TERM=screen-256color fzf-tmux"
alias vim="nvim"

bindkey -e

# for fzf
source <(fzf --zsh)

# for zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  FPATH=/usr/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# for zsh-syntax-highlighting
if type brew &>/dev/null; then
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')

# for zsh-autosuggestions
if type brew &>/dev/null; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

## misc

# SSH agent helper function
ssh-start() {
    # Check if ssh-agent is running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "Starting SSH agent..."
        eval $(ssh-agent -s)
    else
        echo "SSH agent is already running"
    fi

    # Add SSH key
    ssh-add ~/.ssh/aymeeko
}

# Rspec
export SPEC_OPTS="--format documentation --no-profile"

# typescript-language-server
export NODE_OPTIONS="--max-old-space-size=8192"

export LESS="-F -X -R"
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR=$EDITOR
export HOMEBREW_EDITOR=$VISUAL
export TERM="xterm-256color"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# direnv
eval "$(direnv hook zsh)"

# mise
eval "$(mise activate zsh)"

# cursor CLI
export PATH="$HOME/.local/bin:$PATH"
