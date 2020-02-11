let pkgs = import <nixpkgs> {config.allowUnfree=true;}; in

{
  env = pkgs.buildEnv {
    name = "userEnv";
    paths = [
      pkgs.ripgrep
      pkgs.nodejs-10_x
      pkgs.python3Packages.virtualenv
      pkgs.reaper
      pkgs.docker
      pkgs.docker-compose
      pkgs.vagrant
      pkgs.ruby
      pkgs.weechat
      pkgs.brave
      pkgs.xscreensaver
    ];
  };
}
