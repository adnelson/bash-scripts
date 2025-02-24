{ stdenv, fetchFromGitHub, ninja, runCommand, nodejs, python3,
  ocaml-version, version, src,
  ocaml ? (import ./ocaml.nix {
    version = ocaml-version;
    inherit stdenv;
    src = "${src}/ocaml";
  }),
  custom-ninja ? (ninja.overrideAttrs (attrs: {
    src = runCommand "ninja-patched-source" {} ''
      mkdir -p $out
      tar zxvf ${src}/vendor/ninja.tar.gz -C $out
    '';
    patches = [];
  }))
}:
stdenv.mkDerivation {
  inherit src version;
  pname = "bs-platform";
  BS_RELEASE_BUILD = "true";
  buildInputs = [ nodejs python3 custom-ninja ];

  patchPhase = ''
    sed -i 's:./configure.py --bootstrap:python3 ./configure.py --bootstrap:' ./scripts/install.js

    mkdir -p ./native/${ocaml-version}/bin
    ln -sf ${ocaml}/bin/*  ./native/${ocaml-version}/bin

    rm -f vendor/ninja/snapshot/ninja.linux
    cp ${custom-ninja}/bin/ninja vendor/ninja/snapshot/ninja.linux
  '';

  dontConfigure = true;

  buildPhase = ''
    # release build https://github.com/BuckleScript/bucklescript/issues/4091#issuecomment-574514891
    node scripts/install.js
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp -rf jscomp lib vendor odoc_gen native $out
    cp bsconfig.json package.json $out

    ln -s $out/lib/bsb $out/bin/bsb
    ln -s $out/lib/bsc $out/bin/bsc
    ln -s $out/lib/bsrefmt $out/bin/bsrefmt

    # Remove this postinstall script from the package.json
    python3 <<EOF
    import json
    pkg_j = json.load(open('$out/package.json'))
    del pkg_j['scripts']['postinstall']
    open('$out/package.json', 'w').write(json.dumps(pkg_j, indent=2))
    print("Removed scripts.postinstall from package.json")
    EOF
  '';
}
