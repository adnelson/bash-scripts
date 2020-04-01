let
  pkgs = import <nixpkgs> {config.allowUnfree=true;};
  emacsCustom = if
    builtins.pathExists "/etc/nixos"
  then null # Use the system emacs on nixos
  else pkgs.emacsWithPackages (
    epkgs: with epkgs; [
      haskell-mode
      markdown-mode
      monokai-theme
      nix-mode
      reason-mode
      rust-mode
      smex
      systemd
      yaml-mode
    ]
  );
  bs-platform = (import ./bs-platform {inherit pkgs;}).bs-platform7;
in
with builtins;

{
  allen = rec {
    shared = (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.shared.json))) ++ [
      emacsCustom
      pkgs.python3Packages.ipython
      pkgs.python3Packages.virtualenv
      bs-platform
      pkgs.cacert
    ];

    nixos = pkgs.buildEnv {
      name = "allen-user-packages-nixos";
      paths = shared ++ (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.nixos.json))) ++ [
        pkgs.llvmPackages.bintools
      ];
    };

    darwin = pkgs.buildEnv {
      name = "allen-user-packages-darwin";
      paths = shared ++ (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.darwin.json)));
    };
  };

  root = {
    nixos = pkgs.buildEnv {
      name = "root-user-packages-nixos";
      paths = map (a: getAttr a pkgs) (fromJSON (readFile ./root.json));
    };
  };
}
