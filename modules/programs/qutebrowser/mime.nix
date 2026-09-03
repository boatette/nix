{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "org.qutebrowser.qutebrowser.desktop" = [
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xht"
      "application/x-extension-xhtml"
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/qute"
    ];
  };
}
