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
            TerminalApplication = "ghostty";
            TerminalService = "com.mitchellh.ghostty.desktop";
          };

          KDE.SingleClick = false;
        };

        darklyrc.Style = {
          DolphinViewOpacity = 50;
          DolphinSidebarOpacity = 50;
          MenuOpacity = 50;
          MenuBarOpacity = 50;
          ToolBarOpacity = 50;
          TabBarOpacity = 50;
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
                --set QT_STYLE_OVERRIDE Darkly \
                --prefix QT_PLUGIN_PATH : ${pkgs.darkly}/lib/qt-6/plugins
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
      environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
      '';
    };
}
