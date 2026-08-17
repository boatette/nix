{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      kde.settings = {
        dolphinrc = {
          General = {
            ShowFullPath = true;
            RememberOpenedTabs = false;
            DoubleClickViewAction = "none";
            TabStyle = "FixedSize";
          };

          MainWindow.MenuBar = "Disabled";
        };

        kdeglobals.General = {
          TerminalApplication = "foot";
          TerminalService = "foot.desktop";
        };
      };

      home.packages = with pkgs; [
        dolphin-themed

        kdePackages.plasma-integration
        kdePackages.breeze

        kdePackages.kio-fuse
        kdePackages.kconfig

        kdePackages.konsole

        kdePackages.kio-extras
        kdePackages.kdegraphics-thumbnailers
        kdePackages.ffmpegthumbs
        kdePackages.kimageformats
        kdePackages.qtimageformats
      ];
    };

  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
      '';
    };
}
