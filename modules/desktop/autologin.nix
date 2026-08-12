{
    flake.modules.nixos.desktop =
        {
            config,
            lib,
            ...
        }:
        {
            options.preferences.autologin = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                    Boot straight into the session instead of stopping at the greeter.
                    The greeter stays reachable by logging out,
                    or by holding Space during boot and picking the "greeter" entry in the systemd-boot menu
                '';
            };

            config = {
                services.greetd.settings.initial_session = lib.mkIf config.preferences.autologin {
                    command = lib.getExe' config.programs.niri.package "niri-session";
                    user = config.preferences.user.name;
                };

                specialisation.greeter.configuration.preferences.autologin = lib.mkForce false;
            };
        };
}
