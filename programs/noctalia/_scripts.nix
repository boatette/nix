pkgs:

let
  inherit (pkgs) lib;
in
{
  footLiveTheme = pkgs.runCommand "foot-live-theme" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    install -Dm755 ${./scripts/foot-live-theme} $out/bin/foot-live-theme
    wrapProgram $out/bin/foot-live-theme --prefix PATH : ${
      lib.makeBinPath (
        with pkgs;
        [
          gnugrep
          procps
          coreutils
        ]
      )
    }
  '';

  wallustPalette = pkgs.runCommand "wallust-palette" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    install -Dm755 ${./scripts/wallust-palette} $out/bin/wallust-palette
    wrapProgram $out/bin/wallust-palette \
        --set WALLUST_BASE ${./wallust/base.toml} \
        --set WALLUST_TEMPLATE ${./wallust/dump.json} \
        --set WALLUST_MAP ${./wallust/palette.jq} \
        --prefix PATH : ${
          lib.makeBinPath (
            with pkgs;
            [
              wallust
              jq
              imagemagick
              coreutils
            ]
          )
        }
  '';
}
