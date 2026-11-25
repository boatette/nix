{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { lib, ... }:
    let
      inherit (inputs.self.constants.fonts) mono;

      # swayimg reads colours as 0xaarrggbb
      colour = name: "0xff${lib.removePrefix "#" (inputs.self.lib.colours.hex name)}";
    in
    {
      programs.swayimg = {
        enable = true;

        initLua = /* lua */ ''
          swayimg.text.font = "${mono.name}"
          swayimg.text.color = ${colour "text"}

          swayimg.viewer.set_window_background(${colour "base"})
          swayimg.viewer.set_image_chessboard(20, ${colour "surface"}, ${colour "overlay"})

          swayimg.gallery.border_color = ${colour "primary"}
          swayimg.gallery.selected_color = ${colour "overlay"}
          swayimg.gallery.unselected_color = ${colour "surface"}
          swayimg.gallery.window_color = ${colour "base"}
        '';
      };
    };
}
