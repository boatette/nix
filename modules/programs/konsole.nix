{
  flake.modules.homeManager.konsole =
    { pkgs, ... }:
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
              Font = "JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0";
              TerminalMargin = 14;
              TerminalCenter = false;
            };

            Scrolling.ScrollBarPosition = 2;
          };

      kde.settings.konsolerc."Desktop Entry".DefaultProfile = "Noctalia.profile";
    };
}
