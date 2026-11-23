{ inputs, ... }:
{
  flake.modules.homeManager.boatette = inputs.self.lib.mimeHandlers {
    "org.prismlauncher.PrismLauncher.desktop" = [
      "application/x-modrinth-modpack+zip"
      "x-scheme-handler/curseforge"
      "x-scheme-handler/prismlauncher"
    ];
  };
}
