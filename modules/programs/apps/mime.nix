{
  flake.modules.homeManager.mime =
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
}
