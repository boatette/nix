{
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
      programs = {
        noctalia = {
          settings = {
            plugins = {
              auto_update = "all";

              enabled = [
                "dotnetrob/cat"
                "avivbintangaringga/nix-monitor"
                "noctalia/wallhaven"
              ]
              ++ pkgs.local.noctalia-plugins.pluginIds;

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
                  location = "${pkgs.local.noctalia-plugins}";
                  enabled = true;
                }
              ];
            };

            plugin_settings = {
              "avivbintangaringga/nix-monitor" = {
                branch = "nixos-unstable";
                show_update_available_notification = false;
                update_command = ''nix flake update --flake ${flakeDir} && { git -C ${flakeDir} commit -m "chore: update flake lock" flake.lock || true; } && run0 nixos-rebuild switch --flake ${flakeDir}'';
              };

              "boatette/auto-theme".default_dynamic_scheme = "vibrant";
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
