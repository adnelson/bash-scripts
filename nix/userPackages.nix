let pkgs = import <nixpkgs> {config.allowUnfree=true;}; in
with builtins;

{
  allen = pkgs.buildEnv {
    name = "allen-user-packages";
    paths = (map (a: getAttr a pkgs) (fromJSON (readFile ./allen.json))) ++ [
      pkgs.python3Packages.ipython
      pkgs.llvmPackages.bintools
    ];
  };

  root = pkgs.buildEnv {
    name = "root-user-packages";
    paths = map (a: getAttr a pkgs) (fromJSON (readFile ./root.json));
  };
}
