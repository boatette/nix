{
  flake.modules.homeManager.mime =
    { lib, ... }:
    let
      associations = lib.genAttrs [
        "inode/directory"
        "application/x-gnome-saved-search"
      ] (_: "org.kde.dolphin.desktop");
    in
    {
      xdg.mimeApps = {
        defaultApplications = associations;
        associations.added = associations;
      };
    };
}
