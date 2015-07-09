export MANPATH=~/.nix-profile/share/man/:$MANPATH

# This is where python package libs get dropped
export PYTHONPATH=~/.nix-profile/lib/python2.7/site-packages:$PYTHONPATH

alias nsp="nix-shell --pure"
nixi () {
    nix-env -f $HOME/.pkgs.nix -iA $1
}
pixi () {
    nix-env -f $HOME/.pkgs.nix -iA pythonPackages.$1
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
  nix-shell '<nixpkgs>' -A haskellPackages.$1.env --command \
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
    nixlist nixpkgs -r >/dev/null
}

hshell() {
    local name=$1
    if [ -z $name ]; then
        name=$(basename $PWD)
        nix-shell '<nixpkgs>' -A haskellPackages.$name.env
    else
        local dir=~/workspace/haskell/$name
        [ ! -d $dir ] && {
            echo "It appears $name does not exist"
            return 1
        }
        pushd $dir
        nix-shell '<nixpkgs>' -A haskellPackages.$name.env
        popd
    fi
}
