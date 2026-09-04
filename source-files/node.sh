# Local NPM path
export PATH=$HOME/.npm/bin:$HOME/.yarn/bin:$PATH

function showscripts() {
  cat package.json | jq .scripts
}

if which fnm > /dev/null; then
  eval "$(fnm env --use-on-cd)"
fi
