{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
    "org.kde.dolphin.desktop" = [ "application/x-gnome-saved-search" ];
  };
}
