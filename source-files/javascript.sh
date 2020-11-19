# NOTE: called `nls` because I used to be using `npx`
function nls () {
  if ! [ -e package.json ]; then
    echo "No package.json in $(pwd)"
    return 1
  else
    yarn lint-staged
  fi
}
alias ganls='ga && nls'

alias yrw='yarn re:watch'
alias yw='yarn watch'
