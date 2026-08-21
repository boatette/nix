{
  flake.modules = {
    niri.niri.settings.window-rules = [
      {
        matches = [ { app-id = ''^dev\.noctalia\.Noctalia$''; } ];
        open-floating = true;
        default-column-width.fixed = 1080;
        default-window-height.fixed = 920;
      }
    ];

    homeManager.noctalia.programs.noctalia.settings = {
      shell.niri_overview_type_to_launch_enabled = true;

      backdrop = {
        enabled = false;
        blur_intensity = 0.5;
        tint_intensity = 0.3;
      };
    };
  };
}
