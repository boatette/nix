{ pkgs, inputs, ... }:

{
    imports = [ inputs.noctalia-greeter.nixosModules.default ];

    environment.systemPackages = [ pkgs.xwayland-satellite ];

    programs = {
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
}
