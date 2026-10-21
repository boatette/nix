{ inputs, ... }:
{
  flake.modules.homeManager.appearance =
    { config, pkgs, ... }:
    let
      inherit (config.constants.fonts) sans;
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

      kde.settings.kdeglobals = {
        General.font = inputs.self.lib.qtFont sans;
        Icons.Theme = config.gtk.iconTheme.name;
      };

      home = {
        pointerCursor = {
          enable = true;
          package = pkgs.rose-pine-cursor;
          name = "BreezeX-RosePine-Linux";
          size = 24;
          x11.enable = true;
          gtk.enable = true;
        };

        packages = with pkgs; [
          gtk3
          qt6Packages.qt6ct
        ];
      };
    };
}
