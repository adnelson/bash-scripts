if [ -z "$SH_CONFIG" ] || [ ! -e "$SH_CONFIG" ]; then
  echo "SH_CONFIG is not set or does not exist: $SH_CONFIG"
  return
fi

_VERBOSE=

_echo() {
  [ -z $_VERBOSE ] || echo $1
}

_echo 'Loading custom config...'

# Need to load these up first
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
  source ~/.nix-profile/etc/profile.d/nix.sh
fi

unalias grep >/dev/null 2>&1 || true

_echo "Detected session type: $SESSION_TYPE"

if [[ $(id -u) -eq 0 ]]; then
  export EDITOR=emacs
else
  export EDITOR=emacsclient
fi

# Emacs doesn't like the kitty-term...
if [[ $TERM == xterm-kitty ]] || [[ $TERM == eterm-color ]]; then
  export TERM=xterm-256color
fi

if [[ -n "$INSIDE_EMACS" ]]; then
  export EDITOR_FLAGS='-n'
else
  export EDITOR_FLAGS='-nw'
fi

# Opens a text editor.
function e() {
    $EDITOR $EDITOR_FLAGS $@
}

# Reloads the shell, if you've updated an alias etc.
alias reload='exec $CURRENT_SHELL'

# For editing this file.
alias ezsh="e $SH_CONFIG/config.sh && reload"

# For editing the extras file.
alias eextras="e $SH_CONFIG/source-files/extras.sh && reload"

# For editing SSH config.
alias essh="e ~/.ssh/config"

# Lists sorted by date, latest last.
alias lst='ls -tr'

# Lists all of the files with lots of info, sorted by date.
alias la='ls -lrtha'

# Make a shim for the `readlink -f` command because standard OSX doesn't have it
if uname -a | grep -iq darwin; then
  function rlink() {
    python -c "import os; print(os.path.realpath('$1'))"
  }
else
  alias rlink='readlink -f'
fi

for file in $(find $SH_CONFIG/source-files/ -type f -name '*.sh' -a ! -name '.#*'); do
  echo "Sourcing $(rlink $file)"
  source $file
done

if [[ -e $SH_CONFIG/secrets/source-files ]]; then
  for file in $(find $SH_CONFIG/secrets/source-files/ -type f -name '*.sh' -a ! -name '.#*'); do
    echo "Sourcing secret $(rlink $file)"
    source $file
  done
fi

unset BROWSER

# Use light colors for ls
LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS
alias ls='ls --color=tty'

# Remove a right prompt if there is one
export RPROMPT=

(
  cd "$SH_CONFIG"
  if ! git diff-index --quiet HEAD; then
    echo -ne '\033[0;33m'
    echo "##################################################################"
    echo "## You have uncommitted changes in $SH_CONFIG"
    echo "##################################################################"
    echo -ne '\033[0m'
  elif [ $(cur) = master ]; then
    if [ "$(curcommit)" != "$(grp origin/master)" ]; then
      echo -ne '\033[0;33m'
      echo "##################################################################"
      echo "## Local master is out of sync with origin/master in $SH_CONFIG"
      echo "##################################################################"
      echo -ne '\033[0m'
    fi
  fi
)


_echo ok
