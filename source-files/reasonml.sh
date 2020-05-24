alias rml='cd ~/workspace/reasonml'


function fix_bsb_and_patch() {
  bsb-resolve.sh || return 1
  patch-ocaml-binaries.sh
}
