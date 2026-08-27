{
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
      xdg.mimeApps = {
        defaultApplications = associations;
        associations.added = associations;
      };
    };
}
