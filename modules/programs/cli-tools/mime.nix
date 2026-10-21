{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "claude-code-url-handler.desktop" = [ "x-scheme-handler/claude-cli" ];
  };
}
