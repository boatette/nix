{ inputs, ... }:
{
  flake.modules.homeManager.boatette = inputs.self.lib.mimeHandlers {
    "vesktop.desktop" = [ "x-scheme-handler/discord" ];
  };
}
