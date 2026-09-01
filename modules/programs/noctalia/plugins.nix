{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      programs.noctalia.settings = {
        plugins = {
          enabled = [
            "dotnetrob/cat"
            "avivbintangaringga/nix-monitor"
            "noctalia/wallhaven"
            "noctalia/umbriel-companion"

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
            panel_placement = "attached";
            show_update_available_notification = false;
            update_command = rebuild.upgrade;
          };

          "boatette/auto-theme".default_dynamic_scheme = "vibrant";
          "dotnetrob/cat".panel_placement = "attached";
          "noctalia/wallhaven" = {
            browser_placement = "attached";
            browser_position = "top_center";
            download_dir = "~/Pictures/Wallpapers/Dynamic";
          };
        };
      };
    };
}
