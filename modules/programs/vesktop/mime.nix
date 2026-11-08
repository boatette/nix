{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "vesktop.desktop" = [ "x-scheme-handler/discord" ];
  };
}
