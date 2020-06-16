alias killz='$HOME/workspace/python/killproc.py'
alias dri='docker run -it --rm'

# misc configuration items
alias llama='cd ~/workspace/languages/llama/language-llama'
alias llama_='llama && subl .. && pwd && ls && ghcio -isrc Language.Llama.Types.TypeCheck'

# alias quill='apps && act && python src/quill/server.py'
alias ghcio='ghci -XOverloadedStrings'
alias cbe='cabal exec'
alias hs='ws && cd haskell'
alias s3s='hs && cd s3-streams'
alias cbi='cabal sandbox init'
alias fed='cd ~/workspace/haskell/fedallah'
alias fed_='cd && subl fedallah rowling && cd fedallah'
alias haddock='cabal haddock --internal --executables --hyperlink-source'
alias wej='cd ~/workspace/wej'
alias wejb='cd ~/workspace/wej/hs-backend'
alias wejf='cd ~/workspace/wej/frontend'
alias psps='cd ~/workspace/purescript/purescript'
alias pspss='psps && nix-shell ~/nixpkgs -A haskellPackages.purescript.env'
alias wsjs='mkd ~/workspace/javascript'
alias re='cd ~/workspace/reasonml'
alias req='cd ~/workspace/reasonml/requery'
alias reqa='cd ~/workspace/reasonml/requery/packages/abstract'
alias reqae='cd ~/workspace/reasonml/requery/packages/abstract/example'
alias reqp='cd ~/workspace/reasonml/requery/packages/postgres'
alias reqpe='cd ~/workspace/reasonml/requery/packages/postgres/example'
alias reqs='cd ~/workspace/reasonml/requery/packages/sqlite'
alias reqse='cd ~/workspace/reasonml/requery/packages/sqlite/example'
alias youtube-mp3='youtube-dl --extract-audio --audio-format mp3'
alias subl='/Applications/Sublime\ Text.app/Contents/MacOS/Sublime\ Text'
alias scrots='cd ~/Screenshots'

function agpstype() (
  psps && ag "(data|type) $1"
)

function agps() (
  psps && ag $1
)

shttp() {
  local _PORT=${1:-8000}
  curl -s icanhazip.com
  python -m http.server $_PORT
}

alias ei3='e ~/.i3/config'

alias egui='emacs'
alias emcs='emacs -nw'
alias sl='ls'
alias duh='du -h'
alias cd..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'

alias egit='e $SH_CONFIG/source-files/git.sh'

alias enix='e $SH_CONFIG/source-files/nix.sh'

# Tells you where an alias is defined
function where() {
  str="\b$1\b"
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
    cmd+=" | grep -i --color=always $filter"
  done
  bash -c "$cmd" | grep -v "$cmd" | grep -v grep
}

function findit {
  readlink -f $(which $1)
}
PROTECTED_FOLDERS=(devops)
vdf() {
  if [[ ! -e Vagrantfile ]]; then
    echo "This must be done in a folder with a Vagrantfile" >&2
    return 1
  fi
  name=$(basename $PWD)
  for protected in ${PROTECTED_FOLDERS[*]}; do
    if [[ $name == $protected ]]; then
      echo "refusing to destroy protected virtual machine '$name'" >&2
      return 1
    fi
  done
  echo "Destroying $name"
  vagrant destroy -f
}

alias time='/usr/bin/env time'
if [[ $(id -u) -eq 0 ]]; then
  alias enw='emacs -nw'
elif grep -q emacs <<< $TERMINFO; then
  alias enw='emacsclient'
else
  alias enw='emacsclient -nw'
fi

whichl() {
  readlink -f $(which $1)
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
alias bss='cd $SH_CONFIG/scripts'
# Cuz sometimes I type this
alias reloadreload='reload'

alias vssh='vagrant ssh'

# Remove emacs temp files.
clean_emacs() {
  find . -name '.#*' -o -name '*~' -exec rm {} \; -print
}

alias secrets='cd ~/.secrets'

alias j='python -m json.tool --sort-keys'

# Run a process and check its memory usage
mem() {
  ps -eo rss,pid,euser,args:100 --sort %mem | grep -v grep | grep -i $@ | awk '{printf $1/1024 "MB"; $1=""; print }'
}

if which ag &>/dev/null; then
  alias pag='ag --python'
  alias jag='ag --js'
fi

alias psppshell='cd ~/workspace/other/pspp/pspp-source/pspp-1.0.1 && nix-shell ~/nixpkgs -A pspp'

function encuric() {
    node -p "encodeURIComponent('$1')"
}

function encuri() {
    node -p "encodeURI('$1')"
}

function bag() {
    local needle=$1
    shift
    ag "\b$needle\b" "${@}"
}

function bagl() {
    local needle=$1
    shift
    ag "\b$needle" "${@}"
}

function bagr() {
    local needle=$1
    shift
    ag "$needle\b" "${@}"
}

# Install xml2json with PYTHON=/usr/bin/python npm install -g xml2json
function xml2json() {
    NODE_PATH=$HOME/.npm/lib/node_modules node -e "var fs=require('fs');var xml=fs.readFileSync('$1');var j=require('xml2json').toJson(xml,{object:true});console.log(JSON.stringify(j, null, 2))"
}

function pkgversion() {
  cat node_modules/$1/package.json | jq .version
}

edit_source_file() {
    enw ~/.bash-scripts/source-files/${1}.sh
}

# Edit xmonad
if [[ -e ~/.bash-scripts/xmonad/xmonad.hs ]]; then
  alias exm='e ~/.bash-scripts/xmonad/xmonad.hs'
fi

# Tell ripgrep where to look for a config file
export RIPGREP_CONFIG_PATH=$SH_CONFIG/ripgreprc

for f in ~/.bash-scripts/scripts/*; do
  if ! [[ -x $f ]]; then
    echo "WARNING: $f is not executable"
  fi
done

alias xbash='exec bash'

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

# Commonly used directories.
alias ws="mkdir -p ~/workspace && cd ~/workspace"
alias dl="cd ~/Downloads"

# TODO scrape this and keep it up to date
export BLIBBERBLOB_IP='192.168.68.101'

commit_bash_scripts() (
  if [[ -z "$1" ]]; then
    echo "Need a commit message"
    exit 1
  fi
  cd ~/.bash-scripts
  git add .
  git commit -m "$1"
)

push_bash_scripts() (
  cd ~/.bash-scripts
  if ! git diff-index --quiet HEAD; then
    git status
    echo "Stopping due to uncommitted changes in $PWD."
    exit 1
  fi

  git push origin "${1:-master}"
)
