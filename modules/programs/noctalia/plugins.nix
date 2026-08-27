{ inputs, ... }:
{
  flake-file.inputs.noctalia-plugins = {
    url = "github:boatette/noctalia-plugins";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.noctalia =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.constants) flakeDir;
    in
    {
      home.packages = [
        inputs.noctalia-plugins.packages.${pkgs.stdenv.hostPlatform.system}.umbriel-workspace-watch
      ];

      programs = {
        noctalia = {
          settings = {
            plugins = {
              enabled = [
                "dotnetrob/cat"
                "avivbintangaringga/nix-monitor"
                "noctalia/wallhaven"

                "boatette/auto-theme"
              ];

              source = [
                {
                  name = "official";
                  kind = "git";
                  location = "https://github.com/noctalia-dev/official-plugins";
                  enabled = true;
                }
                {
                  name = "community";
                  kind = "git";
                  location = "https://github.com/noctalia-dev/community-plugins";
                  enabled = true;
                }
                {
                  name = "Personal";
                  kind = "path";
                  location = "~/Projects/noctalia-plugins";
                  enabled = true;
                }
              ];
            };

            plugin_settings = {
              "avivbintangaringga/nix-monitor" = {
                branch = "nixos-unstable";
                panel_placement = "floating";
                show_update_available_notification = false;
                update_command = ''nix run ~/nix#write-flake && nix flake update --flake ${flakeDir} && { git -C ${flakeDir} commit -m "chore: update flake lock" flake.lock || true; } && run0 nixos-rebuild switch --flake ${flakeDir}'';
              };

              "boatette/auto-theme".default_dynamic_scheme = "vibrant";
              "dotnetrob/cat".panel_placement = "floating";
              "noctalia/wallhaven".download_dir = "~/Pictures/Wallpapers/Dynamic";
            };

            hooks = {
              colors_changed = lib.mkBefore [
                "noctalia msg plugin boatette/auto-theme:auto-theme all colors-changed"
              ];

              theme_mode_changed = [
                "noctalia msg plugin boatette/auto-theme:auto-theme all theme-mode-changed"
              ];

              wallpaper_changed = [
                ''noctalia msg plugin boatette/auto-theme:auto-theme all wallpaper-changed "$NOCTALIA_WALLPAPER_PATH"''
              ];
            };
          };
        };
      };
    };
}
