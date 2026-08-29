{ inputs, ... }:
{
  flake.modules.homeManager.konsole =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.kdePackages.konsole ];

      xdg.dataFile."konsole/Noctalia.profile".source =
        (pkgs.formats.ini { }).generate "Noctalia.profile"
          {
            General = {
              Name = "Noctalia";
              Parent = "FALLBACK/";
            };

            Appearance = {
              ColorScheme = "Noctalia";
              Font = inputs.self.lib.qtFont config.constants.fonts.mono;
              TerminalMargin = 14;
              TerminalCenter = false;
            };

            Scrolling.ScrollBarPosition = 2;
          };

      kde.settings.konsolerc."Desktop Entry".DefaultProfile = "Noctalia.profile";
    };
}
