{ inputs, ... }:
{
  flake.modules.homeManager.boatette = inputs.self.lib.mimeHandlers {
    "com.github.PintaProject.Pinta.desktop" = [ "image/openraster" ];
  };
}
