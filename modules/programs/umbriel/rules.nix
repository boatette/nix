{ lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    window_rule = lib.mkBefore [
      { blur = true; }

      {
        match.app_id = "^(xdg-desktop-portal-gtk|org\\.gtk\\.FileChooserDialog)$";
        default_floating = true;
        default_size = [
          800
          1000
        ];
      }

      {
        match.title = "^(Open|Save|Select|Import|Export)\\b";
        default_floating = true;
        default_size = [
          800
          1000
        ];
      }

      {
        match.title = "^(Picture-in-Picture|Sign in - Google Accounts)$";
        default_floating = true;
      }

      {
        match.title = "\\b(Dialog|Properties|Preferences|Settings|Rename|Authentication)$";
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

      # umbriel has no `excludes`, so the apps niri exempts from the dialog
      # rules above get the setting put back by a later, narrower rule.
      {
        match.app_id = "^(zen|helium|vesktop|steam)";
        match.title = "^(Open|Save|Select|Import|Export)\\b";
        default_floating = false;
      }

      {
        match.app_id = "^(zen|vesktop)";
        match.title = "\\b(Dialog|Properties|Preferences|Settings|Rename|Authentication)$";
        default_floating = false;
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
