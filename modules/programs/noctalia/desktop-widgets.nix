{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { osConfig, ... }:
    let
      inherit (inputs.self.lib) noctaliaWidget primaryMonitor;

      host = osConfig.networking.hostName;

      # a counter id, the form noctalia assigns itself
      mediaPlayer = "desktop-widget-0000000000000005";
    in
    {
      programs.noctalia.settings.desktop_widgets = {
        widget_order = [ mediaPlayer ];

        widget.${mediaPlayer} = noctaliaWidget host (primaryMonitor host) {
          type = "media_player";

          box = {
            width = 384.0;
            height = 192.0;
            cx = 256.0;
            cy = 188.0;
          };

          settings = {
            album_art_background = true;
            audio_visualizer = true;
            hide_when_no_media = true;
            shadow = false;
          };
        };
      };
    };
}
