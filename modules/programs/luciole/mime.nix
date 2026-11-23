{ inputs, ... }:
{
  flake.modules.homeManager.boatette = inputs.self.lib.mimeHandlers {
    "dev.noctalia.luciole.desktop" = [ "inode/directory" ];
  };
}
