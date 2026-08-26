{ inputs, ... }:
{
  flake.modules.homeManager.appearance =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      papirus = pkgs.papirus-icon-theme;

      papirusThemes = [
        "Papirus"
        "Papirus-Light"
        "Papirus-Dark"
      ];
    in
    {
      imports = [ inputs.self.modules.homeManager.kde ];

      kde.settings.kdeglobals.Icons.Theme = "Papirus";

      gtk = {
        enable = true;

        iconTheme = {
          name = "Papirus";
          package = papirus;
        };

        theme = {
          name = "adw-gtk3";
          package = pkgs.adw-gtk3;
        };
      };

      home = {
        pointerCursor = {
          enable = true;
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors";
          size = 24;
          x11.enable = true;
          gtk.enable = true;
        };

        activation.papirusIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          iconDir="${config.xdg.dataHome}/icons"
          stamp="$iconDir/.papirus-source"

          if [ "$(cat "$stamp" 2>/dev/null)" != "${papirus}" ]; then
              run mkdir -p "$iconDir"
              for theme in ${lib.escapeShellArgs papirusThemes}; do
                  run rm -rf "$iconDir/$theme"
                  run cp -a --reflink=auto --no-preserve=mode \
                      "${papirus}/share/icons/$theme" "$iconDir/$theme"
              done
              run echo "${papirus}" > "$stamp"
          fi
        '';

        packages = with pkgs; [
          gtk3
          qt6Packages.qt6ct
        ];
      };
    };
}
