cabalInit() {
  mkdir -p src
  cabal init \
    --non-interactive \
    --package-name=$(basename $PWD) \
    --version=0.0.0 \
    --license=MIT \
    --author='Allen Nelson' \
    --email=ithinkican@gmail.com \
    --main-is=Main.hs \
    --is-library \
    --language=Haskell2010 \
    --source-dir=src \
    --extension=LambdaCase \
    --extension=OverloadedStrings \
    --extension=NoImplicitPrelude \
    --verbose=2
}

hsInit() {
  [ -z NO_CABAL ] && cabalInit
  cabal2nix . > project.nix
  cat <<EOF > default.nix
{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7102" }:
let
  haskellPackages = nixpkgs.pkgs.haskell.packages.\${compiler};
in

haskellPackages.callPackage ./project.nix {}
EOF
  cat <<EOF > shell.nix
{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7102" }:
(import ./default.nix { inherit nixpkgs compiler; }).env
EOF
}

export HASKELL=$HOME/workspace/haskell
export NIXFROMNPM=$HASKELL/nixfromnpm

cupload() {
  pushd ~/workspace/haskell/$1
  local name=$(cabal info . | head -n 1 | awk '{print $2}')
  echo "Building and uploading $name..."
  nix-shell $HOME/.pkgs.nix -A haskellPackages.$1.env --command \
    "cabal configure && cabal sdist && cabal upload \
     dist/$name.tar.gz -u thinkpad20" || return 1
  popd
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

alias nxe='cd $HASKELL/nix-eval'
