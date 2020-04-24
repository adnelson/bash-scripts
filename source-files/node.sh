# Local NPM path
export PATH=$HOME/.npm/bin:$PATH

function showscripts() {
  cat package.json | jq .scripts
}
