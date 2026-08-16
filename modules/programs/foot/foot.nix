{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      xdg.desktopEntries.footclient = {
        name = "Foot Client";
        genericName = "Terminal";
        comment = "A wayland native terminal emulator (client)";
        exec = lib.getExe pkgs.footclient-themed;
        icon = "foot";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
        settings.Keywords = "shell;prompt;command;commandline;";
      };

      home.packages = with pkgs; [
        footclient-themed
        foot-live-theme
      ];

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
