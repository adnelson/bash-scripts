alias ki='cd ~/workspace/misc/kirei'
alias kirei='ki && cd src && ghci'
alias kirei+='ki && subl . && cd src && ghci'
alias killz='/Users/anelson/workspace/python/killproc.py'

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
alias s='subl . &> /dev/null'
alias snippets='subl /Users/anelson/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/Snippets'
alias ci='cabal install'
alias cui='cabal update && cabal install'
alias crs='cabal repl spec'
alias py='cd ~/workspace/python'
alias haddock='cabal haddock --internal --executables --hyperlink-source'
alias dev='git checkout develop'

shttp() {
    curl -s icanhazip.com; python -m  SimpleHTTPServer 8000
}

alias search='yaourt -Ss'
alias get='yaourt -S'
alias ta='tmux attach'
alias t='git snake test'
alias remove='yaourt -R'
alias ei3='e ~/.i3/config'
alias lock='xscreensaver-command --lock'
alias rr='pga && act && cd src/ns_data_pga/round_recap'
alias grip='grep -i'
alias gsb='git snake build -d'
alias update='yaourt -Syyu'
alias tn='git snake test -n'
alias prs='cd ~/narr/ns_data/ns_data_parsing'
alias cliact='source ~/narr/ns_services/quill_development_toolkit/cli/vendor/python/bin/activate'
alias rmpkg='yaourt -R'
alias grep='grep --color=auto'
alias egui='emacs'
alias emcs='emacs -nw'
alias sf='cd ~/workspace/software-foundations/coqfiles'
alias dt='cd ~/narr/ns_data'
alias sl='ls'
alias duh='du -h'
alias music='cd ~/Music'
alias coq='cd ~/workspace/coq'
alias onprem='cd ~/narr/ns_systems/on_prem'
alias cd..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias venv='virtualenv venv; source venv/bin/activate'
alias onp='lsi -p vpc-onprem'
alias nsp="nix-shell --pure -I root=$NARR -I /home/anelson/narr/RND-Data"

alias egit='e ~/.zsh/git.sh'
alias sys='cd ~/narr/ns_systems'
alias adf='dapps; cd ns_analytics_default'

# Show disk space on machines matching filters.
function dspace() {
  lsi $@ -c 'df -h | head -n 2 | tail -n 1' -y
}

# Show what is taking up disk space on machines matching filters.
function whatspace() {
  lsi $@ -c 'sudo du / | sort -nsr | head -n 20' -y
}

alias enix='e $ZSH_PROFILE/nix.sh'
alias enix='e $SH_CONFIG/nix.sh'
alias ans='cd ~/narr/ns_systems/on_prem/ansible_installer'

# Tells you where an alias is defined
function where() {
  grep --color=auto --exclude='#*' -R $1 $SH_CONFIG/scripts
  grep --color=auto --exclude='#*' -R $1 $SH_CONFIG/secrets
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
alias copy='xsel -ib'
alias paste='xsel -ob'
alias ns='nix-shell'
alias e_='emacsclient -nw'
psa() {
  local cmd='ps auxww'
  for filter in "$@"; do
    cmd+=" | ag $filter"
  done
  bash -c "$cmd"
}
alias vgr='cd ~/narr/vagrantboxes'
alias sdev='cd ~/narr/ns_systems/on_prem/dev'
function findit {
  readlink -f $(which $1)
}
alias vdf='vagrant destroy -f'

alias time='/usr/bin/env time'
alias enw='emacsclient -nw'
alias qosx='cd ~/narr/vagrantboxes/quill-osx && vagrant ssh'

whichl() {
  ls -l $(which $1)
}
export PATH="$PATH:$HOME/.npm/bin"
alias nnp='cd /home/anelson/workspace/nix/nix-node-packages'

export WS=$HOME/workspace
alias osx='nvgr && cd osx'
alias band='cd /home/anelson/narr/ns_systems/builders/pypi/bandersnatch-mirror'

linesFrom() {
  local start=$1 numLines=$2 file=$3
  # Get the number of lines in the file
  local nlines=$(wc -l $file | awk '{print $1}')
  # Output the file starting at that line, and take numLines lines
  tail -n -$(($nlines - $start + 1)) $file | head -n $numLines
}
alias nfn='cd $HOME/workspace/haskell/nixfromnpm'
alias bs='cd $SH_CONFIG'
alias allen='cd $NARR/vagrantboxes/allen && vagrant ssh'
