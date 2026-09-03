{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.dock = {
    enabled = true;

    reserve_space = false;
    smart_auto_hide = true;

    background_opacity = 0.5;

    icon_size = 40;

    radius = 4;
    radius_bottom_left = 4;
    radius_bottom_right = 4;
    radius_top_left = 4;
    radius_top_right = 4;

    show_dots = true;
    show_instance_count = false;

    pinned = [
      "com.mitchellh.ghostty"
      "qutebrowser"
      "vesktop"
      "steam"
      "org.prismlauncher.PrismLauncher"
      "com.stremio.Stremio"
      "org.kde.dolphin"
    ];
  };
}
