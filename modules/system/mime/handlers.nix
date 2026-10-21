{ lib, ... }:
{
  flake.lib.mimeHandlers =
    handlers:
    let
      associations = lib.concatMapAttrs (desktop: types: lib.genAttrs types (_: desktop)) handlers;
    in
    {
      xdg.mimeApps = {
        defaultApplications = associations;
        associations.added = associations;
      };
    };
}
