{
  flake.modules.homeManager.foot =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.foot = {
        enable = true;
        server.enable = true;

        settings = {
          main = {
            font = "JetBrainsMono Nerd Font:size=12";
            pad = "14x14";
            include = "${config.xdg.configHome}/foot/themes/noctalia";
          };

          colors-dark = {
            alpha = 0.8;
            blur = "yes";
          };
        };
      };

      xdg.desktopEntries.footclient = {
        name = "Foot Client";
        genericName = "Terminal";
        comment = "A wayland native terminal emulator (client)";
        exec = lib.getExe pkgs.local.footclient-themed;
        icon = "foot";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
        settings.Keywords = "shell;prompt;command;commandline;";
      };

      home.packages = [
        pkgs.local.footclient-themed
        pkgs.local.foot-live-theme
      ];
    };
}
