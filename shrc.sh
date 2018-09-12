# Path to folder containing this file.
export SH_CONFIG=$HOME/.bash-scripts

# Locale settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


if [[ ! -z $TERM ]]; then
  if echo $TERMINFO | grep -q emacs; then
    export TERM=xterm
  else
    export TERM=xterm-256color
  fi
fi

if [[ -n "$BASH_VERSION" ]]; then
  current_shell=bash
elif [[ -n "$ZSH_VERSION" ]]; then
  current_shell=zsh
else
  current_shell=$SHELL
fi

if [[ -n $current_shell ]]; then
  echo "Detected shell: $current_shell"
fi

case $current_shell in
*bash)
  # If which is a binary, disable any 'which' alias
  type -p which >/dev/null 2>&1 && unalias which >/dev/null 2>&1 || true
  # Turn on special glob patterns
  shopt -s extglob
  # Set the fancy prompt we're working on
  source $HOME/.bash-scripts/style.sh
  # Source all of the dotfiles, unless we're in a nix shell.
  source $SH_CONFIG/config.sh
;;
*zsh)
  # Make sure which isn't an alias
  unalias which >/dev/null 2>&1 || true
  # Turn on extended globbing
  setopt extendedglob

  # Path to your oh-my-zsh installation.
  export ZSH=$SH_CONFIG/oh-my-zsh

  # Set name of the theme to load.
  # Look in ~/.oh-my-zsh/themes/
  # Optionally, if you set this to "random", it'll load a random theme each
  # time that oh-my-zsh is loaded.
  ZSH_THEME="pygmalion"

  # Uncomment the following line to use case-sensitive completion.
  # CASE_SENSITIVE="true"

  # Uncomment the following line to use hyphen-insensitive completion. Case
  # sensitive completion must be off. _ and - will be interchangeable.
  # HYPHEN_INSENSITIVE="true"

  # Uncomment the following line to disable bi-weekly auto-update checks.
  DISABLE_AUTO_UPDATE="true"

  # Uncomment the following line to change how often to auto-update (in days).
  # export UPDATE_ZSH_DAYS=13

  # Uncomment the following line to disable colors in ls.
  # DISABLE_LS_COLORS="true"

  # Uncomment the following line to disable auto-setting terminal title.
  # DISABLE_AUTO_TITLE="true"

  # Uncomment the following line to enable command auto-correction.
  # ENABLE_CORRECTION="true"

  # Uncomment the following line to display red dots whilst waiting for completion.
  # COMPLETION_WAITING_DOTS="true"

  # Uncomment the following line if you want to disable marking untracked files
  # under VCS as dirty. This makes repository status check for large repositories
  # much, much faster.
  # DISABLE_UNTRACKED_FILES_DIRTY="true"

  # Uncomment the following line if you want to change the command execution time
  # stamp shown in the history command output.
  # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
  # HIST_STAMPS="mm/dd/yyyy"

  # Would you like to use another custom folder than $ZSH/custom?
  # ZSH_CUSTOM=/path/to/new-custom-folder

  # Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
  # Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
  # Example format: plugins=(rails git textmate ruby lighthouse)
  # Add wisely, as too many plugins slow down shell startup.
  plugins=(git)

  # User configuration
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

  # ssh
  # export SSH_KEY_PATH="~/.ssh/dsa_id"

  # Set personal aliases, overriding those provided by oh-my-zsh libs,
  # plugins, and themes. Aliases can be placed here, though oh-my-zsh
  # users are encouraged to define aliases within the ZSH_CUSTOM folder.
  # For a full list of active aliases, run `alias`.
  #
  # Example aliases
  # alias zshconfig="mate ~/.zshrc"
  # alias ohmyzsh="mate ~/.oh-my-zsh"


  # If we're *not* in a nix shell, then set up a default PATH here and
  # source the oh-my-zsh startup script.
  if [[ -z $IN_NIX_SHELL ]]; then
    export PATH="$HOME/bin:/var/setuid-wrappers:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/run/current-system/sw/bin:/run/current-system/sw/sbin:/run/current-system/sw/lib/kde4/libexec:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    source $ZSH/oh-my-zsh.sh
    source $SH_CONFIG/config.sh

  else
    PROMPT="[nix-shell]$PROMPT"
    source $ZSH/oh-my-zsh.sh
    source $SH_CONFIG/config.sh

    # Set PATH to a SAVED_PATH environment variable if we've set
    # one (this is a way to communicate a path to `nix-shell`
    if [ ! -z $SAVED_PATH ]]; then
      export PATH=$SAVED_PATH
    fi
  fi
;;
*)
  echo "Unknown shell: $0"
;;
esac
