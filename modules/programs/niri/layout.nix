{ inputs, ... }:
let
  inherit (inputs.self.constants) glass palette;
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings.layout = {
    gaps = 8;
    struts = {
      left = 20;
      right = 20;
    };

    focus-ring.off = { };
    border = {
      on = { };
      width = 1;
      active-color = "#${palette.rose}";
      inactive-color = "#${palette.muted}";
      urgent-color = "#${palette.love}";
    };

    tab-indicator.corner-radius = glass.radius;

    shadow = {
      on = { };
      softness = 20;
      offset._props.y = 4;
    };

    background-color = "transparent";
  };
}
