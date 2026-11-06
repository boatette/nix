{ inputs, lib, ... }:
{
  flake.modules.homeManager.noctalia =
    { osConfig, ... }:
    let
      inherit (inputs.self.lib) monitorProfiles parseMode;

      host = osConfig.networking.hostName;
      profiles = monitorProfiles (inputs.self.monitors.${host} or { });
      # the compositor starts in the first profile; monitor-autorotate turns away from there
      monitors = lib.filterAttrs (_: m: m.mode != null) profiles.${lib.head (lib.attrNames profiles)};

      primary = lib.findFirst (name: monitors.${name}.primary or false) null (lib.attrNames monitors);

      isPortrait =
        m:
        lib.elem m.transform [
          90
          270
          "flipped-90"
          "flipped-270"
        ];

      # noctalia copies this section into its state file, shadowing this one, when placement
      # size is not the output's logical size
      logicalSize =
        m:
        let
          mode = parseMode m.mode;
          portrait = isPortrait m;
          physicalWidth = lib.toInt mode.width * 1.0;
          physicalHeight = lib.toInt mode.height * 1.0;
        in
        {
          width = (if portrait then physicalHeight else physicalWidth) / m.scale;
          height = (if portrait then physicalWidth else physicalHeight) / m.scale;
        };

      # laid out on a 1920x1080 screen, then scaled onto the output
      x = m: n: n * (logicalSize m).width / 1920.0;
      y = m: n: n * (logicalSize m).height / 1080.0;

      # one counter id, the form noctalia assigns itself
      widgetId = "desktop-widget-0000000000000005";

      mediaPlayer =
        let
          m = monitors.${primary};
          size = logicalSize m;
        in
        {
          ${widgetId} = {
            output = primary;
            type = "media_player";

            placement_width = size.width;
            placement_height = size.height;

            box_width = x m 384.0;
            box_height = y m 192.0;
            rotation = 0.0;

            cx = x m 256.0;
            cy = y m 188.0;

            settings = {
              album_art_background = true;
              audio_visualizer = true;
              hide_when_no_media = true;
              layout = "horizontal";
              shadow = false;
            };
          };
        };
    in
    lib.throwIf (primary == null)
      "noctalia/desktop-widgets.nix: no monitor in flake.monitors.${host} is marked `primary = true`"
      {
        programs.noctalia.settings.desktop_widgets = {
          enabled = true;
          schema_version = 2;

          widget_order = [ widgetId ];

          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };

          widget = mediaPlayer;
        };
      };
}
