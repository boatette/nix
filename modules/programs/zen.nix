{ inputs, ... }:
{
  flake-file.inputs.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager = {
    zen =
      { pkgs, ... }:
      let
        inherit (pkgs.stdenv.hostPlatform) system;
      in
      {
        home.packages = [ inputs.zen-browser.packages.${system}.beta ];
      };

    mime =
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

    umbriel.programs.umbriel.settings.window_rule = [
      {
        match.app_id = "^zen-beta$";
        default_maximize = true;
      }
    ];
  };
}
