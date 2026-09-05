{
  flake.modules.homeManager.umbriel.programs.umbriel = {
    validateConfig = false;

    settings = {
      include.files = [ "noctalia.toml" ];

      window_rule = [
        {
          match.app_id = "^dev\\.noctalia\\.Noctalia$";
          default_floating = true;
          default_size = [
            1080
            920
          ];
        }

        {
          match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
          default_floating = true;
          default_size = [
            800
            600
          ];
        }
      ];

      layer_rule = [
        {
          match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
        }

        {
          match.namespace = "^noctalia-window-switcher$";
          blur = true;
          blur_ignore_alpha = 0.5;
        }
      ];
    };
  };
}
