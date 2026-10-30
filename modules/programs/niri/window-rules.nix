{ inputs, lib, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
  floating = match: rule match { open-floating = true; };
in
{
  # first, so the app rules from other modules can override them
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = lib.mkBefore [
    (rule { is-focused = false; } { opacity = 0.8; })

    (floating { app-id = "^xdg-desktop-portal-gtk$"; })
    (floating { app-id = "^org\\.gtk\\.FileChooserDialog$"; })
    (floating { title = "^Sign in - Google Accounts"; })
    (floating { title = "^Picture-in-Picture$"; })
    (floating { app-id = "^steamwebhelper$"; })
  ];
}
