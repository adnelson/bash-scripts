let
  pkgs = import <nixpkgs> {config.allowUnfree=true;};
  emacsCustom = pkgs.emacsWithPackages (
    epkgs: with epkgs; [
      monokai-theme
      smex
      nix-mode
      haskell-mode
      reason-mode
      rust-mode
    ]
  );
in
with builtins;

{
  allen = {
    nixos = pkgs.buildEnv {
      name = "allen-user-packages-nixos";
      paths = (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.json))) ++ [
        pkgs.python3Packages.ipython
        pkgs.llvmPackages.bintools
      ];
    };

    darwin = pkgs.buildEnv {
      name = "allen-user-packages-darwin";
      paths = (map (a: getAttr a pkgs) (fromJSON (readFile ./allen-darwin.json))) ++ [
        emacsCustom
        pkgs.cacert
        pkgs.python3Packages.ipython
      ];
    };
  };

  root = {
    nixos = pkgs.buildEnv {
      name = "root-user-packages-nixos";
      paths = map (a: getAttr a pkgs) (fromJSON (readFile ./root.json));
    };
  };
}
