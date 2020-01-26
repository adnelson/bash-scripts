let pkgs = import <nixpkgs> {}; in

{
  env = pkgs.buildEnv {
    name = "userEnv";
    paths = [
      pkgs.ripgrep
      pkgs.nodejs-10_x
    ];
  };
}
