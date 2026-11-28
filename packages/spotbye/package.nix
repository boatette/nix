{
  appimageTools,
  requireFile,
}:
let
  pname = "spotbye";
  version = "3.0.8";

  # a patreon-only download nix can't fetch; spotbye-bump adds it, or the copy ssd restores, to the store
  src = requireFile {
    name = "SpotBye-${version}.AppImage";
    url = "https://www.patreon.com/cw/spotbye";
    hash = "sha256-B0lps9mX3hqJ/x2jaqvJR6busXBQNhL9ZRUMW5iiiHs=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # it downloads its own ffmpeg when it finds none, which won't run outside the fhs env
  extraPkgs = pkgs: [ pkgs.ffmpeg ];

  # a runtime reference keeps the appimage from being garbage collected, which nix can't fetch back
  extraInstallCommands = ''
    install -Dm444 ${contents}/spotbye.desktop $out/share/applications/spotbye.desktop
    install -Dm444 ${contents}/spotbye.png $out/share/pixmaps/spotbye.png
    ln -s ${src} $out/share/spotbye.AppImage
  '';

  meta = {
    description = "Download Spotify tracks in FLAC from Tidal, Qobuz and Deezer";
    homepage = "https://github.com/spotbye/SpotBye";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
