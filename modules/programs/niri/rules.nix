{
  flake.modules.niri.niri.settings.window-rules = [
    {
      geometry-corner-radius = 4;
      clip-to-geometry = true;
      draw-border-with-background = false;

      background-effect = {
        blur = true;
        xray = true;
      };
      popups.background-effect = {
        blur = true;
        xray = false;
      };
    }

    {
      matches = [
        { app-id = "^xdg-desktop-portal-gtk$"; }
        { app-id = ''^org\.gtk\.FileChooserDialog$''; }
        { title = ''^(Open|Save|Select|Import|Export)\b''; }
      ];
      excludes = [
        { app-id = "^zen"; }
        { app-id = "^helium"; }
        { app-id = "^vesktop$"; }
        { app-id = "^steam$"; }
      ];
      open-floating = true;
      default-column-width.proportion = 0.0;
      max-width = 800;
      max-height = 1000;
    }

    {
      matches = [
        { title = "^Picture-in-Picture$"; }
        { title = "Sign in - Google Accounts"; }
      ];
      open-floating = true;
    }

    {
      matches = [ { title = ''\b(Dialog|Properties|Preferences|Settings|Rename|Authentication)$''; } ];
      excludes = [
        { app-id = "^zen"; }
        { app-id = "^vesktop$"; }
      ];
      open-floating = true;
    }
  ];
}
