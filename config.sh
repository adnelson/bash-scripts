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


for file in $(find $SH_CONFIG/source-files/ -type f -name '*.sh' -a ! -name '.#*'); do
  echo "Sourcing $(rlink $file)"
  source $file
done

if [[ -e ~/.secrets/source-files ]]; then
  for file in $(find ~/.secrets/source-files/ -type f -name '*.sh' -a ! -name '.#*'); do
    echo "Sourcing secret $(rlink $file)"
    source $file
  done
fi

checkuncommitted $SH_CONFIG
checkuncommitted ~/.secrets

if [ -e $SH_CONFIG/secrets ]; then
  print-warning "secrets symlink found"
fi

unset BROWSER

# Use light colors for ls
LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS
alias ls='ls --color=tty'

# Remove a right prompt if there is one
export RPROMPT=

_echo ok
