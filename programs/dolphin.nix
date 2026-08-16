{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      settings = {
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

      kwriteconfig = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";

      writeKey = file: group: key: value: ''
        run ${kwriteconfig} --file ${lib.escapeShellArg "${config.xdg.configHome}/${file}"} \
            --group ${lib.escapeShellArg group} --key ${lib.escapeShellArg key} \
            ${lib.escapeShellArg (if lib.isBool value then lib.boolToString value else toString value)}
      '';

      writeGroups =
        file: groups:
        lib.concatLists (
          lib.mapAttrsToList (group: keys: lib.mapAttrsToList (writeKey file group) keys) groups
        );
    in
    {
      home = {
        packages = with pkgs; [
          (symlinkJoin {
            name = "dolphin-kde-theme";
            paths = [ kdePackages.dolphin ];
            nativeBuildInputs = [ makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/dolphin --set QT_QPA_PLATFORMTHEME kde
            '';
          })

          kdePackages.plasma-integration
          kdePackages.breeze

          kdePackages.kio-fuse
          kdePackages.kconfig
        ];

        activation.dolphinSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.concatStrings (lib.concatLists (lib.mapAttrsToList writeGroups settings))
        );
      };
    };

  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
      '';
    };
}
