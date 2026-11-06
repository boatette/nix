{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "claude-code-url-gandler.desktop" = [ "x-scheme-handler/cluade-cli" ];
  };
}
