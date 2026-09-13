{
  flake.modules.homeManager.btop =
    { config, ... }:
    {
      programs.btop = {
        enable = true;

        settings = {
          color_theme = "${config.xdg.configHome}/btop/themes/noctalia.theme";
          theme_background = false;

          vim_keys = true;
          rounded_corners = false;

          update_ms = 500;
          background_update = false;

          save_config_on_exit = false;
        };
      };
    };
}
