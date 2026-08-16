{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
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
    };

  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.etc."xdg/menus/applications.menu".source = pkgs.runCommand "applications.menu" { } ''
        cp ${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu $out
      '';
    };
}
