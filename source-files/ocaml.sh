# OPAM configuration
if [ "$CURRENT_SHELL" = bash ]; then
  . $HOME/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true
elif [ "$CURRENT_SHELL" = zsh ]; then
  . $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

alias rml='cd ~/workspace/reasonml'


function re2ml() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: re2ml <re path> <ml path>"
    return 1
  fi

  npx bsrefmt --parse=re --print=ml "${@}"
}

function rei2mli() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: rei2mli <rei path> <mli path>"
    return 1
  fi

  out=$(npx bsrefmt --parse=ml --print=re -i true "$1")
  if [ $? = 0 ]; then
    echo "$out" > "$2"
    echo "Wrote to $2"
  else
    return 1
  fi
}

function ml2re() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: ml2re <ml path> <re path>"
    return 1
  fi

  out=$(npx bsrefmt --parse=ml --print=re "$1")
  if [ $? = 0 ]; then
    echo "$out" > "$2"
    echo "Wrote to $2"
  else
    return 1
  fi
}

function mli2rei() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: mli2rei <mli path> <rei path>"
    return 1
  fi

  out=$(npx bsrefmt --parse=ml --print=re -i true "$1")
  if [ $? = 0 ]; then
    echo "$out" > "$2"
    echo "Wrote to $2"
  else
    return 1
  fi
}

function findre() {
  local fname=$1
  if [[ -z $fname ]]; then
    echo "Need 1 argument"
    return 1
  fi
  if [[ ! -d src ]]; then
    echo "No 'src' directory"
    return 1
  fi
  find src -iname "$fname.re"
}
