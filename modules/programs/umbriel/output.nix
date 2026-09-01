{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel =
    { osConfig, ... }:
    {
      programs.umbriel.settings.output = lib.mapAttrs (
        _: m:
        let
          transform = m.transform or "normal";
        in
        {
          scale = (m.scale or 1) * 1.0;
          transform = if lib.isInt transform then toString transform else transform;

          position = [
            (m.position.x or 0)
            (m.position.y or 0)
          ];

          workspaces = 10;
        }
        // lib.optionalAttrs (m.mode or null != null) { inherit (m) mode; }
      ) (inputs.self.monitors.${osConfig.networking.hostName} or { });
    };
}
