{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;
    in
    {
      programs.noctalia.settings = {
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
            update_command = ''nix run ${flakeDir}#write-flake && nix flake update --flake ${flakeDir} && { git -C ${flakeDir} commit -m "chore: update flake lock" flake.lock || true; } && run0 nixos-rebuild switch --flake ${flakeDir}'';
          };

          "boatette/auto-theme".default_dynamic_scheme = "vibrant";
          "dotnetrob/cat".panel_placement = "floating";
          "noctalia/wallhaven" = {
            browser_placement = "floating";
            browser_position = "top_center";
            download_dir = "~/Pictures/Wallpapers/Dynamic";
          };
        };
      };
    };
}
