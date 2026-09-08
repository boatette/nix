{ inputs, lib, ... }:
let
  isPortrait =
    m:
    lib.elem (toString (m.transform or "normal")) [
      "90"
      "270"
      "flipped-90"
      "flipped-270"
    ];
in
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

          workspace_axis = if isPortrait m then "horizontal" else "vertical";
        }
        // lib.optionalAttrs (m.mode or null != null) { inherit (m) mode; }
      ) (inputs.self.monitors.${osConfig.networking.hostName} or { });
    };
}
