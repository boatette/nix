{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      config,
      ...
    }:
    let
      inherit (import ./noctalia/_scripts.nix pkgs) footclientThemed;
    in
    {
      xdg.desktopEntries.footclient = {
        name = "Foot Client";
        genericName = "Terminal";
        comment = "A wayland native terminal emulator (client)";
        exec = "${footclientThemed}/bin/footclient-themed";
        icon = "foot";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
        settings.Keywords = "shell;prompt;command;commandline;";
      };

      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          main = {
            include = "${config.xdg.configHome}/foot/themes/noctalia";

            font = "JetBrainsMono Nerd Font:size=12";
            pad = "14x14";
          };

          colors-dark = {
            alpha = 0.8;
            blur = "yes";
          };
        };
      };
    };
}
