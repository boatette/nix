{ inputs, ... }:
{
  flake-file.inputs.noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";

  flake.modules.nixos.greeter =
    { config, ... }:
    {
      imports = [ inputs.noctalia-greeter.nixosModules.default ];

      programs.noctalia-greeter = {
        enable = true;

        settings = {
          appearance.hide_logo = true;
          inherit (config.constants) keyboard;
        };

        passwordless-sync-users = [ config.constants.username ];
      };
    };
}
