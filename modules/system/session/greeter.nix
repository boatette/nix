{ inputs, ... }:
{
  flake.modules.nixos.greeter =
    { config, lib, ... }:
    let
      host = config.networking.hostName;
      monitors = inputs.self.monitors.${host} or { };
      cursor = config.home-manager.users.${config.constants.username}.home.pointerCursor;

      primary = lib.findFirst (name: monitors.${name}.primary or false) null (lib.attrNames monitors);
    in
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        cursorTheme = {
          inherit (cursor) name package;
        };

        settings = {
          appearance = {
            hide_logo = true;
            password_style = "random";
            scheme_selector_position = "hidden";
          };
          inherit (config.constants) keyboard;

          output.name = lib.throwIf (
            primary == null
          ) "session/greeter.nix: no monitor in flake.monitors.${host} is marked `primary = true`" primary;
        };

        passwordlessSyncUsers = [ config.constants.username ];
      };
    };
}
