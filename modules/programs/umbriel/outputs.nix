{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.output = lib.mapAttrs (
    _: m:
    {
      position = [
        (m.position.x or 0)
        (m.position.y or 0)
      ];

      workspaces = 10;
    }
    // lib.optionalAttrs (m.mode or null != null) { inherit (m) mode; }
    // lib.optionalAttrs (m.scale or null != null) { scale = m.scale * 1.0; }
    // lib.optionalAttrs (m.transform or null != null) {
      transform = if lib.isInt m.transform then toString m.transform else m.transform;
    }
  ) inputs.self.monitors;
}
