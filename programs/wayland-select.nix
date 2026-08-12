{ inputs, ... }:

{
    flake.modules.nixos.base =
        { lib, ... }:
        {
            options.preferences.waylandSelect.enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "whether to install wayland-select";
            };
        };

    flake.modules.homeManager.desktop =
        {
            pkgs,
            lib,
            waylandSelect,
            ...
        }:
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
            config = lib.mkIf waylandSelect.enable {
                home.packages = [ inputs.wayland-select.packages.${system}.default ];

                xdg.configFile."wayland-select/config.toml".source =
                    toml.generate "wayland-select-config.toml" settings;
            };
        };
}
