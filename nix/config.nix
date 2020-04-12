# NOTE: this should be symlinked at ~/.nixpkgs/config.nix
{
  allowUnfree = true;
  packageOverrides = ps: {
    tandem = ps.callPackage ./tandem { };
    bs-platform = (import ./bs-platform {pkgs = ps;}).bs-platform7;
    ocaml = ps.ocaml-ng.ocamlPackages_4_07.ocaml;
  };
}
