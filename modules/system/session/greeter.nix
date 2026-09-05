{ inputs, ... }:
{
  flake-file.inputs.noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

  flake.modules.nixos.greeter =
    { config, lib, ... }:
    let
      host = config.networking.hostName;
      monitors = inputs.self.monitors.${host} or { };

      primary = lib.findFirst (name: monitors.${name}.primary or false) null (lib.attrNames monitors);
    in
    {
      imports = [ inputs.noctalia-greeter.nixosModules.default ];

      programs.noctalia-greeter = {
        enable = true;

        settings = {
          appearance.hide_logo = true;
          inherit (config.constants) keyboard;

          output.name = lib.throwIf (
            primary == null
          ) "session/greeter.nix: no monitor in flake.monitors.${host} is marked `primary = true`" primary;
        };

        passwordless-sync-users = [ config.constants.username ];
      };
    };
}
