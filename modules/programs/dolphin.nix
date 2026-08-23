{
  flake.modules.homeManager = {
    dolphin =
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

    mime =
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

    umbriel.programs.umbriel.settings.window_rule = [
      {
        match.app_id = "^org\\.kde\\.dolphin";
        opacity = 0.8;
      }
    ];
  };

  flake.modules.nixos.dolphin =
    { pkgs, ... }:
    {

      environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
      '';
    };
}
