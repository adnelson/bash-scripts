# Local NPM path
export PATH=$HOME/.npm/bin:$HOME/.yarn/bin:$PATH

function showscripts() {
  cat package.json | jq .scripts
}

if which fnm > /dev/null; then
  echo "Initializing fnm..."
  eval "$(fnm env --use-on-cd)"
fi
