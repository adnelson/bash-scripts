{ lib, fetchurl, appimageTools, tree }:

let
  pname = "Tandem";
  version = "1.5.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://wisp-app.s3-us-west-1.amazonaws.com/${pname}x86_64${version}.AppImage";
    sha256 = "0975mjnrfa056g6jws8hgc9lz2gqa30p73hxi015xw9i5myws276";
  };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${lib.strings.toLower pname}
  '';

  meta = with lib; {
    description = "Tandem chat/workflow app";
    homepage = "https://tandem.chat/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
