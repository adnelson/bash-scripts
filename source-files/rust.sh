# Rust-related bash shenanigans
function setrustpath() {
  export PATH=$HOME/.cargo/bin:$PATH
}


if [[ -e $HOME/.cargo/bin ]]; then
  setrustpath
fi
