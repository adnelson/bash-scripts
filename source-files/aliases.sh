alias ydl='yt-dlp'

function addalias() {
  local name="$1"
  local command="$2"
  if [[ -z "$name" ]] || [[ -z "$command" ]]; then
    echo 'Bad args' >&2
    return 1
  fi
  echo "alias $name='$command'" >> ~/.bash-scripts/source-files/aliases.sh
  echo "Added alias $name='$command'"
  reload
}
alias ytm='youtube-mp3'

alias addscript=make-script
alias add-script=make-script
function add-sh() {
  make-script $1 --sh
}

function add-js() {
  make-script $1 --js
}
alias ydlt='ydl-twitter'
alias mus='cd ~/Music'
alias tf='cd ~/workspace/javascript/tellphone'
