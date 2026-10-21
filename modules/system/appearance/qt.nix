{ inputs, ... }:
{
  flake-file.inputs.rose-pine-kde = {
    url = "github:ashbork/kde";
    flake = false;
  };

  flake.modules.homeManager.appearance =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.constants.fonts) mono sans;
      inherit (inputs.self.lib) fromINI qtFont;

      theme = "rose-pine-rose";

      kdeColours = "${inputs.rose-pine-kde}/Rose Pine/colorschemes/rose-pine.colors";

      # nixpkgs installs these under share/Kvantum/themes/, but kvantum only looks in share/Kvantum/<theme>/
      kvantumThemes = pkgs.runCommandLocal "${theme}-kvantum" { } ''
        src=${pkgs.rose-pine-kvantum}/share/Kvantum/themes/${theme}
        mkdir -p $out/share/Kvantum
        cp -r $src $out/share/Kvantum/${theme}
      '';
    in
    {
      qt = {
        enable = true;

        qt6ctSettings = {
          Appearance = {
            style = "kvantum";
            custom_palette = false;
            icon_theme = config.gtk.iconTheme.name;
            standard_dialogs = "default";
          };

          Fonts = {
            general = ''"${qtFont sans}"'';
            fixed = ''"${qtFont mono}"'';
          };
        };

        kvantum = {
          enable = true;
          themes = [ kvantumThemes ];

          settings.General = { inherit theme; };
        };
      };

      home.packages = [ pkgs.qt6Packages.qtstyleplugin-kvantum ];

      xdg.dataFile."color-schemes/rose-pine.colors".source = kdeColours;

      kde.settings.kdeglobals = lib.mkMerge [
        (fromINI (builtins.readFile kdeColours))
        { General.ColorScheme = "rose-pine"; }
      ];
    };
}
