{ lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    window_rule = lib.mkBefore [
      { blur = true; }

      {
        match.app_id = "^xdg-desktop-portal-gtk$";
        default_floating = true;
        default_size = [
          800
          1000
        ];
      }

      {
        match = {
          app_id = "^(org\\.kde\\.dolphin|gimp|libreoffice|soffice)";
          title = "^(Open|Save|Select|Import|Export|Rename|Properties|Preferences|Settings)\\b";
        };
        default_floating = true;
      }

      {
        match.title = "^Picture-in-Picture$";
        default_floating = true;
      }

      {
        match.app_id = "^dev\\.noctalia\\.Noctalia$";
        default_floating = true;
        default_size = [
          1080
          920
        ];
        blur_popups = false;
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
}
