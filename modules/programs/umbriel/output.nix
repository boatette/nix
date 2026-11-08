{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel =
    { osConfig, ... }:
    let
      inherit (inputs.self.lib) isPortrait startLayout transformName;
    in
    {
      programs.umbriel.settings.output = lib.mapAttrs (
        _: m:
        {
          scale = m.scale * 1.0;
          transform = transformName m;

          position = [
            m.position.x
            m.position.y
          ];

          workspaces = "dynamic";
          min_workspaces = 5;

          workspace_axis = if isPortrait m then "horizontal" else "vertical";
        }
        // lib.optionalAttrs (m.mode != null) { inherit (m) mode; }
      ) (startLayout osConfig.networking.hostName);
    };
}
