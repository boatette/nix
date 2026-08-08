{ inputs, self, ... }:

{
    flake.nixosModules.desktop =
        { pkgs, ... }:
        {
            programs.niri = {
                enable = true;
                package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
            };
        };

    flake.homeModules.desktop.xdg.configFile."niri/.keep".text = "";

    perSystem =
        { pkgs, ... }:
        {
            packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
                inherit pkgs;

                settings = {
                    input = {
                        keyboard.xkb = {
                            layout = "us,us";
                            variant = ",dvp";
                            options = "caps:super,grp:win_space_toggle";
                        };

                        touchpad = {
                            tap = _: { };
                            natural-scroll = _: { };
                        };
                    };

                    outputs = {
                        "HDMI-A-1" = {
                            scale = 1.0;
                            transform = "normal";
                            position = _: {
                                props = {
                                    x = -1920;
                                    y = 0;
                                };
                            };
                            mode = "1920x1080@75.000";
                        };

                        "eDP-1" = {
                            mode = "1920x1080@144";
                            scale = 1;
                            position = _: {
                                props = {
                                    x = 0;
                                    y = 0;
                                };
                            };
                        };
                    };

                    layout = {
                        gaps = 8;

                        always-center-single-column = _: { };
                        background-color = "transparent";

                        focus-ring = {
                            on = _: { };
                            width = 2;
                        };

                        default-column-width.proportion = 0.5;

                        preset-column-widths = [
                            { proportion = 0.33333; }
                            { proportion = 0.5; }
                            { proportion = 0.66667; }
                        ];

                        border = {
                            off = _: { };
                            width = 2;
                        };

                        shadow = {
                            on = _: { };
                            offset = _: {
                                props = {
                                    x = 0;
                                    y = 0;
                                };
                            };
                        };

                        struts = {
                            left = 0;
                            right = 0;
                            top = 0;
                            bottom = 0;
                        };
                    };

                    cursor = {
                        xcursor-theme = self.cursor.name;
                        xcursor-size = self.cursor.size;

                        hide-when-typing = _: { };
                        hide-after-inactive-ms = 5000;
                    };

                    prefer-no-csd = _: { };

                    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

                    hotkey-overlay.skip-at-startup = _: { };

                    blur = {
                        passes = 4;
                        offset = 6;
                        noise = 0.03;
                        saturation = 1;
                    };

                    environment = {
                        ELECTRON_OZONE_PLATFORM_HINT = "auto";
                        XDG_SESSION_TYPE = "wayland";
                        XDG_CURRENT_DESKTOP = "niri";

                        QT_QPA_PLATFORM = "wayland";
                        QT_QPA_PLATFORMTHEME = "qt6ct";
                        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
                        QT_AUTO_SCREEN_SCALE_FACTOR = "1";

                        GDK_BACKEND = "wayland,x11";
                        MOZ_ENABLE_WAYLAND = "1";
                        MOZ_DBUS_REMOTE = "1";

                        GSK_RENDERER = "ngl";

                        VDPAU_DRIVER = "va_gl";
                        LIBVA_DRIVER_NAME = "iHD";
                    };

                    spawn-at-startup = [
                        "noctalia"
                        "wayland-select"
                        [
                            "nautilus"
                            "--gapplication-service"
                        ]
                    ];

                    switch-events.lid-close.spawn = [
                        "noctalia"
                        "msg"
                        "session"
                        "lock-and-suspend"
                    ];

                    debug.honor-xdg-activation-with-invalid-serial = _: { };

                    binds = import ./_binds.nix { inherit pkgs; };

                    window-rules = import ./_rules.nix;

                    layer-rules = [
                        {
                            # match namespace="^noctalia-backdrop" to enable [niri/backdrop]
                            matches = [ { namespace = "^noctalia-wallpaper"; } ];
                            place-within-backdrop = true;
                        }
                        {
                            matches = [ { namespace = "noctalia-window-switcher"; } ];
                            background-effect = {
                                blur = true;
                                xray = false;
                            };
                        }
                    ];

                    extraConfig = ''
                        workspace "misc" {
                            open-on-output "eDP-1"
                        }

                        workspace "browser" {
                            open-on-output "eDP-1"
                        }

                        workspace "term" {
                            open-on-output "eDP-1"
                        }

                        include optional=true "~/.config/niri/noctalia.kdl"
                    '';
                };
            };
        };
}
