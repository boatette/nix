{
  flake.modules.homeManager.prism =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];
    };

  flake.modules.homeManager.mime =
    { lib, ... }:
    let
      associations = lib.genAttrs [
        "application/x-modrinth-modpack+zip"
        "x-scheme-handler/curseforge"
        "x-scheme-handler/prismlauncher"
      ] (_: "org.prismlauncher.PrismLauncher.desktop");
    in
    {
      xdg.mimeApps.defaultApplications = associations;
      xdg.mimeApps.associations.added = associations;
    };
}
