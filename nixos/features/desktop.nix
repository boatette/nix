{ inputs, self, ... }:

{
    flake.nixosModules.desktop =
        { config, pkgs, ... }:
        {
            imports = [ inputs.noctalia-greeter.nixosModules.default ];

            home-manager.users.${config.preferences.user.name}.imports = [
                self.homeModules.desktop
            ];

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

                noctalia-greeter = {
                    enable = true;

                    settings = {
                        appearance.hide_logo = true;

                        cursor = {
                            inherit (self.cursor) name size;
                            path = "${pkgs.${self.cursor.package}}/share/icons";
                        };

                        keyboard.layout = "us";
                    };
                };
            };

            security.polkit.extraConfig = ''
                polkit.addRule(function(action, subject) {
                    if (action.id == "org.noctalia.greeter.apply-appearance" &&
                        subject.local && subject.active && subject.isInGroup("wheel")) {
                        return polkit.Result.YES;
                    }
                });
            '';

            services = {
                gvfs.enable = true;
                tumbler.enable = true;
                upower.enable = true;
            };
        };
}
