{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      rebuild = inputs.self.lib.rebuild config.constants.flakeDir;
    in
    {
      programs.noctalia.settings.plugin_settings = {
        "noctalia/umbriel-companion" = {
          panel_open_near_click = false;
          panel_placement = "floating";
        };

        "avivbintangaringga/nix-monitor" = {
          branch = "nixos-unstable";
          panel_open_near_click = false;
          panel_placement = "floating";
          show_update_available_notification = false;
          update_command = rebuild.upgrade;
          clean_command = rebuild.clean;
          hide_optimize_button = true;
        };
      };
    };
}
