{
  flake.modules.homeManager.appearance =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };
      };

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
