with import <nixpkgs> {};

{
  copypass = let
    copy = if stdenv.isDarwin then "pbcopy" else "${xsel}/bin/xsel -ib";
    homeRoot = if stdenv.isDarwin then "/Users" else "/home";
    whoami = "$(${coreutils}/bin/whoami)";
    credsFile = "${homeRoot}/${whoami}/.secrets/credentials.sh";
  in stdenv.mkDerivation {
    name = "copypass";
    script = ''
      #!${stdenv.shell}
      if [[ ! -e ${credsFile} ]]; then
        echo "No credentials file found." >&2
        exit 1
      fi
      source ${credsFile}
      echo -n "$LDAP_PASS" | ${copy}
    '';
    buildCommand = ''
      mkdir -p $out/bin
      echo "$script" >> $out/bin/copypass
      chmod +x $out/bin/copypass
    '';
  };
}
