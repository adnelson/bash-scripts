echo 'Loading custom config...'

# Set these as appropriate.
export EDITOR=emacsclient
export EDITOR_FLAGS=''
export WORK_DIRECTORY=$HOME/narr

# Opens a text editor.
function e() {
    $EDITOR $EDITOR_FLAGS $@
}

# Reloads the zsh config, if you've updated an alias etc.
alias reload="exec $SHELL"

# For editing this file.
alias ezsh="e $ZSH_CONFIG/config.sh && reload"

# For editing the extras file.
alias eextras="e $ZSH_CONFIG/extras.sh && reload"

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

_VERBOSE=

for file in $(ls $ZSH_CONFIG); do
  echo $file | command grep -Pq '.sh$' || continue
  echo $file | command grep -Pq '^config.sh$' && continue
  [ -z $_VERBOSE ] || echo "Sourcing $ZSH_CONFIG/$file"
  source "$ZSH_CONFIG/$file"
done

export BROWSER='firefox'
export BROWSER_FLAGS='-P'
alias browse="$BROWSER $BROWSER_FLAGS"
# export XDG_CONFIG_HOME=$HOME/.fontconfigs

# Use light colors for ls
LS_COLORS=$LS_COLORS:'di=0;36:' ; export LS_COLORS

# Remove a right prompt if there is one
export RPROMPT=

echo ok
