# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="my"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('nvim')

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew bundler git ruby zsh-nvm)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

alias ls='ls -G'
alias be='bundle exec'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpr='git pull --rebase'
alias gd='git diff --color'
alias gdc='git diff --cached --color'
alias s='rg -S'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gss='git stash save'
alias localdictionary='vim ~/Library/Spelling/LocalDictionary'
#alias vim='mvim -v'
alias fzf-tmux="TERM=screen-256color fzf-tmux"
alias real_vim="mvim -v"
alias vim="nvim"

export LESS="-F -X -R"
export EDITOR="vim"
export VISUAL="vim"
export GIT_EDITOR=$EDITOR
export HOMEBREW_EDITOR=$VISUAL
export TERM="xterm-256color"
if [[ $(uname -m) == 'arm64' ]]; then
  export BREW_DIR=$(brew --prefix)
  export PATH=$BREW_DIR/bin:$PATH
  export ZSH_PATH=$BREW_DIR/bin/zsh
  export BREW_BIN=$BREW_DIR/bin/
else
  export PATH=$HOME/src/brew/bin:$PATH
  export BREW_DIR=$HOME/src/brew
  export ZSH_PATH=/Users/$(whoami)/src/brew/bin/zsh
  export BREW_BIN=$BREW_DIR/bin/brew
fi
export PYTHON3_HOST_PROG=$(pyenv which python3)
export PATH="$HOME/src/brew/bin/mosh-server:$PATH"

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
HELPDIR=/usr/local/share/zsh/help

bindkey -e
#bindkey '^R' history-incremental-pattern-search-backward

source $BREW_DIR/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

      autoload -Uz compinit
        compinit
fi
[[ $TMUX = "" ]] && export TERM="xterm-256color"

# Install pyenv for Python support
PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install rbenv for Ruby support
eval "$(rbenv init - zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# Golang
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"
