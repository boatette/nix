{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants.glass) radius opacity;
    in
    {
      programs.noctalia.settings.dock = {
        enabled = true;

        reserve_space = false;
        smart_auto_hide = true;

        background_opacity = opacity;

        icon_size = 40;

        inherit radius;

        show_dots = true;

        launcher_position = "start";
        pinned = [
          "foot"
          "org.qutebrowser.qutebrowser"
          "vesktop"
          "steam"
          "org.prismlauncher.PrismLauncher"
          "com.stremio.Stremio"
          "org.kde.dolphin"
        ];
      };
    };
}
