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
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };

        font = {
          inherit (sans) name size;
        };
      };

      kde.settings.kdeglobals.General.font = inputs.self.lib.qtFont sans;

      home = {
        pointerCursor = {
          enable = true;
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors";
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
