export MANPATH=~/.nix-profile/share/man/:$MANPATH

# This is where python package libs get dropped
export PYTHONPATH=~/.nix-profile/lib/python2.7/site-packages:$PYTHONPATH

alias nsp="nix-shell --pure"
nixi () {
    nix-channel-update
    nix-env -f ~/.nix-defexpr/channels/nixpkgs -iA pkgs.$1
    rm -f ~/.cache/dmenu_run 2>/dev/null 1>/dev/null
}
pixi () {
    nixi "pythonPackages.$1"
}
hixi () {
    nixi "haskellPackages.$1"
}

alias ncg='nix-collect-garbage -d'
pyrm () {
  nix-env -e "python2.7-$1"
}
alias nb='nix-build'
alias lsp='PAGER= nix-env -q'
function nsshell() {
    # Enter a nix shell specific to a NS package.
    nix-shell --pure '<nsnix>' -A "nspackages.$1"
}

function nsbuild() {
    # Build an ns package.
    local pkg_name=$1
    echo "Building package $pkg_name"
    nix-build '<nsnix>' -A "nspackages.$pkg_name"
}

function nsinstall() {
    # Install an ns package
    nix-env -f '<nsnix>' -iA "nspackages.$1"
}

cupload() {
  pushd ~/workspace/haskell/$1
  local name=$(cabal info . | head -n 1 | awk '{print $2}')
  echo "Building and uploading $name..."
  nix-shell $HOME/.pkgs.nix -A haskellPackages.$1.env --command \
    "cabal configure && cabal sdist && cabal upload \
     dist/$name.tar.gz -u thinkpad20" || return 1
  popd
}

tmpnix() {
    local chan="$1"
    if [ ! -e ~/.nix-defexpr/channels_root/$chan ]; then
	echo "No such channel: $chan" >&2
        return 1
    fi
    local dir=$(tempdir make)
    cp -r ~/.nix-defexpr/channels_root/$chan/* $dir
    chmod -R +w $dir
    echo $dir
}

update_nixos() {
    sudo sh ~/.update_nixos.sh "$@"
}

update_channels() {
    nix-channel --update
    nixlist -r >/dev/null
}

hshell() {
    local name=$1
    if [ -z $name ]; then
        name=$(basename $PWD)
        nix-shell $HOME/.pkgs.nix -A haskellPackages.$name.env
    else
        local dir=~/workspace/haskell/$name
        [ ! -d $dir ] && {
            echo "It appears $name does not exist"
            return 1
        }
        pushd $dir
        nix-shell $HOME/.pkgs.nix -A haskellPackages.$name.env
        popd
    fi
}

export PATH="$HOME/.nix-profile/bin:$PATH"
export NIX_PATH="$HOME/.nix-defexpr/channels:$NIX_PATH"
alias nixpkgs="cd $HOME/nixpkgs"

# Print the hash of the current nixpkgs hash installed to stdout.
current_nixpkgs() {
  local nixpkgs_link=$(readlink -f ~/.nix-defexpr/channels/nixpkgs)
  local nixpkgs_folder=$(basename $(dirname $nixpkgs_link))
  echo $nixpkgs_folder | command grep -Po '.*?\K(\w+$)'
}

# Follow the nixpkgs channel url to the latest.
latest_nixpkgs() {
  local url=http://nixos.org/channels/nixpkgs-unstable
  local res=$(curl -Ls -o /dev/null -w %{url_effective} $url)
  python -c "import re; print(re.match(r'.*?(\w+)/$', '$res').group(1))"
}

nix-channel-update() {
  if [ $(latest_nixpkgs) != $(current_nixpkgs) ]; then
    nix-channel --update
  else
    echo "Already up-to-date at $(current_nixpkgs)"
  fi
}

alias ncg='nix-collect-garbage -d'
pyrm() {
  nix-env -e "python2.7-$1"
}
alias nb='nix-build'
alias lsp='PAGER= nix-env -q'
nixrm() {
    lsp | egrep $1 | xargs nix-env -e
}
alias nse='nix-shell --pure -A env'
