# Local NPM path
export PATH=$HOME/.npm/bin:$HOME/.yarn/bin:$PATH

function showscripts() {
  cat package.json | jq .scripts
}
