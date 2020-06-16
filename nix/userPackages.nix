let
  pkgs = import <nixpkgs> { config = import ./config.nix; };
  emacsCustom = if
    builtins.pathExists "/etc/nixos"
  then null # Use the system emacs on nixos
  else pkgs.emacsWithPackages (
    epkgs: with epkgs; [
      haskell-mode
      markdown-mode
      monokai-theme
      nix-mode
      projectile
      reason-mode
      rust-mode
      smex
      systemd
      tuareg
      typescript-mode
      yaml-mode
    ]
  );
in
with builtins;

{
  allen = rec {
    shared = (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.shared.json))) ++ [
      emacsCustom
      pkgs.python3Packages.ipython
      pkgs.python3Packages.virtualenv
    ];

    linux = pkgs.buildEnv {
      name = "allen-user-packages";
      paths = shared ++ (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.linux.json)));
    };

    darwin = pkgs.buildEnv {
      name = "allen-user-packages";
      paths = shared ++ (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.darwin.json)));
    };
  };

  root = {
    linux = pkgs.buildEnv {
      name = "root-user-packages";
      paths = map (a: getAttr a pkgs) (fromJSON (readFile ./root.linux.json));
    };
  };
}
