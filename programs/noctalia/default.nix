{ inputs, ... }:

let
    mkNoctalia =
        {
            pkgs,
            homeDirectory,
            primaryMonitor ? "eDP-1",
        }:
        let
            inherit (pkgs) lib;

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

            settings = import ./_config.nix {
                inherit
                    footLiveTheme
                    homeDirectory
                    primaryMonitor
                    wallustPalette
                    ;
                templates = ./templates;
            };
        in
        rec {
            inherit footLiveTheme settings wallustPalette;

            package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

            configToml = (pkgs.formats.toml { }).generate "noctalia-config.toml" settings;

            configHome = pkgs.runCommand "noctalia-config-home" { } ''
                mkdir -p $out/noctalia
                cp ${configToml} $out/noctalia/config.toml
            '';

            wrapped = pkgs.symlinkJoin {
                name = "noctalia-${package.version or "configured"}";
                paths = [ package ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                    wrapProgram $out/bin/noctalia --set NOCTALIA_CONFIG_HOME ${configHome}
                '';
                meta = package.meta or { } // {
                    mainProgram = "noctalia";
                };
            };
        };
in
{
    flake.homeModules.desktop =
        {
            pkgs,
            config,
            lib,
            monitors,
            ...
        }:
        let
            noctalia = mkNoctalia {
                inherit pkgs;
                inherit (config.home) homeDirectory;
                primaryMonitor = lib.findFirst (name: monitors.${name}.primary) "eDP-1" (lib.attrNames monitors);
            };
        in
        {
            home.packages = [
                noctalia.package
                noctalia.footLiveTheme
                noctalia.wallustPalette
            ];

            xdg.configFile."noctalia/config.toml" = {
                source = noctalia.configToml;

                onChange = ''
                    ${noctalia.package}/bin/noctalia msg config-reload || true
                '';
            };
        };

    perSystem =
        { pkgs, ... }:
        {
            packages.noctalia =
                (mkNoctalia {
                    inherit pkgs;
                    homeDirectory = "/home/boatette";
                }).wrapped;
        };
}
