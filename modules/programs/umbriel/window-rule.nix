{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = lib.mkBefore [
    {
      blur = true;
    }

    {
      match.is_focused = true;
      opacity = 1.0;
    }

    {
      match.is_focused = false;
      inherit (inputs.self.constants.glass) opacity;
    }

    {
      match.is_floating = true;
      title_bar = "forced";
    }

    {
      match.app_id = "^(foot|org\\.kde\\.konsole)$";
      opacity = 1.0;
    }

    {
      match.app_id = "^xdg-desktop-portal-gtk$";
      default_floating = true;
      default_floating_size_px = {
        width = 800;
        height = 1000;
      };
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
        app_id = "^(org\\.kde\\.dolphin|com\\.github\\.PintaProject\\.Pinta|libreoffice|soffice)";
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
