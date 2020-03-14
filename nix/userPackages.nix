let
  pkgs = import <nixpkgs> {config.allowUnfree=true;};
  bs-platform = (import ./bs-platform { inherit pkgs; }).bs-platform7;
in


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
      pkgs.gcc
      pkgs.bind
      pkgs.postgresql_11
      pkgs.cloc
      pkgs.rustup
      pkgs.spotify
      pkgs.urweb
      pkgs.slack
      pkgs.stalonetray
      pkgs.trayer
      pkgs.cabal-install
      pkgs.redshift
      pkgs.stylish-haskell
      pkgs.llvmPackages.bintools
      pkgs.vlc
      pkgs.tdesktop
      pkgs.frostwire
      pkgs.mplayer
      pkgs.vscode
      pkgs.deluge
      pkgs.python3Packages.ipython
      bs-platform
      pkgs.zsnes
      pkgs.subsonic
    ];
  };
}
