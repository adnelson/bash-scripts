if [[ $(id -u) == 0 ]]; then
  IS_ROOT=1
fi

if [[ $(python3 -c 'import sys;print(sys.platform)') == darwin ]]; then
  IS_DARWIN=1
fi

if [[ -e /etc/nixos ]]; then
  IS_NIXOS=1
fi

# Locale settings
export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8

# if [[ ! -z $TERM ]]; then
#   if echo $TERMINFO | grep -q emacs; then
#     export TERM=xterm
#   else
#     export TERM=xterm-256color
#   fi
# fi

if [[ -z "$CURRENT_SHELL" ]]; then
  CURRENT_SHELL="$(echo $0 | tr / '\n' | tr -d '-' | tail -n1)"
  if [[ "$CURRENT_SHELL" == '.zshrc' ]]; then
    CURRENT_SHELL=zsh
  fi
  if [[ -z "$CURRENT_SHELL" ]]; then
    if [[ -n "$BASH_VERSION" ]]; then
      CURRENT_SHELL=bash
    elif [[ -n "$ZSH_VERSION" ]]; then
      CURRENT_SHELL=zsh
    else
      CURRENT_SHELL=$SHELL
    fi
  fi
fi

if [[ -n $CURRENT_SHELL ]]; then
  echo "Detected shell: $CURRENT_SHELL"
else
  echo "Couldn't detect shell from '$0'"
fi

# Path to folder containing this file.
if [[ "$CURRENT_SHELL" == "bash" ]]; then
  export SH_CONFIG="$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
else
  # TODO how to do this in zsh
  export SH_CONFIG="$HOME/.bash-scripts"
fi

if echo $TERMINFO | grep -q emacs; then
  INSIDE_EMACS=1
  if [[ ! $IS_DARWIN ]] && [[ -z $ALREADY_RESET ]]; then
    # Hack: I always have to reset for some reason
    reset
    # Prevent reloads from resetting screen by setting this
    export ALREADY_RESET=1
  fi
else
  unset INSIDE_EMACS
fi

if [[ -z $IN_NIX_SHELL ]]; then
  export PATH="$HOME/bin:/run/wrappers/bin:$HOME/.secrets/scripts:$HOME/.bash-scripts/scripts:$HOME/.nix-profile/bin:/etc/profiles/per-user/$(whoami)/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  if [[ -z "$IS_NIXOS" ]]; then
    export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"
  fi
fi

if [[ "$CURRENT_SHELL" == "bash" ]]; then
  # If which is a binary, disable any 'which' alias
  type -p which >/dev/null 2>&1 && unalias which >/dev/null 2>&1 || true
  # Turn on special glob patterns
  shopt -s extglob
  # Set the fancy prompt we're working on
  source $HOME/.bash-scripts/style.sh
  # Source all of the dotfiles, unless we're in a nix shell.
  source $SH_CONFIG/config.sh

elif [[ "$CURRENT_SHELL" == "zsh" ]]; then
  if [[ -n "$INSIDE_EMACS" ]]; then
    unset zle_bracketed_paste
    unsetopt zle
  fi

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
  if [[ -z "$ZSH_THEME" ]]; then
    if [[ -n "$IS_ROOT" ]]; then
      ZSH_THEME="agnoster"
    else
      ZSH_THEME="flazz"
    fi
  fi

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


  # If we're *not* in a nix shell, source the oh-my-zsh startup script.
  if [[ -n $IN_NIX_SHELL ]]; then
    PROMPT="[nix-shell]$PROMPT"
    # Set PATH to a SAVED_PATH environment variable if we've set
    # one (this is a way to communicate a path to `nix-shell`
    if [ ! -z $SAVED_PATH ]]; then
      export PATH=$SAVED_PATH
    fi
  fi
  source $ZSH/oh-my-zsh.sh
  source $SH_CONFIG/config.sh
else
  echo "Unknown shell: '$CURRENT_SHELL'"
fi
if [ -e /Users/allennelson/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/allennelson/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/allennelson/workspace/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/allennelson/workspace/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/allennelson/workspace/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/allennelson/workspace/google-cloud-sdk/completion.zsh.inc'; fi
