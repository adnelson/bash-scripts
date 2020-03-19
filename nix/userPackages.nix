let pkgs = import <nixpkgs> {config.allowUnfree=true;}; in
with builtins;

{
  allen = let
    json = (fromJSON (readFile ./allen.json));
  in pkgs.buildEnv {
    name = "allen-user-packages";
    paths = (map (a: getAttr a pkgs) json.toplevel) ++
            (map (a: getAttr a pkgs.python3Packages) json.python3Packages) ++
    [
      pkgs.llvmPackages.bintools
    ];
  };

  root = pkgs.buildEnv {
    name = "root-user-packages";
    paths = map (a: getAttr a pkgs) (fromJSON (readFile ./root.json));
  };
}
