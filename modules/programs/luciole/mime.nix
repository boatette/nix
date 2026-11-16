{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "dev.noctalia.luciole.desktop" = [ "inode/directory" ];
  };
}
