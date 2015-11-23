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
  cabalInit
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
