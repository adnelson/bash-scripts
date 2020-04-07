# Rust-related bash shenanigans
function setrustpath() {
  export PATH=$HOME/.cargo/bin:$PATH
}


if [[ -e $HOME/.cargo/bin ]]; then
  setrustpath
fi

if type -p rustup >/dev/null; then
  echo "Adding rustup cargo executable directory to PATH"
  export PATH=$(dirname $(rustup which cargo)):$PATH
fi

alias rs='cd ~/workspace/rust'

# Run a command with the rustup stable build
alias rrs='rustup run stable --'
alias carg='rustup run stable -- cargo'
