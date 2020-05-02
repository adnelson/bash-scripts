# NOTE: this should be symlinked at ~/.nixpkgs/config.nix
{
  allowUnfree = true;
  packageOverrides = ps: {
    tandem = ps.callPackage ./tandem { };
    bs-platform = (import ./bs-platform { pkgs = ps; }).bs-platform7; /* .overrideAttrs(attrs: {
      patchPhase = ''
        ${attrs.patchPhase or ""}
        rm -f linux/ninja.exe
        ln -s $(type -p ninja) linux/ninja.exe
        patch -p1 < ${./install-script.patch}
        python3 <<EOF
        import json
        with open('package.json') as f:
            pkg_j = json.load(f)
        del pkg_j['scripts']['postinstall']
        with open('package.json', 'w') as f:
            f.write(json.dumps(pkg_j, indent=2))
        EOF
      '';
    });*/
  };
}
