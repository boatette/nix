{ inputs, ... }:

{
    flake.homeModules.desktop =
        { pkgs, ... }:
        let
            inherit (pkgs.stdenv.hostPlatform) system;

            toml = pkgs.formats.toml { };

            settings = {
                border_size = 1.0;

                rounding = 0.0;
                rounding_power = 2.0;

                fade_in_ms = 65.0;
                fade_out_ms = 65.0;

                blur = true;

                button = "left";

                drag_threshold = 4.0;

                outputs = [ ];

                cursor_shape = "none";
            };
        in
        {
            home.packages = [ inputs.wayland-select.packages.${system}.default ];

            xdg.configFile."wayland-select/config.toml".source =
                toml.generate "wayland-select-config.toml" settings;
        };
}
