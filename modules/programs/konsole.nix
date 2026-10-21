{ inputs, ... }:
{
  flake.modules.homeManager.konsole =
    { config, pkgs, ... }:
    {
      home.packages = [ pkgs.kdePackages.konsole ];

      xdg.dataFile."konsole/rose-pine.profile".source =
        (pkgs.formats.ini { }).generate "rose-pine.profile"
          {
            General = {
              Name = "Rosé Pine";
              Parent = "FALLBACK/";
            };

            Appearance = {
              ColorScheme = "rose-pine";
              Font = inputs.self.lib.qtFont config.constants.fonts.mono;
              TerminalMargin = 14;
              TerminalCenter = false;
            };

            Scrolling.ScrollBarPosition = 2;
          };

      kde.settings.konsolerc."Desktop Entry".DefaultProfile = "rose-pine.profile";
    };
}
