{ pkgs, inputs, ... }:

{
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    programs = {
        appimage = {
            enable = true;
            binfmt = true;
            package = pkgs.appimage-run.override {
                extraPkgs = pkgs: [
                    pkgs.webkitgtk_4_1
                    pkgs.gtk3
                    pkgs.glib
                ];
            };
        };

        localsend.enable = true;

        niri.enable = true;

        noctalia-greeter = {
            enable = true;

            settings = {
                appearance.hide_logo = true;

                cursor = {
                    theme = "capitaine-cursors";
                    size = 24;
                    path = "${pkgs.capitaine-cursors}/share/icons";
                };

                keyboard.layout = "us";
            };
        };
    };

    services = {
        gvfs.enable = true;
        tumbler.enable = true;
        upower.enable = true;
    };
}
