{
  appimageTools,
  fetchurl,
}:
let
  pname = "bambu-studio";
  version = "02.09.01.70";

  # the official appimage, as nixpkgs licenses its bambu-studio unfree: hydra never builds it,
  # so every nixpkgs bump meant a ~30 minute local build. bumped by hand
  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubu24-v${version}-20261103183404.AppImage";
    hash = "sha256-Zo2rsb5Tx1gYnta8iZNShd6l4K9GIWVGsbr9aILpr/A=";
  };

  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    pkgs.webkitgtk_4_1
    pkgs.glib-networking
  ];

  # without it, every start shows a dialog saying which distro ca bundle it found
  extraBwrapArgs = [
    "--setenv SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt"
  ];

  extraInstallCommands = ''
    install -Dm444 ${contents}/BambuStudio.desktop $out/share/applications/bambu-studio.desktop
    install -Dm444 ${contents}/BambuStudio.png $out/share/pixmaps/BambuStudio.png
    substituteInPlace $out/share/applications/bambu-studio.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = {
    description = "Slicer for Bambu Lab 3D printers";
    homepage = "https://github.com/bambulab/BambuStudio";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
