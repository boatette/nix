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

    home.packages = with pkgs; [
        capitaine-cursors
        adw-gtk3
        nwg-look
    ];
}
