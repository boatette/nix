{
  flake.modules.homeManager.mime =
    { lib, ... }:
    let
      associations = lib.genAttrs [
        "application/pdf"
        "application/xhtml+xml"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xht"
        "application/x-extension-xhtml"
        "text/html"
        "x-scheme-handler/chrome"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ] (_: "zen-beta.desktop");
    in
    {
      xdg.mimeApps = {
        defaultApplications = associations;
        associations.added = associations;
      };
    };
}
