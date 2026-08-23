{ inputs, ... }:
{
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager = {
    apps =
      { pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) system;
      in
      {
        home.packages =
          (with pkgs; [
            vesktop
            gimp
            stremio-linux-shell
            qbittorrent
            proton-pass

            libreoffice-qt
            hunspell
          ])
          ++ [
            inputs.helium.packages.${system}.default
          ];
      };

    mime =
      { lib, ... }:
      let
        handles = handler: types: lib.genAttrs types (_: handler);

        associations =
          handles "gimp.desktop" [
            "image/openraster"
            "image/x-psd"
            "image/x-xcf"
          ]
          // handles "writer.desktop" [
            "application/msword"
            "application/rtf"
            "application/vnd.oasis.opendocument.text"
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          ]
          // handles "calc.desktop" [
            "application/vnd.ms-excel"
            "application/vnd.oasis.opendocument.spreadsheet"
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            "text/csv"
          ]
          // handles "impress.desktop" [
            "application/vnd.ms-powerpoint"
            "application/vnd.oasis.opendocument.presentation"
            "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          ]
          // handles "vesktop.desktop" [ "x-scheme-handler/discord" ];
      in
      {
        xdg.mimeApps = {
          defaultApplications = associations;
          associations.added = associations;
        };
      };

    umbriel.programs.umbriel.settings.window_rule = [
      {
        match.app_id = "helium|vesktop|gimp|libreoffice";
        default_maximize = true;
      }
      {
        match.app_id = "stremio";
        default_fullscreen = true;
      }
    ];
  };
}
