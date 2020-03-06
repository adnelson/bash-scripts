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
      pkgs.gcc
      pkgs.bind
      pkgs.postgresql_11
      pkgs.cloc
      pkgs.rustup
      pkgs.spotify
      pkgs.urweb
      pkgs.slack
      pkgs.stalonetray
      pkgs.xmobar
      pkgs.trayer
      pkgs.cabal-install
      pkgs.redshift
      pkgs.stylish-haskell
    ];
  };
}
