{ inputs, ... }:
{
  flake.modules.nixos.greeter =
    { config, pkgs, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        cursorTheme = {
          inherit (config.constants.cursor) name;
          package = pkgs.rose-pine-cursor;
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
