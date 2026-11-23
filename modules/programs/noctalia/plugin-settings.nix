{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    let
      rebuild = inputs.self.lib.rebuild inputs.self.constants.flakeDir;
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

        "riversyx/noctaproton-vpn" = {
          panel_placement = "floating";
          panel_position = "top_center";
        };

        "rylos/tailnet" = {
          panel_placement = "floating";
          panel_position = "top_center";
        };
      };
    };
}
