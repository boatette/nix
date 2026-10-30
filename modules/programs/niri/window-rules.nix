{ inputs, lib, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
  floating = match: rule match { open-floating = true; };
in
{
  # first, so the app rules from other modules can override them
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = lib.mkBefore [
    {
      window-rule = {
        geometry-corner-radius = 12;
        clip-to-geometry = true;
        # otherwise translucent windows with their own decorations show solid border colour
        draw-border-with-background = false;
        background-effect.blur = true;
      };
    }

    (rule { is-focused = true; } { opacity = 0.92; })
    (rule { is-focused = false; } { opacity = 0.8; })

    # these draw their own translucent background; window opacity would fade the text too
    (rule { app-id = "^(foot|org\\.kde\\.konsole)$"; } { opacity = 1.0; })

    (rule { app-id = "^xdg-desktop-portal-gtk$"; } {
      open-floating = true;
      default-column-width.fixed = 800;
      default-window-height.fixed = 1000;
    })
    (floating { app-id = "^org\\.gtk\\.FileChooserDialog$"; })
    (floating { title = "^Sign in - Google Accounts"; })
    (floating {
      app-id = "^(org\\.kde\\.dolphin|gimp|libreoffice|soffice)";
      title = "^(Open|Save|Select|Import|Export|Rename|Properties|Preferences|Settings)\\b";
    })
    (floating { title = "^Picture-in-Picture$"; })
    (rule
      {
        app-id = "^qimgv$";
        title = "\\bdvp\\.webp\\b";
      }
      {
        open-floating = true;
        default-column-width.fixed = 900;
        default-window-height.fixed = 300;
        default-floating-position._props = {
          x = 0;
          y = 0;
          relative-to = "bottom-right";
        };
      }
    )
  ];
}
