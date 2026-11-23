{ inputs, lib, ... }:
let
  inherit (inputs.self.constants) monitors;
in
{
  # a portrait output's strip runs top to bottom, so its columns fill the width
  flake.lib.umbrielLayout =
    pkgs: name: layout:
    (pkgs.formats.toml { }).generate "umbriel-${name}.toml" {
      output = lib.mapAttrs (_: m: {
        inherit (m) transform;
        position = [
          m.position.x
          m.position.y
        ];
        workspace_axis =
          if
            lib.elem m.transform [
              "90"
              "270"
            ]
          then
            "horizontal"
          else
            "vertical";
      }) layout;
    };

  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      programs.umbriel.settings = {
        # included rather than set here, so monitor-autorotate's include, read after it, can turn the outputs
        include.files = [ "${inputs.self.lib.umbrielLayout pkgs "start" monitors.layouts.landscape}" ];

        output = lib.mapAttrs (_: mode: {
          inherit mode;
          scale = 1.0;
          workspaces = "dynamic";
          min_workspaces = 5;
        }) monitors.modes;
      };
    };
}
