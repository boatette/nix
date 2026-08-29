{ lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = lib.mkBefore [
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
      match.app_id = "^org\\.gtk\\.FileChooserDialog$";
      default_floating = true;
    }

    {
      match.title = "Sign in - Google Accounts";
      default_floating = true;
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
  ];
}
