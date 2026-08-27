{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "gimp.desktop" = [
      "image/openraster"
      "image/x-psd"
      "image/x-xcf"
    ];

    "writer.desktop" = [
      "application/msword"
      "application/rtf"
      "application/vnd.oasis.opendocument.text"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    ];

    "calc.desktop" = [
      "application/vnd.ms-excel"
      "application/vnd.oasis.opendocument.spreadsheet"
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      "text/csv"
    ];

    "impress.desktop" = [
      "application/vnd.ms-powerpoint"
      "application/vnd.oasis.opendocument.presentation"
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    ];

    "vesktop.desktop" = [ "x-scheme-handler/discord" ];
  };
}
