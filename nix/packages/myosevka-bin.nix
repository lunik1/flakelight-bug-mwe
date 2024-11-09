{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "myosevka-bin";
  version = "v31.9.1";

  src = fetchzip {
    url = "https://github.com/lunik1/myosevka-bin/releases/download/v31.9.1/myosevka-31.9.1.tar.zstd";
    stripRoot = false;
    hash = "sha256-blrYHYGv/Z3vi0ZE9oN6Zq49iVXm/DhjOIRVLvpy7Zc=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    install * "$fontdir"
    runHook postInstall
  '';

  meta = with lib; {
    description = "My Iosevka variant (binary)";
    license = licenses.ofl;
    homepage = "https://github.com/lunik1/myosevka-bin";
    downloadPage = "https://github.com/lunik1/myosevka-bin/releases";
    platforms = platforms.all;
    maintainers = with lib.maintainers; [ lunik1 ];
  };
}
