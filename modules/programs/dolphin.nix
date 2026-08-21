{
  flake.modules = {
    homeManager.dolphin =
      { pkgs, ... }:
      {
        kde.settings.dolphinrc = {
          General = {
            ShowFullPath = true;
            RememberOpenedTabs = false;
            DoubleClickViewAction = "none";
            TabStyle = "FixedSize";
          };

          MainWindow.MenuBar = "Disabled";
        };

        kde.settings.kdeglobals.General = {
          TerminalApplication = "foot";
          TerminalService = "foot.desktop";
        };

        home.packages = [

          pkgs.local.dolphin-themed
        ]
        ++ (with pkgs.kdePackages; [
          plasma-integration
          breeze
          kconfig
          konsole

          kio-fuse
          kio-extras
          kdegraphics-thumbnailers
          ffmpegthumbs
          kimageformats
          qtimageformats
        ]);
      };

    nixos.dolphin =
      { pkgs, ... }:
      {

        environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
          cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
        '';
      };

    homeManager.mime =
      { lib, ... }:
      let
        associations = lib.genAttrs [
          "inode/directory"
          "application/x-gnome-saved-search"
        ] (_: "org.kde.dolphin.desktop");
      in
      {
        xdg.mimeApps = {
          defaultApplications = associations;
          associations.added = associations;
        };
      };

    niri.niri.settings.window-rules = [
      {
        matches = [ { app-id = ''^org\.kde\.dolphin''; } ];
        opacity = 0.8;
      }
    ];
  };
}
