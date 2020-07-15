alias rml='cd ~/workspace/reasonml'
alias rejs='cd ~/workspace/reasonml/re-js'


function fix_bsb_and_patch() {
  bsb-resolve.sh || return 1
  patch-ocaml-binaries.sh
}
