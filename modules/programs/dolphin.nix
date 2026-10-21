{
  flake.modules.homeManager.dolphin =
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

        kdeglobals = {
          General = {
            TerminalApplication = "foot";
            TerminalService = "foot.desktop";
          };

          KDE.SingleClick = false;
        };
      };

      home.packages = [
        (pkgs.symlinkJoin {
          name = "dolphin-themed";
          paths = [ pkgs.kdePackages.dolphin ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/dolphin \
                --set QT_QPA_PLATFORMTHEME kde \
                --set QT_STYLE_OVERRIDE kvantum
          '';
          meta.mainProgram = "dolphin";
        })
      ]
      ++ (with pkgs.kdePackages; [
        plasma-integration
        breeze
        kconfig

        kio-fuse
        kio-extras
        kdegraphics-thumbnailers
        ffmpegthumbs
        kimageformats
        qtimageformats
      ]);
    };

  flake.modules.nixos.dolphin =
    { pkgs, ... }:
    {
      environment.etc."xdg/menus/applications.menu".source =
        pkgs.runCommandLocal "applications.menu" { }
          ''
            cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
          '';
    };
}
