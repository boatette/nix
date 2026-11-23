{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { config, pkgs, ... }:
    let
      inherit (inputs.self.constants.fonts) mono sans;
      inherit (inputs.self.lib) qtFont;

      theme = "rose-pine-rose";

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

        platformTheme = {
          name = "qt6ct";
          package = pkgs.qt6Packages.qt6ct;
        };

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
    };
}
