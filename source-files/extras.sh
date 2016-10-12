alias ki='cd ~/workspace/misc/kirei'
alias kirei='ki && cd src && ghci'
alias kirei+='ki && subl . && cd src && ghci'
alias killz='$HOME/workspace/python/killproc.py'

# misc configuration items
export QUIVER2_DB=quiver2_press_stg
alias llama='cd ~/workspace/languages/llama/language-llama'
alias llama_='llama && subl .. && pwd && ls && ghcio -isrc Language.Llama.Types.TypeCheck'

# alias quill='apps && act && python src/quill/server.py'
alias ghcio='ghci -XOverloadedStrings'
alias langs='cd ~/workspace/languages'
alias sargs='cd ~/workspace/python/simpleargs'
alias cbe='cabal exec'
alias hs='ws && cd haskell'
alias s3s='hs && cd s3-streams'
alias cbi='cabal sandbox init'
alias fed='cd ~/workspace/haskell/fedallah'
alias fed_='cd && subl fedallah rowling && cd fedallah'
alias haddock='cabal haddock --internal --executables --hyperlink-source'
alias dev='git checkout develop'

shttp() {
  local _PORT=${1:-8000}
  curl -s icanhazip.com
  python -m  SimpleHTTPServer $_PORT
}

alias ei3='e ~/.i3/config'
alias grip='grep -i'
alias tn='git snake test -n'

alias grep='grep --color=auto'
alias egui='emacs'
alias emcs='emacs -nw'
alias sf='cd ~/workspace/software-foundations/coqfiles'
alias sl='ls'
alias duh='du -h'
alias coq='cd ~/workspace/coq'
alias cd..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

alias egit='e $SH_CONFIG/scripts/git.sh'

# Show disk space on machines matching filters.
function dspace() {
  lsi $@ -c 'df -h | head -n 2 | tail -n 1' -y
}

# Show what is taking up disk space on machines matching filters.
function whatspace() {
  lsi $@ -c 'sudo du / | sort -nsr | head -n 20' -y
}

alias enix='e $SH_CONFIG/scripts/nix.sh'

# Tells you where an alias is defined
function where() {
  str=$1
  shift
  if which ag >/dev/null 2>&1; then
    ag $str $SH_CONFIG $@ -C 10
  else
    grep --color=auto --exclude='#*' -Rn -C 10 $str $SH_CONFIG $@
  fi
}

# Greps current directory for a pattern
function findhere() {
  grep -r $1 .
}

# Appends another alias to the `extras` file.
function add() {
   echo "alias $1='$2'" >> $SH_CONFIG/scripts/extras.sh && reload
}

alias showpath='echo $PATH | tr ":" "\n"'
if [[ $OSTYPE == darwin* ]]; then
  alias copy=pbcopy
  alias paste=pbpaste
else
  alias copy='xsel -ib'
  alias paste='xsel -ob'
fi
alias ns='nix-shell'
alias e_='emacsclient -nw'
psa() {
  local cmd='ps auxww'
  for filter in "$@"; do
    cmd+=" | grep --color=always $filter"
  done
  bash -c "$cmd"
}

alias vgr='cd ~/narr/vagrantboxes'
alias sdev='cd ~/narr/ns_systems/on_prem/dev'
function findit {
  readlink -f $(which $1)
}
PROTECTED_FOLDERS=(quill quill-vagrant-box)
vdf() {
  name=$(basename $PWD)
  for protected in ${PROTECTED_FOLDERS[*]}; do
    if [[ $name == $protected ]]; then
      echo "refusing to destroy protected virtual machine '$name'" >&2
      return
    fi
  done
  echo "Destroying $name"
  vagrant destroy -f
}

alias time='/usr/bin/env time'
alias enw='emacsclient -nw'

whichl() {
  ls -l $(which $1)
}
alias nnp='cd $HOME/workspace/nix/nix-node-packages'

export WS=$HOME/workspace

linesFrom() {
  local start=$1 numLines=$2 file=$3
  # Get the number of lines in the file
  local nlines=$(wc -l $file | awk '{print $1}')
  # Output the file starting at that line, and take numLines lines
  tail -n -$(($nlines - $start + 1)) $file | head -n $numLines
}
alias nfn='cd $HOME/workspace/haskell/nixfromnpm'
alias bs='cd $SH_CONFIG'
# Cuz sometimes I type this
alias reloadreload='reload'

alias vssh='vagrant ssh'

# Remove emacs temp files.
clean_emacs() {
  find . -name '.#*' -o -name '*~' -exec rm {} \; -print
}

alias secrets='cd ~/.secrets'
