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

# if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
#   SESSION_TYPE=ssh
# else
#   case $(ps -o comm= -p $PPID) in
#     sshd|*/sshd) SESSION_TYPE=ssh;;
#     *) SESSION_TYPE=terminal;;
#   esac
# fi

_echo "Detected session type: $SESSION_TYPE"

export EDITOR=emacsclient
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
alias reload='exec $SHELL'

# For editing this file.
alias ezsh="e $SH_CONFIG/config.sh && reload"

# For editing the extras file.
alias eextras="e $SH_CONFIG/extras.sh && reload"

# For editing SSH config.
alias essh="e ~/.ssh/config"

# Creates a directory and enters it. If the directory already exists, then
# enters it and lists the contents of the directory.
function mkd () {
   if ! [[ -e $1 ]] ; then
      echo "Creating and entering folder $1"
      mkdir -p $1
      cd $1
   else
      echo "Folder $1 exists, entering. Contents:"
      cd $1
      ls
   fi
}

# Enters a directory and lists the contents.
function cdl() {
    cd $1 && ls
}

# Commonly used directories.
alias ws="cd ~/workspace"
alias dl="cd ~/Downloads"

# Lists sorted by date, latest last.
alias lst='ls -tr'

# Lists all of the files with lots of info, sorted by date.
alias la='ls -lrtha'

# Activates a python virtualenv, assuming the path below is appropriate.
alias act='source vendor/python/bin/activate'

for file in $(find $SH_CONFIG/source-files/ -name '*.sh' -a ! -name '.#*'); do
  echo "Sourcing $file"
  source $file
done

for file in $(find $SH_CONFIG/secrets/ -name '*.sh' -a ! -name '.#*'); do
  echo "Sourcing secret $file"
  source $file
done

export BROWSER='firefox'
export BROWSER_FLAGS='-P'
alias browse="$BROWSER $BROWSER_FLAGS"

# Use light colors for ls
LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS

# Remove a right prompt if there is one
export RPROMPT=

_echo ok
