{
  flake.modules.nixos.luciole =
    { config, ... }:
    {
      xdg.portal = {
        extraPortals = [ config.programs.luciole.package ];

        # nixpkgs' umbriel portal predates upstream preferring luciole's chooser, and this replaces its umbriel-portals.conf whole
        config.umbriel = {
          default = [
            "umbriel"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [
            "luciole"
            "gtk"
          ];
        };
      };
    };
}
