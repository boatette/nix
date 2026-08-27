{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "org.kde.dolphin.desktop" = [
      "inode/directory"
      "application/x-gnome-saved-search"
    ];
  };
}
