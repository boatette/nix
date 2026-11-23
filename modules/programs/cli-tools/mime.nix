{ inputs, ... }:
{
  flake.modules.homeManager.boatette = inputs.self.lib.mimeHandlers {
    "claude-code-url-handler.desktop" = [ "x-scheme-handler/claude-cli" ];
  };
}
