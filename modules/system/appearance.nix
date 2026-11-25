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
          # main only; dawn and moon are two thirds of its 320M
          package = pkgs.rose-pine-icon-theme.overrideAttrs {
            postInstall = "rm -r $out/share/icons/rose-pine-{dawn,moon}";
          };
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
