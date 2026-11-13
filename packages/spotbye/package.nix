{
  appimageTools,
  requireFile,
}:
let
  pname = "spotbye";
  version = "3.0.6";

  # releases are a proton drive link for patreon supporters, which nix can't fetch. to bump:
  # spotbye-bump SpotBye-<version>.AppImage, then rebuild. after a reinstall, ssd restores
  # the current one to ~/.local/share/spotbye: run spotbye-bump on it to add it back
  src = requireFile {
    name = "SpotBye-${version}.AppImage";
    url = "https://www.patreon.com/cw/spotbye";
    hash = "sha256-lzzq9o9RcIrDAQf3Gqqu0HhyFuSN4t0LmS4E0mfsuUo=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # it downloads its own ffmpeg when it finds none, which won't run outside the fhs env
  extraPkgs = pkgs: [ pkgs.ffmpeg ];

  extraInstallCommands = ''
    install -Dm444 ${contents}/spotbye.desktop $out/share/applications/spotbye.desktop
    install -Dm444 ${contents}/spotbye.png $out/share/pixmaps/spotbye.png
  '';

  meta = {
    description = "Download Spotify tracks in FLAC from Tidal, Qobuz and Deezer";
    homepage = "https://github.com/spotbye/SpotBye";
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
