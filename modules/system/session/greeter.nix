{ inputs, ... }:
{
  flake.modules.nixos.greeter =
    { config, ... }:
    let
      cursor = config.home-manager.users.${config.constants.username}.home.pointerCursor;
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

          output.name = inputs.self.lib.primaryMonitor config.networking.hostName;
        };

        passwordlessSyncUsers = [ config.constants.username ];
      };
    };
}
