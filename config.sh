if [ -z "$SH_CONFIG" ] || [ ! -e "$SH_CONFIG" ]; then
  echo "SH_CONFIG is not set or does not exist: $SH_CONFIG"
  return
fi

if-verbose echo 'Loading custom config...'

# Need to load these up first
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
  source ~/.nix-profile/etc/profile.d/nix.sh
fi

unalias grep >/dev/null 2>&1 || true

if-verbose echo "Detected session type: $SESSION_TYPE"

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
  if-verbose echo "Sourcing $(rlink $file)"
  source $file
done

if [[ -e ~/.secrets/source-files ]]; then
  for file in $(find ~/.secrets/source-files/ -type f -name '*.sh' -a ! -name '.#*'); do
    if-verbose echo "Sourcing secret $(rlink $file)"
    source $file
  done
fi

checkuncommitted $SH_CONFIG
checkuncommitted ~/.secrets

# Check for non-executable files in the scripts directory
function findnonexecutables() {
  comm -3 <(fd '.*' "$1") <(fd '.*' "$1" -t x)
}

non_execs=$(findnonexecutables $SH_CONFIG/scripts)
if [ -n "$non_execs" ]; then
  print-big-warning "Non-executable file(s) in scripts directory:\n$non_execs"
fi

non_execs=$(findnonexecutables ~/.secrets/scripts)
if [ -n "$non_execs" ]; then
  print-big-warning "Non-executable file(s) in .secrets/scripts directory:\n$non_execs"
fi

if [ -e $SH_CONFIG/secrets ]; then
  print-big-warning "secrets symlink found"
fi

unset BROWSER

# Use light colors for ls
LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS
alias ls='ls --color=tty'

# Remove a right prompt if there is one
export RPROMPT=

if-verbose echo ok

HISTCONTROL=ignoreboth
