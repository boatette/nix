{ inputs, lib, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.constants.monitors) primary modes;

      # placed on a 1920x1080 output; any other placement size lands the whole section in noctalia's state
      widget =
        output: attrs:
        attrs
        // {
          inherit output;
          placement_width = 1920.0;
          placement_height = 1080.0;
        };

      # noctalia's compact login box: 400 wide, and 38 plus 16 of padding on each side tall
      loginBox =
        output:
        lib.nameValuePair "lockscreen-login-box@${output}" (
          widget output {
            enabled = output == primary;
            type = "login_box";

            box_width = 400.0;
            box_height = 70.0;
            cx = 960.0;
            cy = 940.0;

            settings = {
              layout = "compact";
              background_radius = inputs.self.constants.glass.radius * 1.0;
              show_unlock_hint = false;
            };
          }
        );

      # counter ids, the form noctalia assigns itself
      clockId = "lockscreen-widget-0000000000000001";
      dateId = "lockscreen-widget-0000000000000002";

      # a clock's text fills its box, so the date's is shorter, and wide enough for "Wednesday, September 30"
      clock =
        box: settings:
        widget primary (
          box
          // {
            type = "clock";

            settings = {
              background = false;
              center_text = true;
              shadow = false;
            }
            // settings;
          }
        );
    in
    {
      programs.noctalia.settings.lockscreen_widgets = {
        enabled = true;

        # without a login box on every output noctalia adds its own to its state; disabled ones still count
        widget_order =
          map (output: "lockscreen-login-box@${output}") (
            [ primary ] ++ lib.remove primary (lib.attrNames modes)
          )
          ++ [
            clockId
            dateId
          ];

        widget = lib.listToAttrs (map loginBox (lib.attrNames modes)) // {
          ${clockId} = clock {
            box_width = 368.0;
            box_height = 208.0;
            cx = 960.0;
            cy = 292.0;
          } { };

          ${dateId} = clock {
            box_width = 560.0;
            box_height = 50.0;
            cx = 960.0;
            cy = 161.0;
          } { format = "{:%A, %B %d}"; };
        };
      };
    };
}
