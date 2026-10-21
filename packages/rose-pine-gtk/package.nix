{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "2.2.0";

  release =
    name: hash:
    fetchurl {
      url = "https://github.com/rose-pine/gtk/releases/download/v${version}/${name}.tar.gz";
      inherit hash;
    };

  gtk3 = release "gtk3" "sha256-PnkPaJizn0OyP7R5QhfFzDG2QGDelR2203xCQ0UtDZM=";
  gtk4 = release "gtk4" "sha256-p79eMU1vcPduuiGQuSJ3TnwswwGwmMQ+CGwxw2EZipA=";
in
stdenvNoCC.mkDerivation {
  pname = "rose-pine-gtk";
  inherit version;

  srcs = [
    gtk3
    gtk4
  ];
  sourceRoot = ".";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    theme=$out/share/themes/rose-pine-gtk
    mkdir -p $out/share/themes
    cp -r gtk3/rose-pine-gtk $theme
    install -Dm644 gtk4/rose-pine.css $theme/gtk-4.0/gtk.css
    find $out -name '._*' -delete

    runHook postInstall
  '';

  meta = {
    description = "Rosé Pine (main) GTK 3 theme and GTK 4 stylesheet";
    homepage = "https://github.com/rose-pine/gtk";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
