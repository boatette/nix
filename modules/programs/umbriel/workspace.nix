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

  portraitOutputs = lib.attrNames (lib.filterAttrs (_: isPortrait) inputs.self.monitors);

  verticalWorkspace = output: index: {
    inherit output index;
    layout.scrolling.direction = "vertical";
  };
in
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.workspace = lib.concatMap (
    output: map (verticalWorkspace output) (lib.range 1 10)
  ) portraitOutputs;
}
