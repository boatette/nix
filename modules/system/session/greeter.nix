{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      services.displayManager.noctalia-greeter = {
        enable = true;

        cursorTheme = {
          inherit (inputs.self.constants.cursor) name;
          package = pkgs.rose-pine-cursor;
        };

        settings = {
          appearance = {
            hide_logo = true;
            password_style = "random";
            scheme_selector_position = "hidden";
          };

          inherit (inputs.self.constants) keyboard;
          output.name = inputs.self.constants.monitors.primary;
        };

        passwordlessSyncUsers = [ inputs.self.constants.username ];
      };
    };
}
