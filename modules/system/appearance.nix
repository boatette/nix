{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { config, pkgs, ... }:
    let
      inherit (inputs.self.constants.fonts) sans;
    in
    {
      gtk = {
        enable = true;

        theme = {
          name = "rose-pine-gtk";
          package = pkgs.local.rose-pine-gtk;
        };

        iconTheme = {
          name = "rose-pine";
          package = pkgs.rose-pine-icon-theme;
        };

        font = {
          inherit (sans) name size;
        };

        gtk4 = {
          inherit (config.gtk) theme;
          colorScheme = "dark";
        };
      };

      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      home = {
        pointerCursor = {
          enable = true;
          inherit (inputs.self.constants.cursor) name size;
          package = pkgs.rose-pine-cursor;
          x11.enable = true;
          gtk.enable = true;
        };

        packages = [ pkgs.gtk3 ];
      };
    };
}
