# NOTE: this should be symlinked at ~/.nixpkgs/config.nix
{
  allowUnfree = true;
  packageOverrides = ps: {
    tandem = ps.callPackage ./tandem { };
    nodejs = ps.nodejs-16_x;
    bs-platform = ps.bs-platform.overrideAttrs(attrs: {
      patchPhase = ''
        ${attrs.patchPhase or ""}
        python3 <<EOF
        import json
        with open('package.json') as f:
            pkg_j = json.load(f)
        del pkg_j['scripts']['postinstall']
        with open('package.json', 'w') as f:
            f.write(json.dumps(pkg_j, indent=2))
        EOF
      '';
    });
  };
}
