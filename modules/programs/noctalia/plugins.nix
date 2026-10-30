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
              kind = "git";
              location = "https://github.com/boatette/noctalia-plugins";
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
            clean_command = rebuild.clean;
            hide_optimize_button = true;
          };
          "dotnetrob/cat".panel_placement = "attached";
        };
      };
    };
}
