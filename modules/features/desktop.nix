{ config, inputs, ... }:

{
    flake.modules.nixos.desktop =
        {
            pkgs,
            lib,
            ...
        }:
        {
            imports = [ inputs.noctalia-greeter.nixosModules.default ];

            environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
                lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
                    (
                        with pkgs.gst_all_1;
                        [
                            gstreamer
                            gst-plugins-base
                            gst-plugins-good
                            gst-plugins-bad
                            gst-plugins-ugly
                            gst-libav
                        ]
                    );

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
                            inherit (config.flake.lib.cursor) name size;
                            path = "${pkgs.capitaine-cursors}/share/icons";
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
