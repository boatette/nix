{ pkgs, ... }:
{
    home.pointerCursor = {
        enable = true;
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors";
        size = 24;
        x11.enable = true;
        gtk.enable = true;
    };

    gtk = {
        enable = true;

        iconTheme = {
            name = "Papirus";
        };

        theme = {
            name = "adw-gtk3";
            package = pkgs.adw-gtk3;
        };
    };
}
