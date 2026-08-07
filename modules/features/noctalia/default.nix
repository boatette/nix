{ inputs, ... }:

let
    mkNoctalia =
        {
            pkgs,
            homeDirectory,
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

            settings = import ./_config.nix {
                inherit footLiveTheme homeDirectory;
                templates = ./templates;
            };
        in
        rec {
            inherit footLiveTheme settings;

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
    flake.modules.homeManager.desktop =
        { pkgs, config, ... }:
        let
            noctalia = mkNoctalia {
                inherit pkgs;
                inherit (config.home) homeDirectory;
            };
        in
        {
            home.packages = [
                noctalia.package
                noctalia.footLiveTheme
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
